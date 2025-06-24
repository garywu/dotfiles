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
  exit 1
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Get the repository URL from the current git remote
get_repo_url() {
  if [[  -d .git  ]]; then
    git remote get-url origin 2>/dev/null || print_error "Not a git repository or no remote 'origin' found"
  else
    print_error "Not a git repository"
  fi
}

# Install Nix if not present
if ! command_exists nix; then
  print_status "Installing Nix..."
  if ! curl -L https://nixos.org/nix/install -o /tmp/nix-install.sh; then
    print_error "Failed to download Nix installer"
  fi
  if ! sh /tmp/nix-install.sh --daemon; then
    print_error "Failed to install Nix"
  fi

  # Source Nix environment
  if [[  -f ~/.nix-profile/etc/profile.d/nix.sh  ]]; then
    # shellcheck source=/dev/null
    . ~/.nix-profile/etc/profile.d/nix.sh
  else
    print_warning "Nix profile not found. You may need to restart your terminal."
  fi
else
  print_status "Nix is already installed"
fi

# Install chezmoi using Nix if not present
if ! command_exists chezmoi; then
  print_status "Installing chezmoi..."
  nix profile install nixpkgs#chezmoi || print_error "Failed to install chezmoi"
else
  print_status "chezmoi is already installed"
fi

# Get the repository URL
REPO_URL=$(get_repo_url)
print_status "Using repository: $REPO_URL"

# Initialize chezmoi and apply your dotfiles
print_status "Initializing chezmoi and applying dotfiles..."
chezmoi init --apply "$REPO_URL" || print_error "Failed to initialize chezmoi"

print_status "Minimal installation completed!"
print_status "Next steps:"
print_status "1. Activate your Nix environment: cd ~/.dotfiles/nix && home-manager switch"
print_status "2. On Mac, install GUI apps: brew bundle --file=~/.dotfiles/brew/Brewfile"
print_status "3. Restart your terminal to apply all changes"
