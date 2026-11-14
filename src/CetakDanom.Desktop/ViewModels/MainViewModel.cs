using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

public class MainViewModel : ViewModelBase
{
    private readonly IAuthenticationService _authService;
    private readonly DashboardHomeViewModel _homeVm;
    private readonly DanomViewModel _danomVm;
    private readonly PrintPreviewViewModel _printVm;

    private ViewModelBase _currentViewModel;
    private string _currentPageTitle = "Dashboard Utama";

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

    public ICommand NavigateHomeCommand { get; }
    public ICommand NavigateDanomCommand { get; }
    public ICommand NavigatePrintCommand { get; }
    public ICommand LogoutCommand { get; }

    public event Action? RequestLogout;

    public MainViewModel(
        IAuthenticationService authService,
        DashboardHomeViewModel homeVm,
        DanomViewModel danomVm,
        PrintPreviewViewModel printVm)
    {
        _authService = authService;
        _homeVm = homeVm;
        _danomVm = danomVm;
        _printVm = printVm;

        _currentViewModel = _homeVm;

        NavigateHomeCommand = new RelayCommand(async () =>
        {
            CurrentPageTitle = "Dashboard Utama";
            CurrentViewModel = _homeVm;
            await _homeVm.InitializeAsync();
        });

        NavigateDanomCommand = new RelayCommand(async () =>
        {
            CurrentPageTitle = "Pengelolaan Danom & Ekspor BNBA";
            CurrentViewModel = _danomVm;
            await _danomVm.InitializeAsync();
        });

        NavigatePrintCommand = new RelayCommand(() =>
        {
            CurrentPageTitle = "Pratinjau & Validasi Dokumen Cetak";
            CurrentViewModel = _printVm;
        });

        LogoutCommand = new RelayCommand(() =>
        {
            _authService.Logout();
            RequestLogout?.Invoke();
        });

        // Wire sub-viewmodel events
        _homeVm.RequestNavigateToDanom += async () =>
        {
            CurrentPageTitle = "Pengelolaan Danom & Ekspor BNBA";
            CurrentViewModel = _danomVm;
            await _danomVm.InitializeAsync();
        };

        _danomVm.RequestPrintPreview += (doc) =>
        {
            CurrentPageTitle = $"Pratinjau: {doc.Title}";
            _printVm.LoadDocument(doc);
            CurrentViewModel = _printVm;
        };

        _printVm.RequestBack += () =>
        {
            CurrentPageTitle = "Pengelolaan Danom & Ekspor BNBA";
            CurrentViewModel = _danomVm;
        };
    }

    public async Task InitializeAsync()
    {
        OnPropertyChanged(nameof(CurrentPetugas));
        CurrentPageTitle = "Dashboard Utama";
        CurrentViewModel = _homeVm;
        await _homeVm.InitializeAsync();
    }
}
