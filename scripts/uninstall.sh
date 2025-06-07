#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Function to remove Homebrew packages
remove_homebrew() {
    print_status "Removing Homebrew packages..."
    
    # Uninstall all packages from Brewfile
    if [ -f "$DOTFILES_DIR/brew/Brewfile" ]; then
        cd "$DOTFILES_DIR/brew" && brew bundle cleanup --force
    fi
    
    # Remove Homebrew itself
    print_status "Removing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
}

# Function to remove Nix
remove_nix() {
    print_status "Removing Nix..."
    
    # Remove Home Manager
    if command -v home-manager &> /dev/null; then
        print_status "Removing Home Manager..."
        rm -rf ~/.config/nixpkgs
        rm -rf ~/.nix-profile
    fi
    
    # Remove Nix
    if command -v nix &> /dev/null; then
        sudo rm -rf /nix
        sudo rm -rf /etc/nix
        sudo rm -rf /etc/profile.d/nix.sh
        sudo rm -rf /etc/profile.d/nix-daemon.sh
    fi
}

# Function to remove chezmoi
remove_chezmoi() {
    print_status "Removing chezmoi..."
    
    if command -v chezmoi &> /dev/null; then
        # Remove chezmoi configuration
        rm -rf ~/.config/chezmoi
        rm -rf ~/.local/share/chezmoi
        
        # Remove chezmoi binary
        rm -f ~/.local/bin/chezmoi
    fi
}

# Function to remove dotfiles
remove_dotfiles() {
    print_status "Removing dotfiles..."
    
    # Remove Starship configuration
    rm -f ~/.config/starship.toml
    
    # Remove version manager configurations
    rm -f ~/.config/version-managers.zsh
    
    # Remove NVM
    rm -rf ~/.nvm
    
    # Remove pyenv
    rm -rf ~/.pyenv
    
    # Remove rbenv
    rm -rf ~/.rbenv
    
    # Remove asdf
    rm -rf ~/.asdf
}

# Function to restore default shell
restore_default_shell() {
    print_status "Restoring default shell..."
    
    # Check if zsh is the current shell
    if [ "$SHELL" = "$(which zsh)" ]; then
        # Change back to bash
        chsh -s /bin/bash
    fi
}

# Function to clean up environment variables
cleanup_env() {
    print_status "Cleaning up environment variables..."
    
    # Remove Homebrew from PATH
    if [ -f ~/.zprofile ]; then
        sed -i '' '/brew shellenv/d' ~/.zprofile
    fi
    
    # Remove Nix from PATH
    if [ -f ~/.zprofile ]; then
        sed -i '' '/nix-daemon.sh/d' ~/.zprofile
    fi
    
    # Remove version managers from PATH
    if [ -f ~/.zshrc ]; then
        sed -i '' '/nvm/d' ~/.zshrc
        sed -i '' '/pyenv/d' ~/.zshrc
        sed -i '' '/rbenv/d' ~/.zshrc
        sed -i '' '/asdf/d' ~/.zshrc
    fi
}

# Main uninstallation function
uninstall() {
    print_warning "This will remove all installed components. Are you sure? (y/N) "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        exit 0
    fi
    
    print_status "Starting uninstallation process..."
    
    # Remove components in reverse order of installation
    remove_dotfiles
    remove_chezmoi
    remove_nix
    remove_homebrew
    cleanup_env
    restore_default_shell
    
    print_status "Uninstallation completed successfully!"
    print_status "Please restart your terminal to apply all changes"
}

# Run the uninstallation
uninstall 