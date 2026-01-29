# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-pixpin.ps1
# Or in PowerShell:
# .\install-pixpin.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-pixpin.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-pixpin.ps1 | iex

# Description: Install PixPin from official installer

class PixPinInstaller {
    [string] $DownloadUrl = "https://download.pixpinapp.com/PixPin_intl_en-us_2.4.8.0.exe"
    [string] $InstallerPath = "$env:TEMP\PixPin_intl_en-us_2.4.8.0.exe"

    [void] Download() {
        Write-Host "Downloading PixPin installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing PixPin (silent)..." -ForegroundColor Cyan
        # /S = silent mode
        # /D = installation directory (must be last parameter for NSIS)
        $installDir = "$env:ProgramFiles\PixPin"
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S", "/D=$installDir" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "PixPin installer exited with code: $($process.ExitCode)"
        }
        Write-Host "PixPin installed successfully!" -ForegroundColor Green
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
$installer = [PixPinInstaller]::new()
$installer.Run()
