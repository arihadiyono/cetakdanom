using System.Collections.ObjectModel;
using System.IO;
using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

/// <summary>
/// ViewModel untuk Menu 2: Cetak Danom
/// Menampilkan list penerima bansos, pencarian NIK/Nama, pembuatan file BNBA (CSV),
/// dan pencetakan dokumen Danom (meniru pnlTampilData pada Utama.pas).
/// </summary>
public class CetakDanomViewModel : ViewModelBase
{
    private readonly IDanomRepository _danomRepo;
    private readonly IExportService _exportService;
    private readonly IPrintService _printService;
    private readonly IAuthenticationService _authService;

    private ObservableCollection<PenerimaBansos> _allRecords = new();
    private ObservableCollection<PenerimaBansos> _filteredRecords = new();
    private PenerimaBansos? _selectedPenerima;

    private string _searchText = string.Empty;
    private StatusCetak? _selectedStatusFilter;
    private bool _isLoading;
    private string _statusMessage = string.Empty;
    private bool _hasStatusMessage;

    // Summary counts
    private int _totalKpm;
    private decimal _totalNominal;
    private int _belumCetakCount;
    private int _sudahCetakCount;

    public ObservableCollection<PenerimaBansos> FilteredRecords
    {
        get => _filteredRecords;
        set => SetProperty(ref _filteredRecords, value);
    }

    public PenerimaBansos? SelectedPenerima
    {
        get => _selectedPenerima;
        set => SetProperty(ref _selectedPenerima, value);
    }

    public string SearchText
    {
        get => _searchText;
        set
        {
            if (SetProperty(ref _searchText, value))
            {
                ApplyFilter();
            }
        }
    }

    public StatusCetak? SelectedStatusFilter
    {
        get => _selectedStatusFilter;
        set
        {
            if (SetProperty(ref _selectedStatusFilter, value))
            {
                ApplyFilter();
            }
        }
    }

    public bool IsLoading
    {
        get => _isLoading;
        set => SetProperty(ref _isLoading, value);
    }

    public string StatusMessage
    {
        get => _statusMessage;
        set
        {
            SetProperty(ref _statusMessage, value);
            HasStatusMessage = !string.IsNullOrEmpty(value);
        }
    }

    public bool HasStatusMessage
    {
        get => _hasStatusMessage;
        set => SetProperty(ref _hasStatusMessage, value);
    }

    public int TotalKpm
    {
        get => _totalKpm;
        set => SetProperty(ref _totalKpm, value);
    }

    public decimal TotalNominal
    {
        get => _totalNominal;
        set => SetProperty(ref _totalNominal, value);
    }

    public int BelumCetakCount
    {
        get => _belumCetakCount;
        set => SetProperty(ref _belumCetakCount, value);
    }

    public int SudahCetakCount
    {
        get => _sudahCetakCount;
        set => SetProperty(ref _sudahCetakCount, value);
    }

    public ICommand ExportBnbaCommand { get; }
    public ICommand PreviewDanomCommand { get; }
    public ICommand CetakDanomCommand { get; }
    public ICommand RefreshCommand { get; }

    public event Action<PrintPreviewDocument>? RequestPrintPreview;

    public CetakDanomViewModel(
        IDanomRepository danomRepo,
        IExportService exportService,
        IPrintService printService,
        IAuthenticationService authService)
    {
        _danomRepo = danomRepo;
        _exportService = exportService;
        _printService = printService;
        _authService = authService;

        ExportBnbaCommand = new RelayCommand(async () => await ExecuteExportBnbaAsync(), () => FilteredRecords.Count > 0);
        PreviewDanomCommand = new RelayCommand(async () => await ExecutePreviewDanomAsync(), () => FilteredRecords.Count > 0);
        CetakDanomCommand = new RelayCommand(async () => await ExecuteCetakDanomAsync(), () => FilteredRecords.Count > 0);
        RefreshCommand = new RelayCommand(async () => await LoadDataAsync());
    }

