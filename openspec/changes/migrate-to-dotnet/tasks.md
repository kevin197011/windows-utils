## 1. Project Setup
- [x] 1.1 Create .NET solution and AvaloniaUI project structure
- [x] 1.2 Install AvaloniaUI NuGet packages (configured in .csproj)
- [x] 1.3 Configure project for self-contained deployment
- [x] 1.4 Set up embedded resources for PowerShell scripts
- [x] 1.5 Configure build settings and output

## 2. Core Application Structure
- [x] 2.1 Create main window (MainWindow.axaml)
- [x] 2.2 Implement application entry point (App.axaml.cs, Program.cs)
- [x] 2.3 Set up MVVM structure (using MVVM pattern with ReactiveUI)
- [x] 2.4 Configure application metadata and settings
- [x] 2.5 Set up AvaloniaUI application lifecycle

## 3. Script Management
- [x] 3.1 Implement embedded resource loading for scripts
- [x] 3.2 Create script discovery mechanism
- [x] 3.3 Implement script metadata parsing (description extraction)
- [x] 3.4 Create Script model class

## 4. UI Components
- [x] 4.1 Create script list view (ListBox in AvaloniaUI)
- [x] 4.2 Implement log output area (TextBox in AvaloniaUI)
- [x] 4.3 Create execute and clear buttons (Button controls)
- [x] 4.4 Add status label and description display
- [x] 4.5 Implement window layout (Grid for split view)

## 5. Script Execution
- [x] 5.1 Implement PowerShell execution wrapper
- [x] 5.2 Create process management for script execution
- [x] 5.3 Implement real-time output streaming
- [x] 5.4 Add error handling and status updates
- [x] 5.5 Configure hidden console window

## 6. Visual Design
- [x] 6.1 Implement dark theme (geek style)
- [x] 6.2 Configure color scheme (dark backgrounds, green/cyan accents)
- [x] 6.3 Set monospace fonts for script list and logs
- [x] 6.4 Add color-coded status indicators
- [x] 6.5 Style buttons and UI elements

## 7. Application Features
- [x] 7.1 Implement single-instance application (Mutex)
- [x] 7.2 Add window management (center, focus, show)
- [ ] 7.3 Implement logging to file (optional enhancement)
- [ ] 7.4 Add error dialogs and user feedback (basic error handling implemented)

## 8. Build and Deployment
- [x] 8.1 Update GitHub Actions workflow for .NET build
- [x] 8.2 Configure self-contained publish settings
- [ ] 8.3 Test build process and output (requires .NET SDK on Windows)
- [x] 8.4 Update Makefile/build scripts

## 9. Testing & Validation
- [ ] 9.1 Test on Windows Server 2019
- [ ] 9.2 Test on Windows Server 2022
- [ ] 9.3 Test on Windows 10/11
- [ ] 9.4 Verify all scripts execute correctly
- [ ] 9.5 Test window visibility and display
- [ ] 9.6 Verify single-instance behavior

## 10. Documentation and Cleanup
- [ ] 10.1 Update README with .NET requirements
- [ ] 10.2 Update build instructions
- [ ] 10.3 Document .NET version requirements
- [ ] 10.4 Remove or archive Go implementation (optional)
