# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-chrome.ps1
# Or in PowerShell:
# .\install-chrome.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-chrome.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-chrome.ps1 | iex

# Description: Install or upgrade Google Chrome from official installer (no winget)

class ChromeInstaller {
    [string] $DownloadUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    [string] $InstallerPath = "$env:TEMP\chrome_installer.exe"

    [void] Download() {
        Write-Host "Downloading Google Chrome installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing Google Chrome (silent)..." -ForegroundColor Cyan
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/silent", "/install" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "Chrome installer exited with code: $($process.ExitCode)"
        }
        Write-Host "Google Chrome installed/upgraded successfully!" -ForegroundColor Green
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
$installer = [ChromeInstaller]::new()
$installer.Run()
