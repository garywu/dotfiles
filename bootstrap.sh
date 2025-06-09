#!/bin/sh

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
    exit 1
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if we're in a fresh shell with Nix environment
if ! command_exists nix; then
    print_status "Installing Nix..."
    curl -L https://nixos.org/nix/install > /tmp/nix-install.sh
    sh /tmp/nix-install.sh --daemon || print_error "Failed to install Nix"
    rm /tmp/nix-install.sh
    
    print_status "Nix installed! Please restart your terminal and run this script again."
    exit 0
fi

# Check if Home Manager is installed
if ! command_exists home-manager; then
    print_status "Installing Home Manager..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
    nix-shell '<home-manager>' -A install || print_error "Failed to install Home Manager"
    
    print_status "Home Manager installed! Please restart your terminal and run this script again."
    exit 0
fi

# Install chezmoi if not present
if ! command_exists chezmoi; then
    print_status "Installing chezmoi..."
    nix-env -iA nixpkgs.chezmoi || print_error "Failed to install chezmoi"
fi

# Get the repository URL
if [ -d .git ]; then
    REPO_URL=$(git remote get-url origin 2>/dev/null) || print_error "Not a git repository or no remote 'origin' found"
else
    print_error "Not a git repository"
fi

print_status "Using repository: $REPO_URL"

# Initialize chezmoi and apply your dotfiles
print_status "Initializing chezmoi and applying dotfiles..."
chezmoi init --apply "$REPO_URL" || print_error "Failed to initialize chezmoi"

# Activate Home-Manager configuration
print_status "Activating Home-Manager configuration..."
(cd "$HOME/.dotfiles/nix" && home-manager switch) || print_warning "home-manager switch failed"

# On macOS, install Homebrew if not present and then install GUI apps
if [ "$(uname)" = "Darwin" ]; then
    if ! command_exists brew || ! brew --version >/dev/null 2>&1; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        print_status "Configuring Homebrew in PATH..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        print_status "Homebrew installed! Please restart your terminal and run this script again."
        exit 0
    fi
    
    print_status "Installing GUI apps via Brewfile..."
    brew bundle --file="$HOME/.dotfiles/brew/Brewfile" || print_warning "brew bundle failed"
fi

print_status "Bootstrap completed!"
print_status "Your system is now fully configured. Enjoy!" 