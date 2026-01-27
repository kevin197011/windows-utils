# GitHub Actions Workflows

## Release Workflow

自动构建 Windows 二进制文件并推送到 GitHub Release。

### 触发方式

1. **推送版本标签**：当推送以 `v` 开头的标签时（如 `v1.0.0`），会自动触发构建和发布
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **手动触发**：在 GitHub Actions 页面可以手动触发 workflow

### 构建产物

- `ps1-gui-manager-x86.exe` - Windows 32位版本
- `ps1-gui-manager-x64.exe` - Windows 64位版本

### 使用说明

1. 创建并推送版本标签：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. GitHub Actions 会自动：
   - 构建 Windows x86 和 x64 二进制文件
   - 创建 GitHub Release
   - 上传二进制文件到 Release

3. 用户可以从 Release 页面下载二进制文件

### 注意事项

- 需要确保仓库有 `GITHUB_TOKEN` 权限（GitHub 自动提供）
- 二进制文件使用 `-ldflags="-s -w"` 进行优化，减小文件大小
- Release 会自动包含版本信息和使用说明
