## Context
The project contains PowerShell scripts (`.ps1` files) that users currently execute manually via command line. A GUI tool will make these utilities more accessible and provide better visibility into execution progress and logs.

## Goals / Non-Goals

### Goals
- Provide a simple, intuitive GUI for discovering and executing PS1 scripts
- Display real-time execution logs within the application
- Automatically discover scripts without manual configuration
- Handle errors gracefully with clear user feedback
- Keep the implementation simple and maintainable

### Non-Goals
- Script editing capabilities (read-only execution)
- Script parameter configuration UI (execute with defaults)
- Multi-script execution queue
- Script scheduling or automation
- Remote script execution
- Script validation or linting

## Decisions

### Decision: Use Fyne for GUI Framework
**Rationale**: Fyne is a modern, cross-platform GUI framework for Go that provides native look-and-feel on Windows. It's actively maintained, has good documentation, and supports the required widgets (lists, text areas, buttons).

**Alternatives considered**:
- **Walk (Windows-only)**: Native Windows look but platform-specific
- **Wails**: Web-based UI, more complex for simple use case
- **Qt bindings**: Heavier dependency, more complex setup

### Decision: Organize scripts in dedicated `scripts/` directory and embed into binary
**Rationale**: Centralizing scripts in a dedicated directory improves project organization. Using Go's `embed` package (Go 1.16+) to embed scripts into the compiled binary creates a self-contained executable that doesn't require external script files at runtime. This simplifies distribution and deployment.

**Alternatives considered**:
- **Project root**: Scripts mixed with other files, less organized
- **External scripts directory**: Requires distributing both executable and scripts, more complex deployment
- **Configuration file**: Adds complexity, requires maintenance
- **Multiple directories**: More complex scanning logic, not needed for initial version

### Decision: Execute scripts synchronously with streaming output
**Rationale**: Real-time log display requires streaming stdout/stderr. Synchronous execution provides clear execution state and prevents concurrent script conflicts.

**Alternatives considered**:
- **Asynchronous execution**: More complex state management, potential race conditions
- **Buffered output**: Delayed log visibility, less responsive UX

### Decision: Parse script metadata from comments
**Rationale**: Scripts already contain header comments with copyright/license. Extracting name/description from comments is lightweight and doesn't require separate metadata files.

**Alternatives considered**:
- **Separate metadata file**: Additional maintenance burden
- **Filename-based naming**: Less descriptive, no additional context

### Decision: Embed scripts using Go `embed` package
**Rationale**: Go 1.16+ provides the `embed` package for embedding files at compile time. This creates a single, self-contained executable that includes all scripts, eliminating the need to distribute script files separately. The embedded files are read-only and accessed via `embed.FS`.

**Implementation approach**:
- Use `//go:embed scripts/*.ps1` directive in Go code
- Access embedded files via `embed.FS` at runtime
- Scripts are loaded from embedded resources, not from filesystem

**Alternatives considered**:
- **External script files**: Requires distributing executable + scripts, more complex
- **Hardcoded strings**: Scripts become part of source code, harder to maintain
- **Build-time file copying**: More complex build process, less standard

## Risks / Trade-offs

### Risk: PowerShell execution policy restrictions
**Mitigation**: Document execution policy requirements, provide clear error messages if blocked, suggest `-ExecutionPolicy Bypass` flag usage.

### Risk: Long-running scripts blocking UI
**Mitigation**: Execute in goroutine with proper channel communication for log streaming. Consider timeout mechanism for future enhancement.

### Risk: Cross-platform compatibility
**Mitigation**: Focus on Windows initially (primary use case). Fyne supports cross-platform, but PowerShell execution is Windows-specific. Document platform limitations.

### Trade-off: Simplicity vs Features
**Decision**: Prioritize simplicity. Start with basic execution and log display. Advanced features (parameter input, script editing) can be added later if needed.

## Migration Plan
N/A - This is a new addition, not a migration.

## Open Questions
- Should the tool support script parameters/arguments? (Deferred to future enhancement)
- Should there be a way to refresh the script list without restarting? (Consider adding refresh button)
- Should execution history be persisted? (Not in initial version)
