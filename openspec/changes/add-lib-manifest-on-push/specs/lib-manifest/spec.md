## ADDED Requirements

### Requirement: Lib manifest generated before push

Before the repository is pushed (e.g. when the Rake `:push` task runs), the project SHALL generate a JSON file that lists the install scripts under `lib/`. The file SHALL be written to a designated directory (e.g. `meta/`) under a fixed filename (e.g. `lib-manifest.json`).

#### Scenario: Manifest exists after push workflow

- **WHEN** the user runs the push workflow (e.g. `rake push`)
- **THEN** a manifest file is generated before the commit/push step, and the generated file is included in that commit

#### Scenario: Manifest is machine-readable

- **WHEN** the manifest file is read
- **THEN** it is valid JSON and contains a list of script names or paths under `lib/` (e.g. an array of filenames or an object with a key such as `files`)

#### Scenario: Manifest path is stable

- **WHEN** the manifest is generated
- **THEN** it is written to the same path every time (e.g. `meta/lib-manifest.json`), so tooling can rely on a fixed location
