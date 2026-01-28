## Context
The current Go/Fyne implementation works on desktop Windows but has issues on Windows Server environments:
- Window visibility problems
- GUI rendering issues
- Compatibility problems with server configurations
- Requires complex workarounds for Windows Server

.NET Core provides native Windows integration and is better suited for Windows Server environments.

## Goals / Non-Goals

### Goals
- Maintain all existing functionality
- Improve Windows Server compatibility
- Use AvaloniaUI framework for modern cross-platform GUI with better Windows Server support
- Keep the same user experience and visual design
- Preserve script embedding and self-contained deployment
- Maintain single-instance behavior
- Keep geek-style dark theme

### Non-Goals
- Complete UI redesign (maintain current layout and functionality)
- Additional features beyond current scope
- Breaking changes to script format or execution

## Decisions

### Decision: Use AvaloniaUI for GUI Framework
**Rationale**: AvaloniaUI is a modern, cross-platform .NET UI framework that provides better Windows Server compatibility than Fyne while maintaining cross-platform capabilities. It uses XAML (similar to WPF) for familiar development experience, has good rendering reliability, and works well on Windows Server environments. Unlike WPF, it's actively developed and has better cross-platform support if needed in the future.

**Alternatives considered**:
- **WPF**: Windows-only, well-supported but tied to Windows platform
- **WinUI 3**: Modern but requires Windows 10/11, may have compatibility issues on older servers
- **Windows Forms**: Older technology, less modern UI capabilities
- **MAUI**: More complex, primarily for mobile-first scenarios

### Decision: Self-contained Deployment
**Rationale**: Self-contained .NET applications include the .NET runtime, eliminating the need for separate .NET installation on target machines. This matches the current Go implementation's self-contained approach.

**Alternatives considered**:
- **Framework-dependent**: Requires .NET runtime installation, adds deployment complexity
- **Single-file**: Good option, but may have startup performance impact

### Decision: Keep Script Embedding
**Rationale**: Continue embedding PowerShell scripts as resources in the assembly, maintaining the self-contained executable model. Use .NET's embedded resources mechanism.

**Implementation approach**:
- Use `EmbeddedResource` build action in .csproj
- Load scripts using `Assembly.GetManifestResourceStream()`
- Maintain same script discovery and execution logic

### Decision: Preserve Go Implementation Initially
**Rationale**: Keep Go version alongside .NET version during migration to allow comparison and fallback. Can be removed after .NET version is proven stable.

**Alternatives considered**:
- **Immediate replacement**: Riskier, no fallback option
- **Parallel maintenance**: Too complex, choose one

## Risks / Trade-offs

### Risk: .NET Runtime Size
**Mitigation**: Use self-contained deployment with trimming to reduce size. Consider single-file deployment.

### Risk: Migration Complexity
**Mitigation**: Maintain feature parity, test thoroughly on Windows Server environments before removing Go version.

### Trade-off: Windows-only vs Cross-platform
**Decision**: Use AvaloniaUI which provides both Windows Server compatibility and optional cross-platform support. While the primary target is Windows, AvaloniaUI's architecture allows for better reliability on Windows Server compared to Fyne, while maintaining the option for future cross-platform expansion if needed.

### Risk: Learning Curve
**Mitigation**: AvaloniaUI uses XAML (similar to WPF), is well-documented, C# is widely used, and the application logic is straightforward to port. AvaloniaUI has good documentation and active community support.

## Migration Plan

1. **Phase 1: Create .NET Project Structure**
   - Initialize .NET AvaloniaUI project
   - Install AvaloniaUI NuGet packages
   - Set up build configuration
   - Create basic window structure

2. **Phase 2: Port Core Functionality**
   - Implement script discovery from embedded resources
   - Port UI components (list, log area, buttons)
   - Implement script execution with PowerShell

3. **Phase 3: Port Visual Design**
   - Implement dark theme
   - Port geek-style color scheme
   - Configure monospace fonts

4. **Phase 4: Port Advanced Features**
   - Single-instance application
   - Window management
   - Error handling and logging

5. **Phase 5: Testing and Validation**
   - Test on Windows Server 2019/2022
   - Test on Windows 10/11
   - Verify all functionality works

6. **Phase 6: Update Build and Deployment**
   - Update GitHub Actions workflow
   - Update documentation
   - Remove Go implementation (optional)

## Open Questions
- Should we use WPF, WinUI 3, or AvaloniaUI? (Decision: AvaloniaUI for better server compatibility and modern framework)
- Should we keep Go version as fallback? (Decision: Remove after validation)
- What .NET version to target? (Recommend: .NET 8 LTS for long-term support)
