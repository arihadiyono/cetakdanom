using System.Collections.ObjectModel;
using System.IO;
using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

public class DanomViewModel : ViewModelBase
{
    private readonly IDanomRepository _danomRepo;
    private readonly IWilayahRepository _wilayahRepo;
    private readonly IExportService _exportService;
    private readonly IAuthenticationService _authService;

    // Filter properties
    private ObservableCollection<LayananBansos> _layananList = new();
    private LayananBansos? _selectedLayanan;

    private ObservableCollection<string> _tahapList = new() { "1", "2", "3", "4" };
    private string _selectedTahap = "1";

    private ObservableCollection<Wilayah> _provinsiList = new();
    private Wilayah? _selectedProvinsi;

    private ObservableCollection<Wilayah> _kabupatenList = new();
    private Wilayah? _selectedKabupaten;

    private ObservableCollection<Wilayah> _kecamatanList = new();
    private Wilayah? _selectedKecamatan;

    private ObservableCollection<Wilayah> _kelurahanList = new();
    private Wilayah? _selectedKelurahan;

    private string _searchText = string.Empty;
    private StatusCetak? _selectedStatusFilter;

    // Grid data
    private ObservableCollection<PenerimaBansos> _penerimaList = new();
    private PenerimaBansos? _selectedPenerima;

    // Summary
    private DanomSummaryDto _summary = new();
    private bool _isLoading;
    private string _statusMessage = string.Empty;
    private bool _hasStatusMessage;

    public ObservableCollection<LayananBansos> LayananList
    {
        get => _layananList;
        set => SetProperty(ref _layananList, value);
    }

    public LayananBansos? SelectedLayanan
    {
        get => _selectedLayanan;
        set
        {
            if (SetProperty(ref _selectedLayanan, value))
            {
                _ = LoadDataAsync();
            }
        }
    }

    public ObservableCollection<string> TahapList
    {
        get => _tahapList;
        set => SetProperty(ref _tahapList, value);
    }

    public string SelectedTahap
    {
        get => _selectedTahap;
        set
        {
            if (SetProperty(ref _selectedTahap, value))
            {
                _ = LoadDataAsync();
            }
        }
    }

    public ObservableCollection<Wilayah> ProvinsiList
    {
        get => _provinsiList;
        set => SetProperty(ref _provinsiList, value);
    }

    public Wilayah? SelectedProvinsi
    {
        get => _selectedProvinsi;
        set
        {
            if (SetProperty(ref _selectedProvinsi, value))
            {
                OnProvinsiChanged(value);
            }
        }
    }

    public ObservableCollection<Wilayah> KabupatenList
    {
        get => _kabupatenList;
        set => SetProperty(ref _kabupatenList, value);
    }

    public Wilayah? SelectedKabupaten
    {
        get => _selectedKabupaten;
        set
        {
            if (SetProperty(ref _selectedKabupaten, value))
            {
                OnKabupatenChanged(value);
            }
        }
    }

    public ObservableCollection<Wilayah> KecamatanList
    {
        get => _kecamatanList;
        set => SetProperty(ref _kecamatanList, value);
    }

    public Wilayah? SelectedKecamatan
    {
        get => _selectedKecamatan;
        set
        {
            if (SetProperty(ref _selectedKecamatan, value))
            {
                OnKecamatanChanged(value);
            }
        }
    }

    public ObservableCollection<Wilayah> KelurahanList
    {
        get => _kelurahanList;
        set => SetProperty(ref _kelurahanList, value);
    }

    public Wilayah? SelectedKelurahan
    {
        get => _selectedKelurahan;
        set
        {
            if (SetProperty(ref _selectedKelurahan, value))
            {
                _ = LoadDataAsync();
            }
        }
    }

    public string SearchText
    {
        get => _searchText;
        set
        {
            if (SetProperty(ref _searchText, value))
            {
                _ = LoadDataAsync();
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
                _ = LoadDataAsync();
            }
        }
    }

    public ObservableCollection<PenerimaBansos> PenerimaList
    {
        get => _penerimaList;
        set => SetProperty(ref _penerimaList, value);
    }

