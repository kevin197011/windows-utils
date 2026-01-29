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

# Description: Install or upgrade Snipaste from official portable zip (no winget).
# Installs to %LOCALAPPDATA%\Snipaste (write-friendly; avoid Program Files per official docs).

$SnipasteZipUrl = "https://dl.snipaste.com/win-x64"
$InstallDir = "$env:LOCALAPPDATA\Snipaste"
$ZipPath = "$env:TEMP\Snipaste-win-x64.zip"

Write-Host "Downloading Snipaste (portable)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $SnipasteZipUrl -OutFile $ZipPath -UseBasicParsing

Write-Host "Extracting to $InstallDir ..." -ForegroundColor Cyan
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}
Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force

$exePath = Join-Path $InstallDir "Snipaste.exe"
if (-not (Test-Path $exePath)) {
    # Zip may contain a single top-level folder
    $sub = Get-ChildItem -Path $InstallDir -Directory | Select-Object -First 1
    if ($sub) {
        Get-ChildItem -Path $sub.FullName -Recurse | Move-Item -Destination $InstallDir -Force
        Remove-Item -Path $sub.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}
if (Test-Path $exePath) {
    Write-Host "Snipaste installed at: $exePath" -ForegroundColor Green
    # Optional: create Desktop shortcut
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut("$env:USERPROFILE\Desktop\Snipaste.lnk")
    $shortcut.TargetPath = $exePath
    $shortcut.WorkingDirectory = $InstallDir
    $shortcut.Save()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wsh) | Out-Null
    Write-Host "Desktop shortcut created." -ForegroundColor Green
} else {
    throw "Snipaste.exe not found after extract. Check contents of $InstallDir"
}

Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue
