# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-snipaste.ps1
# Or in PowerShell:
# .\install-snipaste.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-snipaste.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-snipaste.ps1 | iex

# Description: Install or upgrade Snipaste screenshot tool using winget

class SnipasteInstaller {
    [string] $PackageId = "Snipaste.Snipaste"
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

        # Check if Snipaste is already installed
        try {
            $null = winget list --id $this.PackageId --exact 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Found existing Snipaste installation. Upgrading to latest version..."
            } else {
                Write-Host "Installing Snipaste using winget..."
            }
        } catch {
            Write-Host "Installing Snipaste using winget..."
        }
        
        $arguments = @(
            "install",
            "--id", $this.PackageId,
            "--silent",
            "--accept-package-agreements",
            "--accept-source-agreements",
            "--force"
        )
        
        $process = Start-Process -FilePath "winget" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        
        # winget exit codes:
        # 0 = success (installed or upgraded)
        # 0x8A150011 = package already installed (but --force should upgrade it)
        # Other codes = error
        if ($process.ExitCode -eq 0) {
            Write-Host "Snipaste installed/upgraded successfully!"
        } elseif ($process.ExitCode -eq 0x8A150011) {
            Write-Host "Snipaste is already installed at the latest version, or upgrade completed."
        } else {
            throw "Failed to install/upgrade Snipaste. Exit code: $($process.ExitCode)"
        }
    }

    [void] Run() {
        $this.Install()
    }
}

# Main execution
$installer = [SnipasteInstaller]::new()
$installer.Run()
