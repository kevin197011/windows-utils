# Tasks: add-lib-entry-script

## 1. Layout and convention

- [x] 1.1 Confirm all install scripts are under `lib/` (install-winget.ps1, install-chrome.ps1, install-bandizip.ps1, install-snipaste.ps1). Move any that are elsewhere.

## 2. Entry script

- [x] 2.1 Add entry script at repo root (e.g. `install-all.ps1`) that runs each `lib/*.ps1` script in a defined order (e.g. winget, then chrome, bandizip, snipaste).
- [x] 2.2 Each script SHALL be invoked via `irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/<name>.ps1 | iex` (same pattern as per-script remote exec).
- [x] 2.3 Entry script SHALL run scripts sequentially; failure of one MAY stop the run (design choice: fail-fast or continue—spec leaves room; task: implement and document in script comment).

## 3. Documentation

- [x] 3.1 Document in README the one-liner to run the entry script (e.g. `irm .../install-all.ps1 | iex`).

## 4. Validation

- [x] 4.1 Manually verify: run entry script in PowerShell and confirm each lib script is invoked in order (dry run or real run as appropriate).
