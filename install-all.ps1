# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling: fail-fast (first script failure stops the run)
$ErrorActionPreference = 'Stop'

# Usage:
# Local execution:
#   powershell -ExecutionPolicy Bypass -File install-all.ps1
#   .\install-all.ps1
#   .\install-all.ps1 -Force  (force reinstall all)
#
# Remote execution:
#   irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex
#   $env:FORCE_INSTALL='true'; irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex

# Description: Run all installation scripts from the manifest

# Parse arguments manually to support 'irm | iex' which fails with param() block
$Force = $false
if ($args -contains "-Force" -or $args -contains "-force") {
    $Force = $true
}

# Check for environment variable (for remote execution with irm | iex)
if ($env:FORCE_INSTALL -eq 'true') {
    $Force = $true
}

class ScriptRunner {
    [string] $BaseUrl = "https://raw.githubusercontent.com/kevin197011/windows-utils/main"
    [string] $ManifestUrl
    [array] $Scripts
    [bool] $Force = $false

    ScriptRunner() {
        $this.ManifestUrl = "$($this.BaseUrl)/meta/lib-manifest.json"
    }

    [void] LoadManifest() {
        Write-Host "Loading manifest from $($this.ManifestUrl)..." -ForegroundColor Cyan
        $manifest = Invoke-WebRequest -Uri $this.ManifestUrl -UseBasicParsing | ConvertFrom-Json
        $this.Scripts = $manifest.files
        Write-Host "Found $($this.Scripts.Count) scripts to run." -ForegroundColor Green
    }

    [void] RunScript([string] $ScriptName) {
        $url = "$($this.BaseUrl)/lib/$ScriptName"
        Write-Host "Running $ScriptName ..." -ForegroundColor Cyan
        try {
            $scriptContent = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
            if ($this.Force) {
                Write-Host "  (Force mode enabled)" -ForegroundColor Yellow
                Invoke-Expression "$scriptContent -Force"
            } else {
                Invoke-Expression $scriptContent
            }
        } catch {
            Write-Host "Error running $ScriptName : $_" -ForegroundColor Red
            throw
        }
    }

    [void] RunAll() {
        $this.LoadManifest()
        foreach ($script in $this.Scripts) {
            $this.RunScript($script)
        }
        Write-Host "All install scripts completed successfully." -ForegroundColor Green
    }
}

# Main execution
$runner = [ScriptRunner]::new()
$runner.Force = $Force
$runner.RunAll()
