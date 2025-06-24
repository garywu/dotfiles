#!/usr/bin/env bash
# configure-uv.sh - Configure uv to use Nix Python and avoid Homebrew Python
#
# This script sets up uv configuration to ensure it uses the correct Python

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color

print_status() {
  echo -e "${GREEN}==>${NC} $1"
}

# Create uv config directory
UV_CONFIG_DIR="$HOME/.config/uv"
mkdir -p "$UV_CONFIG_DIR"

# Find Nix Python path
NIX_PYTHON=$(command -v python3 | grep -E "\.nix-profile|/nix/store" | head -1)

if [[ -z $NIX_PYTHON ]]; then
  echo "Warning: Could not find Nix Python installation"
  exit 1
fi

print_status "Found Nix Python at: $NIX_PYTHON"

# Create uv configuration file
cat >"$UV_CONFIG_DIR/config.toml" <<EOF
# uv configuration to use Nix Python
[python]
# Prefer system Python (Nix) over managed installations
preference = "only-system"

# Don't download Python automatically
downloads = false
EOF

print_status "Created uv config at: $UV_CONFIG_DIR/config.toml"

# Add environment variables to shell config
SHELL_CONFIG=""
if [[ -f "$HOME/.bashrc" ]]; then
  SHELL_CONFIG="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
  SHELL_CONFIG="$HOME/.zshrc"
fi

# Add to Fish config separately
if [[ -d "$HOME/.config/fish" ]]; then
  FISH_CONFIG="$HOME/.config/fish/conf.d/uv.fish"
  cat >"$FISH_CONFIG" <<EOF
# Configure uv to use Nix Python
set -gx UV_PYTHON_PREFERENCE only-system
set -gx UV_PYTHON_DOWNLOADS false
EOF
  print_status "Added Fish configuration to: $FISH_CONFIG"
fi

# Add to bash/zsh config
if [[ -n $SHELL_CONFIG ]]; then
  # Check if already configured
  if ! grep -q "UV_PYTHON_PREFERENCE" "$SHELL_CONFIG"; then
    cat >>"$SHELL_CONFIG" <<EOF

# Configure uv to use Nix Python
export UV_PYTHON_PREFERENCE=only-system
export UV_PYTHON_DOWNLOADS=false
EOF
    print_status "Added configuration to: $SHELL_CONFIG"
  else
    print_status "Configuration already exists in: $SHELL_CONFIG"
  fi
fi

print_status "uv configuration complete!"
print_status "Python preference set to use system (Nix) Python only"
print_status "Automatic Python downloads disabled"

# Test the configuration
print_status "Testing configuration..."
if command -v uv &>/dev/null; then
  uv python list
fi
