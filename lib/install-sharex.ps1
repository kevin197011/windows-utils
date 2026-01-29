# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-sharex.ps1
# Or in PowerShell:
# .\install-sharex.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-sharex.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-sharex.ps1 | iex

# Description: Install ShareX from official installer

class ShareXInstaller {
    [string] $DownloadUrl = "https://github.com/ShareX/ShareX/releases/download/v19.0.2/ShareX-19.0.2-setup.exe"
    [string] $InstallerPath = "$env:TEMP\ShareX-19.0.2-setup.exe"

    [void] Download() {
        Write-Host "Downloading ShareX installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing ShareX (silent)..." -ForegroundColor Cyan
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "ShareX installer exited with code: $($process.ExitCode)"
        }
        Write-Host "ShareX installed successfully!" -ForegroundColor Green
    }

    [void] Cleanup() {
        Remove-Item -Path $this.InstallerPath -Force -ErrorAction SilentlyContinue
    }

    [void] Run() {
        $this.Download()
        try {
            $this.Install()
        } finally {
            $this.Cleanup()
        }
    }
}

# Main execution
$installer = [ShareXInstaller]::new()
$installer.Run()
