.PHONY: build clean run

build:
	@echo "Building PS1 GUI Manager..."
	@go build -o ps1-gui-manager ./cmd/ps1-gui-manager
	@echo "Build complete: ps1-gui-manager"

build-windows:
	@echo "Building PS1 GUI Manager for Windows..."
	@GOOS=windows GOARCH=amd64 go build -o ps1-gui-manager.exe ./cmd/ps1-gui-manager
	@echo "Build complete: ps1-gui-manager.exe"

clean:
	@echo "Cleaning build artifacts..."
	@rm -f ps1-gui-manager ps1-gui-manager.exe
	@echo "Clean complete"

run:
	@go run ./cmd/ps1-gui-manager

test:
	@go test ./...
