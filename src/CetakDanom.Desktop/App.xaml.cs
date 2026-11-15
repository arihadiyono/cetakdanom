using System.Windows;
using CetakDanom.Application.Interfaces;
using CetakDanom.Desktop.ViewModels;
using CetakDanom.Desktop.Views;
using CetakDanom.Infrastructure.Api;
using CetakDanom.Infrastructure.Export;
using CetakDanom.Infrastructure.Mock;
using CetakDanom.Infrastructure.Printing;
using Microsoft.Extensions.DependencyInjection;
using WpfApp = System.Windows.Application;

namespace CetakDanom.Desktop;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : WpfApp
{
    private ServiceProvider? _serviceProvider;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        DispatcherUnhandledException += (s, args) =>
        {
            MessageBox.Show($"Terjadi kesalahan UI tak terduga:\n{args.Exception.Message}\n\n{args.Exception.StackTrace}",
                "Fatal UI Error", MessageBoxButton.OK, MessageBoxImage.Error);
            args.Handled = true;
        };

        AppDomain.CurrentDomain.UnhandledException += (s, args) =>
        {
            if (args.ExceptionObject is Exception ex)
            {
                MessageBox.Show($"Kesalahan fatal sistem:\n{ex.Message}\n\n{ex.StackTrace}",
                    "Critical Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        };

        var services = new ServiceCollection();
        ConfigureServices(services);
        _serviceProvider = services.BuildServiceProvider();

        ShowLoginWindow();
    }

    private void ConfigureServices(IServiceCollection services)
    {
        // Go REST API Client & Integrated Repositories (Connecting to Go REST API -> SQL Server)
        services.AddSingleton<CetakDanomApiClient>();
        services.AddSingleton<IAuthenticationService, ApiAuthenticationService>();
        services.AddSingleton<IWilayahRepository, ApiWilayahRepository>();
        services.AddSingleton<IDanomRepository, ApiDanomRepository>();
        services.AddTransient<IExportService, BnbaCsvExportService>();
        services.AddSingleton<IQrCodeService, QrCodeService>();
        services.AddTransient<IPrintService, MockPrintService>();
        services.AddSingleton<ISuratService, MockSuratService>();
        services.AddSingleton<ICdsBltService, ApiCdsBltService>();

        // ViewModels
        services.AddTransient<LoginViewModel>();
        services.AddTransient<DashboardHomeViewModel>();
        services.AddTransient<DanomViewModel>();
        services.AddTransient<UnduhDanomViewModel>();
        services.AddTransient<CetakDanomViewModel>();
        services.AddTransient<CetakSuratViewModel>();
        services.AddTransient<CetakDanomSatuanViewModel>();
        services.AddTransient<PrintPreviewViewModel>();
        services.AddTransient<MainViewModel>();

        // Views
        services.AddTransient<LoginView>();
        services.AddTransient<MainView>();
        services.AddTransient<UnduhDanomView>();
        services.AddTransient<CetakDanomView>();
        services.AddTransient<CetakSuratView>();
        services.AddTransient<CetakDanomSatuanView>();
    }

    private void ShowLoginWindow()
    {
        if (_serviceProvider == null) return;

        var loginVm = _serviceProvider.GetRequiredService<LoginViewModel>();
        var loginWindow = new LoginView(loginVm);
        MainWindow = loginWindow;

        loginVm.LoginSucceeded += async () =>
        {
            try
            {
                var mainVm = _serviceProvider.GetRequiredService<MainViewModel>();
                await mainVm.InitializeAsync();

                var mainWindow = new MainView(mainVm);
                MainWindow = mainWindow;
                mainWindow.Show();

                mainVm.RequestLogout += () =>
                {
                    mainWindow.Close();
                    ShowLoginWindow();
                };

                loginWindow.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Terjadi kesalahan saat memuat menu utama:\n{ex.Message}\n\nDetail:\n{ex.StackTrace}",
                    "Kesalahan Sistem", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        };

        loginWindow.Show();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _serviceProvider?.Dispose();
        base.OnExit(e);
    }
}
