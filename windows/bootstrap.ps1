# Windows Bootstrap Script
# Equivalent to Unix bootstrap.sh but for native Windows
# Run this in PowerShell (preferably Windows Terminal)

# Set strict error handling
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# Colors for output (similar to Unix bootstrap)
function Write-Status { Write-Host "==> " -ForegroundColor Green -NoNewline; Write-Host $args[0] }
function Write-Error { Write-Host "Error: " -ForegroundColor Red -NoNewline; Write-Host $args[0]; exit 1 }
function Write-Warning { Write-Host "Warning: " -ForegroundColor Yellow -NoNewline; Write-Host $args[0] }
function Write-Success { Write-Host "✓ " -ForegroundColor Green -NoNewline; Write-Host $args[0] }

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$DOTFILES_ROOT = Split-Path -Parent $SCRIPT_DIR

Write-Host "`nWindows Dotfiles Bootstrap" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "This will set up your Windows development environment"
Write-Host "to match the Unix dotfiles as closely as possible.`n"

# Check if running as Administrator (warn but don't require)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "Not running as Administrator. Some installations may fail."
    Write-Warning "For best results, run PowerShell as Administrator."
    Write-Host ""
}

# Step 1: Install Scoop (primary package manager)
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Scoop package manager..."

    # Set Scoop to install to user directory (no admin needed)
    $env:SCOOP = "$env:USERPROFILE\scoop"
    [Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

    # Install Scoop
    try {
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Write-Success "Scoop installed successfully"
    } catch {
        Write-Error "Failed to install Scoop: $_"
    }
} else {
    Write-Status "Scoop is already installed"
}

# Add Scoop to current session PATH if needed
$env:Path = "$env:USERPROFILE\scoop\shims;$env:Path"

# Step 2: Install Git (required for Scoop buckets)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Git..."
    scoop install git
    Write-Success "Git installed"
} else {
    Write-Status "Git is already installed"
}

# Step 3: Add essential Scoop buckets
Write-Status "Adding Scoop buckets..."
$buckets = @('extras', 'versions', 'nerd-fonts', 'java', 'games')
foreach ($bucket in $buckets) {
    if (-not (scoop bucket list | Select-String $bucket)) {
        scoop bucket add $bucket
        Write-Success "Added $bucket bucket"
    }
}

# Step 4: Install core packages from scoop-packages.json
Write-Status "Installing core packages..."
$packagesFile = Join-Path $SCRIPT_DIR "packages\scoop-packages.json"
if (Test-Path $packagesFile) {
    $packages = Get-Content $packagesFile | ConvertFrom-Json

    # Install packages by category
    foreach ($category in $packages.PSObject.Properties) {
        Write-Status "Installing $($category.Name) packages..."
        foreach ($package in $category.Value) {
            if (-not (scoop list | Select-String "^$package\s")) {
                Write-Host "  Installing $package..." -ForegroundColor Gray
                scoop install $package
            } else {
                Write-Host "  $package is already installed" -ForegroundColor DarkGray
            }
        }
    }
} else {
    Write-Warning "Package list not found at $packagesFile"
}

# Step 5: Install Windows Terminal (if not present)
if (-not (Get-AppxPackage -Name Microsoft.WindowsTerminal)) {
    Write-Status "Installing Windows Terminal..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Microsoft.WindowsTerminal -e --silent
        Write-Success "Windows Terminal installed"
    } else {
        Write-Warning "winget not found. Please install Windows Terminal from the Microsoft Store."
    }
} else {
    Write-Status "Windows Terminal is already installed"
}

# Step 6: Install PowerShell 7+ (if using old PowerShell)
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Status "Installing PowerShell 7..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Microsoft.PowerShell -e --silent
        Write-Success "PowerShell 7 installed"
        Write-Warning "Please restart your terminal and use PowerShell 7 for best results"
    } else {
        scoop install pwsh
        Write-Success "PowerShell 7 installed via Scoop"
    }
} else {
    Write-Status "PowerShell 7+ is already installed"
}

# Step 7: Configure PowerShell profile
Write-Status "Setting up PowerShell profile..."
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

# Link or copy PowerShell profile
$sourceProfile = Join-Path $SCRIPT_DIR "powershell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $sourceProfile) {
    Copy-Item -Path $sourceProfile -Destination $PROFILE -Force
    Write-Success "PowerShell profile configured"
} else {
    Write-Warning "PowerShell profile not found at $sourceProfile"
}

# Step 8: Install Starship prompt
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Starship prompt..."
    scoop install starship
    Write-Success "Starship installed"
} else {
    Write-Status "Starship is already installed"
}

