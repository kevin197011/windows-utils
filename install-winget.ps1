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
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-winget.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-winget.ps1 | iex

# vars

# run code
function winget::install::run {
    winget::install::common
}

# common code
function winget::install::common {
    # Get the latest winget release download URL
    $downloadUrl = (
        Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    ).assets | Where-Object {
        $_.name -like "*.msixbundle"
    } | Select-Object -ExpandProperty browser_download_url

    # Download the winget installer
    $installerPath = "$env:TEMP\winget.msixbundle"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    # Install the package
    Add-AppxPackage -Path $installerPath
}

# run main
winget::install::run
