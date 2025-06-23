#!/usr/bin/env bash
# setup-python-tools.sh - Install common Python development tools via pipx
#
# This script installs essential Python development tools using pipx,
# ensuring each tool is isolated in its own virtual environment.
# It's designed to be idempotent and can be run multiple times safely.

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

# Check if pipx is installed
if ! command -v pipx &> /dev/null; then
  print_error "pipx is not installed. Please run bootstrap.sh first."
  exit 1
fi

# Ensure pipx paths are set up
pipx ensurepath

# Check if pipx packages need reinstalling (e.g., after Python version change)
if pipx list 2>&1 | grep -q "invalid interpreter"; then
  print_warning "Found packages with invalid Python interpreter"
  print_status "Reinstalling all pipx packages..."
  pipx reinstall-all
fi

print_status "Installing Python development tools..."

# Core development tools
TOOLS=(
  # Code quality
  "black"           # Code formatter
  "ruff"            # Fast Python linter (replaces flake8, isort, etc.)
  "mypy"            # Static type checker

  # Development workflow
  "pre-commit"      # Git hooks framework
  "poetry"          # Modern dependency management
  "ipython"         # Enhanced Python REPL

  # Testing tools
  "pytest"          # Testing framework
  "tox"             # Test automation

  # Documentation
  "mkdocs"          # Documentation generator
  "sphinx"          # Documentation generator (alternative)

  # Utilities
  "httpie"          # User-friendly HTTP client
  "cookiecutter"    # Project templates
  "pip-tools"       # Pin Python dependencies
)

# Optional data science tools (uncomment if needed)
# DS_TOOLS=(
#   "jupyter"         # Jupyter notebooks
#   "pandas"          # Data analysis
#   "matplotlib"      # Plotting
#   "numpy"           # Numerical computing
# )

# Install each tool
for tool in "${TOOLS[@]}"; do
  if pipx list --short | grep -q "^${tool} "; then
    print_warning "$tool is already installed"
  else
    print_status "Installing $tool..."
    if pipx install "$tool"; then
      print_status "$tool installed successfully"
    else
      print_error "Failed to install $tool"
    fi
  fi
done

print_status "Python development tools installation complete!"
print_status "Run 'pipx list' to see all installed tools"

# Optional: Install pre-commit hooks globally
if command -v pre-commit &> /dev/null; then
  print_status "Setting up global pre-commit hooks..."
  git config --global init.templateDir ~/.git-template
  pre-commit init-templatedir ~/.git-template || true
fi
