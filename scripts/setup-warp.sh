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
uname_result=$(uname)
if [[[ "$uname_result" != "Darwin" ]]]; then
  print_error "This script is designed for macOS only"
  exit 1
fi

# Check if running as root
if [[[ $EUID -eq 0 ]]]; then
  print_error "This script should not be run as root"
  exit 1
fi

# Function to check if Warp is installed
check_warp() {
  if [[[ ! -d "/Applications/Warp.app" ]]]; then
    print_error "Warp is not installed. Please install it first using Homebrew."
    return 1
  fi
  return 0
}

# Function to install JetBrains Mono font
install_font() {
  print_status "Installing JetBrains Mono font..."

  # Create fonts directory if it doesn't exist
  mkdir -p ~/Library/Fonts

  # Download and install JetBrains Mono
  curl -L https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip -o /tmp/jetbrains-mono.zip
  unzip -j /tmp/jetbrains-mono.zip "fonts/ttf/*" -d ~/Library/Fonts/
  rm /tmp/jetbrains-mono.zip

  print_status "JetBrains Mono font installed"
}

# Function to set up Warp configuration
setup_warp_config() {
  print_status "Setting up Warp configuration..."

  # Create Warp config directory if it doesn't exist
  mkdir -p ~/.warp

  # Copy our settings file
  cp "$(dirname "$0")/../warp/settings.json" ~/.warp/settings.json

  print_status "Warp configuration installed"
}

# Function to set up Warp workflows
setup_workflows() {
  print_status "Setting up Warp workflows..."

  # Create workflows directory if it doesn't exist
  mkdir -p ~/.warp/workflows

  # Example workflow for development
  cat >~/.warp/workflows/dev.json <<EOF
{
  "name": "Development",
  "description": "Start development environment",
  "commands": [
    "cd ~/projects",
    "git status",
    "ls -la"
  ]
}
EOF

  print_status "Warp workflows installed"
}

# Main function
main() {
  print_status "Starting Warp setup..."

  # Check if Warp is installed
  check_warp || exit 1

  # Install font
  install_font

  # Set up configuration
  setup_warp_config

  # Set up workflows
  setup_workflows

  print_status "Warp setup completed!"
  print_status "Please restart Warp to apply the changes"
}

# Run the main function
main
