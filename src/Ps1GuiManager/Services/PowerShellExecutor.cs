using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Avalonia.Threading;

namespace Ps1GuiManager.Services;

public class PowerShellExecutor
{
    public event EventHandler<string>? OutputReceived;
    public event EventHandler<string>? ErrorReceived;
    public event EventHandler? ExecutionCompleted;

    public async Task<int> ExecuteScriptAsync(string scriptContent, CancellationToken cancellationToken = default)
    {
        // Create temporary file
        var tempFile = Path.Combine(Path.GetTempPath(), $"ps1-script-{Guid.NewGuid()}.ps1");
        
        try
        {
            // Write script to temporary file
            await File.WriteAllTextAsync(tempFile, scriptContent, Encoding.UTF8, cancellationToken);

            // Find PowerShell executable
            var powershellPath = FindPowerShell();
            if (string.IsNullOrEmpty(powershellPath))
            {
                throw new Exception("PowerShell not found. Please ensure PowerShell is installed.");
            }

            // Create process start info
            var startInfo = new ProcessStartInfo
            {
                FileName = powershellPath,
                Arguments = $"-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -NonInteractive -File \"{tempFile}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8
            };

            // Start process
            using var process = new Process { StartInfo = startInfo };
            
            // Set up output handlers
            process.OutputDataReceived += (sender, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data))
                {
                    Dispatcher.UIThread.Post(() =>
                    {
                        OutputReceived?.Invoke(this, e.Data);
                    });
                }
            };

            process.ErrorDataReceived += (sender, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data))
                {
                    Dispatcher.UIThread.Post(() =>
                    {
                        ErrorReceived?.Invoke(this, "[ERROR] " + e.Data);
                    });
                }
            };

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();

            // Wait for completion
            await process.WaitForExitAsync(cancellationToken);
            
            ExecutionCompleted?.Invoke(this, EventArgs.Empty);
            
            return process.ExitCode;
        }
        finally
        {
            // Clean up temporary file
            try
            {
                if (File.Exists(tempFile))
                {
                    File.Delete(tempFile);
                }
            }
            catch
            {
                // Ignore cleanup errors
            }
        }
    }

    private string? FindPowerShell()
    {
        var paths = new[]
        {
            "powershell.exe",
            @"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",
            @"C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
        };

        foreach (var path in paths)
        {
            if (File.Exists(path))
            {
                return path;
            }
        }

        return null;
    }
}
