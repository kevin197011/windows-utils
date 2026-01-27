//go:build !windows
// +build !windows

package main

import "fmt"

func showMessage(title, message string) {
	fmt.Printf("%s: %s\n", title, message)
}
