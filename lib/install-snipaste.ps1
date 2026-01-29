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
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-snipaste.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-snipaste.ps1 | iex

# Description: Install or upgrade Snipaste from official portable zip (no winget).
# Installs to %LOCALAPPDATA%\Snipaste (write-friendly; avoid Program Files per official docs).

class SnipasteInstaller {
    [string] $ZipUrl = "https://dl.snipaste.com/win-x64"
    [string] $InstallDir = "$env:LOCALAPPDATA\Snipaste"
    [string] $ZipPath = "$env:TEMP\Snipaste-win-x64.zip"

    [void] Download() {
        Write-Host "Downloading Snipaste (portable)..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.ZipUrl -OutFile $this.ZipPath -UseBasicParsing
    }

    [void] Extract() {
        Write-Host "Extracting to $($this.InstallDir) ..." -ForegroundColor Cyan
        if (-not (Test-Path $this.InstallDir)) {
            New-Item -ItemType Directory -Path $this.InstallDir -Force | Out-Null
        }
        Expand-Archive -Path $this.ZipPath -DestinationPath $this.InstallDir -Force
    }

    [void] FlattenSubfolder() {
        $exePath = Join-Path $this.InstallDir "Snipaste.exe"
        if (Test-Path $exePath) { return }
        $sub = Get-ChildItem -Path $this.InstallDir -Directory | Select-Object -First 1
        if ($sub) {
            Get-ChildItem -Path $sub.FullName -Recurse | Move-Item -Destination $this.InstallDir -Force
            Remove-Item -Path $sub.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    [void] CreateShortcut() {
        $exePath = Join-Path $this.InstallDir "Snipaste.exe"
        if (-not (Test-Path $exePath)) { return }
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut("$env:USERPROFILE\Desktop\Snipaste.lnk")
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = $this.InstallDir
        $shortcut.Save()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wsh) | Out-Null
        Write-Host "Desktop shortcut created." -ForegroundColor Green
    }

    [void] Install() {
        $this.Extract()
        $this.FlattenSubfolder()
        $exePath = Join-Path $this.InstallDir "Snipaste.exe"
        if (-not (Test-Path $exePath)) {
            throw "Snipaste.exe not found after extract. Check contents of $($this.InstallDir)"
        }
        Write-Host "Snipaste installed at: $exePath" -ForegroundColor Green
        $this.CreateShortcut()
    }

    [void] Cleanup() {
        Remove-Item -Path $this.ZipPath -Force -ErrorAction SilentlyContinue
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
$installer = [SnipasteInstaller]::new()
$installer.Run()
