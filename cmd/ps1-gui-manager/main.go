package main

import (
	"bufio"
	"embed"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/widget"
)

//go:embed scripts/*.ps1
var scriptFS embed.FS

type Script struct {
	Name        string
	Path        string
	Content     string
	Description string
}

func main() {
	myApp := app.NewWithID("com.windows-utils.ps1-gui-manager")
	// Apply geek theme
	myApp.Settings().SetTheme(&GeekTheme{})
	
	myWindow := myApp.NewWindow("PS1 Script Manager")
	myWindow.Resize(fyne.NewSize(900, 700))

	// Load scripts from embedded resources
	scripts, err := loadScripts()
	if err != nil {
		showError(myWindow, fmt.Sprintf("Failed to load scripts: %v", err))
		return
	}

	if len(scripts) == 0 {
		showError(myWindow, "No scripts found. Please ensure scripts are embedded in the binary.")
		return
	}

	// Create UI components with monospace font for geek style
	scriptList := widget.NewList(
		func() int {
			return len(scripts)
		},
		func() fyne.CanvasObject {
			label := widget.NewLabel("")
			label.TextStyle = fyne.TextStyle{Monospace: true}
			return label
		},
		func(id widget.ListItemID, obj fyne.CanvasObject) {
			label := obj.(*widget.Label)
			label.SetText(scripts[id].Name)
		},
	)

	var selectedScript *Script
	var logOutput *widget.Entry
	var statusLabel *widget.Label
	var executeBtn *widget.Button
	var logMutex sync.Mutex

	// Create log output area with monospace font for terminal feel
	logOutput = widget.NewMultiLineEntry()
	logOutput.SetText("Ready. Select a script and click Execute.\n")
	logOutput.Disable() // Make read-only
	logOutput.TextStyle = fyne.TextStyle{Monospace: true}

	// Create status label with color coding
	statusLabel = widget.NewLabel("Status: Ready")
	statusLabel.Importance = widget.MediumImportance

	// Create description label
	descriptionLabel := widget.NewLabel("Select a script to see its description")
	descriptionLabel.Wrapping = fyne.TextWrapWord

	// Create execute button
	executeBtn = widget.NewButton("Execute", func() {
		if selectedScript == nil {
			appendLog(myApp, logOutput, &logMutex, "Error: No script selected\n")
			return
		}

		executeBtn.SetText("Executing...")
		executeBtn.Disable()
		updateStatusLabel(statusLabel, "Executing...", "executing")
		appendLog(myApp, logOutput, &logMutex, "\n--- Executing: "+selectedScript.Name+" ---\n")

		// Execute script in goroutine to avoid blocking UI
		go func() {
			err := executeScript(selectedScript, myApp, logOutput, &logMutex)
			
			// Update UI on main thread using fyne.DoAndWait
			fyne.DoAndWait(func() {
				executeBtn.SetText("Execute")
				executeBtn.Enable()
				if err != nil {
					updateStatusLabel(statusLabel, "Error", "error")
					appendLog(myApp, logOutput, &logMutex, "\nError: "+err.Error()+"\n")
				} else {
					updateStatusLabel(statusLabel, "Completed", "success")
					appendLog(myApp, logOutput, &logMutex, "\n--- Execution completed ---\n")
				}
			})
		}()
	})
	executeBtn.Disable()

	// Create clear log button
	clearBtn := widget.NewButton("Clear Log", func() {
		logMutex.Lock()
		defer logMutex.Unlock()
		logOutput.SetText("")
	})

	// Handle script selection
	scriptList.OnSelected = func(id widget.ListItemID) {
		selectedScript = &scripts[id]
		executeBtn.Enable()

		// Update description
		desc := selectedScript.Description
		if desc == "" {
			desc = "No description available"
		}
		descriptionLabel.SetText("Description: " + desc)
	}

	// Layout with improved spacing
	scriptHeader := widget.NewLabel("Available Scripts:")
	scriptHeader.TextStyle = fyne.TextStyle{Bold: true}
	
	leftPanel := container.NewBorder(
		scriptHeader,
		nil,
		nil,
		nil,
		scriptList,
	)

	logHeader := widget.NewLabel("Execution Log:")
	logHeader.TextStyle = fyne.TextStyle{Bold: true, Monospace: true}
	
	rightPanel := container.NewVBox(
		descriptionLabel,
		widget.NewSeparator(),
		statusLabel,
		container.NewHBox(executeBtn, clearBtn),
		widget.NewSeparator(),
		logHeader,
		container.NewScroll(logOutput),
	)

	content := container.NewHSplit(leftPanel, rightPanel)
	content.SetOffset(0.3) // 30% for script list, 70% for details

	myWindow.SetContent(content)
	myWindow.ShowAndRun()
}

