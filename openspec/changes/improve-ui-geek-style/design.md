## Context
The current GUI uses default Fyne styling which results in a basic, light-themed interface. Users want a more distinctive "geek" aesthetic that reflects the technical nature of the tool - similar to terminal emulators, code editors, and developer tools.

## Goals / Non-Goals

### Goals
- Create a dark, terminal-inspired theme
- Use monospace fonts for technical feel
- Implement color scheme reminiscent of terminal/console applications
- Improve visual hierarchy and readability
- Maintain all existing functionality
- Keep performance impact minimal

### Non-Goals
- Complete UI redesign (keep current layout structure)
- Animation or complex visual effects
- Custom widget implementations (use Fyne's theming system)
- Multiple theme options (single geek theme)

## Decisions

### Decision: Use Fyne Theme System
**Rationale**: Fyne provides a built-in theme system that allows customization of colors, fonts, and styles. Using the theme system ensures consistency and proper integration with Fyne widgets.

**Implementation approach**:
- Create a custom theme struct implementing `fyne.Theme` interface
- Define dark color palette with terminal-inspired colors
- Set monospace font for text areas and lists
- Apply theme to the application

**Alternatives considered**:
- **Custom CSS-like styling**: Not supported by Fyne
- **Individual widget styling**: Less maintainable, harder to keep consistent
- **External theme library**: Adds dependency, Fyne's built-in system is sufficient

### Decision: Dark Theme with Green/Cyan Accents
**Rationale**: Dark themes are common in developer tools and reduce eye strain. Green/cyan colors are associated with terminals and code, creating the desired "geek" aesthetic.

**Color palette**:
- Background: Dark gray/black (#1e1e1e, #0d1117)
- Text: Light gray/white (#e6e6e6, #ffffff)
- Accents: Green (#00ff00, #39ff14) for success/active states
- Accents: Cyan (#00ffff, #00d4ff) for information/highlights
- Error: Red (#ff4444, #ff0000)
- Warning: Yellow/Orange (#ffaa00, #ff8800)

**Alternatives considered**:
- **Blue accents**: More common but less "terminal" feel
- **Purple accents**: Too colorful, less professional
- **Pure black background**: Too harsh, dark gray is more comfortable

### Decision: Monospace Font for Script List and Logs
**Rationale**: Monospace fonts are associated with code and terminals, reinforcing the technical/geek aesthetic. They also improve readability for script names and log output.

**Font selection**:
- Primary: System monospace font (Consolas on Windows, Monaco on macOS, DejaVu Sans Mono on Linux)
- Fallback: Fyne's default monospace font

**Alternatives considered**:
- **Proportional fonts**: Less "geeky", harder to read code/logs
- **Custom font files**: Adds complexity, system fonts are sufficient

### Decision: Enhanced Visual Feedback
**Rationale**: Better visual feedback improves user experience. Adding hover states, selection highlighting, and color-coded status indicators makes the interface more responsive and informative.

**Implementation**:
- Highlight selected script with accent color
- Add hover effect on script list items
- Color-code status labels (green=ready/success, yellow=executing, red=error)
- Style buttons with geek aesthetic

## Risks / Trade-offs

### Risk: Theme customization complexity
**Mitigation**: Fyne's theme system is well-documented. Start with basic color/font changes, add complexity incrementally.

### Risk: Readability on different displays
**Mitigation**: Test dark theme on various displays. Ensure sufficient contrast ratios for accessibility.

### Trade-off: Customization vs Maintainability
**Decision**: Use Fyne's built-in theme system rather than custom styling. This balances customization needs with maintainability.

## Migration Plan
N/A - This is a visual enhancement, no data migration needed.

## Open Questions
- Should we add a theme toggle (light/dark) in the future? (Deferred - single geek theme for now)
- Should log output support syntax highlighting? (Future enhancement)
