# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling: fail-fast (first script failure stops the run)
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-all.ps1
# Or in PowerShell:
# .\install-all.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex

# Description: Run all installation scripts from the manifest

class ScriptRunner {
    [string] $BaseUrl = "https://raw.githubusercontent.com/kevin197011/windows-utils/main"
    [string] $ManifestUrl
    [array] $Scripts

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
            Invoke-Expression (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
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
$runner.RunAll()
