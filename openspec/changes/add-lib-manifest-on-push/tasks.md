# Tasks: add-lib-manifest-on-push

## 1. Manifest generator

- [x] 1.1 Add a Rake task (e.g. `lib:manifest` or `manifest:lib`) that lists files under `lib/` (e.g. `lib/*.ps1` or all non-dir entries), builds a JSON structure (e.g. `{ "files": ["install-winget.ps1", ...] }` with sorted names), and writes to `meta/lib-manifest.json`. Create `meta/` if it does not exist.

## 2. Wire into push

- [x] 2.1 In Rakefile `:push` task, invoke the manifest task before `git:auto_commit_push` so the generated file is included in the same commit/push.

## 3. Consistency

- [x] 3.1 Ensure output path and JSON shape match design.md (e.g. `meta/lib-manifest.json`, stable sort). Do not add `meta/lib-manifest.json` to .gitignore so the file is committed.

## 4. Validation

- [x] 4.1 Run the manifest task locally and confirm `meta/lib-manifest.json` is created and contains the expected list. Run `rake push` (or equivalent) and confirm the manifest is generated and committed before push.
