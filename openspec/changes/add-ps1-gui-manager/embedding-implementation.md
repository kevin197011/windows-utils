# 脚本嵌入实现说明

## 概述

使用 Go 1.16+ 的 `embed` 包将 PS1 脚本嵌入到编译后的可执行文件中，创建自包含的单文件应用程序。

## 实现方式

### 1. 使用 embed 指令

在 Go 代码中使用 `//go:embed` 指令嵌入脚本目录：

```go
package main

import (
    "embed"
    "io/fs"
)

//go:embed scripts/*.ps1
var scriptFS embed.FS
```

### 2. 访问嵌入的文件

使用 `embed.FS` 读取嵌入的脚本：

```go
import (
    "embed"
    "io/fs"
    "path/filepath"
)

//go:embed scripts/*.ps1
var scriptFS embed.FS

func loadScripts() ([]Script, error) {
    var scripts []Script
    
    // 遍历嵌入的文件系统
    err := fs.WalkDir(scriptFS, "scripts", func(path string, d fs.DirEntry, err error) error {
        if err != nil {
            return err
        }
        
        if !d.IsDir() && filepath.Ext(path) == ".ps1" {
            // 读取脚本内容
            content, err := scriptFS.ReadFile(path)
            if err != nil {
                return err
            }
            
            scripts = append(scripts, Script{
                Name:    filepath.Base(path),
                Path:    path,
                Content: string(content),
            })
        }
        return nil
    })
    
    return scripts, err
}
```

### 3. 执行脚本

由于 PowerShell 需要文件路径，有两种方式执行嵌入的脚本：

#### 方式 A: 临时文件（推荐）

```go
import (
    "io/ioutil"
    "os"
    "path/filepath"
)

func executeScript(scriptContent string) error {
    // 创建临时文件
    tmpFile, err := ioutil.TempFile("", "script-*.ps1")
    if err != nil {
        return err
    }
    defer os.Remove(tmpFile.Name()) // 清理临时文件
    
    // 写入脚本内容
    if _, err := tmpFile.WriteString(scriptContent); err != nil {
        return err
    }
    tmpFile.Close()
    
    // 执行 PowerShell
    cmd := exec.Command("powershell.exe", "-ExecutionPolicy", "Bypass", "-File", tmpFile.Name())
    // ... 设置输出流等
    
    return cmd.Run()
}
```

#### 方式 B: 通过 stdin（如果 PowerShell 支持）

```go
func executeScript(scriptContent string) error {
    cmd := exec.Command("powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", "-")
    cmd.Stdin = strings.NewReader(scriptContent)
    // ... 设置输出流等
    
    return cmd.Run()
}
```

## 目录结构

```
windows-utils/
├── scripts/                    # 源代码中的脚本目录
│   ├── install-winget.ps1
│   └── [其他脚本].ps1
│
├── cmd/
│   └── ps1-gui-manager/
│       └── main.go            # 包含 //go:embed scripts/*.ps1
│
└── [编译后的可执行文件]        # 包含所有嵌入的脚本
```

## 构建说明

### 编译时

```bash
# 确保 scripts/ 目录存在且包含 .ps1 文件
go build -o ps1-gui-manager.exe ./cmd/ps1-gui-manager
```

### 运行时

编译后的可执行文件是自包含的：
- ✅ 不需要 `scripts/` 目录
- ✅ 不需要外部脚本文件
- ✅ 单文件分发

## 优势

1. **自包含**: 单个可执行文件包含所有脚本
2. **简化分发**: 无需管理多个文件
3. **版本一致**: 脚本版本与可执行文件版本绑定
4. **安全性**: 脚本内容在编译时确定，运行时不可修改

## 注意事项

1. **Go 版本要求**: 需要 Go 1.16 或更高版本
2. **文件大小**: 嵌入脚本会增加可执行文件大小
3. **临时文件**: 执行时需要创建临时文件（或使用 stdin）
4. **路径**: embed 路径相对于包含 `//go:embed` 指令的 Go 文件

## 示例代码结构

```go
package main

import (
    "embed"
    "fmt"
    "io/fs"
    "path/filepath"
)

//go:embed scripts/*.ps1
var scriptFS embed.FS

type Script struct {
    Name    string
    Path    string
    Content string
}

func main() {
    scripts, err := loadScripts()
    if err != nil {
        panic(err)
    }
    
    for _, script := range scripts {
        fmt.Printf("Found script: %s\n", script.Name)
    }
}

func loadScripts() ([]Script, error) {
    var scripts []Script
    
    err := fs.WalkDir(scriptFS, "scripts", func(path string, d fs.DirEntry, err error) error {
        if err != nil {
            return err
        }
        
        if !d.IsDir() && filepath.Ext(path) == ".ps1" {
            content, err := scriptFS.ReadFile(path)
            if err != nil {
                return err
            }
            
            scripts = append(scripts, Script{
                Name:    filepath.Base(path),
                Path:    path,
                Content: string(content),
            })
        }
        return nil
    })
    
    return scripts, err
}
```
