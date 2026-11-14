using System.Windows;
using CetakDanom.Application.Interfaces;
using CetakDanom.Desktop.ViewModels;
using CetakDanom.Desktop.Views;
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

        var services = new ServiceCollection();
        ConfigureServices(services);
        _serviceProvider = services.BuildServiceProvider();

        ShowLoginWindow();
    }

    private void ConfigureServices(IServiceCollection services)
    {
        // Infrastructure & Application Services (Mock abstractions for Phase 1)
        services.AddSingleton<IAuthenticationService, MockAuthenticationService>();
        services.AddSingleton<IWilayahRepository, MockWilayahRepository>();
        services.AddSingleton<IDanomRepository, MockDanomRepository>();
        services.AddTransient<IExportService, BnbaCsvExportService>();
        services.AddSingleton<IQrCodeService, QrCodeService>();
        services.AddTransient<IPrintService, MockPrintService>();

        // ViewModels
        services.AddTransient<LoginViewModel>();
        services.AddTransient<DashboardHomeViewModel>();
        services.AddTransient<DanomViewModel>();
        services.AddTransient<PrintPreviewViewModel>();
        services.AddTransient<MainViewModel>();

        // Views
        services.AddTransient<LoginView>();
        services.AddTransient<MainView>();
    }

    private void ShowLoginWindow()
    {
        if (_serviceProvider == null) return;

        var loginVm = _serviceProvider.GetRequiredService<LoginViewModel>();
        var loginWindow = new LoginView(loginVm);

        loginVm.LoginSucceeded += async () =>
        {
            var mainVm = _serviceProvider.GetRequiredService<MainViewModel>();
            await mainVm.InitializeAsync();

            var mainWindow = new MainView(mainVm);
            mainWindow.Show();

            mainVm.RequestLogout += () =>
            {
                mainWindow.Close();
                ShowLoginWindow();
            };

            loginWindow.Close();
        };

        loginWindow.Show();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _serviceProvider?.Dispose();
        base.OnExit(e);
    }
}
