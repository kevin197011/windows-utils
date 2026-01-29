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
    [string] $DownloadUrl = "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-32.0.4-Windows-x64-Installer.exe"
    [string] $GithubUrl = "https://github.com/obsproject/obs-studio/releases/download/32.0.4/OBS-Studio-32.0.4-Windows-x64-Installer.exe"
    [string] $InstallerPath = "$env:TEMP\OBS-Studio-32.0.4-Windows-x64-Installer.exe"
    [int] $MaxRetries = 5
    [int] $RetryDelaySeconds = 10

    [void] Download() {
        Write-Host "Downloading OBS Studio installer..." -ForegroundColor Cyan
        
        $urls = @($this.DownloadUrl, $this.GithubUrl)
        $downloaded = $false
        
        foreach ($url in $urls) {
            if ($downloaded) { break }
            
            Write-Host "Attempting download from: $url" -ForegroundColor Cyan
            
            $retryCount = 0
            while ($retryCount -lt $this.MaxRetries -and -not $downloaded) {
                try {
                    $retryCount++
                    if ($retryCount -gt 1) {
                        Write-Host "Retry attempt $retryCount of $($this.MaxRetries)..." -ForegroundColor Yellow
                        Start-Sleep -Seconds $this.RetryDelaySeconds
                    }
                    
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri $url `
                        -OutFile $this.InstallerPath `
                        -UseBasicParsing `
                        -TimeoutSec 600 `
                        -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" `
                        -ErrorAction Stop
                    
                    $downloaded = $true
                    Write-Host "Download completed successfully!" -ForegroundColor Green
                } catch {
                    Write-Host "Download attempt $retryCount failed: $_" -ForegroundColor Yellow
                    
                    if ($retryCount -ge $this.MaxRetries) {
                        Write-Host "Failed to download from this URL after $($this.MaxRetries) attempts." -ForegroundColor Yellow
                    }
                }
            }
        }
        
        if (-not $downloaded) {
            throw "Failed to download OBS Studio from all available sources. Please check your internet connection."
        }
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
