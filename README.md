# windows-utils

Windows utility scripts and tools: install scripts in `lib/`, run via one-liner.

## Scripts in `lib/`

| Script | Description |
|--------|-------------|
| `install-winget.ps1` | Install or upgrade winget (Windows Package Manager) from GitHub release |
| `install-chrome.ps1` | Install or upgrade Google Chrome from official installer |
| `install-bandizip.ps1` | Install or upgrade Bandizip from official installer |
| `install-snipaste.ps1` | Install or upgrade Snipaste (portable) to `%LOCALAPPDATA%\Snipaste` |
| `install-obs.ps1` | Install OBS Studio from official CDN |
| `install-caddy.ps1` | Install or upgrade Caddy Web Server |
| `install-vscode.ps1` | Install or upgrade Visual Studio Code (System Installer) |

## Feature: Skip installed software or force reinstall

By default, all scripts check if software is already installed and skip installation:

```powershell
# Skip already installed software (default behavior)
.\install-all.ps1
.\lib\install-chrome.ps1

# Force reinstall all software (overwrite existing installations)
# Local execution supports -Force parameter
.\install-all.ps1 -Force
.\lib\install-chrome.ps1 -Force
```

## Install all (one-liner)

### Local execution

```powershell
# Default mode: skip already installed software
.\install-all.ps1

# Force mode: reinstall all software
.\install-all.ps1 -Force
```

### Remote execution (irm | iex)

Supports remote execution via `Invoke-RestMethod` (irm) piped to `Invoke-Expression` (iex).

**Note**: For `irm | iex`, argument passing is limited in PowerShell.
- To use `-Force` equivalent, set `$env:FORCE_INSTALL='true'` before running.
- We also support parsing `-Force` from args manually in most scripts if supported by your shell wrapper, but env var is safest.

```powershell
# Default mode: skip already installed software
irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex

# Force mode: reinstall all software (via environment variable)
$env:FORCE_INSTALL='true'; irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex
```

### Run a single script

```powershell
# Remote - default mode
irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-vscode.ps1 | iex

# Remote - force mode
$env:FORCE_INSTALL='true'; irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-vscode.ps1 | iex
```

## License

This software is released under the MIT License.
See [LICENSE](LICENSE) for details.
