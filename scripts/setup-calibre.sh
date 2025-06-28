#!/usr/bin/env bash

# Setup Calibre CLI tools across platforms
# Since Nix package is broken, use platform-specific methods

set -euo pipefail

# Source helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers/validation-helpers.sh" || {
  echo "Error: Could not source validation helpers"
  exit 1
}

print_status "Setting up Calibre CLI tools..."

# Detect platform
OS="$(uname -s)"
case "${OS}" in
  Darwin*)
    # macOS - Already handled via Homebrew in Brewfile
    if command -v calibre >/dev/null 2>&1; then
      print_success "Calibre CLI already installed via Homebrew"
    else
      print_status "Calibre should be installed via Homebrew (brew install calibre)"
      print_warning "Run: brew bundle install --file=brew/Brewfile"
    fi
    ;;
  Linux*)
    # Linux - Use system package manager
    if command -v calibre >/dev/null 2>&1; then
      print_success "Calibre CLI already installed"
    else
      print_status "Installing Calibre via system package manager..."

      # Detect Linux distribution
      if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        print_status "Detected Debian/Ubuntu system"
        sudo apt-get update
        sudo apt-get install -y calibre
      elif [[ -f /etc/redhat-release ]]; then
        # RHEL/Fedora/CentOS
        print_status "Detected Red Hat-based system"
        sudo dnf install -y calibre || sudo yum install -y calibre
      elif [[ -f /etc/arch-release ]]; then
        # Arch Linux
        print_status "Detected Arch Linux"
        sudo pacman -S --noconfirm calibre
      elif [[ -f /etc/alpine-release ]]; then
        # Alpine Linux
        print_status "Detected Alpine Linux"
        sudo apk add calibre
      else
        print_warning "Unknown Linux distribution. Please install calibre manually."
        print_status "Try: sudo apt install calibre (Debian/Ubuntu)"
        print_status "     sudo dnf install calibre (Fedora)"
        print_status "     sudo pacman -S calibre (Arch)"
        exit 1
      fi
    fi
    ;;
  MINGW* | MSYS* | CYGWIN*)
    # Windows
    print_status "Windows detected. Installing Calibre..."
    if command -v winget >/dev/null 2>&1; then
      winget install calibre.calibre
    elif command -v choco >/dev/null 2>&1; then
      choco install calibre -y
    else
      print_warning "Please install Calibre manually from https://calibre-ebook.com"
      exit 1
    fi
    ;;
  *)
    print_error "Unsupported operating system: ${OS}"
    exit 1
    ;;
esac

# Verify installation
if command -v ebook-convert >/dev/null 2>&1; then
  print_success "Calibre CLI tools installed successfully!"
  print_status "Available commands: ebook-convert, calibredb, ebook-meta, ebook-viewer"
else
  print_error "Calibre CLI tools installation verification failed"
  exit 1
fi
