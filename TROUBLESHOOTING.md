# 故障排除指南

## Windows Server 2019 上无法显示界面

### 问题诊断

如果程序在 Windows Server 2019 上运行没有反应，请按以下步骤检查：

1. **检查日志文件**
   - 程序会在运行目录创建 `ps1-gui-manager.log` 文件
   - 查看日志文件了解程序启动到哪一步
   - 日志会记录所有关键步骤和错误信息

2. **检查桌面体验**
   - Windows Server 需要安装"桌面体验"功能才能运行 GUI 应用
   - 检查方法：
     ```powershell
     Get-WindowsFeature Server-Gui-Mgmt-Infra, Server-Gui-Shell
     ```
   - 如果未安装，需要安装：
     ```powershell
     Install-WindowsFeature Server-Gui-Mgmt-Infra, Server-Gui-Shell -Restart
     ```

3. **检查服务器模式**
   - Server Core 模式不支持 GUI 应用
   - 需要完整安装模式（Full Installation）

4. **检查远程桌面会话**
   - 如果通过远程桌面连接，确保：
     - 使用 RDP 连接（不是 PowerShell Remoting）
     - 会话类型支持 GUI（不是控制台会话）
     - 已启用远程桌面服务

### 常见错误

#### 错误：窗口无法显示
- **原因**：缺少 GUI 支持
- **解决**：安装桌面体验功能

#### 错误：单实例检查失败
- **原因**：权限问题或系统限制
- **解决**：程序会继续运行，检查日志文件了解详情

#### 错误：脚本加载失败
- **原因**：二进制文件损坏或脚本未正确嵌入
- **解决**：重新编译程序

### 调试步骤

1. **运行程序并检查日志**：
   ```cmd
   ps1-gui-manager.exe
   type ps1-gui-manager.log
   ```

2. **检查进程是否运行**：
   ```powershell
   Get-Process ps1-gui-manager -ErrorAction SilentlyContinue
   ```

3. **检查是否有错误消息框**：
   - 程序可能会显示错误对话框
   - 检查任务栏是否有隐藏的窗口

### 临时解决方案

如果无法安装桌面体验，可以考虑：
- 使用命令行方式执行脚本
- 在本地 Windows 10/11 机器上运行 GUI 工具
- 使用远程桌面连接到有 GUI 支持的服务器
