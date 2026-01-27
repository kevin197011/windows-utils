## ADDED Requirements

### Requirement: PS1 Script Discovery
The GUI application SHALL automatically discover and load all `.ps1` files from embedded resources at startup. Scripts are embedded into the compiled binary using Go's `embed` package and loaded from embedded filesystem at runtime.

#### Scenario: Application startup discovers embedded scripts
- **WHEN** the GUI application starts
- **THEN** it reads all `.ps1` files from the embedded filesystem (created at compile time)
- **AND** loads all discovered scripts into the application's script list
- **AND** scripts are accessed from embedded resources, not from external filesystem

#### Scenario: No scripts found
- **WHEN** the application starts and no embedded `.ps1` files are found
- **THEN** the script list is empty
- **AND** a message is displayed indicating no scripts are available

#### Scenario: Scripts are self-contained
- **WHEN** the application is distributed as a compiled binary
- **THEN** all scripts are embedded within the executable
- **AND** no external `scripts/` directory is required at runtime
- **AND** the application works as a single, self-contained executable

### Requirement: Script List Display
The GUI application SHALL display discovered scripts in a selectable list with script names visible to the user.

#### Scenario: Script list shows available scripts
- **WHEN** scripts are discovered
- **THEN** each script appears as an item in a list widget
- **AND** the script filename (without extension) is displayed as the list item text
- **AND** users can select a script by clicking on it

#### Scenario: Script selection highlights item
- **WHEN** a user clicks on a script in the list
- **THEN** the selected script is visually highlighted
- **AND** the script becomes the target for execution

### Requirement: Script Execution
The GUI application SHALL execute the selected PowerShell script when the user triggers execution.

#### Scenario: Execute selected script
- **WHEN** a script is selected
- **AND** the user clicks an "Execute" or "Run" button
- **THEN** the application extracts the script content from embedded resources
- **AND** launches PowerShell to execute the script (via temporary file or stdin)
- **AND** the execution runs with appropriate PowerShell flags (e.g., `-ExecutionPolicy Bypass`)

#### Scenario: Execution state indication
- **WHEN** a script execution is in progress
- **THEN** the UI indicates the executing state (e.g., button disabled, status text)
- **AND** the execute button text may change to "Executing..." or similar

#### Scenario: Execution completion
- **WHEN** script execution completes (successfully or with error)
- **THEN** the execution state indicator returns to normal
- **AND** the execute button becomes enabled again

### Requirement: Real-time Log Display
The GUI application SHALL display script execution output (stdout and stderr) in real-time within a scrollable log area.

#### Scenario: Logs appear during execution
- **WHEN** a script is executing
- **THEN** stdout and stderr output from the script appear in a text widget
- **AND** new log lines are appended as they are received
- **AND** the log area automatically scrolls to show the latest output

#### Scenario: Log area is scrollable
- **WHEN** log output exceeds the visible area
- **THEN** a scrollbar appears in the log widget
- **AND** users can scroll to view previous log entries

#### Scenario: Logs persist after execution
- **WHEN** script execution completes
- **THEN** all log output remains visible in the log area
- **AND** users can review the complete execution log

### Requirement: Error Handling
The GUI application SHALL handle execution errors gracefully and display clear error messages to the user.

#### Scenario: PowerShell not found
- **WHEN** the application attempts to execute a script
- **AND** PowerShell is not available on the system
- **THEN** an error message is displayed to the user
- **AND** the error indicates that PowerShell is required

#### Scenario: Script execution failure
- **WHEN** a script execution fails (non-zero exit code or exception)
- **THEN** error output is displayed in the log area
- **AND** the execution state indicates failure
- **AND** the application remains responsive and allows selecting another script

#### Scenario: Invalid script file
- **WHEN** an embedded script cannot be read or contains invalid content
- **THEN** the script is either excluded from the list or marked as invalid
- **AND** an appropriate error indication is shown if execution is attempted

#### Scenario: Script extraction for execution
- **WHEN** a script is selected for execution
- **THEN** the script content is read from embedded resources
- **AND** the script is written to a temporary file or passed to PowerShell via stdin
- **AND** temporary files are cleaned up after execution completes

### Requirement: Script Metadata Display
The GUI application SHALL display script descriptions or metadata when available.

#### Scenario: Script description shown
- **WHEN** a script is selected
- **AND** the script contains metadata (e.g., description in comments)
- **THEN** the description is displayed in a dedicated area or tooltip
- **AND** users can see what the script does before executing
