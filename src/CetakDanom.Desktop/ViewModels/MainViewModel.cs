using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

public class MainViewModel : ViewModelBase
{
    private readonly IAuthenticationService _authService;
    private readonly UnduhDanomViewModel _unduhDanomVm;
    private readonly CetakDanomViewModel _cetakDanomVm;
    private readonly CetakSuratViewModel _cetakSuratVm;
    private readonly CetakDanomSatuanViewModel _cdsVm;
    private readonly PrintPreviewViewModel _printVm;

    private ViewModelBase _currentViewModel;
    private string _currentPageTitle = "Unduh Danom";
    private ViewModelBase? _previousViewModel;

    public Petugas? CurrentPetugas => _authService.CurrentPetugas;
    public string AppTitle => "CETAKDANOM FDPOS MODERN";
    public string AppVersion => "v5.0.0-PROTOTYPE (.NET 8.0)";
    public string ModeBadge => "MODE DEMO / SYNTHETIC DATA";

    public ViewModelBase CurrentViewModel
    {
        get => _currentViewModel;
        set => SetProperty(ref _currentViewModel, value);
    }

    public string CurrentPageTitle
    {
        get => _currentPageTitle;
        set => SetProperty(ref _currentPageTitle, value);
    }

    // 4 Menu Utama Navigasi Sesuai Alur Delphi Asli
    public ICommand NavigateUnduhDanomCommand { get; }
    public ICommand NavigateCetakDanomCommand { get; }
    public ICommand NavigateCetakSuratCommand { get; }
    public ICommand NavigateCdsCommand { get; }
    public ICommand LogoutCommand { get; }

    public event Action? RequestLogout;

    public MainViewModel(
        IAuthenticationService authService,
        UnduhDanomViewModel unduhDanomVm,
        CetakDanomViewModel cetakDanomVm,
        CetakSuratViewModel cetakSuratVm,
        CetakDanomSatuanViewModel cdsVm,
        PrintPreviewViewModel printVm)
    {
        _authService = authService;
        _unduhDanomVm = unduhDanomVm;
        _cetakDanomVm = cetakDanomVm;
        _cetakSuratVm = cetakSuratVm;
        _cdsVm = cdsVm;
        _printVm = printVm;

        // Default menu awal setelah login: Menu 1 (Unduh Danom) - Tanpa Dashboard
        _currentViewModel = _unduhDanomVm;

        NavigateUnduhDanomCommand = new RelayCommand(async () =>
        {
            CurrentPageTitle = "1. Unduh Danom (Penarikan Data Wilayah)";
            CurrentViewModel = _unduhDanomVm;
            await _unduhDanomVm.InitializeAsync();
        });

        NavigateCetakDanomCommand = new RelayCommand(async () =>
        {
            CurrentPageTitle = "2. Cetak Danom & Ekspor BNBA";
            CurrentViewModel = _cetakDanomVm;
            await _cetakDanomVm.InitializeAsync();
        });

        NavigateCetakSuratCommand = new RelayCommand(async () =>
        {
            CurrentPageTitle = "3. Cetak Surat Pemberitahuan KPM";
            CurrentViewModel = _cetakSuratVm;
            await _cetakSuratVm.InitializeAsync();
        });

        NavigateCdsCommand = new RelayCommand(async () =>
        {
            CurrentPageTitle = "4. Cetak Danom Satuan (CDS Loket)";
            CurrentViewModel = _cdsVm;
            await _cdsVm.InitializeAsync();
        });

        LogoutCommand = new RelayCommand(() =>
        {
            _authService.Logout();
            RequestLogout?.Invoke();
        });

        // Wire event handlers
        _unduhDanomVm.RequestNavigateToCetakDanom += async () =>
        {
            CurrentPageTitle = "2. Cetak Danom & Ekspor BNBA";
            CurrentViewModel = _cetakDanomVm;
            await _cetakDanomVm.InitializeAsync();
        };

        _cetakDanomVm.RequestPrintPreview += (doc) =>
        {
            _previousViewModel = _cetakDanomVm;
            CurrentPageTitle = $"Pratinjau Dokumen: {doc.Title}";
            _printVm.LoadDocument(doc);
            CurrentViewModel = _printVm;
        };

        _cetakSuratVm.RequestPrintPreview += (doc) =>
        {
            _previousViewModel = _cetakSuratVm;
            CurrentPageTitle = $"Pratinjau Surat: {doc.Title}";
            _printVm.LoadDocument(doc);
            CurrentViewModel = _printVm;
        };

        _cdsVm.RequestPrintPreview += (doc) =>
        {
            _previousViewModel = _cdsVm;
            CurrentPageTitle = $"Pratinjau Bukti Terima CDS: {doc.Title}";
            _printVm.LoadDocument(doc);
            CurrentViewModel = _printVm;
        };

        _printVm.RequestBack += () =>
        {
            CurrentViewModel = _previousViewModel ?? _cetakDanomVm;
            CurrentPageTitle = _previousViewModel switch
            {
                CetakSuratViewModel => "3. Cetak Surat Pemberitahuan KPM",
                CetakDanomSatuanViewModel => "4. Cetak Danom Satuan (CDS Loket)",
                _ => "2. Cetak Danom & Ekspor BNBA"
            };
        };
    }

    public async Task InitializeAsync()
    {
        CurrentPageTitle = "1. Unduh Danom (Penarikan Data Wilayah)";
        CurrentViewModel = _unduhDanomVm;
        await _unduhDanomVm.InitializeAsync();
    }
}
