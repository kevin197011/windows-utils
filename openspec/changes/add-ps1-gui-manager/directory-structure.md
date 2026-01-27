# 目录结构规划

## 推荐的项目结构

```
windows-utils/
├── scripts/                          # PS1 脚本目录（新建）
│   ├── install-winget.ps1           # 从根目录移动
│   └── [future-scripts].ps1         # 未来添加的脚本
│
├── cmd/                              # Go 应用程序目录（新建）
│   └── ps1-gui-manager/             # GUI 工具
│       ├── main.go
│       ├── gui.go
│       ├── script_discovery.go
│       └── execution.go
│
├── openspec/                         # OpenSpec 规范
│   ├── project.md
│   ├── AGENTS.md
│   └── changes/
│       └── add-ps1-gui-manager/
│
├── .gitignore
├── LICENSE
├── README.md
├── Rakefile
├── push.rb
└── [其他项目文件]
```

## 目录说明

### `scripts/` 目录
- **用途**：集中存放所有 PowerShell 脚本
- **命名**：使用 `scripts/` 而非 `ps1/`，便于未来扩展支持其他脚本类型
- **结构**：扁平结构（初始版本），所有 `.ps1` 文件直接放在此目录下
- **扫描规则**：GUI 工具扫描 `scripts/*.ps1`

### `cmd/ps1-gui-manager/` 目录
- **用途**：GUI 应用程序源代码
- **结构**：遵循 Go 项目标准布局
- **模块**：
  - `main.go` - 应用程序入口
  - `gui.go` - Fyne GUI 界面代码
  - `script_discovery.go` - 脚本发现逻辑
  - `execution.go` - PowerShell 执行逻辑

## 迁移计划

1. **创建目录**：`mkdir scripts`
2. **移动脚本**：`mv install-winget.ps1 scripts/`
3. **更新引用**：更新 README 和文档中的脚本路径
4. **验证**：确保脚本在 `scripts/` 目录中正常工作

## 未来扩展

如果脚本数量增加，可以考虑分类结构：

```
scripts/
├── installers/
│   ├── install-winget.ps1
│   └── install-chocolatey.ps1
├── setup/
│   └── setup-dev-environment.ps1
└── utils/
    └── ...
```

GUI 工具可以扩展支持递归扫描子目录。
