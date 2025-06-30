# PowerShell Profile - Equivalent to Fish config
# This replicates the Unix dotfiles functionality for Windows

# Set strict mode for better error handling
Set-StrictMode -Version Latest

# Enable verbose error messages
$ErrorActionPreference = 'Continue'

# Set window title to show current directory
$Host.UI.RawUI.WindowTitle = "PowerShell - $PWD"

# Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Set up PATH for development tools
# Scoop shims are automatically in PATH, but we add others
$env:PATH = @(
    "$env:USERPROFILE\scoop\apps\python\current\Scripts"
    "$env:USERPROFILE\.cargo\bin"
    "$env:USERPROFILE\go\bin"
    "$env:USERPROFILE\.local\bin"
    "$env:USERPROFILE\AppData\Roaming\npm"
    $env:PATH
) -join [System.IO.Path]::PathSeparator

# Environment variables for development
$env:GOPATH = "$env:USERPROFILE\go"
$env:CARGO_HOME = "$env:USERPROFILE\.cargo"
$env:RUSTUP_HOME = "$env:USERPROFILE\.rustup"
$env:GOTOOLCHAIN = "auto"  # Go automatic toolchain switching

# fnm (Fast Node Manager) integration
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

# Set up aliases to match Unix environment
Set-Alias -Name ls -Value eza -Option AllScope -Force
Set-Alias -Name ll -Value Get-EzaLong -Option AllScope
Set-Alias -Name la -Value Get-EzaAll -Option AllScope
Set-Alias -Name cat -Value bat -Option AllScope -Force
Set-Alias -Name find -Value fd -Option AllScope -Force
Set-Alias -Name grep -Value rg -Option AllScope -Force
Set-Alias -Name which -Value Get-Command -Option AllScope

# Custom functions for enhanced aliases
function Get-EzaLong { eza -l @args }
function Get-EzaAll { eza -la @args }

# Git aliases to match Unix setup
function gst { git status @args }
function gco { git checkout @args }
function gbr { git branch @args }
function gci { git commit @args }
function gad { git add @args }
function gdiff { git diff @args }
function glog { git log --oneline --graph --decorate @args }
function gpull { git pull @args }
function gpush { git push @args }

# Common directory shortcuts
function dev { Set-Location "$env:USERPROFILE\Development" }
function dotfiles { Set-Location "$env:USERPROFILE\.dotfiles" }
function dl { Set-Location "$env:USERPROFILE\Downloads" }
function docs { Set-Location "$env:USERPROFILE\Documents" }

# Enhanced functionality
function mkcd {
    param($dir)
    New-Item -ItemType Directory -Force -Path $dir
    Set-Location $dir
}

# Touch command for Windows
function touch {
    param($file)
    if (Test-Path $file) {
        (Get-Item $file).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $file
    }
}

# Better history search
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Syntax highlighting and autosuggestions (if modules are installed)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -Colors @{
        Command = 'DarkCyan'
        Parameter = 'DarkGray'
        String = 'DarkGreen'
    }
}

# fzf integration for fuzzy finding
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Ctrl+T - Insert selected file path
    Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
        $selected = fd --type f | fzf
        if ($selected) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
        }
    }

    # Ctrl+R - Search command history
    Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
        $selected = Get-History | Select-Object -ExpandProperty CommandLine | fzf
        if ($selected) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
        }
    }
}

# Zoxide integration (smart cd)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Load local customizations if they exist
$localProfile = "$env:USERPROFILE\.config\powershell\local.ps1"
if (Test-Path $localProfile) {
    . $localProfile
}

# Welcome message
Write-Host "Windows Development Environment Ready! " -ForegroundColor Green -NoNewline
Write-Host "🚀" -NoNewline
Write-Host " (PowerShell $($PSVersionTable.PSVersion))" -ForegroundColor DarkGray
Write-Host "Run 'Get-Command <tool>' to verify installations" -ForegroundColor DarkGray
Write-Host ""
