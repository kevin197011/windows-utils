//go:build !windows
// +build !windows

package main

import (
	"fmt"
	"os"
	"path/filepath"
)

var lockFile string

func init() {
	lockFile = filepath.Join(os.TempDir(), "ps1-gui-manager.lock")
}

func checkSingleInstance() (bool, error) {
	// Try to create a lock file
	file, err := os.OpenFile(lockFile, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0600)
	if err != nil {
		if os.IsExist(err) {
			// Lock file exists, check if process is still running
			pidBytes, readErr := os.ReadFile(lockFile)
			if readErr == nil {
				var pid int
				fmt.Sscanf(string(pidBytes), "%d", &pid)
				// Check if process exists (simplified - in production, use proper process check)
				proc, procErr := os.FindProcess(pid)
				if procErr == nil {
					// Try to signal process (doesn't kill it, just checks if it exists)
					if proc.Signal(os.Signal(nil)) == nil {
						return false, nil // Another instance is running
					}
				}
			}
			// Process doesn't exist, remove stale lock file
			os.Remove(lockFile)
		} else {
			return false, err
		}
	}

	// Write PID to lock file
	if file != nil {
		fmt.Fprintf(file, "%d", os.Getpid())
		file.Close()
	}

	return true, nil // This is the first instance
}

func releaseSingleInstance() {
	os.Remove(lockFile)
}