    public PenerimaBansos? SelectedPenerima
    {
        get => _selectedPenerima;
        set => SetProperty(ref _selectedPenerima, value);
    }

    public DanomSummaryDto Summary
    {
        get => _summary;
        set => SetProperty(ref _summary, value);
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
            HasStatusMessage = !string.IsNullOrWhiteSpace(value);
        }
    }

    public bool HasStatusMessage
    {
        get => _hasStatusMessage;
        set => SetProperty(ref _hasStatusMessage, value);
    }

    // Commands
    public ICommand RefreshCommand { get; }
    public ICommand ResetFilterCommand { get; }
    public ICommand ExportBnbaCommand { get; }
    public ICommand CetakDanomCommand { get; }
    public ICommand CetakBuktiCommand { get; }
    public ICommand CetakSuratCommand { get; }

    // Events for navigation to print preview
    public event Action<PrintPreviewDocument>? RequestPrintPreview;

    public DanomViewModel(
        IDanomRepository danomRepo,
        IWilayahRepository wilayahRepo,
        IExportService exportService,
        IAuthenticationService authService,
        IPrintService printService)
    {
        _danomRepo = danomRepo;
        _wilayahRepo = wilayahRepo;
        _exportService = exportService;
        _authService = authService;

        RefreshCommand = new RelayCommand(async () => await LoadDataAsync());
        ResetFilterCommand = new RelayCommand(async () => await ResetFiltersAsync());
        ExportBnbaCommand = new RelayCommand(async () => await ExecuteExportBnbaAsync());

        CetakDanomCommand = new RelayCommand(async () =>
        {
            if (PenerimaList.Count == 0)
            {
                StatusMessage = "Tidak ada baris data Danom untuk dicetak.";
                return;
            }

            string wilayahStr = $"{SelectedKelurahan?.Nama ?? "SEMUA KELURAHAN"}, {SelectedKecamatan?.Nama ?? "SEMUA KECAMATAN"}";
            var doc = await printService.PrepareDanomPrintPreviewAsync(PenerimaList.ToList(), wilayahStr, _authService.CurrentPetugas);

            // Update status Danom in repository
            await _danomRepo.UpdateStatusCetakDanomAsync(PenerimaList.Select(p => p.IdPelanggan));
            await LoadDataAsync();

            RequestPrintPreview?.Invoke(doc);
        });

        CetakBuktiCommand = new RelayCommand(async () =>
        {
            if (SelectedPenerima == null)
            {
                StatusMessage = "Pilih baris penerima KPM pada tabel untuk mencetak Kuitansi Bukti Terima.";
                return;
            }

            var doc = await printService.PrepareBuktiTerimaPrintPreviewAsync(SelectedPenerima, SelectedTahap, _authService.CurrentPetugas);
            await _danomRepo.UpdateStatusCetakBuktiAsync(new[] { SelectedPenerima.IdPelanggan });
            await LoadDataAsync();

            RequestPrintPreview?.Invoke(doc);
        });

        CetakSuratCommand = new RelayCommand(async () =>
        {
            if (SelectedPenerima == null)
            {
                StatusMessage = "Pilih baris penerima KPM pada tabel untuk mencetak Surat Pernyataan Tanggung Jawab Mutlak.";
                return;
            }

            var doc = await printService.PrepareSuratPernyataanPrintPreviewAsync(SelectedPenerima, _authService.CurrentPetugas);
            RequestPrintPreview?.Invoke(doc);
        });
    }

    public async Task InitializeAsync()
    {
        IsLoading = true;
        try
        {
            var layanans = await _wilayahRepo.GetDaftarLayananAsync();
            LayananList = new ObservableCollection<LayananBansos>(layanans);
            SelectedLayanan = LayananList.FirstOrDefault();

            var provs = await _wilayahRepo.GetProvinsiAsync();
            ProvinsiList = new ObservableCollection<Wilayah>(provs);
            SelectedProvinsi = ProvinsiList.FirstOrDefault();
        }
        finally
        {
            IsLoading = false;
        }
    }

    private async void OnProvinsiChanged(Wilayah? prov)
    {
        // Cascading reset: reset anak-anak hierarki
        SelectedKabupaten = null;
        KabupatenList.Clear();
        SelectedKecamatan = null;
        KecamatanList.Clear();
        SelectedKelurahan = null;
        KelurahanList.Clear();

        if (prov != null)
        {
            var kabs = await _wilayahRepo.GetKabupatenAsync(prov.Kode);
            KabupatenList = new ObservableCollection<Wilayah>(kabs);
            SelectedKabupaten = KabupatenList.FirstOrDefault();
        }

        await LoadDataAsync();
    }

    private async void OnKabupatenChanged(Wilayah? kab)
    {
        SelectedKecamatan = null;
        KecamatanList.Clear();
        SelectedKelurahan = null;
        KelurahanList.Clear();

        if (kab != null)
        {
            var kecs = await _wilayahRepo.GetKecamatanAsync(kab.Kode);
            KecamatanList = new ObservableCollection<Wilayah>(kecs);
            SelectedKecamatan = KecamatanList.FirstOrDefault();
        }

        await LoadDataAsync();
    }

    private async void OnKecamatanChanged(Wilayah? kec)
    {
        SelectedKelurahan = null;
        KelurahanList.Clear();

        if (kec != null)
        {
            var kels = await _wilayahRepo.GetKelurahanAsync(kec.Kode);
            KelurahanList = new ObservableCollection<Wilayah>(kels);
            SelectedKelurahan = KelurahanList.FirstOrDefault();
        }

        await LoadDataAsync();
    }

    private async Task ResetFiltersAsync()
    {
        _searchText = string.Empty;
        OnPropertyChanged(nameof(SearchText));
        _selectedStatusFilter = null;
        OnPropertyChanged(nameof(SelectedStatusFilter));
        _selectedTahap = "1";
        OnPropertyChanged(nameof(SelectedTahap));

        await LoadDataAsync();
    }

    public async Task LoadDataAsync()
    {
        IsLoading = true;
        try
        {
            var filter = new DanomFilterRequest
            {
                LayananKode = SelectedLayanan?.Kode,
                Tahap = SelectedTahap,
                ProvinsiKode = SelectedProvinsi?.Kode,
                KabupatenKode = SelectedKabupaten?.Kode,
                KecamatanKode = SelectedKecamatan?.Kode,
                KelurahanKode = SelectedKelurahan?.Kode,
                SearchTerm = SearchText,
                StatusFilter = SelectedStatusFilter
            };

            var records = await _danomRepo.GetPenerimaListAsync(filter);
            PenerimaList = new ObservableCollection<PenerimaBansos>(records);
            Summary = await _danomRepo.GetSummaryAsync(filter);

            SelectedPenerima = PenerimaList.FirstOrDefault();
            StatusMessage = $"Menampilkan {PenerimaList.Count} data penerima bantuan sosial.";
        }
        catch (Exception ex)
        {
            StatusMessage = $"Gagal memuat data Danom: {ex.Message}";
        }
        finally
        {
            IsLoading = false;
        }
    }

    private async Task ExecuteExportBnbaAsync()
    {
        if (PenerimaList.Count == 0)
        {
            StatusMessage = "Tidak ada baris data untuk diekspor ke BNBA.";
            return;
        }

        IsLoading = true;
        try
        {
            string exportDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Export_BNBA");
            string kelName = SelectedKelurahan?.Nama ?? "ALL";
            string fileName = $"BNBA_{SelectedLayanan?.Kode ?? "BST"}_THP{SelectedTahap}_{kelName}_{DateTime.Now:yyyyMMdd_HHmmss}.csv";

            var result = await _exportService.ExportBnbaCsvAsync(new BnbaExportRequest
            {
                Records = PenerimaList.ToList(),
                TargetDirectory = exportDir,
                FileName = fileName
            });

            if (result.IsSuccess)
            {
                StatusMessage = $"SUCCESS: {result.Message} Disimpan di: {result.FullFilePath} ({result.FileSizeBytes:N0} bytes)";
            }
            else
            {
                StatusMessage = $"ERROR: {result.Message}";
            }
        }
        catch (Exception ex)
        {
            StatusMessage = $"Ekspor BNBA gagal: {ex.Message}";
        }
        finally
        {
            IsLoading = false;
        }
    }
}
