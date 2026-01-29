# Design: lib manifest generation

## Context

- Install scripts live under `lib/`. Before push we want a JSON manifest of those files.
- Rake `:push` currently only runs `git:auto_commit_push`. We need a step that runs before that and writes the manifest.

## Goals / Non-Goals

- **Goals:** Generate a single JSON file listing lib contents; run automatically before push; write to a stable path in a dedicated directory.
- **Non-Goals:** No change to script contents or to where scripts live; no dependency on external services.

## Decisions

- **Output path:** Write to `meta/lib-manifest.json`. Directory `meta/` holds generated or metadata artifacts. If `meta/` does not exist, create it when generating.
- **JSON shape:** Minimal: an array of script filenames (e.g. `["install-winget.ps1", "install-chrome.ps1", ...]`) or an object with a key (e.g. `{ "files": [...] }`) so the format is extensible. Prefer a stable sort (e.g. alphabetical) so the file does not churn unnecessarily.
- **Implementation:** A Rake task (e.g. `lib:manifest` or `manifest:lib`) that (1) lists files in `lib/` (e.g. `Dir['lib/*.ps1']` or `Dir['lib/*']`), (2) builds the JSON structure, (3) writes to `meta/lib-manifest.json`. The `:push` task invokes this task before `Rake::Task['git:auto_commit_push'].invoke`.
- **Version control:** Commit `meta/lib-manifest.json` so the manifest is part of the repo (no .gitignore for this file).

## Risks / Trade-offs

- **Stale manifest:** If someone adds/removes a file in `lib/` but does not run the generator, the manifest can be stale. Mitigation: run the generator as part of `:push` so normal workflow keeps it updated; optional CI check that manifest matches `lib/` can be added later.

## Migration Plan

- Add the Rake task and output directory/file. No migration of existing data. If `meta/` is new, ensure it is created by the task and add `meta/lib-manifest.json` to the first commit that includes this change.
