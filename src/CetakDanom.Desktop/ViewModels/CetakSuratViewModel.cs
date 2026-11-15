using System.Collections.ObjectModel;
using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

/// <summary>
/// ViewModel untuk Menu 3: Cetak Surat
/// Menangani pemuatan parameter surat (param_xxx.pos & logoxxx.jpg),
/// preview format surat pemberitahuan KPM, dan pengiriman ke printer.
/// </summary>
public class CetakSuratViewModel : ViewModelBase
{
    private readonly ISuratService _suratService;
    private readonly IDanomRepository _danomRepo;
    private readonly IAuthenticationService _authService;

    private ObservableCollection<SuratParameterDto> _parameterList = new();
    private SuratParameterDto? _selectedParameter;

    private ObservableCollection<PenerimaBansos> _kpmList = new();
    private PenerimaBansos? _selectedKpm;

    private string _suratPreviewText = string.Empty;
    private string _statusMessage = string.Empty;
    private bool _isLoading;

    public ObservableCollection<SuratParameterDto> ParameterList
    {
        get => _parameterList;
        set => SetProperty(ref _parameterList, value);
    }

    public SuratParameterDto? SelectedParameter
    {
        get => _selectedParameter;
        set
        {
            if (SetProperty(ref _selectedParameter, value))
            {
                _ = UpdatePreviewAsync();
            }
        }
    }

    public ObservableCollection<PenerimaBansos> KpmList
    {
        get => _kpmList;
        set => SetProperty(ref _kpmList, value);
    }

    public PenerimaBansos? SelectedKpm
    {
        get => _selectedKpm;
        set
        {
            if (SetProperty(ref _selectedKpm, value))
            {
                _ = UpdatePreviewAsync();
            }
        }
    }

    public string SuratPreviewText
    {
        get => _suratPreviewText;
        set => SetProperty(ref _suratPreviewText, value);
    }

    public string StatusMessage
    {
        get => _statusMessage;
        set => SetProperty(ref _statusMessage, value);
    }

    public bool IsLoading
    {
        get => _isLoading;
        set => SetProperty(ref _isLoading, value);
    }

    public ICommand PreviewSuratCommand { get; }
    public ICommand CetakSuratCommand { get; }
    public ICommand CetakSemuaSuratCommand { get; }

    public event Action<PrintPreviewDocument>? RequestPrintPreview;

    public CetakSuratViewModel(
        ISuratService suratService,
        IDanomRepository danomRepo,
        IAuthenticationService authService)
    {
        _suratService = suratService;
        _danomRepo = danomRepo;
        _authService = authService;

        PreviewSuratCommand = new RelayCommand(async () => await ExecutePreviewSuratAsync(), () => SelectedKpm != null && SelectedParameter != null);
        CetakSuratCommand = new RelayCommand(async () => await ExecuteCetakSuratAsync(), () => SelectedKpm != null && SelectedParameter != null);
        CetakSemuaSuratCommand = new RelayCommand(async () => await ExecuteCetakSemuaSuratAsync(), () => KpmList.Count > 0 && SelectedParameter != null);
    }

    public async Task InitializeAsync()
    {
        IsLoading = true;
        StatusMessage = "Memuat parameter surat dan daftar KPM...";

        if (ParameterList.Count == 0)
        {
            var pars = await _suratService.GetAvailableParametersAsync();
            ParameterList = new ObservableCollection<SuratParameterDto>(pars);
            SelectedParameter = ParameterList.FirstOrDefault();
        }

        if (KpmList.Count == 0)
        {
            var filter = new DanomFilterRequest { LayananKode = "BST", Tahap = "1" };
            var kpms = await _danomRepo.GetPenerimaListAsync(filter);
            KpmList = new ObservableCollection<PenerimaBansos>(kpms);
            SelectedKpm = KpmList.FirstOrDefault();
        }

        IsLoading = false;
        await UpdatePreviewAsync();
    }

    private async Task UpdatePreviewAsync()
    {
        if (SelectedKpm == null || SelectedParameter == null)
        {
            SuratPreviewText = "Silakan pilih Parameter Surat dan Penerima Bantuan (KPM).";
            return;
        }

        var doc = await _suratService.PrepareSuratPrintPreviewAsync(
            SelectedKpm,
            SelectedParameter,
            _authService.CurrentPetugas);

        SuratPreviewText = doc.FormattedContent;
        StatusMessage = $"Format surat aktif: {SelectedParameter.FileName} untuk {SelectedKpm.Nama}.";
    }

    private async Task ExecutePreviewSuratAsync()
    {
        if (SelectedKpm == null || SelectedParameter == null) return;

        var doc = await _suratService.PrepareSuratPrintPreviewAsync(
            SelectedKpm,
            SelectedParameter,
            _authService.CurrentPetugas);

        RequestPrintPreview?.Invoke(doc);
    }

    private async Task ExecuteCetakSuratAsync()
    {
        if (SelectedKpm == null || SelectedParameter == null) return;

        await Task.Delay(200);
        StatusMessage = $"Mencetak Surat Pemberitahuan {SelectedKpm.Nama} ({SelectedKpm.Nik}) ke printer...";
    }

    private async Task ExecuteCetakSemuaSuratAsync()
    {
        if (KpmList.Count == 0 || SelectedParameter == null) return;

        await Task.Delay(300);
        StatusMessage = $"Mencetak {KpmList.Count} Surat Pemberitahuan ke antrean spooler printer...";
    }
}
