# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-winget.ps1
# Or in PowerShell:
# .\install-winget.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-winget.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-winget.ps1 | iex

# Description: Install or upgrade winget (Windows Package Manager) from GitHub releases

class WingetInstaller {
    [string] $DownloadUrl
    [string] $InstallerPath

    WingetInstaller() {
        $this.InstallerPath = "$env:TEMP\winget.msixbundle"
    }

    [void] GetDownloadUrl() {
        Write-Host "Fetching latest winget release URL..."
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $this.DownloadUrl = $release.assets | Where-Object {
            $_.name -like "*.msixbundle"
        } | Select-Object -ExpandProperty browser_download_url -First 1
        
        if (-not $this.DownloadUrl) {
            throw "Failed to find winget installer download URL"
        }
        Write-Host "Download URL: $($this.DownloadUrl)"
    }

    [void] DownloadInstaller() {
        Write-Host "Downloading winget installer..."
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath
        Write-Host "Downloaded to: $($this.InstallerPath)"
    }

    [void] Install() {
        Write-Host "Installing/Upgrading winget..."
        
        # Check if winget is already installed
        $existingWinget = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller" -ErrorAction SilentlyContinue
        if ($existingWinget) {
            Write-Host "Found existing winget installation. Upgrading..."
        } else {
            Write-Host "Installing winget for the first time..."
        }
        
        # Install or upgrade with force update to allow overwriting existing installation
        Add-AppxPackage -Path $this.InstallerPath -ForceApplicationShutdown -ForceUpdateFromAnyVersion
        
        Write-Host "winget installed/upgraded successfully!"
    }

    [void] Cleanup() {
        if (Test-Path $this.InstallerPath) {
            Remove-Item -Path $this.InstallerPath -Force -ErrorAction SilentlyContinue
            Write-Host "Cleaned up installer file"
        }
    }

    [void] Run() {
        try {
            $this.GetDownloadUrl()
            $this.DownloadInstaller()
            $this.Install()
        }
        finally {
            $this.Cleanup()
        }
    }
}

# Main execution
$installer = [WingetInstaller]::new()
$installer.Run()
