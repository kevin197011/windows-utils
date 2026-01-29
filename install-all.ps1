# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling: fail-fast (first script failure stops the run)
$ErrorActionPreference = 'Stop'

# Usage:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex
#
# Reads meta/lib-manifest.json and runs each listed script in lib/ via irm ... | iex.

$BaseUrl = "https://raw.githubusercontent.com/kevin197011/windows-utils/main"
$ManifestUrl = "$BaseUrl/meta/lib-manifest.json"

$manifest = Invoke-WebRequest -Uri $ManifestUrl -UseBasicParsing | ConvertFrom-Json
$Scripts = $manifest.files

foreach ($script in $Scripts) {
    $url = "$BaseUrl/lib/$script"
    Write-Host "Running $script ..." -ForegroundColor Cyan
    Invoke-Expression (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
}

Write-Host "All install scripts completed." -ForegroundColor Green
