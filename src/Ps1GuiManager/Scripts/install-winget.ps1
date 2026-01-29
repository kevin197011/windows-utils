# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Error handling
$ErrorActionPreference = 'Stop'

class WingetInstaller {
    [string] $DownloadUrl
    [string] $DependenciesZipUrl
    [string] $InstallerPath
    [string] $DependenciesZipPath = "$env:TEMP\winget-dependencies.zip"
    [string] $DependenciesExtractPath = "$env:TEMP\winget-dependencies"

    WingetInstaller() {
        $this.InstallerPath = "$env:TEMP\winget.msixbundle"
    }

    [void] GetDownloadUrls() {
        # 使用 v1.11.x 版本以避免 Windows App Runtime 1.8 的复杂依赖问题
        $tagsToTry = @("v1.11.510", "v1.11.400")
        $release = $null
        foreach ($tag in $tagsToTry) {
            try {
                Write-Host "正在获取 winget 版本 $tag..." -ForegroundColor Cyan
                $release = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/tags/$tag"
                break
            } catch {
                Write-Host "  未找到 $tag，尝试下一个..."
            }
        }
        if (-not $release) {
            Write-Host "回退方案：使用最新版本..." -ForegroundColor Yellow
            $release = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        }
        
        $this.DownloadUrl = $release.assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -ExpandProperty browser_download_url -First 1
        if (-not $this.DownloadUrl) {
            throw "在 Release 中未找到 winget 安装包 (.msixbundle)"
        }
        $this.DependenciesZipUrl = $null
        $depAsset = $release.assets | Where-Object { $_.name -like "*Dependencies*.zip" } | Select-Object -First 1
        if ($depAsset) {
            $this.DependenciesZipUrl = $depAsset.browser_download_url
            Write-Host "找到依赖包: $($depAsset.name)" -ForegroundColor Green
        }
    }

    [void] DownloadInstaller() {
        Write-Host "正在下载 winget 安装包..."
        Invoke-WebRequest -Uri $this.DownloadUrl -OutFile $this.InstallerPath -UseBasicParsing
        if ($this.DependenciesZipUrl) {
            Write-Host "正在下载依赖包..."
            Invoke-WebRequest -Uri $this.DependenciesZipUrl -OutFile $this.DependenciesZipPath -UseBasicParsing
            Write-Host "正在解压依赖..."
            if (Test-Path $this.DependenciesExtractPath) {
                Remove-Item -Path $this.DependenciesExtractPath -Recurse -Force -ErrorAction SilentlyContinue
            }
            Expand-Archive -Path $this.DependenciesZipPath -DestinationPath $this.DependenciesExtractPath -Force
        }
    }

    [string[]] GetDependencyPaths() {
        # 获取当前系统架构
        $currentArch = $env:PROCESSOR_ARCHITECTURE.ToLower()
        if ($currentArch -eq "amd64") { $currentArch = "x64" }
        
        Write-Host "系统架构检测为: $currentArch。正在过滤匹配的依赖文件..." -ForegroundColor Cyan

        # 获取所有解压出的依赖文件
        $allFiles = Get-ChildItem -Path $this.DependenciesExtractPath -Recurse -Include "*.msix", "*.appx" -ErrorAction SilentlyContinue
        
        # 过滤逻辑：
        # 1. 匹配当前架构 (x64/arm64) 或 neutral (架构无关)
        # 2. 必须排除掉其他明确不匹配的字符（解决 0x80073D10 报错的核心）
        $filtered = $allFiles | Where-Object {
            $fileName = $_.Name.ToLower()
            $isMatch = ($fileName -like "*$currentArch*") -or ($fileName -like "*neutral*")
            
            # 如果是 x64 系统，强制排除含有 arm 的包
            if ($currentArch -eq "x64") {
                $isMatch = $isMatch -and ($fileName -notlike "*arm*")
            }
            # 如果是 arm64 系统，强制排除含有 x86/x64 的包（视情况而定，通常 arm64 可运行 x86，但建议精准匹配）
            if ($currentArch -eq "arm64") {
                $isMatch = $isMatch -and ($fileName -notlike "*x86*") -and ($fileName -notlike "*x64*")
            }
            
            return $isMatch
        }

        $paths = $filtered | Select-Object -ExpandProperty FullName
        foreach ($p in $paths) {
            Write-Host "  + 待安装依赖: $(Split-Path $p -Leaf)" -ForegroundColor Gray
        }
        return $paths
    }

    [void] Install() {
        Write-Host "正在开始安装/升级 winget..." -ForegroundColor Cyan
        
        $depPaths = @()
        if ($this.DependenciesZipUrl -and (Test-Path $this.DependenciesExtractPath)) {
            $depPaths = $this.GetDependencyPaths()
        }

        try {
            if ($depPaths.Count -gt 0) {
                Write-Host "正在安装主包及其 $($depPaths.Count) 个兼容依赖..." -ForegroundColor Green
                Add-AppxPackage -Path $this.InstallerPath -DependencyPath $depPaths -ForceApplicationShutdown -ForceUpdateFromAnyVersion
            } else {
                Write-Host "正在安装主包 (未发现额外依赖)..."
                Add-AppxPackage -Path $this.InstallerPath -ForceApplicationShutdown -ForceUpdateFromAnyVersion
            }
        } catch {
            Write-Host "安装失败！详细错误信息:" -ForegroundColor Red
            Write-Host $_.Exception.Message
            throw
        }
        
        Write-Host "Winget 安装/升级成功！" -ForegroundColor Green
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Start-Sleep -Seconds 2
        
        # 验证
        $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
        if (Test-Path $wingetPath) {
            Write-Host "✓ Winget 可执行文件位于: $wingetPath"
            try {
                $v = & $wingetPath --version
                Write-Host "✓ 运行测试成功，当前版本: $v" -ForegroundColor Green
            } catch {}
        }
    }

    [void] Cleanup() {
        Write-Host "清理临时文件中..." -ForegroundColor Gray
        if (Test-Path $this.InstallerPath) { Remove-Item $this.InstallerPath -Force }
        if (Test-Path $this.DependenciesZipPath) { Remove-Item $this.DependenciesZipPath -Force }
        if (Test-Path $this.DependenciesExtractPath) { Remove-Item $this.DependenciesExtractPath -Recurse -Force }
    }

    [void] Run() {
        try {
            $this.GetDownloadUrls()
            $this.DownloadInstaller()
            $this.Install()
        }
        finally {
            $this.Cleanup()
        }
    }
}

# 执行
$installer = [WingetInstaller]::new()
$installer.Run()