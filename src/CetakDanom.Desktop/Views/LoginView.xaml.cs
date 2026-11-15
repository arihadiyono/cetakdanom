using System.Windows;
using CetakDanom.Desktop.ViewModels;

namespace CetakDanom.Desktop.Views;

public partial class LoginView : Window
{
    public LoginView(LoginViewModel viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;
        WindowStartupLocation = WindowStartupLocation.CenterScreen;
        Loaded += (s, e) =>
        {
            var workArea = SystemParameters.WorkArea;
            Left = (workArea.Width - Width) / 2 + workArea.Left;
            Top = (workArea.Height - Height) / 2 + workArea.Top;
        };
    }
}
