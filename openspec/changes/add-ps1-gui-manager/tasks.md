## 1. Project Setup
- [x] 1.1 Create `scripts/` directory for PS1 scripts
- [x] 1.2 Move `install-winget.ps1` to `scripts/` directory
- [x] 1.3 Initialize Go module if not exists
- [x] 1.4 Add Fyne dependency (`fyne.io/fyne/v2`)
- [x] 1.5 Create directory structure for GUI application (`cmd/ps1-gui-manager/`)
- [x] 1.6 Set up build configuration (Makefile or build script)

## 2. Core Functionality
- [x] 2.1 Implement Go embed directive to embed `scripts/*.ps1` files
- [x] 2.2 Implement PS1 script discovery from embedded resources (read from `embed.FS`)
- [x] 2.3 Parse script metadata (name, description from comments)
- [x] 2.4 Create GUI window with Fyne
- [x] 2.5 Implement script list widget (List or Table)
- [x] 2.6 Add execute button and selection handling

## 3. Script Execution
- [x] 3.1 Extract embedded script to temporary file (or pass via stdin)
- [x] 3.2 Implement PowerShell execution wrapper
- [x] 3.3 Capture stdout/stderr streams
- [x] 3.4 Handle process lifecycle (start, monitor, cleanup)
- [x] 3.5 Clean up temporary files after execution
- [x] 3.6 Implement error handling for execution failures

## 4. Log Display
- [x] 4.1 Create scrollable text widget for logs
- [x] 4.2 Implement real-time log streaming to UI
- [x] 4.3 Add log formatting (timestamps, error highlighting) - Basic error prefixing implemented
- [x] 4.4 Add clear log button

## 5. UI/UX Polish
- [ ] 5.1 Add application icon (optional enhancement)
- [x] 5.2 Implement window sizing and layout
- [x] 5.3 Add status indicators (executing, success, error)
- [x] 5.4 Add script description display
- [x] 5.5 Implement proper error messages

## 6. Testing & Validation
- [ ] 6.1 Test embedded script loading from compiled binary
- [ ] 6.2 Test with `scripts/install-winget.ps1` script (embedded)
- [ ] 6.3 Verify scripts are embedded correctly in binary
- [ ] 6.4 Test script discovery from embedded resources
- [ ] 6.5 Test error handling (invalid scripts, PowerShell not found, no embedded scripts)
- [ ] 6.6 Test log display with long-running scripts
- [ ] 6.7 Verify self-contained executable works without external script files
- [ ] 6.8 Test temporary file cleanup after execution
- [ ] 6.9 Verify cross-platform compatibility (if applicable)

## 7. Documentation
- [x] 7.1 Add README section for GUI tool
- [x] 7.2 Document build instructions
- [x] 7.3 Add usage examples
