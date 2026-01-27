# windows-utils

Windows utility scripts and tools.

## PS1 Script Manager (GUI)

A graphical user interface tool for managing and executing PowerShell scripts.

### Features

- **Automatic Script Discovery**: Automatically discovers and loads all `.ps1` scripts from embedded resources
- **Script List**: Displays all available scripts in a selectable list
- **Real-time Log Display**: Shows script execution output in real-time with scrollable log area
- **Self-contained**: All scripts are embedded in the executable - no external files needed
- **Error Handling**: Graceful error handling with clear user feedback
- **Geek-style UI**: Dark theme with terminal-inspired design, monospace fonts, and color-coded status indicators

### Building

#### Prerequisites

- Go 1.16 or higher
- Fyne GUI framework (automatically installed via `go mod`)

#### Build Commands

```bash
# Build for current platform
make build

# Build for Windows (from any platform)
make build-windows

# Run directly (development)
make run

# Clean build artifacts
make clean
```

Or use Go directly:

```bash
# Build
go build -o ps1-gui-manager ./cmd/ps1-gui-manager

# Run
go run ./cmd/ps1-gui-manager
```

### Usage

1. Launch the application: `./ps1-gui-manager` (or `ps1-gui-manager.exe` on Windows)
2. Select a script from the list on the left
3. View the script description (if available)
4. Click "Execute" to run the selected script
5. Monitor execution progress in the log area
6. Review execution results

### Script Organization

Scripts are stored in the `scripts/` directory and automatically embedded into the binary during compilation. To add new scripts:

1. Add your `.ps1` file to the `scripts/` directory
2. Rebuild the application
3. The new script will appear in the GUI automatically

### Script Format

Scripts should follow this format for best compatibility:

```powershell
# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Description: Brief description of what the script does

# Error handling
$ErrorActionPreference = 'Stop'

# Your script code here
```

The description line (starting with `# Description:`) will be automatically extracted and displayed in the GUI.

### Requirements

- Windows (PowerShell execution is Windows-specific)
- PowerShell installed and available in PATH

## PowerShell Scripts

### install-winget.ps1

Installs the latest version of winget (Windows Package Manager) from GitHub releases.

**Usage:**
```powershell
.\scripts\install-winget.ps1
```

Or via remote execution:
```powershell
irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/scripts/install-winget.ps1 | iex
```

## License

This software is released under the MIT License.
See [LICENSE](LICENSE) for details.
