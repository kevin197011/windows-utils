# Change: Generate lib/ file manifest JSON before push

## Why

Before each push (e.g. `rake push`), the project should produce a machine-readable manifest of install scripts under `lib/`. That manifest (JSON) is written to a designated directory so tooling, CI, or docs can rely on an up-to-date list without scanning the filesystem.

## What Changes

- Add a build step that generates a JSON file listing the contents of `lib/` (e.g. filenames or minimal metadata).
- Write the manifest to a fixed path under a dedicated directory (e.g. `meta/lib-manifest.json`).
- In the Rakefile `:push` task, run this generator **before** `git:auto_commit_push` so the manifest is committed with the same push.
- All install scripts remain under `lib/` (unchanged; consistent with existing install-scripts spec).

## Impact

- Affected specs: new capability `lib-manifest`.
- Affected code: Rakefile (invoke manifest task before auto_commit_push); new generator (e.g. Rake task or small Ruby script); output file in chosen directory (e.g. `meta/lib-manifest.json`). Whether `meta/` or the file is committed is a project choice (proposal assumes manifest is committed so it is versioned and available in the repo).
