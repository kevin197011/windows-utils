# PS1 GUI Manager (.NET/AvaloniaUI)

.NET Core application using AvaloniaUI for managing and executing PowerShell scripts.

## Building

### Prerequisites

- .NET 8 SDK or later
- Windows (for building Windows executable)

### Build Commands

```bash
# Restore packages
dotnet restore

# Build
dotnet build --configuration Release

# Publish self-contained executable
dotnet publish --configuration Release --runtime win-x64 --self-contained true -p:PublishSingleFile=true

# Output will be in: bin/Release/net8.0-windows/win-x64/publish/Ps1GuiManager.exe
```

## Project Structure

- `Models/` - Data models (Script)
- `ViewModels/` - MVVM view models
- `Views/` - XAML views (MainWindow)
- `Services/` - Business logic (ScriptLoader, PowerShellExecutor, SingleInstanceManager)
- `Themes/` - Custom theme styles
- `Scripts/` - PowerShell scripts (embedded as resources)

## Features

- Embedded PowerShell scripts (no external files needed)
- Real-time log display
- Geek-style dark theme
- Single-instance application
- Hidden console window for script execution