func loadScripts() ([]Script, error) {
	var scripts []Script

	err := fs.WalkDir(scriptFS, "scripts", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if !d.IsDir() && filepath.Ext(path) == ".ps1" {
			content, err := scriptFS.ReadFile(path)
			if err != nil {
				return err
			}

			description := extractDescription(string(content))

			scripts = append(scripts, Script{
				Name:        strings.TrimSuffix(filepath.Base(path), ".ps1"),
				Path:        path,
				Content:     string(content),
				Description: description,
			})
		}
		return nil
	})

	return scripts, err
}

func extractDescription(content string) string {
	lines := strings.Split(content, "\n")
	for i, line := range lines {
		if i < 10 { // Check first 10 lines
			line = strings.TrimSpace(line)
			// Look for description patterns
			if strings.HasPrefix(line, "#") && !strings.HasPrefix(line, "# Copyright") {
				desc := strings.TrimPrefix(line, "#")
				desc = strings.TrimSpace(desc)
				if desc != "" && len(desc) > 5 {
					return desc
				}
			}
		}
	}
	return ""
}

func executeScript(script *Script, app fyne.App, logOutput *widget.Entry, logMutex *sync.Mutex) error {
	// Create temporary file
	tmpFile, err := os.CreateTemp("", "ps1-script-*.ps1")
	if err != nil {
		return fmt.Errorf("failed to create temporary file: %v", err)
	}
	defer os.Remove(tmpFile.Name()) // Clean up

	// Write script content
	if _, err := tmpFile.WriteString(script.Content); err != nil {
		tmpFile.Close()
		return fmt.Errorf("failed to write script to temporary file: %v", err)
	}
	tmpFile.Close()

	// Check if PowerShell is available
	powershellPath, err := findPowerShell()
	if err != nil {
		return fmt.Errorf("PowerShell not found: %v", err)
	}

	// Execute PowerShell script
	appendLog(app, logOutput, logMutex, fmt.Sprintf("Running: %s -ExecutionPolicy Bypass -WindowStyle Hidden -File %s\n", powershellPath, tmpFile.Name()))

	cmd := exec.Command(powershellPath, "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-NoProfile", "-NonInteractive", "-File", tmpFile.Name())
	
	// Hide console window on Windows
	hideWindow(cmd)
	
	// Capture stdout and stderr
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return fmt.Errorf("failed to create stdout pipe: %v", err)
	}

	stderr, err := cmd.StderrPipe()
	if err != nil {
		return fmt.Errorf("failed to create stderr pipe: %v", err)
	}

	// Start command
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start PowerShell: %v", err)
	}

	// Stream output in real-time
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		streamOutput(stdout, app, logOutput, logMutex, false)
	}()
	go func() {
		defer wg.Done()
		streamOutput(stderr, app, logOutput, logMutex, true)
	}()

	// Wait for completion
	err = cmd.Wait()
	
	// Close pipes to signal goroutines to finish
	stdout.Close()
	stderr.Close()
	
	// Wait for output streaming to complete
	wg.Wait()
	
	if err != nil {
		return fmt.Errorf("script execution failed: %v", err)
	}

	return nil
}

func streamOutput(pipe io.ReadCloser, app fyne.App, logOutput *widget.Entry, logMutex *sync.Mutex, isError bool) {
	scanner := bufio.NewScanner(pipe)
	for scanner.Scan() {
		line := scanner.Text()
		if isError {
			appendLog(app, logOutput, logMutex, "[ERROR] "+line+"\n")
		} else {
			appendLog(app, logOutput, logMutex, line+"\n")
		}
	}
}

func appendLog(app fyne.App, logOutput *widget.Entry, logMutex *sync.Mutex, text string) {
	// Update UI on main thread
	fyne.DoAndWait(func() {
		logMutex.Lock()
		defer logMutex.Unlock()
		currentText := logOutput.Text
		logOutput.SetText(currentText + text)
		logOutput.Refresh()
	})
}

func findPowerShell() (string, error) {
	// Try common PowerShell paths
	paths := []string{
		"powershell.exe",
		"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
		"C:\\Windows\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe",
	}

	for _, path := range paths {
		if _, err := exec.LookPath(path); err == nil {
			return path, nil
		}
		if _, err := os.Stat(path); err == nil {
			return path, nil
		}
	}

	return "", fmt.Errorf("PowerShell executable not found")
}

func updateStatusLabel(label *widget.Label, status string, statusType string) {
	label.SetText("Status: " + status)
	
	// Color code status based on type
	switch statusType {
	case "success":
		label.Importance = widget.SuccessImportance
	case "error":
		label.Importance = widget.DangerImportance
	case "executing":
		label.Importance = widget.WarningImportance
	default:
		label.Importance = widget.MediumImportance
	}
	label.Refresh()
}

func showError(window fyne.Window, message string) {
	dialog := dialog.NewError(fmt.Errorf(message), window)
	dialog.Show()
}
