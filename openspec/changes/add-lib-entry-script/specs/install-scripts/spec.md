## ADDED Requirements

### Requirement: Install scripts under lib/

All install scripts SHALL be located under the `lib/` directory. No install script SHALL live at repository root or under other ad-hoc paths.

#### Scenario: Scripts are under lib/

- **WHEN** a user lists install scripts in the repository
- **THEN** every install script path is under `lib/` (e.g. `lib/install-winget.ps1`, `lib/install-chrome.ps1`)

#### Scenario: Single script can be run via irm

- **WHEN** a user runs `irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/install-winget.ps1 | iex`
- **THEN** that single script executes without requiring winget or other scripts

---

### Requirement: Entry script runs all lib scripts in sequence

An entry script at repository root SHALL run every install script in `lib/` in a fixed order. Each script SHALL be invoked using the same remote-exec pattern: `irm <base>/lib/<script>.ps1 | iex`, where `<base>` is the repository raw URL (e.g. `https://raw.githubusercontent.com/kevin197011/windows-utils/main`).

#### Scenario: One-liner runs full sequence

- **WHEN** a user runs `irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/install-all.ps1 | iex` (or the chosen entry script name)
- **THEN** the entry script runs each `lib/*.ps1` script in order, each via `irm .../lib/<name>.ps1 | iex`

#### Scenario: Order is deterministic

- **WHEN** the entry script runs
- **THEN** the order of script execution is fixed (e.g. winget first, then chrome, bandizip, snipaste), not arbitrary or filesystem-dependent
