# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

# Usage:
# powershell -ExecutionPolicy Bypass -File install-cap.ps1
# Or in PowerShell:
# .\install-cap.ps1

# Remote exec:
# powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-cap.ps1').Content"
# Or shorter:
# irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-cap.ps1 | iex

# Description: Install Cap (screen recorder) from official installer

class CapInstaller {
    [string] $DownloadUrl = "https://cap.so/download/windows"
    [string] $InstallerPath = "$env:TEMP\Cap-Setup.exe"
    [string] $VCRedistUrl64 = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    [string] $VCRedistUrl86 = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
    [string] $VCRedistPath64 = "$env:TEMP\vc_redist.x64.exe"
    [string] $VCRedistPath86 = "$env:TEMP\vc_redist.x86.exe"

    [void] InstallVCRedist() {
        Write-Host "Installing Microsoft Visual C++ Redistributable (Latest Supported Version)..." -ForegroundColor Cyan
        Write-Host "This will install both x64 and x86 versions to ensure compatibility." -ForegroundColor Cyan
        
        # Install x64 version (Latest Supported)
        Write-Host "Step 1/2: Installing Visual C++ Redistributable x64..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $this.VCRedistUrl64 -OutFile $this.VCRedistPath64 -UseBasicParsing -ErrorAction Stop
            Write-Host "Executing x64 installer (this may take a minute)..." -ForegroundColor Cyan
            $process = Start-Process -FilePath $this.VCRedistPath64 -ArgumentList "/quiet", "/norestart" -Wait -PassThru -NoNewWindow
            Write-Host "✓ Visual C++ Redistributable x64 installed (Exit code: $($process.ExitCode))" -ForegroundColor Green
        } catch {
            Write-Host "✗ Warning: Failed to install VC Redistributable x64: $_" -ForegroundColor Yellow
        } finally {
            Remove-Item -Path $this.VCRedistPath64 -Force -ErrorAction SilentlyContinue
        }
        
        # Install x86 version (Latest Supported)
        Write-Host "Step 2/2: Installing Visual C++ Redistributable x86..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $this.VCRedistUrl86 -OutFile $this.VCRedistPath86 -UseBasicParsing -ErrorAction Stop
            Write-Host "Executing x86 installer (this may take a minute)..." -ForegroundColor Cyan
            $process = Start-Process -FilePath $this.VCRedistPath86 -ArgumentList "/quiet", "/norestart" -Wait -PassThru -NoNewWindow
            Write-Host "✓ Visual C++ Redistributable x86 installed (Exit code: $($process.ExitCode))" -ForegroundColor Green
        } catch {
            Write-Host "✗ Warning: Failed to install VC Redistributable x86: $_" -ForegroundColor Yellow
        } finally {
            Remove-Item -Path $this.VCRedistPath86 -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "Visual C++ Redistributable installation complete!" -ForegroundColor Green
    }

    [void] Download() {
        Write-Host "Downloading Cap installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
    }

    [void] Install() {
        Write-Host "Installing Cap (silent)..." -ForegroundColor Cyan
        # /S = silent mode
        # /D = installation directory (must be last parameter for NSIS)
        $installDir = "$env:ProgramFiles\Cap"
        $process = Start-Process -FilePath $this.InstallerPath -ArgumentList "/S", "/D=$installDir" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "Cap installer exited with code: $($process.ExitCode)"
        }
        Write-Host "Cap installed successfully!" -ForegroundColor Green
    }

    [void] Cleanup() {
        Remove-Item -Path $this.InstallerPath -Force -ErrorAction SilentlyContinue
    }

    [void] Run() {
        $this.InstallVCRedist()
        $this.Download()
        try {
            $this.Install()
        
        Write-Host "" -ForegroundColor Cyan
        Write-Host "================================" -ForegroundColor Green
        Write-Host "Installation completed!" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠ IMPORTANT: For best results, please restart your computer." -ForegroundColor Yellow
        Write-Host "This ensures all Visual C++ Redistributable libraries are properly loaded." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Restart now? (Y/N) " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        if ($response -eq "Y" -or $response -eq "y") {
            Write-Host "Restarting in 30 seconds... (Press Ctrl+C to cancel)" -ForegroundColor Cyan
            Start-Sleep -Seconds 5
            Restart-Computer -Force
        } else {
            Write-Host "Restart skipped. Cap may not work properly until you manually restart." -ForegroundColor Yellow
        }
        } finally {
            $this.Cleanup()
        }
    }
}

# Main execution
$installer = [CapInstaller]::new()
$installer.Run()
