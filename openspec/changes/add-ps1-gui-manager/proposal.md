# Change: Add PS1 GUI Manager

## Why
Currently, PowerShell scripts in this project must be executed manually via command line. A GUI tool would provide a more user-friendly way to discover, select, and execute PS1 scripts with real-time log visibility, making the utilities more accessible to non-technical users.

## What Changes
- Create `scripts/` directory to organize all PowerShell scripts
- Move existing `install-winget.ps1` to `scripts/` directory
- Add a new Go application using Fyne framework for cross-platform GUI
- Embed all `.ps1` scripts from `scripts/` directory into the compiled binary using Go's `embed` package
- Load scripts from embedded resources at runtime (no external script files required)
- Display scripts in a selectable list with script names/descriptions
- Execute selected scripts via PowerShell with real-time log output
- Show execution logs in a scrollable text area within the GUI
- Handle script execution errors gracefully with user feedback

## Impact
- Affected specs: New capability `ps1-gui-manager`
- Affected code: 
  - New Go application in `cmd/ps1-gui-manager/` directory
  - New `scripts/` directory for PS1 scripts
  - Existing `install-winget.ps1` moved to `scripts/`
  - Scripts embedded into binary using Go `embed` package
- New dependencies: Go modules for Fyne GUI framework
- Build artifacts: Single self-contained executable binary for Windows (and potentially cross-platform) with all scripts embedded
- **BREAKING**: Executable is self-contained - no external `scripts/` directory needed at runtime
