using Avalonia.Controls;
using Avalonia.Markup.Xaml;
using Ps1GuiManager.ViewModels;

namespace Ps1GuiManager.Views;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        DataContext = new MainWindowViewModel();
        
        // Ensure window is visible and focused
        this.Opened += (s, e) =>
        {
            this.BringIntoView();
            this.Activate();
        };
    }

    private void InitializeComponent()
    {
        AvaloniaXamlLoader.Load(this);
    }
}
