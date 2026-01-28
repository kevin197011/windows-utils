# Change: Migrate PS1 GUI Manager from Go/Fyne to .NET Core

## Why
The current Go/Fyne implementation has compatibility issues on Windows Server environments, particularly with GUI display and window management. .NET Core provides better native Windows integration, more reliable GUI rendering on Windows Server, and better compatibility with Windows-specific features. Additionally, .NET Core applications are more commonly used in Windows enterprise environments and have better support for Windows Server scenarios.

## What Changes
- Replace Go/Fyne implementation with .NET Core (C#) application
- Use AvaloniaUI framework for cross-platform GUI with better Windows Server compatibility
- Maintain all existing functionality (script discovery, execution, log display)
- Keep the same geek-style dark theme and visual design
- Preserve script embedding mechanism (using .NET embedded resources)
- Maintain single-instance application behavior
- Keep PowerShell script execution with hidden console window
- Update build process and GitHub Actions workflow for .NET Core
- **BREAKING**: Remove Go implementation, replace with .NET Core

## Impact
- Affected specs: Modify existing `ps1-gui-manager` capability
- Affected code: 
  - Remove `cmd/ps1-gui-manager/` Go implementation
  - Add new `src/Ps1GuiManager/` .NET Core project
  - Update build configuration (replace Go build with .NET build)
  - Update GitHub Actions workflow for .NET Core
- New dependencies: .NET SDK, AvaloniaUI framework
- Build artifacts: .NET executable (self-contained or framework-dependent)
- **BREAKING**: Different runtime requirements (.NET Runtime vs Go binary)