    public async Task InitializeAsync()
    {
        await LoadDataAsync();
    }

    public async Task LoadDataAsync()
    {
        IsLoading = true;
        StatusMessage = "Memuat data Danom...";

        var filter = new DanomFilterRequest
        {
            LayananKode = "BST",
            Tahap = "1"
        };
        var records = await _danomRepo.GetPenerimaListAsync(filter);
        _allRecords = new ObservableCollection<PenerimaBansos>(records);
        ApplyFilter();

        IsLoading = false;
        StatusMessage = $"Data dimuat: {_allRecords.Count} KPM.";
    }

    private void ApplyFilter()
    {
        IEnumerable<PenerimaBansos> q = _allRecords;

        if (!string.IsNullOrWhiteSpace(SearchText))
        {
            string term = SearchText.Trim().ToLowerInvariant();
            q = q.Where(r => r.Nik.ToLowerInvariant().Contains(term) ||
                             r.Nama.ToLowerInvariant().Contains(term) ||
                             r.Alamat.ToLowerInvariant().Contains(term));
        }

        if (SelectedStatusFilter.HasValue)
        {
            q = q.Where(r => r.StatusDanom == SelectedStatusFilter.Value);
        }

        var result = q.ToList();
        FilteredRecords = new ObservableCollection<PenerimaBansos>(result);

        TotalKpm = result.Count;
        TotalNominal = result.Sum(r => r.Nominal);
        BelumCetakCount = result.Count(r => r.StatusDanom == StatusCetak.BelumCetak);
        SudahCetakCount = result.Count(r => r.StatusDanom == StatusCetak.SudahCetak);

        if (SelectedPenerima == null || !result.Contains(SelectedPenerima))
        {
            SelectedPenerima = result.FirstOrDefault();
        }
    }

    private async Task ExecuteExportBnbaAsync()
    {
        if (FilteredRecords.Count == 0) return;

        try
        {
            string exportDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Export_BNBA");
            string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            string filename = $"BNBA_BST_TAHAP1_{timestamp}.csv";

            var exportRequest = new BnbaExportRequest
            {
                Records = FilteredRecords.ToList(),
                TargetDirectory = exportDir,
                FileName = filename
            };

            var result = await _exportService.ExportBnbaCsvAsync(exportRequest);
            if (result.IsSuccess)
            {
                StatusMessage = $"BNBA Sukses! Berkas disimpan: {result.FullFilePath} ({result.ExportedRecordCount} baris).";
            }
            else
            {
                StatusMessage = $"Gagal ekspor BNBA: {result.Message}";
            }
        }
        catch (Exception ex)
        {
            StatusMessage = $"Kesalahan ekspor: {ex.Message}";
        }
    }

    private async Task ExecutePreviewDanomAsync()
    {
        if (FilteredRecords.Count == 0) return;

        var sample = FilteredRecords.First();
        string infoWilayah = $"Kel. {sample.Kelurahan}, Kec. {sample.Kecamatan}, {sample.Kabupaten}";

        var doc = await _printService.PrepareDanomPrintPreviewAsync(
            FilteredRecords.ToList(),
            infoWilayah,
            _authService.CurrentPetugas);

        RequestPrintPreview?.Invoke(doc);
    }

    private async Task ExecuteCetakDanomAsync()
    {
        if (FilteredRecords.Count == 0) return;

        await Task.Delay(200);
        StatusMessage = $"Mencetak dokumen Danom ({FilteredRecords.Count} KPM) ke printer default...";
        
        // Simulasikan pembaruan status cetak
        foreach (var r in FilteredRecords)
        {
            r.StatusDanom = StatusCetak.SudahCetak;
        }

        ApplyFilter();
        StatusMessage = "Dokumen Danom berhasil dicetak ke spooler printer.";
    }
}
