# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-bandizip.ps1
# Or in PowerShell:
# .\install-bandizip.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-bandizip.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-bandizip.ps1 | iex

# Description: Install or upgrade Bandizip from official installer (no winget)

class BandizipInstaller {
    [string] $DownloadUrl = "https://dl.bandisoft.com/bandizip.std/BANDIZIP-SETUP-STD-ALL.EXE"
    [string] $InstallerPath = "$env:TEMP\Bandizip-Setup.exe"

    [void] Download() {
        Write-Host "Downloading Bandizip installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing Bandizip (silent)..." -ForegroundColor Cyan
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "Bandizip installer exited with code: $($process.ExitCode)"
        }
        Write-Host "Bandizip installed/upgraded successfully!" -ForegroundColor Green
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
$installer = [BandizipInstaller]::new()
$installer.Run()
