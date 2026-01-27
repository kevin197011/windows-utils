//go:build windows
// +build windows

package main

import (
	"fmt"
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	kernel32         = windows.NewLazySystemDLL("kernel32.dll")
	procCreateMutexW = kernel32.NewProc("CreateMutexW")
)

const mutexName = "PS1-GUI-Manager-SingleInstance"

func checkSingleInstance() (bool, error) {
	// Create a named mutex
	mutexNameUTF16, err := syscall.UTF16PtrFromString(mutexName)
	if err != nil {
		return true, err // Allow to continue if string conversion fails
	}

	handle, _, _ := procCreateMutexW.Call(
		0,
		0,
		uintptr(unsafe.Pointer(mutexNameUTF16)),
	)

	// GetLastError to check if mutex already exists
	lastErr := windows.GetLastError()

	if handle == 0 {
		// If mutex creation fails, allow to continue (don't block startup)
		return true, fmt.Errorf("failed to create mutex: %v", lastErr)
	}

	// Check if mutex already exists (ERROR_ALREADY_EXISTS = 183)
	if lastErr == windows.ERROR_ALREADY_EXISTS {
		// Close the handle we just got (it's not ours)
		windows.CloseHandle(windows.Handle(handle))
		return false, nil // Another instance is running
	}

	// Store handle for cleanup (though it will be released on process exit)
	_ = handle

	return true, nil // This is the first instance
}

func releaseSingleInstance() {
	// Mutex will be automatically released when process exits
	// No explicit cleanup needed
}
