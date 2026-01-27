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

# vars

# run code
function chrome::install::run {
    chrome::install::common
}

# common code
function chrome::install::common {
    # Check if winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget is not installed. Please install winget first using install-winget.ps1"
        exit 1
    }

    Write-Host "Installing Google Chrome..."
    
    # Install Chrome using winget
    # --silent: Silent installation
    # --accept-package-agreements: Accept package agreements
    # --accept-source-agreements: Accept source agreements
    winget install --id Google.Chrome --silent --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Google Chrome installed successfully!"
    } else {
        Write-Error "Failed to install Google Chrome. Exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

# run main
chrome::install::run
