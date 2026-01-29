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
    [string] $DependenciesZipUrl
    [string] $InstallerPath
    [string] $DependenciesZipPath = "$env:TEMP\winget-dependencies.zip"
    [string] $DependenciesExtractPath = "$env:TEMP\winget-dependencies"

    WingetInstaller() {
        $this.InstallerPath = "$env:TEMP\winget.msixbundle"
    }

    [void] GetDownloadUrls() {
        Write-Host "Fetching latest winget release..."
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        
        $this.DownloadUrl = $release.assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -ExpandProperty browser_download_url -First 1
        if (-not $this.DownloadUrl) {
            throw "Failed to find winget installer (.msixbundle) in release"
        }
        
        # Dependencies zip (contains Microsoft.WindowsAppRuntime.1.8 and other frameworks)
        $depAsset = $release.assets | Where-Object { $_.name -like "*Dependencies*.zip" } | Select-Object -First 1
        if ($depAsset) {
            $this.DependenciesZipUrl = $depAsset.browser_download_url
            Write-Host "Found dependencies: $($depAsset.name)"
        } else {
            # Fallback: official permalink for latest dependencies
            $this.DependenciesZipUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip"
            Write-Host "Using dependencies from: DesktopAppInstaller_Dependencies.zip"
        }
        Write-Host "Winget bundle: $($this.DownloadUrl)"
    }

    [void] DownloadInstaller() {
        Write-Host "Downloading winget installer..."
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
        Write-Host "Downloading winget dependencies (Windows App Runtime 1.8, etc.)..."
        Invoke-WebRequest -Uri $this.DependenciesZipUrl -OutFile $this.DependenciesZipPath -UseBasicParsing
        Write-Host "Extracting dependencies..."
        if (Test-Path $this.DependenciesExtractPath) {
            Remove-Item -Path $this.DependenciesExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Expand-Archive -Path $this.DependenciesZipPath -DestinationPath $this.DependenciesExtractPath -Force
    }

    [string[]] GetDependencyPaths() {
        $paths = @()
        $paths += Get-ChildItem -Path $this.DependenciesExtractPath -Recurse -Include "*.msix", "*.appx" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        return $paths
    }

    [void] Install() {
        Write-Host "Installing/Upgrading winget with dependencies..."
        
        $existingWinget = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller" -ErrorAction SilentlyContinue
        if ($existingWinget) {
            Write-Host "Found existing winget installation. Upgrading..."
        } else {
            Write-Host "Installing winget for the first time..."
        }
        
        $depPaths = $this.GetDependencyPaths()
        if ($depPaths.Count -gt 0) {
            Write-Host "Installing $($depPaths.Count) dependency package(s) with winget..."
            Add-AppxPackage -Path $this.InstallerPath -DependencyPath $depPaths -ForceApplicationShutdown -ForceUpdateFromAnyVersion
        } else {
            Write-Host "No dependency packages found in zip; attempting direct install..."
            Add-AppxPackage -Path $this.InstallerPath -ForceApplicationShutdown -ForceUpdateFromAnyVersion
        }
        
        Write-Host "winget installed/upgraded successfully!"
        Write-Host "Refreshing environment variables..."
        
        # Refresh PATH environment variable for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Wait a moment for the installation to complete
        Start-Sleep -Seconds 2
        
        # Verify installation
        Write-Host "Verifying winget installation..."
        $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
        if (Test-Path $wingetPath) {
            Write-Host "✓ winget is available at: $wingetPath"
        } else {
            Write-Host "⚠ winget executable not found at expected path, but package is installed."
            Write-Host "  You may need to restart PowerShell or the application for winget to be available."
        }
        
        # Try to get winget version
        try {
            $wingetVersion = & winget --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ winget is working! Version: $wingetVersion"
            } else {
                Write-Host "⚠ winget command is not yet available in this session."
                Write-Host "  Please restart the application or open a new PowerShell window to use winget."
            }
        } catch {
            Write-Host "⚠ winget command is not yet available in this session."
            Write-Host "  Please restart the application or open a new PowerShell window to use winget."
        }
    }

    [void] Cleanup() {
        if (Test-Path $this.InstallerPath) {
            Remove-Item -Path $this.InstallerPath -Force -ErrorAction SilentlyContinue
            Write-Host "Cleaned up installer file"
        }
        if (Test-Path $this.DependenciesZipPath) {
            Remove-Item -Path $this.DependenciesZipPath -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $this.DependenciesExtractPath) {
            Remove-Item -Path $this.DependenciesExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    [void] Run() {
        try {
            $this.GetDownloadUrls()
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
