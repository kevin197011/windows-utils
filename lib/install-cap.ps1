# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-cap.ps1
# Or in PowerShell:
# .\install-cap.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-cap.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-cap.ps1 | iex

# Description: Install Cap (screen recorder) from official installer

class CapInstaller {
    [string] $DownloadUrl = "https://cap.so/download/windows"
    [string] $InstallerPath = "$env:TEMP\Cap-Setup.exe"

    [void] Download() {
        Write-Host "Downloading Cap installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing Cap (silent)..." -ForegroundColor Cyan
        # /S = silent mode
        # /D = installation directory (must be last parameter for NSIS)
        $installDir = "$env:ProgramFiles\Cap"
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S", "/D=$installDir" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "Cap installer exited with code: $($process.ExitCode)"
        }
        Write-Host "Cap installed successfully!" -ForegroundColor Green
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
$installer = [CapInstaller]::new()
$installer.Run()
