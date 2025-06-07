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

# Function to install Nix
install_nix() {
    if ! command_exists nix; then
        print_status "Installing Nix..."
        sh <(curl -L https://nixos.org/nix/install) --daemon
        # Source Nix environment
        . ~/.nix-profile/etc/profile.d/nix.sh
    else
        print_status "Nix is already installed"
    fi
}

# Function to install Home Manager
install_home_manager() {
    if ! command_exists home-manager; then
        print_status "Installing Home Manager..."
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install
    else
        print_status "Home Manager is already installed"
    fi
}

# Function to install chezmoi
install_chezmoi() {
    if ! command_exists chezmoi; then
        print_status "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply
    else
        print_status "chezmoi is already installed"
    fi
}

# Main installation function
install_requirements() {
    print_status "Starting installation process..."
    
    # Install Homebrew
    install_homebrew
    
    # Install Nix
    install_nix
    
    # Install Home Manager
    install_home_manager
    
    # Install chezmoi
    install_chezmoi
    
    # Install all packages from Brewfile
    print_status "Installing packages from Brewfile..."
    cd "$DOTFILES_DIR/brew" && brew bundle
    
    # Apply Nix configuration
    print_status "Applying Nix configuration..."
    cd "$DOTFILES_DIR/nix" && home-manager switch
    
    # Apply chezmoi configuration
    print_status "Applying chezmoi configuration..."
    cd "$DOTFILES_DIR/chezmoi" && chezmoi apply
    
    # Copy Starship configuration
    print_status "Configuring Starship..."
    mkdir -p ~/.config
    cp "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
    
    # Set Zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_status "Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
    
    print_status "Installation completed successfully!"
    print_status "Please restart your terminal to apply all changes"
}

# Run the installation
install_requirements 