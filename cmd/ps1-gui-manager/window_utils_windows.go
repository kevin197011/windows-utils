//go:build windows
// +build windows

package main

import (
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	user32                = windows.NewLazySystemDLL("user32.dll")
	procSetForegroundWindow = user32.NewProc("SetForegroundWindow")
	procShowWindow          = user32.NewProc("ShowWindow")
	procSetWindowPos        = user32.NewProc("SetWindowPos")
	procFindWindowW         = user32.NewProc("FindWindowW")
	procGetWindowThreadProcessId = user32.NewProc("GetWindowThreadProcessId")
	procAttachThreadInput   = user32.NewProc("AttachThreadInput")
	procGetForegroundWindow = user32.NewProc("GetForegroundWindow")
)

const (
	SW_SHOW            = 5
	SW_RESTORE         = 9
	HWND_TOP           = 0
	SWP_NOMOVE         = 0x0002
	SWP_NOSIZE         = 0x0001
	SWP_SHOWWINDOW     = 0x0040
	SWP_NOACTIVATE     = 0x0010
)

// ForceWindowToFront forces a window to the front using Windows API
func ForceWindowToFront(windowTitle string) bool {
	titleUTF16, err := syscall.UTF16PtrFromString(windowTitle)
	if err != nil {
		return false
	}
	
	// Find window by title
	hwnd, _, _ := procFindWindowW.Call(0, uintptr(unsafe.Pointer(titleUTF16)))
	if hwnd == 0 {
		// Try to find by class name or use EnumWindows (simpler: just try again)
		return false
	}
	
	// Show window (restore if minimized)
	procShowWindow.Call(hwnd, SW_RESTORE)
	procShowWindow.Call(hwnd, SW_SHOW)
	
	// Set window position to bring to front
	procSetWindowPos.Call(
		hwnd,
		HWND_TOP,
		0, 0, 0, 0,
		SWP_NOMOVE|SWP_NOSIZE|SWP_SHOWWINDOW,
	)
	
	// Try to set foreground window (may fail if another app has focus)
	procSetForegroundWindow.Call(hwnd)
	
	return true
}
