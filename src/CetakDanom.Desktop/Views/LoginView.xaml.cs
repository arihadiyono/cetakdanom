using System.Windows;
using CetakDanom.Desktop.ViewModels;

namespace CetakDanom.Desktop.Views;

public partial class LoginView : Window
{
    public LoginView(LoginViewModel viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;
    }
}
