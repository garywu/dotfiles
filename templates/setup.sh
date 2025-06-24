#!/bin/bash

# OS-Specific Dotfiles Setup Script
# Detects the operating system and runs the appropriate setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
  if [[  "$OSTYPE" == "darwin"*  ]]; then
    echo "macos"
  elif grep -q Microsoft /proc/version 2>/dev/null; then
    echo "wsl2"
  elif [[  -f /etc/lsb-release  ]] && grep -q Ubuntu /etc/lsb-release; then
    echo "ubuntu"
  elif [[  -f /etc/debian_version  ]]; then
    echo "ubuntu" # Treat Debian as Ubuntu for our purposes
  elif [[  -f /etc/redhat-release  ]]; then
    echo "redhat"
  elif [[  "$OSTYPE" == "linux-gnu"*  ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

# Check if running with appropriate privileges
check_privileges() {
  if [[  $EUID -eq 0  ]]; then
    log_error "This script should not be run as root/sudo!"
    log_info "Please run as your regular user account."
    exit 1
  fi
}

# Show OS-specific setup information
show_setup_info() {
  local os=$1

  echo ""
  log_info "=== OS-Specific Setup Information ==="
  echo ""

  case $os in
  "macos")
    echo "📱 Detected: macOS"
    echo "🔧 Setup will include:"
    echo "   • Xcode Command Line Tools"
    echo "   • Nix Package Manager"
    echo "   • Homebrew (for GUI apps)"
    echo "   • chezmoi dotfiles management"
    echo "   • Fish shell + Starship prompt"
    echo "   • Development tools and CLI utilities"
    echo ""
    echo "📖 For detailed instructions, see: templates/macos.md"
    ;;
  "ubuntu")
    echo "🐧 Detected: Ubuntu/Debian"
    echo "🔧 Setup will include:"
    echo "   • System package updates"
    echo "   • Nix Package Manager"
    echo "   • Essential build tools"
    echo "   • chezmoi dotfiles management"
    echo "   • Fish shell + Starship prompt"
    echo "   • Development tools and CLI utilities"
    echo ""
    echo "📖 For detailed instructions, see: templates/ubuntu.md"
    ;;
  "wsl2")
    echo "🪟 Detected: WSL2 (Windows Subsystem for Linux)"
    echo "🔧 Setup will include:"
    echo "   • WSL-specific optimizations"
    echo "   • Nix Package Manager"
    echo "   • X11 forwarding setup"
    echo "   • chezmoi dotfiles management"
    echo "   • Fish shell + Starship prompt"
    echo "   • Development tools optimized for WSL2"
    echo ""
    echo "📖 For detailed instructions, see: templates/wsl2.md"
    ;;
  *)
    echo "❓ Detected: Unknown/Unsupported OS"
    echo "🔧 Supported operating systems:"
    echo "   • macOS (10.15+)"
    echo "   • Ubuntu (20.04+)"
    echo "   • WSL2 with Ubuntu"
    echo ""
    echo "📖 Check templates/ directory for available setups"
    ;;
  esac
  echo ""
}

# Install prerequisites based on OS
install_prerequisites() {
  local os=$1

  log_info "Installing prerequisites for $os..."

  case $os in
  "macos")
    # Check if Xcode Command Line Tools are installed
    if ! xcode-select -p &>/dev/null; then
      log_info "Installing Xcode Command Line Tools..."
      xcode-select --install
      log_warning "Please complete the Xcode installation and run this script again."
      exit 0
    fi
    ;;
  "ubuntu")
    log_info "Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    log_info "Installing essential dependencies..."
    sudo apt install -y \
      curl \
      wget \
      git \
      build-essential \
      software-properties-common \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release
    ;;
  "wsl2")
    log_info "Updating WSL system packages..."
    sudo apt update && sudo apt upgrade -y

    log_info "Installing WSL-specific dependencies..."
    sudo apt install -y \
      curl \
      wget \
      git \
      build-essential \
      software-properties-common \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release \
      wslu \
      ubuntu-wsl
    ;;
  esac
}

