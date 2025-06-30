# Windows Update Script
# Updates all packages and configurations

# Set strict error handling
$ErrorActionPreference = "Stop"

# Colors for output
function Write-Status { Write-Host "==> " -ForegroundColor Green -NoNewline; Write-Host $args[0] }
function Write-Success { Write-Host "✓ " -ForegroundColor Green -NoNewline; Write-Host $args[0] }
function Write-Warning { Write-Host "⚠ " -ForegroundColor Yellow -NoNewline; Write-Host $args[0] }

Write-Host "`nWindows Development Environment Update" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Update Scoop
Write-Status "Updating Scoop..."
scoop update
Write-Success "Scoop updated"

# Update all Scoop packages
Write-Status "Updating Scoop packages..."
scoop update *
Write-Success "All packages updated"

# Clean up old versions
Write-Status "Cleaning up old versions..."
scoop cleanup *
scoop cache rm *
Write-Success "Cleanup complete"

# Update npm packages
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Status "Updating global npm packages..."
    npm update -g
    Write-Success "npm packages updated"
}

# Update pip packages
if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Status "Updating pip packages..."
    pip list --outdated --format=freeze | ForEach-Object { $_.Split('==')[0] } | ForEach-Object { pip install --upgrade $_ }
    Write-Success "pip packages updated"
}

# Update PowerShell modules
Write-Status "Updating PowerShell modules..."
Update-Module -Force -ErrorAction SilentlyContinue
Write-Success "PowerShell modules updated"

# Update VS Code extensions
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Status "Updating VS Code extensions..."
    code --update-extensions
    Write-Success "VS Code extensions updated"
}

# Update Windows Terminal settings (if changed in repo)
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$DOTFILES_ROOT = Split-Path -Parent $SCRIPT_DIR
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtSourcePath = Join-Path (Split-Path $SCRIPT_DIR -Parent) "terminal\settings.json"

if ((Test-Path $wtSourcePath) -and (Test-Path (Split-Path $wtSettingsPath -Parent))) {
    $sourceHash = (Get-FileHash $wtSourcePath).Hash
    $destHash = if (Test-Path $wtSettingsPath) { (Get-FileHash $wtSettingsPath).Hash } else { "" }

    if ($sourceHash -ne $destHash) {
        Write-Status "Updating Windows Terminal settings..."
        Copy-Item $wtSourcePath $wtSettingsPath -Force
        Write-Success "Windows Terminal settings updated"
    }
}

# Update PowerShell profile (if changed in repo)
$sourceProfile = Join-Path (Split-Path $SCRIPT_DIR -Parent) "powershell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $sourceProfile) {
    $sourceHash = (Get-FileHash $sourceProfile).Hash
    $destHash = if (Test-Path $PROFILE) { (Get-FileHash $PROFILE).Hash } else { "" }

    if ($sourceHash -ne $destHash) {
        Write-Status "Updating PowerShell profile..."
        Copy-Item -Path $sourceProfile -Destination $PROFILE -Force
        Write-Success "PowerShell profile updated"
    }
}

Write-Host "`n✅ Update complete!" -ForegroundColor Green
Write-Host "Restart your terminal to ensure all changes take effect." -ForegroundColor DarkGray
