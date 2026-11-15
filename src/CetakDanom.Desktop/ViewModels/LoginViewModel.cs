using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;

namespace CetakDanom.Desktop.ViewModels;

public class LoginViewModel : ViewModelBase
{
    private readonly IAuthenticationService _authService;
    private string _userId = "asep";
    private string _password = "123";
    private string _errorMessage = string.Empty;
    private bool _isLoading;
    private bool _hasError;

    public string AppTitle => "CETAKDANOM FDPOS MODERN";
    public string AppVersion => "v5.0.0-PROTOTYPE (LTS .NET 8.0)";
    public string Subtitle => "Sistem Penyaluran & Cetak Dokumen Bantuan Sosial Tunai PT Pos Indonesia";

    public string UserId
    {
        get => _userId;
        set => SetProperty(ref _userId, value);
    }

    public string Password
    {
        get => _password;
        set => SetProperty(ref _password, value);
    }

    public string ErrorMessage
    {
        get => _errorMessage;
        set
        {
            SetProperty(ref _errorMessage, value);
            HasError = !string.IsNullOrWhiteSpace(value);
        }
    }

    public bool HasError
    {
        get => _hasError;
        set => SetProperty(ref _hasError, value);
    }

    public bool IsLoading
    {
        get => _isLoading;
        set => SetProperty(ref _isLoading, value);
    }

    public ICommand LoginCommand { get; }
    public ICommand FillDemoAccountCommand { get; }
    public ICommand FillPetugas01Command { get; }
    public ICommand FillSupervisorCommand { get; }

    public event Action? LoginSucceeded;

    public LoginViewModel(IAuthenticationService authService)
    {
        _authService = authService;

        LoginCommand = new RelayCommand(async () => await ExecuteLoginAsync(), () => !IsLoading);
        FillDemoAccountCommand = new RelayCommand(() =>
        {
            UserId = "asep";
            Password = "123";
            ErrorMessage = string.Empty;
        });
        FillPetugas01Command = new RelayCommand(() =>
        {
            UserId = "10009kakp";
            Password = "123";
            ErrorMessage = string.Empty;
        });
        FillSupervisorCommand = new RelayCommand(() =>
        {
            UserId = "10009loket01";
            Password = "123";
            ErrorMessage = string.Empty;
        });
    }

    private async Task ExecuteLoginAsync()
    {
        IsLoading = true;
        ErrorMessage = string.Empty;

        try
        {
            var result = await _authService.LoginAsync(new LoginRequest
            {
                UserId = UserId,
                Password = Password,
                AppVersion = AppVersion
            });

            if (result.IsSuccess)
            {
                LoginSucceeded?.Invoke();
            }
            else
            {
                ErrorMessage = result.Message;
            }
        }
        catch (Exception ex)
        {
            ErrorMessage = $"Terjadi kesalahan sistem: {ex.Message}";
        }
        finally
        {
            IsLoading = false;
        }
    }
}