# Install Nix package manager
install_nix() {
  if command -v nix &>/dev/null; then
    log_success "Nix is already installed"
    return 0
  fi

  log_info "Installing Nix package manager..."

  if [[  $(detect_os) == "macos"  ]]; then
    # Multi-user installation for macOS
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    # Source Nix profile
    if [[  -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh  ]]; then
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
  else
    # Single-user installation for Linux/WSL
    curl -L https://nixos.org/nix/install | sh

    # Source Nix profile
    if [[  -f ~/.nix-profile/etc/profile.d/nix.sh  ]]; then
      source ~/.nix-profile/etc/profile.d/nix.sh
    fi
  fi

  log_success "Nix installed successfully"
}

# Run the minimal installer
run_minimal_installer() {
  log_info "Running minimal installer..."

  if [[  -f "./minimal_install.sh"  ]]; then
    bash ./minimal_install.sh
  else
    curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/minimal_install.sh | bash
  fi
}

# Run OS-specific bootstrap
run_bootstrap() {
  local os=$1

  case $os in
  "macos")
    if [[  -f "./scripts/bootstrap.sh"  ]]; then
      log_info "Running macOS bootstrap script..."
      bash ./scripts/bootstrap.sh
    else
      log_warning "Bootstrap script not found, skipping..."
    fi
    ;;
  "ubuntu" | "wsl2")
    log_info "OS-specific bootstrap completed via minimal installer"
    ;;
  esac
}

# Show next steps
show_next_steps() {
  local os=$1

  echo ""
  log_success "=== Setup Complete! ==="
  echo ""
  log_info "🎉 Your development environment is ready!"
  echo ""
  log_info "Next steps:"
  echo "1. 🔄 Restart your terminal or run: exec \$SHELL"
  echo "2. 🎨 Configure your terminal with FiraCode Nerd Font"
  echo "3. ⚙️  Customize your setup:"
  echo "   • Edit ~/.config/starship.toml for prompt customization"
  echo "   • Edit ~/.config/fish/config.fish for shell aliases"
  echo "   • Run 'chezmoi edit' to modify dotfiles"
  echo ""

  case $os in
  "macos")
    echo "📱 macOS specific:"
    echo "   • Configure iTerm2 or Terminal with Nerd Font"
    echo "   • Install GUI apps: brew bundle --file=~/.local/share/chezmoi/brew/Brewfile"
    echo "   • Set up development directories"
    ;;
  "ubuntu")
    echo "🐧 Ubuntu specific:"
    echo "   • Install GUI apps if using desktop: sudo snap install code --classic"
    echo "   • Configure terminal emulator (Kitty, Alacritty, etc.)"
    echo "   • Set up development directories"
    ;;
  "wsl2")
    echo "🪟 WSL2 specific:"
    echo "   • Configure Windows Terminal with WSL profile"
    echo "   • Install X server for GUI apps (VcXsrv or X410)"
    echo "   • Set up development directories in WSL filesystem"
    echo "   • Configure Git credential manager"
    ;;
  esac

  echo ""
  log_info "📚 Documentation:"
  echo "   • Main README: README.md"
  echo "   • OS-specific guide: templates/$os.md"
  echo "   • Troubleshooting: Check the templates for common issues"
  echo ""
  log_info "🆘 Need help? Check the troubleshooting sections in the templates!"
}

# Main execution
main() {
  echo "🚀 Dotfiles Setup Script"
  echo "======================="

  # Check privileges
  check_privileges

  # Detect OS
  local os=$(detect_os)

  # Show setup information
  show_setup_info $os

  # Check if OS is supported
  if [[  $os == "unknown"  ]] || [[  $os == "redhat"  ]] || [[  $os == "linux"  ]]; then
    log_error "Unsupported operating system detected: $os"
    log_info "Please check the templates directory for available setups."
    exit 1
  fi

  # Confirm before proceeding
  echo ""
  read -p "$(echo -e ${BLUE}Do you want to proceed with the setup? [y/N]:${NC})" -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Setup cancelled by user."
    exit 0
  fi

  # Install prerequisites
  install_prerequisites $os

  # Install Nix
  install_nix

  # Run minimal installer
  run_minimal_installer

  # Run OS-specific bootstrap
  run_bootstrap $os

  # Show next steps
  show_next_steps $os
}

# Run main function
main "$@"
