#!/bin/bash

# Exit on any error
set -e

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

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install Homebrew
install_homebrew() {
    if ! command_exists brew; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH if needed
        if [[ -f /opt/homebrew/bin/brew ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_status "Homebrew is already installed"
    fi
}

# Function to install Nix using Determinate Nix Installer (more reliable)
install_nix() {
    if ! command_exists nix; then
        print_status "Installing Nix using Determinate Nix Installer..."
        if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; then
            print_status "Nix installed successfully"
            # Source Nix environment - try multiple possible locations
            if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
                . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            elif [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
                . ~/.nix-profile/etc/profile.d/nix.sh
            fi
        else
            print_error "Failed to install Nix"
            exit 1
        fi
    else
        print_status "Nix is already installed"
    fi
}

# Function to install Home Manager
install_home_manager() {
    if ! command_exists home-manager; then
        print_status "Installing Home Manager..."
        if nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager && \
           nix-channel --update && \
           nix-shell '<home-manager>' -A install; then
            print_status "Home Manager installed successfully"
        else
            print_error "Failed to install Home Manager"
            exit 1
        fi
    else
        print_status "Home Manager is already installed"
    fi
}

# Function to check if running on Apple Silicon
is_apple_silicon() {
    [[ "$(uname -m)" == "arm64" ]]
}

# Function to check for and remove existing Nix APFS volume
check_nix_volume() {
    if is_apple_silicon; then
        print_status "Checking for existing Nix APFS volume..."
        NIX_VOLUME=$(diskutil list | grep "Nix Store" | awk '{print $NF}')
        if [ -n "$NIX_VOLUME" ]; then
            print_warning "Found existing Nix volume: $NIX_VOLUME"
            print_warning "This volume needs to be removed before installing Nix"
            print_warning "Please run the unbootstrap script first to remove it"
            exit 1
        fi
    fi
}

# Main installation function
install_requirements() {
    print_status "Starting clean installation process..."
    
    # Check for existing Nix volume on Apple Silicon
    check_nix_volume
    
    # Install Homebrew first
    install_homebrew
    
    # Install packages from Brewfile (GUI apps and Mac-specific tools only)
    print_status "Installing packages from Brewfile..."
    cd "$DOTFILES_DIR/brew" && brew bundle
    
    # Install Nix (more reliable installer)
    install_nix
    
    # Install Home Manager
    install_home_manager
    
    # Apply Nix configuration (this will install bun and other dev tools)
    print_status "Applying Nix configuration..."
    if cd "$DOTFILES_DIR/nix" && home-manager switch; then
        print_status "Nix configuration applied successfully"
    else
        print_error "Failed to apply Nix configuration"
        exit 1
    fi
    
    # Set Fish as default shell
    if [ "$SHELL" != "$(which fish)" ]; then
        print_status "Setting Fish as default shell..."
        chsh -s "$(which fish)"
    fi
    
    print_status "Installation completed successfully!"
    print_status "Please restart your terminal to apply all changes"
}

# Run the installation
install_requirements 