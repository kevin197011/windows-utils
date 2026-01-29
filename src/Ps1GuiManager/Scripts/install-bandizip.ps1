# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-bandizip.ps1
# Or in PowerShell:
# .\install-bandizip.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-bandizip.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-bandizip.ps1 | iex

# Description: Install or upgrade Bandizip from official installer (no winget)

$BandizipInstallerUrl = "https://dl.bandisoft.com/bandizip.std/BANDIZIP-SETUP-STD-ALL.EXE"
$InstallerPath = "$env:TEMP\Bandizip-Setup.exe"

Write-Host "Downloading Bandizip installer..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $BandizipInstallerUrl -OutFile $InstallerPath -UseBasicParsing

Write-Host "Installing Bandizip (silent)..." -ForegroundColor Cyan
$process = Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    Write-Host "Bandizip installed/upgraded successfully!" -ForegroundColor Green
} else {
    throw "Bandizip installer exited with code: $($process.ExitCode)"
}

# Cleanup
Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
