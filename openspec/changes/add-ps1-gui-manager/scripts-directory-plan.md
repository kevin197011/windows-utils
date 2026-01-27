# PS1 脚本目录结构规划

## 目录结构

```
windows-utils/
├── scripts/              # PS1 脚本目录
│   ├── install-winget.ps1
│   └── [其他脚本].ps1
├── cmd/                  # Go 应用程序
│   └── ps1-gui-manager/
├── openspec/
└── ...
```

## 目录命名选择

### 推荐：`scripts/`
- **优点**：
  - 通用且清晰，表明这是脚本集合
  - 未来可以扩展支持其他脚本类型（如 `.bat`, `.sh`）
  - 符合常见项目结构约定
- **缺点**：无

### 备选：`ps1/`
- **优点**：明确表示只包含 PowerShell 脚本
- **缺点**：如果未来需要支持其他脚本类型，需要重命名

### 备选：`powershell/` 或 `ps/`
- **优点**：非常明确
- **缺点**：名称较长，不够简洁

## 目录组织建议

### 扁平结构（推荐）
```
scripts/
├── install-winget.ps1
├── install-chocolatey.ps1
├── setup-dev-environment.ps1
└── ...
```
- **优点**：简单直接，GUI 工具扫描容易
- **适用**：脚本数量较少（< 20 个）

### 分类结构（未来扩展）
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
- **优点**：便于组织大量脚本
- **缺点**：GUI 工具需要支持目录遍历
- **适用**：脚本数量较多（> 20 个）或需要分类

## 实施步骤

1. 创建 `scripts/` 目录
2. 移动现有 `install-winget.ps1` 到 `scripts/`
3. 更新 GUI 工具扫描路径为 `scripts/` 目录
4. 更新文档说明脚本位置

## 与 GUI 工具的集成

GUI 工具将从 `scripts/` 目录自动发现脚本：
- 扫描 `scripts/*.ps1`
- 支持扁平结构（初始版本）
- 未来可扩展支持子目录（如果采用分类结构）
