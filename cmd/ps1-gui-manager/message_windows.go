//go:build windows
// +build windows

package main

import (
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	user32           = windows.NewLazySystemDLL("user32.dll")
	procMessageBoxW  = user32.NewProc("MessageBoxW")
)

func showMessage(title, message string) {
	titleUTF16, _ := syscall.UTF16PtrFromString(title)
	messageUTF16, _ := syscall.UTF16PtrFromString(message)
	
	procMessageBoxW.Call(
		0,
		uintptr(unsafe.Pointer(messageUTF16)),
		uintptr(unsafe.Pointer(titleUTF16)),
		0, // MB_OK
	)
}
