//go:build !windows
// +build !windows

package main

func ForceWindowToFront(windowTitle string) bool {
	// No-op on non-Windows platforms
	return false
}
