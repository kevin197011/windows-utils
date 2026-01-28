.PHONY: build clean run restore

restore:
	@echo "Restoring .NET dependencies..."
	@dotnet restore src/Ps1GuiManager/Ps1GuiManager.csproj

build:
	@echo "Building PS1 GUI Manager (.NET)..."
	@dotnet build src/Ps1GuiManager/Ps1GuiManager.csproj --configuration Release
	@echo "Build complete"

build-windows:
	@echo "Building PS1 GUI Manager for Windows (self-contained)..."
	@dotnet publish src/Ps1GuiManager/Ps1GuiManager.csproj \
		--configuration Release \
		--runtime win-x64 \
		--self-contained true \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true
	@echo "Build complete: bin/Release/net8.0-windows/win-x64/publish/Ps1GuiManager.exe"

clean:
	@echo "Cleaning build artifacts..."
	@dotnet clean src/Ps1GuiManager/Ps1GuiManager.csproj
	@rm -rf bin obj
	@echo "Clean complete"

run:
	@dotnet run --project src/Ps1GuiManager/Ps1GuiManager.csproj

test:
	@echo "No tests configured yet"
