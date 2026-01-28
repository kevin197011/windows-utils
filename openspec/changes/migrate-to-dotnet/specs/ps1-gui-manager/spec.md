## MODIFIED Requirements

### Requirement: PS1 Script Discovery
The GUI application SHALL automatically discover and load all `.ps1` files from embedded resources at startup. Scripts are embedded into the compiled .NET assembly using embedded resources and loaded at runtime.

#### Scenario: Application startup discovers embedded scripts
- **WHEN** the GUI application starts
- **THEN** it reads all `.ps1` files from embedded resources in the .NET assembly
- **AND** loads all discovered scripts into the application's script list
- **AND** scripts are accessed from embedded resources, not from external filesystem

#### Scenario: No scripts found
- **WHEN** the application starts and no embedded `.ps1` files are found
- **THEN** the script list is empty
- **AND** a message is displayed indicating no scripts are available

#### Scenario: Scripts are self-contained
- **WHEN** the application is distributed as a compiled .NET executable
- **THEN** all scripts are embedded within the assembly
- **AND** no external `scripts/` directory is required at runtime
- **AND** the application works as a single, self-contained executable

### Requirement: Script List Display
The GUI application SHALL display discovered scripts in a selectable list with script names visible to the user, using a dark theme with monospace fonts and geek-style visual design.

#### Scenario: Script list shows available scripts with geek styling
- **WHEN** scripts are discovered
- **THEN** each script appears as an item in a list control (ListBox/ListView)
- **AND** the script filename (without extension) is displayed using monospace font
- **AND** the list uses dark background with light text
- **AND** users can select a script by clicking on it

#### Scenario: Script selection highlights item with accent color
- **WHEN** a user clicks on a script in the list
- **THEN** the selected script is visually highlighted with a geek-style accent color (green or cyan)
- **AND** the script becomes the target for execution
- **AND** hover effects provide visual feedback

### Requirement: Script Execution
The GUI application SHALL execute the selected PowerShell script when the user triggers execution, with improved Windows Server compatibility.

#### Scenario: Execute selected script
- **WHEN** a script is selected
- **AND** the user clicks an "Execute" or "Run" button
- **THEN** the application extracts the script content from embedded resources
- **AND** launches PowerShell to execute the script (via temporary file)
- **AND** the execution runs with appropriate PowerShell flags (e.g., `-ExecutionPolicy Bypass -WindowStyle Hidden`)
- **AND** the console window is hidden during execution

#### Scenario: Execution state indication
- **WHEN** a script execution is in progress
- **THEN** the UI indicates the executing state (e.g., button disabled, status text)
- **AND** the execute button text may change to "Executing..." or similar

#### Scenario: Execution completion
- **WHEN** script execution completes (successfully or with error)
- **THEN** the execution state indicator returns to normal
- **AND** the execute button becomes enabled again

### Requirement: Real-time Log Display
The GUI application SHALL display script execution output (stdout and stderr) in real-time within a scrollable log area styled to resemble a terminal/console, with reliable rendering on Windows Server.

#### Scenario: Logs appear during execution with terminal styling
- **WHEN** a script is executing
- **THEN** stdout and stderr output from the script appear in a text control
- **AND** the log area uses dark background (terminal-like) with monospace font
- **AND** new log lines are appended as they are received in real-time
- **AND** the log area automatically scrolls to show the latest output
- **AND** error lines may be displayed with red text color

#### Scenario: Log area has terminal appearance
- **WHEN** the application displays the log area
- **THEN** it resembles a terminal/console window
- **AND** uses monospace font for all text
- **AND** uses dark background with light text
- **AND** maintains terminal-like aesthetic
- **AND** renders correctly on Windows Server environments

### Requirement: Error Handling
The GUI application SHALL handle execution errors gracefully and display clear error messages to the user, with improved reliability on Windows Server.

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
- **AND** the script is written to a temporary file
- **AND** temporary files are cleaned up after execution completes

### Requirement: Application Theme
The GUI application SHALL use a dark, geek-style theme throughout the interface, with reliable rendering on Windows Server.

#### Scenario: Dark theme applied globally
- **WHEN** the application starts
- **THEN** all UI elements use dark background colors
- **AND** text uses light colors for contrast
- **AND** accent colors (green/cyan) are used for highlights and active states
- **AND** the overall appearance is consistent with terminal/developer tool aesthetics
- **AND** theme renders correctly on Windows Server environments

#### Scenario: Monospace fonts for technical content
- **WHEN** script names are displayed
- **THEN** they use monospace font
- **WHEN** log output is displayed
- **THEN** it uses monospace font
- **AND** monospace fonts create a code/terminal aesthetic

### Requirement: Window Management
The GUI application SHALL properly display and manage the application window on Windows Server environments.

#### Scenario: Window displays correctly on Windows Server
- **WHEN** the application starts on Windows Server
- **THEN** the window is visible and properly displayed
- **AND** the window appears in the foreground
- **AND** the window can be interacted with normally
- **AND** window rendering is reliable without workarounds

#### Scenario: Single instance enforcement
- **WHEN** a user attempts to launch a second instance
- **THEN** the application detects the existing instance
- **AND** shows a message indicating another instance is running
- **AND** exits without creating a duplicate window
