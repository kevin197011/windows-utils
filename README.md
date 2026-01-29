# windows-utils

Windows utility scripts and tools: install scripts in `lib/`, run via one-liner.

## Scripts in `lib/`

| Script | Description |
|--------|-------------|
| `install-winget.ps1` | Install or upgrade winget (Windows Package Manager) from GitHub release |
| `install-chrome.ps1` | Install or upgrade Google Chrome from official installer |
| `install-bandizip.ps1` | Install or upgrade Bandizip from official installer |
| `install-snipaste.ps1` | Install or upgrade Snipaste (portable) to `%LOCALAPPDATA%\Snipaste` |

All scripts support remote execution: `irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/<script>.ps1 | iex`

## Install all (one-liner)

Run every install script in order (winget → Chrome → Bandizip → Snipaste):

```powershell
irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex
```

Run a single script, e.g. winget only:

```powershell
irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-winget.ps1 | iex
```

## License

This software is released under the MIT License.
See [LICENSE](LICENSE) for details.
