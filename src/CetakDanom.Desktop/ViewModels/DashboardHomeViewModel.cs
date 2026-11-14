using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

public class DashboardHomeViewModel : ViewModelBase
{
    private readonly IDanomRepository _danomRepo;
    private readonly IAuthenticationService _authService;
    private int _totalKpm;
    private decimal _totalNominal;
    private int _siapCetak;
    private int _sudahCetak;

    public Petugas? Petugas => _authService.CurrentPetugas;

    public int TotalKpm
    {
        get => _totalKpm;
        set => SetProperty(ref _totalKpm, value);
    }

    public decimal TotalNominal
    {
        get => _totalNominal;
        set
        {
            SetProperty(ref _totalNominal, value);
            OnPropertyChanged(nameof(TotalNominalFormatted));
        }
    }

    public string TotalNominalFormatted =>
        TotalNominal.ToString("C0", new System.Globalization.CultureInfo("id-ID"));

    public int SiapCetak
    {
        get => _siapCetak;
        set => SetProperty(ref _siapCetak, value);
    }

    public int SudahCetak
    {
        get => _sudahCetak;
        set => SetProperty(ref _sudahCetak, value);
    }

    public ICommand RefreshCommand { get; }
    public ICommand NavigateToDanomCommand { get; }

    public event Action? RequestNavigateToDanom;

    public DashboardHomeViewModel(IDanomRepository danomRepo, IAuthenticationService authService)
    {
        _danomRepo = danomRepo;
        _authService = authService;

        RefreshCommand = new RelayCommand(async () => await LoadMetricsAsync());
        NavigateToDanomCommand = new RelayCommand(() => RequestNavigateToDanom?.Invoke());
    }

    public async Task InitializeAsync()
    {
        OnPropertyChanged(nameof(Petugas));
        await LoadMetricsAsync();
    }

    private async Task LoadMetricsAsync()
    {
        var summary = await _danomRepo.GetSummaryAsync(new DanomFilterRequest());
        TotalKpm = summary.TotalRecords;
        TotalNominal = summary.TotalNominal;
        SiapCetak = summary.SiapCetakCount;
        SudahCetak = summary.SudahCetakCount;
    }
}
