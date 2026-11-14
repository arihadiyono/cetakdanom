using System.Windows;
using CetakDanom.Desktop.ViewModels;

namespace CetakDanom.Desktop.Views;

public partial class MainView : Window
{
    public MainView(MainViewModel viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;
    }
}
