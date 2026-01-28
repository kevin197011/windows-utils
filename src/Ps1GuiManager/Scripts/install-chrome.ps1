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
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/cmd/ps1-gui-manager/scripts/install-chrome.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/cmd/ps1-gui-manager/scripts/install-chrome.ps1 | iex

# Description: Install Google Chrome browser using winget

class ChromeInstaller {
    [string] $PackageId = "Google.Chrome"
    [bool] $Silent = $true

    [bool] CheckWinget() {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            return $false
        }
        return $true
    }

    [void] Install() {
        if (-not $this.CheckWinget()) {
            throw "winget is not installed. Please install winget first using install-winget.ps1"
        }

        Write-Host "Installing Google Chrome using winget..."
        
        $arguments = @(
            "install",
            "--id", $this.PackageId,
            "--silent",
            "--accept-package-agreements",
            "--accept-source-agreements"
        )
        
        $process = Start-Process -FilePath "winget" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Google Chrome installed successfully!"
        } else {
            throw "Failed to install Google Chrome. Exit code: $($process.ExitCode)"
        }
    }

    [void] Run() {
        $this.Install()
    }
}

# Main execution
$installer = [ChromeInstaller]::new()
$installer.Run()
