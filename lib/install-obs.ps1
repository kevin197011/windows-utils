# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-obs.ps1
# .\install-obs.ps1
# .\install-obs.ps1 -Force  (force reinstall)
#
# Remote exec:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-obs.ps1 | iex
# $env:FORCE_INSTALL='true'; irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-obs.ps1 | iex

# Description: Install OBS Studio from official installer

# Parse arguments manually for irm | iex support
$Force = $false
if ($args -contains "-Force" -or $args -contains "-force") {
    $Force = $true
}

if ($env:FORCE_INSTALL -eq 'true') {
    $Force = $true
}

class OBSInstaller {
    [string] $DownloadUrl = "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-32.0.4-Windows-x64-Installer.exe"
    [string] $InstallerPath = "$env:TEMP\OBS-Studio-32.0.4-Windows-x64-Installer.exe"
    [string] $InstallDir = "$env:ProgramFiles\obs-studio"
    [bool] $Force = $false

    [bool] IsInstalled() {
        if (Test-Path -Path $this.InstallDir) {
            return $true
        }
        return $false
    }

    [void] Download() {
        Write-Host "Downloading OBS Studio installer..." -ForegroundColor Cyan
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $this.DownloadUrl `
            -OutFile $this.InstallerPath `
            -UseBasicParsing `
            -TimeoutSec 600 `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    }

    [void] Install() {
        Write-Host "Installing OBS Studio (silent)..." -ForegroundColor Cyan
        # /S = silent mode
        # /D = installation directory (must be last parameter for NSIS)
        
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S", "/D=$($this.InstallDir)" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "OBS Studio installer exited with code: $($process.ExitCode)"
        }
        Write-Host "OBS Studio installed successfully!" -ForegroundColor Green
    }

    [void] Cleanup() {
        Remove-Item -Path $this.InstallerPath -Force -ErrorAction SilentlyContinue
    }

    [void] Run() {
        if ($this.IsInstalled() -and -not $this.Force) {
            Write-Host "OBS Studio is already installed at: $($this.InstallDir)" -ForegroundColor Green
            Write-Host "Skipping installation. Use -Force parameter to force reinstall." -ForegroundColor Yellow
            return
        }
        
        if ($this.Force -and $this.IsInstalled()) {
            Write-Host "Force flag detected. Proceeding with reinstall..." -ForegroundColor Yellow
        }
        
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
$installer.Force = $Force
$installer.Run()
