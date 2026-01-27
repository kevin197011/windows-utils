package main

import (
	"image/color"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/theme"
)

// GeekTheme implements a dark, terminal-inspired theme
type GeekTheme struct{}

var _ fyne.Theme = (*GeekTheme)(nil)

// Color returns the color for the given color name
func (t *GeekTheme) Color(name fyne.ThemeColorName, variant fyne.ThemeVariant) color.Color {
	switch name {
	case theme.ColorNameBackground:
		return color.RGBA{R: 0x0d, G: 0x11, B: 0x17, A: 0xff} // #0d1117
	case theme.ColorNameButton:
		return color.RGBA{R: 0x1e, G: 0x1e, B: 0x1e, A: 0xff} // #1e1e1e
	case theme.ColorNameDisabledButton:
		return color.RGBA{R: 0x2d, G: 0x2d, B: 0x2d, A: 0xff} // #2d2d2d
	case theme.ColorNameDisabled:
		return color.RGBA{R: 0x66, G: 0x66, B: 0x66, A: 0xff} // #666666
	case theme.ColorNameError:
		return color.RGBA{R: 0xff, G: 0x44, B: 0x44, A: 0xff} // #ff4444
	case theme.ColorNameFocus:
		return color.RGBA{R: 0x39, G: 0xff, B: 0x14, A: 0xff} // #39ff14 (green)
	case theme.ColorNameForeground:
		return color.RGBA{R: 0xe6, G: 0xe6, B: 0xe6, A: 0xff} // #e6e6e6
	case theme.ColorNameHover:
		return color.RGBA{R: 0x00, G: 0xff, B: 0xff, A: 0x40} // #00ffff with transparency
	case theme.ColorNameInputBackground:
		return color.RGBA{R: 0x1e, G: 0x1e, B: 0x1e, A: 0xff} // #1e1e1e
	case theme.ColorNameInputBorder:
		return color.RGBA{R: 0x39, G: 0x39, B: 0x39, A: 0xff} // #393939
	case theme.ColorNameMenuBackground:
		return color.RGBA{R: 0x1e, G: 0x1e, B: 0x1e, A: 0xff} // #1e1e1e
	case theme.ColorNameOverlayBackground:
		return color.RGBA{R: 0x0d, G: 0x11, B: 0x17, A: 0xf0} // #0d1117 with transparency
	case theme.ColorNamePlaceHolder:
		return color.RGBA{R: 0x99, G: 0x99, B: 0x99, A: 0xff} // #999999
	case theme.ColorNamePressed:
		return color.RGBA{R: 0x00, G: 0xd4, B: 0xff, A: 0x60} // #00d4ff (cyan) with transparency
	case theme.ColorNamePrimary:
		return color.RGBA{R: 0x39, G: 0xff, B: 0x14, A: 0xff} // #39ff14 (green)
	case theme.ColorNameScrollBar:
		return color.RGBA{R: 0x39, G: 0x39, B: 0x39, A: 0xff} // #393939
	case theme.ColorNameSelection:
		return color.RGBA{R: 0x00, G: 0xff, B: 0xff, A: 0x30} // #00ffff (cyan) with transparency
	case theme.ColorNameSeparator:
		return color.RGBA{R: 0x39, G: 0x39, B: 0x39, A: 0xff} // #393939
	case theme.ColorNameShadow:
		return color.RGBA{R: 0x00, G: 0x00, B: 0x00, A: 0x80} // black with transparency
	case theme.ColorNameSuccess:
		return color.RGBA{R: 0x39, G: 0xff, B: 0x14, A: 0xff} // #39ff14 (green)
	case theme.ColorNameWarning:
		return color.RGBA{R: 0xff, G: 0xaa, B: 0x00, A: 0xff} // #ffaa00 (yellow/orange)
	default:
		return theme.DefaultTheme().Color(name, variant)
	}
}

// Font returns the font resource for the given text style
func (t *GeekTheme) Font(style fyne.TextStyle) fyne.Resource {
	// Use monospace font for code/terminal feel
	if style.Monospace {
		return theme.DefaultTheme().Font(style)
	}
	// For regular text, still use default but can be customized
	return theme.DefaultTheme().Font(style)
}

// Icon returns the icon resource for the given icon name
func (t *GeekTheme) Icon(name fyne.ThemeIconName) fyne.Resource {
	return theme.DefaultTheme().Icon(name)
}

// Size returns the size for the given size name
func (t *GeekTheme) Size(name fyne.ThemeSizeName) float32 {
	return theme.DefaultTheme().Size(name)
}
