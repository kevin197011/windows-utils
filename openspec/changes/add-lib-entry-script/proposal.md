# Change: Install scripts under lib/ and entry script for sequential run

## Why

Users want a single one-liner to run all install scripts in order (e.g. on a fresh machine), and a clear layout: all install scripts live under `lib/`, with one entry script at repo root that runs them sequentially using the same remote-exec pattern as individual scripts (`irm <url> | iex`).

## What Changes

- All install scripts SHALL live under `lib/` (already the case; document as requirement).
- Add one entry script at repository root that runs each script in `lib/` in a fixed order, each via `irm https://raw.githubusercontent.com/kevin197011/windows-utils/main/lib/<script>.ps1 | iex`.
- Document the entry script one-liner in README (optional follow-up).

## Impact

- Affected specs: new capability `install-scripts`.
- Affected code: new file at repo root (e.g. `install-all.ps1` or `run-installs.ps1`); README may be updated to mention the entry script.
