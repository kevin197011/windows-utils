using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reactive;
using System.Threading;
using System.Threading.Tasks;
using Ps1GuiManager.Models;
using Ps1GuiManager.Services;
using ReactiveUI;

namespace Ps1GuiManager.ViewModels;

public class MainWindowViewModel : ViewModelBase
{
    private readonly ScriptLoader _scriptLoader;
    private readonly PowerShellExecutor _executor;
    private Script? _selectedScript;
    private string _statusText = "Status: Ready - Select a script to execute";
    private string _descriptionText = "Select a script to see its description";
    private string _logText = "Ready. Select a script and click Execute.\nYou can execute multiple scripts in sequence.\n";
    private bool _isExecuting;
    private CancellationTokenSource? _cancellationTokenSource;

    public ObservableCollection<Script> Scripts { get; } = new();

    public Script? SelectedScript
    {
        get => _selectedScript;
        set
        {
            this.RaiseAndSetIfChanged(ref _selectedScript, value);
            if (value != null)
            {
                DescriptionText = string.IsNullOrWhiteSpace(value.Description) 
                    ? "No description available" 
                    : $"Description: {value.Description}";
                
                // Update status when selecting a new script (if not executing)
                if (!IsExecuting)
                {
                    StatusText = $"Status: Ready - {value.Name} selected";
                }
            }
        }
    }

    public string StatusText
    {
        get => _statusText;
        set => this.RaiseAndSetIfChanged(ref _statusText, value);
    }

    public string DescriptionText
    {
        get => _descriptionText;
        set => this.RaiseAndSetIfChanged(ref _descriptionText, value);
    }

    public string LogText
    {
        get => _logText;
        set => this.RaiseAndSetIfChanged(ref _logText, value);
    }

    public bool IsExecuting
    {
        get => _isExecuting;
        set
        {
            this.RaiseAndSetIfChanged(ref _isExecuting, value);
            this.RaisePropertyChanged(nameof(ExecuteButtonText));
        }
    }

    public string ExecuteButtonText => IsExecuting ? "Executing..." : "Execute";

    public ReactiveCommand<Unit, Unit> ExecuteCommand { get; }
    public ReactiveCommand<Unit, Unit> ClearLogCommand { get; }

    public MainWindowViewModel()
    {
        _scriptLoader = new ScriptLoader();
        _executor = new PowerShellExecutor();
        
        _executor.OutputReceived += OnOutputReceived;
        _executor.ErrorReceived += OnErrorReceived;
        _executor.ExecutionCompleted += OnExecutionCompleted;

        var canExecute = this.WhenAnyValue(
            x => x.SelectedScript, 
            x => x.IsExecuting, 
            (script, executing) => script != null && !executing);
        
        ExecuteCommand = ReactiveCommand.CreateFromTask(ExecuteScriptAsync, canExecute);
        ClearLogCommand = ReactiveCommand.Create(ClearLog);

        LoadScripts();
    }

    private void LoadScripts()
    {
        var scripts = _scriptLoader.LoadScripts();
        foreach (var script in scripts)
        {
            Scripts.Add(script);
        }
    }

    private async Task ExecuteScriptAsync()
    {
        if (SelectedScript == null || IsExecuting) return;

        IsExecuting = true;
        StatusText = $"Status: Executing {SelectedScript.Name}...";
        AppendLog($"\n{new string('=', 60)}\n");
        AppendLog($"Executing: {SelectedScript.Name}\n");
        AppendLog($"{new string('=', 60)}\n");

        _cancellationTokenSource?.Dispose();
        _cancellationTokenSource = new CancellationTokenSource();

        try
        {
            var exitCode = await _executor.ExecuteScriptAsync(
                SelectedScript.Content, 
                _cancellationTokenSource.Token);

            if (exitCode == 0)
            {
                StatusText = "Status: Completed - Ready for next script";
                AppendLog($"\n{new string('=', 60)}\n");
                AppendLog("✓ Execution completed successfully\n");
                AppendLog($"{new string('=', 60)}\n");
                AppendLog("Ready to execute another script. Select a script and click Execute.\n");
                AppendLog("The application will continue running. You can install more tools.\n\n");
            }
            else
            {
                StatusText = "Status: Error - Ready for next script";
                AppendLog($"\n{new string('=', 60)}\n");
                AppendLog($"✗ Execution failed with exit code: {exitCode}\n");
                AppendLog($"{new string('=', 60)}\n");
                AppendLog("You can try another script or re-execute this one.\n");
                AppendLog("The application will continue running. You can select and execute other scripts.\n\n");
            }
        }
        catch (OperationCanceledException)
        {
            StatusText = "Status: Cancelled - Ready for next script";
            AppendLog($"\n{new string('=', 60)}\n");
            AppendLog("⚠ Script execution was cancelled\n");
            AppendLog($"{new string('=', 60)}\n");
            AppendLog("You can select and execute another script.\n\n");
        }
        catch (Exception ex)
        {
            StatusText = "Status: Error - Ready for next script";
            AppendLog($"\n{new string('=', 60)}\n");
            AppendLog($"✗ Error occurred: {ex.Message}\n");
            if (ex.InnerException != null)
            {
                AppendLog($"  Inner exception: {ex.InnerException.Message}\n");
            }
            AppendLog($"{new string('=', 60)}\n");
            AppendLog("The application will continue running. You can try another script or re-execute this one.\n\n");
        }
        finally
        {
            IsExecuting = false;
            // Ensure the execute button is re-enabled
            this.RaisePropertyChanged(nameof(ExecuteButtonText));
        }
    }

    private void OnOutputReceived(object? sender, string data)
    {
        AppendLog(data + "\n");
    }

    private void OnErrorReceived(object? sender, string data)
    {
        AppendLog(data + "\n");
    }

    private void OnExecutionCompleted(object? sender, EventArgs e)
    {
        // Handled in ExecuteScriptAsync
    }

    private void AppendLog(string text)
    {
        // Append text and auto-scroll (handled by binding)
        LogText += text;
    }

    private void ClearLog()
    {
        LogText = string.Empty;
    }
}
