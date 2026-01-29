# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-obs.ps1
# Or in PowerShell:
# .\install-obs.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-obs.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-obs.ps1 | iex

# Description: Install OBS Studio from official installer

class OBSInstaller {
    [string] $DownloadUrl = "https://github.com/obsproject/obs-studio/releases/download/31.1.0/OBS-Studio-31.1.0-Full-Installer-x64.exe"
    [string] $InstallerPath = "$env:TEMP\OBS-Studio-Full-Installer-x64.exe"

    [void] Download() {
        Write-Host "Downloading OBS Studio installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing OBS Studio (silent)..." -ForegroundColor Cyan
        # /S = silent mode
        # /D = installation directory (must be last parameter for NSIS)
        $installDir = "$env:ProgramFiles\obs-studio"
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S", "/D=$installDir" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "OBS Studio installer exited with code: $($process.ExitCode)"
        }
        Write-Host "OBS Studio installed successfully!" -ForegroundColor Green
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
$installer = [OBSInstaller]::new()
$installer.Run()
