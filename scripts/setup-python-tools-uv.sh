#!/usr/bin/env bash
# setup-python-tools-uv.sh - Install common Python development tools using uv
#
# This script installs essential Python CLI TOOLS (not libraries) using uv.
# Tools = executables you run from command line (black, pytest, etc.)
# Libraries = imports in Python code (pillow, numpy, etc.) - install per-project
#
# For libraries, use in your project:
#   uv venv && source .venv/bin/activate && uv pip install pillow numpy
#
# uv is 10-100x faster than traditional pip/pipx.

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

print_status() {
  echo -e "${GREEN}==>${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1" >&2
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

# Ensure uv is installed
install_uv() {
  if ! command -v uv &>/dev/null; then
    print_status "Installing uv (fast Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
  else
    local uv_version
    uv_version=$(uv --version)
    print_status "uv is already installed ($uv_version)"
  fi

  # Configure uv to use Nix Python by default
  print_status "Configuring uv to use Nix Python..."
  export UV_PYTHON_PREFERENCE=only-system

  # Set the default Python to Nix Python
  if command -v python3 &>/dev/null; then
    local nix_python
    nix_python=$(command -v python3 | grep -E "\.nix-profile|/nix/store" | head -1)
    if [[ -n $nix_python ]]; then
      export UV_PYTHON="$nix_python"
      print_status "Set UV_PYTHON to: $nix_python"
    fi
  fi
}

# Install Python tool using uv
install_tool() {
  local tool="$1"
  local package="${2:-$tool}" # Allow override for package name

  print_status "Installing $tool..."

  # Use uv tool install (similar to pipx)
  if uv tool install "$package" --quiet; then
    print_status "$tool installed successfully"
  else
    print_warning "Failed to install $tool (may already be installed)"
  fi
}

# Main installation
main() {
  print_status "Setting up Python development tools with uv..."

  # Ensure uv is available
  install_uv

  # Core development tools
  print_status "Installing code quality tools..."
  install_tool "black" # Code formatter
  install_tool "ruff"  # Fast Python linter
  install_tool "mypy"  # Static type checker

  print_status "Installing development workflow tools..."
  install_tool "pre-commit" # Git hooks framework
  install_tool "poetry"     # Modern dependency management
  install_tool "ipython"    # Enhanced Python REPL

  print_status "Installing testing tools..."
  install_tool "pytest" # Testing framework
  install_tool "tox"    # Test automation

  print_status "Installing documentation tools..."
  install_tool "mkdocs" # Documentation generator

  print_status "Installing utilities..."
  install_tool "httpie"       # User-friendly HTTP client
  install_tool "cookiecutter" # Project templates
  install_tool "pip-tools"    # Pin Python dependencies

  # Show installed tools
  print_status "Python development tools installation complete!"
  print_status "Installed tools:"
  uv tool list

  # Optional: Set up global pre-commit hooks
  if command -v pre-commit &>/dev/null; then
    print_status "Setting up global pre-commit hooks..."
    git config --global init.templateDir ~/.git-template
    pre-commit init-templatedir ~/.git-template || true
  fi
}

# Run main function
main "$@"
