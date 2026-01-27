//go:build windows
// +build windows

package main

import (
	"os/exec"

	"golang.org/x/sys/windows"
)

func hideWindow(cmd *exec.Cmd) {
	cmd.SysProcAttr = &windows.SysProcAttr{
		HideWindow: true,
	}
}
