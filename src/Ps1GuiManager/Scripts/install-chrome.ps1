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
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-chrome.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/src/Ps1GuiManager/Scripts/install-chrome.ps1 | iex

# Description: Install or upgrade Google Chrome from official installer (no winget)

$ChromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
$InstallerPath = "$env:TEMP\chrome_installer.exe"

Write-Host "Downloading Google Chrome installer..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $ChromeInstallerUrl -OutFile $InstallerPath -UseBasicParsing

Write-Host "Installing Google Chrome (silent)..." -ForegroundColor Cyan
$process = Start-Process -FilePath $InstallerPath -ArgumentList "/silent", "/install" -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    Write-Host "Google Chrome installed/upgraded successfully!" -ForegroundColor Green
} else {
    throw "Chrome installer exited with code: $($process.ExitCode)"
}

# Cleanup
Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