# Copy Starship config
$starshipConfig = "$env:USERPROFILE\.config\starship.toml"
$starshipConfigDir = Split-Path $starshipConfig -Parent
if (-not (Test-Path $starshipConfigDir)) {
    New-Item -ItemType Directory -Force -Path $starshipConfigDir | Out-Null
}
if (Test-Path "$DOTFILES_ROOT\starship\starship.toml") {
    Copy-Item "$DOTFILES_ROOT\starship\starship.toml" -Destination $starshipConfig -Force
    Write-Success "Starship config copied"
}

# Step 9: Configure Windows Terminal
Write-Status "Configuring Windows Terminal..."
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtSourcePath = Join-Path $SCRIPT_DIR "terminal\settings.json"

if (Test-Path (Split-Path $wtSettingsPath -Parent)) {
    if (Test-Path $wtSourcePath) {
        # Backup existing settings
        if (Test-Path $wtSettingsPath) {
            Copy-Item $wtSettingsPath "$wtSettingsPath.backup" -Force
        }
        Copy-Item $wtSourcePath $wtSettingsPath -Force
        Write-Success "Windows Terminal configured"
    }
} else {
    Write-Warning "Windows Terminal settings directory not found. Is Windows Terminal installed?"
}

# Step 10: Install programming languages and tools
Write-Status "Installing development tools..."

# Node.js via fnm (Fast Node Manager)
if (-not (Get-Command fnm -ErrorAction SilentlyContinue)) {
    Write-Status "Installing fnm (Node.js version manager)..."
    scoop install fnm
    fnm install --lts
    fnm use lts-latest
    Write-Success "Node.js installed via fnm"
}

# Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Python..."
    scoop install python
    Write-Success "Python installed"
}

# Rust
if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Rust..."
    scoop install rustup
    rustup-init -y
    Write-Success "Rust installed"
}

# Go
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Go..."
    scoop install go
    Write-Success "Go installed"
}

# Step 11: Configure Git
Write-Status "Configuring Git..."
$gitConfig = "$env:USERPROFILE\.gitconfig"
if (Test-Path "$DOTFILES_ROOT\git\.gitconfig") {
    Copy-Item "$DOTFILES_ROOT\git\.gitconfig" -Destination $gitConfig -Force
    Write-Success "Git config copied"
}

# Step 12: Install VS Code and extensions
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Visual Studio Code..."
    scoop install vscode
    Write-Success "VS Code installed"
}

# Install VS Code extensions
$extensionsFile = Join-Path $SCRIPT_DIR "config\vscode-extensions.txt"
if ((Get-Command code -ErrorAction SilentlyContinue) -and (Test-Path $extensionsFile)) {
    Write-Status "Installing VS Code extensions..."
    Get-Content $extensionsFile | ForEach-Object {
        code --install-extension $_ --force
    }
    Write-Success "VS Code extensions installed"
}

# Step 13: Set up chezmoi for dotfiles management
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Status "Installing chezmoi..."
    scoop install chezmoi
    Write-Success "chezmoi installed"
}

# Step 14: Install additional development tools
Write-Status "Installing additional tools..."
$additionalTools = @(
    'ripgrep',    # Better grep
    'fd',         # Better find
    'bat',        # Better cat
    'eza',        # Better ls
    'zoxide',     # Better cd
    'fzf',        # Fuzzy finder
    'gh',         # GitHub CLI
    'jq',         # JSON processor
    'yq',         # YAML processor
    'delta',      # Better diff
    'hyperfine',  # Benchmarking
    'tokei',      # Code statistics
    'glow',       # Markdown renderer
    'lazygit',    # Git UI
    'bottom'      # System monitor
)

foreach ($tool in $additionalTools) {
    if (-not (scoop list | Select-String "^$tool\s")) {
        scoop install $tool
    }
}

# Step 15: Final setup message
Write-Host "`n" -NoNewline
Write-Success "Windows development environment setup complete!"
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Restart your terminal (use Windows Terminal with PowerShell 7)"
Write-Host "2. Your new prompt (Starship) will be active"
Write-Host "3. All development tools are available in your PATH"
Write-Host "4. Run 'Get-Command <tool>' to verify installations"
Write-Host "`nKey differences from Unix setup:" -ForegroundColor Yellow
Write-Host "- Use PowerShell instead of Fish/Bash"
Write-Host "- Scoop instead of Nix for package management"
Write-Host "- Windows Terminal instead of iTerm2/Alacritty"
Write-Host "- Some tools may have slightly different Windows versions"
Write-Host "`nHappy coding! 🚀" -ForegroundColor Green
