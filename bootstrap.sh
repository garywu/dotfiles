#!/bin/bash

# Check for old Bash and handle compatibility
if [[ -n "${BASH_VERSION}" ]]; then
  BASH_MAJOR_VERSION=$(echo "${BASH_VERSION}" | cut -d. -f1)
  if [[ "${BASH_MAJOR_VERSION}" -lt 4 ]]; then
    # Check if modern bash is already available
    MODERN_BASH_AVAILABLE=false
    if [[ -x "$HOME/.nix-profile/bin/bash" ]]; then
      MODERN_BASH_VERSION=$("$HOME/.nix-profile/bin/bash" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
      if [[ -n "$MODERN_BASH_VERSION" ]]; then
        MODERN_BASH_AVAILABLE=true
      fi
    fi

    if [[ "$MODERN_BASH_AVAILABLE" == "true" ]]; then
      echo "ℹ️  Bootstrap is running with system Bash ${BASH_VERSION}"
      echo "   ✅ Modern Bash ${MODERN_BASH_VERSION} is already installed at ~/.nix-profile/bin/bash"
      echo "   Your shell sessions will use the modern version."
      echo ""
    else
      echo "⚠️  Bootstrap is running with system Bash ${BASH_VERSION}"
      echo "   macOS ships with Bash 3.2 (2007) due to GPL licensing."
      echo ""
      echo "🔧 This bootstrap will install modern Bash 5.2+ via Nix."
      echo "   After completion, new shells will use the modern version."
      echo ""
    fi
  fi
fi

# Setup logging
# Source CI helpers if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/scripts/ci-helpers.sh" ]]; then
  # shellcheck source=/dev/null
  source "${SCRIPT_DIR}/scripts/ci-helpers.sh"
elif [[ -f "${HOME}/.dotfiles/scripts/ci-helpers.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.dotfiles/scripts/ci-helpers.sh"
fi

BOOTSTRAP_LOG="${SCRIPT_DIR}/logs/bootstrap-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$(dirname "${BOOTSTRAP_LOG}")"

# Function to log and display
log_and_echo() {
  echo "$1" | tee -a "${BOOTSTRAP_LOG}"
}

echo "Bootstrap started at $(date)" | tee "${BOOTSTRAP_LOG}"
echo "System: $(uname -a)" | tee -a "${BOOTSTRAP_LOG}"
echo "User: $(whoami)" | tee -a "${BOOTSTRAP_LOG}"
echo "PWD: $(pwd)" | tee -a "${BOOTSTRAP_LOG}"
echo "PATH: ${PATH}" | tee -a "${BOOTSTRAP_LOG}"
echo "Log file: ${BOOTSTRAP_LOG}" | tee -a "${BOOTSTRAP_LOG}"
echo "---" | tee -a "${BOOTSTRAP_LOG}"

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
  command -v "$1" >/dev/null 2>&1
}

# Function to set up PyUNO integration for unoserver on macOS
setup_pyuno_macos() {
  # Only run on macOS when LibreOffice is available
  if [[ "$OSTYPE" == darwin* ]] && command_exists soffice; then
    print_status "Setting up PyUNO integration for unoserver..."

    # 1. Remove broken pipx installation if it exists
    if command_exists pipx && pipx list | grep -q unoserver; then
      print_status "  → Removing broken pipx unoserver installation..."
      pipx uninstall unoserver 2>/dev/null || true
    fi

    # 2. Create dedicated virtual environment
    LIBREOFFICE_VENV="$HOME/.local/libreoffice-venv"
    if [[ ! -d "$LIBREOFFICE_VENV" ]]; then
      print_status "  → Creating dedicated LibreOffice Python environment..."
      python3 -m venv "$LIBREOFFICE_VENV"
    fi

    # 3. Install unoserver in the dedicated environment
    print_status "  → Installing unoserver with LibreOffice integration..."
    source "$LIBREOFFICE_VENV/bin/activate"
    pip install --upgrade pip >/dev/null 2>&1
    pip install unoserver >/dev/null 2>&1
    deactivate

    # 4. Create wrapper scripts for seamless execution
    create_uno_wrappers

    print_status "  ✅ PyUNO integration setup complete"
  else
    if [[ "$OSTYPE" != darwin* ]]; then
      print_status "  → Skipping PyUNO setup (not macOS)"
    elif ! command_exists soffice; then
      print_warning "  → LibreOffice not found, skipping PyUNO setup"
    fi
  fi
}

# Function to create transparent wrapper scripts for unoserver commands
create_uno_wrappers() {
  local wrapper_dir="$HOME/.local/bin"
  mkdir -p "$wrapper_dir"

  # Find LibreOffice UNO Python paths
  local libreoffice_resources_path=""
  local libreoffice_frameworks_path=""

  if [[ -d "/Applications/LibreOffice.app/Contents/Resources" ]]; then
    libreoffice_resources_path="/Applications/LibreOffice.app/Contents/Resources"
    libreoffice_frameworks_path="/Applications/LibreOffice.app/Contents/Frameworks"
  elif [[ -d "/opt/homebrew/Caskroom/libreoffice" ]]; then
    # Find the latest LibreOffice version directory
    local latest_version
    latest_version=$(ls -1 /opt/homebrew/Caskroom/libreoffice/ | sort -V | tail -1)
    if [[ -n "$latest_version" && -d "/opt/homebrew/Caskroom/libreoffice/$latest_version/LibreOffice.app/Contents/Resources" ]]; then
      libreoffice_resources_path="/opt/homebrew/Caskroom/libreoffice/$latest_version/LibreOffice.app/Contents/Resources"
      libreoffice_frameworks_path="/opt/homebrew/Caskroom/libreoffice/$latest_version/LibreOffice.app/Contents/Frameworks"
    fi
  fi

  if [[ -z "$libreoffice_resources_path" ]]; then
    print_warning "  → Could not find LibreOffice UNO paths, wrappers may not work"
    libreoffice_resources_path="/Applications/LibreOffice.app/Contents/Resources"
    libreoffice_frameworks_path="/Applications/LibreOffice.app/Contents/Frameworks"
  fi

  # Create unoserver wrapper
  cat >"$wrapper_dir/unoserver" <<EOF
#!/bin/bash
# Transparent wrapper for unoserver with PyUNO integration
export PYTHONPATH="$libreoffice_resources_path:$libreoffice_frameworks_path:\$PYTHONPATH"
source "$HOME/.local/libreoffice-venv/bin/activate"
exec "$HOME/.local/libreoffice-venv/bin/unoserver" "\$@"
EOF

  # Create unoconvert wrapper
  cat >"$wrapper_dir/unoconvert" <<EOF
#!/bin/bash
# Transparent wrapper for unoconvert with PyUNO integration
export PYTHONPATH="$libreoffice_resources_path:$libreoffice_frameworks_path:\$PYTHONPATH"
source "$HOME/.local/libreoffice-venv/bin/activate"
exec "$HOME/.local/libreoffice-venv/bin/unoconvert" "\$@"
EOF

  # Create unocompare wrapper (bonus utility)
  cat >"$wrapper_dir/unocompare" <<EOF
#!/bin/bash
# Transparent wrapper for unocompare with PyUNO integration
export PYTHONPATH="$libreoffice_resources_path:$libreoffice_frameworks_path:\$PYTHONPATH"
source "$HOME/.local/libreoffice-venv/bin/activate"
exec "$HOME/.local/libreoffice-venv/bin/unocompare" "\$@"
EOF

  # Make wrappers executable
  chmod +x "$wrapper_dir/unoserver" "$wrapper_dir/unoconvert" "$wrapper_dir/unocompare"

  print_status "  → Created transparent wrapper scripts in ~/.local/bin/"
}

# Function to handle previous Nix installation remnants following official documentation
handle_nix_remnants() {
  print_status "Checking for previous Nix installation remnants..."

  local found_backups=false

  # Official backup files that the Nix installer creates (per official docs)
  local official_backups=(
    "/etc/zshrc.backup-before-nix"
    "/etc/zsh/zshrc.backup-before-nix"
    "/etc/bashrc.backup-before-nix"
    "/etc/bash.bashrc.backup-before-nix"
  )

  # Check for backup files that block installation
  for backup_file in "${official_backups[@]}"; do
    if [[ -f "${backup_file}" ]]; then
      found_backups=true
      print_warning "Found Nix backup file: ${backup_file}"
    fi
  done

  if [[ "${found_backups}" = true ]]; then
    echo ""
    echo "According to the official Nix documentation, these backup files contain"
    echo "your original system configuration and should be restored."
    echo ""
    echo "The Nix installer cannot proceed with these backup files present."
    echo "Following official documentation, the recommended action is to restore"
    echo "the backup files to their original locations."
    echo ""
    printf "Restore backup files as recommended by official Nix docs? [Y/n]: "
    if command -v is_ci &>/dev/null && is_ci; then
      response="Y"
      echo "Y [auto-confirmed in CI]"
    else
      read -r response
    fi

    case "${response}" in
    [nN] | [nN][oO])
      print_warning "Moving backup files to /tmp (you can restore them later)"
      local timestamp=$(date +%s)
      for backup_file in "${official_backups[@]}"; do
        if [[ -f "${backup_file}" ]]; then
          local basename=$(basename "${backup_file}")
          sudo mv "${backup_file}" "/tmp/${basename}.${timestamp}" 2>/dev/null &&
            echo "  → Moved ${backup_file} to /tmp/${basename}.${timestamp}"
        fi
      done
      ;;
    *)
      print_status "Restoring backup files (following official Nix documentation)..."

      # Follow exact commands from official docs
      if [[ -f "/etc/zshrc.backup-before-nix" ]]; then
        sudo mv /etc/zshrc.backup-before-nix /etc/zshrc &&
          print_status "  → Restored /etc/zshrc"
      fi

      if [[ -f "/etc/zsh/zshrc.backup-before-nix" ]]; then
        sudo mv /etc/zsh/zshrc.backup-before-nix /etc/zsh/zshrc &&
          print_status "  → Restored /etc/zsh/zshrc"
      fi

      if [[ -f "/etc/bashrc.backup-before-nix" ]]; then
        sudo mv /etc/bashrc.backup-before-nix /etc/bashrc &&
          print_status "  → Restored /etc/bashrc"
      fi

      if [[ -f "/etc/bash.bashrc.backup-before-nix" ]]; then
        sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc &&
          print_status "  → Restored /etc/bash.bashrc"
      fi

      print_status "Backup files restored per official documentation."
      print_status "System is now clean for a fresh Nix installation."
      ;;
    esac
  fi

  # Clean up other remnants (also from official docs)
  if [[ -f "/etc/nix/nix.conf" ]]; then
    print_warning "Removing leftover Nix configuration..."
    sudo rm -rf /etc/nix 2>/dev/null || print_warning "Could not remove /etc/nix"
  fi

  if [[ -f "/Library/LaunchDaemons/org.nixos.nix-daemon.plist" ]]; then
    print_warning "Removing leftover Nix daemon service..."
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
    sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null ||
      print_warning "Could not remove daemon plist"
  fi

  if [[ -f "/Library/LaunchDaemons/org.nixos.darwin-store.plist" ]]; then
    print_warning "Removing leftover Darwin store service..."
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true
    sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null ||
      print_warning "Could not remove darwin-store plist"
  fi

  print_status "Cleanup completed following official documentation"
}

# Check if we're in a fresh shell with Nix environment
if ! command_exists nix; then
  handle_nix_remnants

  print_status "Installing Nix..."
  curl -L https://nixos.org/nix/install >/tmp/nix-install.sh
  sh /tmp/nix-install.sh --daemon || print_error "Failed to install Nix"
  rm /tmp/nix-install.sh

  if command -v is_ci &>/dev/null && is_ci; then
    print_status "Nix installed! Continuing in CI mode..."
    # In CI, source nix immediately to make it available
    if [[ "$(uname)" == "Darwin" ]]; then
      # macOS uses nix-daemon.sh for multi-user installation
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # shellcheck source=/dev/null
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    else
      # Linux uses nix.sh
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]]; then
        # shellcheck source=/dev/null
        source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi
    fi
    # Also try user profile
    if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
      # shellcheck source=/dev/null
      source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    # Ensure PATH includes Nix binaries
    export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"
    # Export PATH to GitHub Actions for subsequent steps
    if [[ -n "${GITHUB_PATH}" ]]; then
      echo "/nix/var/nix/profiles/default/bin" >>"${GITHUB_PATH}"
      echo "$HOME/.nix-profile/bin" >>"${GITHUB_PATH}"
    fi
  else
    print_status "Nix installed! Please restart your terminal and run this script again."
    exit 0
  fi
fi

# Check if Home Manager is installed
if ! command_exists home-manager; then
  print_status "Installing Home Manager..."
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

  # Install Home Manager
  nix-shell '<home-manager>' -A install || print_error "Failed to install Home Manager"

  if command -v is_ci &>/dev/null && is_ci; then
    print_status "Home Manager installed! Continuing in CI mode..."
    # In CI, source the home-manager script to make it available immediately
    if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
      # shellcheck source=/dev/null
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
    # Export PATH to GitHub Actions for subsequent steps (in case paths changed)
    if [[ -n "${GITHUB_PATH}" ]]; then
      echo "/nix/var/nix/profiles/default/bin" >>"${GITHUB_PATH}"
      echo "$HOME/.nix-profile/bin" >>"${GITHUB_PATH}"
    fi
  else
    print_status "Home Manager installed! Please restart your terminal and run this script again."
    exit 0
  fi
fi

# Set NIX_PATH if not set (needed for home-manager to work properly)
if [[ -z "${NIX_PATH}" ]]; then
  export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
fi

# Setup Home Manager configuration link
print_status "Setting up Home Manager configuration..."
mkdir -p ~/.config/home-manager
if [[ -f ~/.config/home-manager/home.nix ]] && [[ ! -L ~/.config/home-manager/home.nix ]]; then
  print_warning "Backing up existing home.nix..."
  mv ~/.config/home-manager/home.nix ~/.config/home-manager/home.nix.backup
fi
ln -sf "${SCRIPT_DIR}/nix/home.nix" ~/.config/home-manager/home.nix

# Install chezmoi temporarily to get dotfiles, then Home Manager will manage it
if ! command_exists chezmoi; then
  print_status "Installing chezmoi temporarily..."
  nix-env -iA nixpkgs.chezmoi || print_error "Failed to install chezmoi"
fi

# Get the repository URL
if [[ -d .git ]]; then
  REPO_URL=$(git remote get-url origin 2>/dev/null) || print_error "Not a git repository or no remote 'origin' found"
else
  print_error "Not a git repository"
fi

print_status "Using repository: ${REPO_URL}"

# Sync chezmoi-managed files from repo to Chezmoi's source directory
rsync -a --delete "${SCRIPT_DIR}/chezmoi/" "${HOME}/.local/share/chezmoi/"

# Apply dotfiles
chezmoi apply

# Home Manager configuration is now directly managed in nix/home.nix
print_status "Home Manager configuration is linked from nix/home.nix..."

# Remove temporary chezmoi to avoid conflicts with Home Manager
print_status "Removing temporary chezmoi installation..."
nix-env -e chezmoi || print_warning "Could not remove temporary chezmoi"

# Activate Home-Manager configuration
print_status "Activating Home-Manager configuration..."
echo "[DEBUG] Before home-manager switch:"
ls -l ~/.config/fish/config.fish 2>&1 || echo "config.fish does not exist"

home-manager switch || print_warning "home-manager switch failed"

echo "[DEBUG] After home-manager switch:"
ls -l ~/.config/fish/config.fish 2>&1 || echo "config.fish does not exist"

# Install Go protoc plugins for gRPC development
print_status "Installing Go protoc plugins for gRPC development..."
if command -v go >/dev/null 2>&1; then
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
  print_status "  → Installed protoc-gen-go and protoc-gen-go-grpc"
else
  print_warning "Go not found, skipping protoc plugin installation"
fi

# Ensure Nix tools (including modern bash) take precedence in PATH
print_status "Configuring shell environment for Nix tools..."
NIX_PROFILE_PATH="${HOME}/.nix-profile/bin"

# Add to shell configuration files to ensure proper PATH ordering
for shell_config in "${HOME}/.zprofile" "${HOME}/.bash_profile" "${HOME}/.profile"; do
  if [[ -f "${shell_config}" ]] || [[ "${shell_config}" = "${HOME}/.zprofile" ]]; then
    # Remove any existing nix profile path entries to avoid duplicates
    if [[ -f "${shell_config}" ]]; then
      grep -v "/.nix-profile/bin" "${shell_config}" >"${shell_config}.tmp" && mv "${shell_config}.tmp" "${shell_config}"
    fi
    # Add nix profile path at the beginning (prepend to PATH)
    echo "# Nix package manager - ensure modern tools take precedence" >>"${shell_config}"
    echo "export PATH=\"${NIX_PROFILE_PATH}:\$PATH\"" >>"${shell_config}"
    print_status "  → Updated ${shell_config}"
  fi
done

# Configure fish shell specifically for Nix environment
# print_status "Configuring fish shell for Nix environment..."
# FISH_CONFIG_DIR="$HOME/.config/fish"
# FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
#
# if [[ -f "${FISH_CONFIG_FILE}" ]]; then
#     # Check if Nix environment is already configured to avoid duplicates
#     if ! grep -q "nix.fish" "$FISH_CONFIG_FILE" && ! grep -q "NIX_PROFILES" "$FISH_CONFIG_FILE"; then
#         # Remove any existing Nix configurations to avoid duplicates
#         # Remove simple PATH additions and any references to nix profile
#         grep -v -E "(\.nix-profile/bin|NIX_PROFILES|nix\.fish)" "$FISH_CONFIG_FILE" > "$FISH_CONFIG_FILE.tmp" && mv "$FISH_CONFIG_FILE.tmp" "$FISH_CONFIG_FILE"
#         # Add Nix environment setup at the beginning of fish config
#         {
#             echo "# Nix environment setup"
#             echo "if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish"
#             echo "    source /nix/var/nix/profiles/default/etc/profile.d/nix.fish"
#             echo "end"
#             echo ""
#             cat "$FISH_CONFIG_FILE"
#         } > "$FISH_CONFIG_FILE.tmp" && mv "$FISH_CONFIG_FILE.tmp" "$FISH_CONFIG_FILE"
#         print_status "  → Updated fish configuration for Nix environment"
#     else
#         print_status "  → Fish configuration already includes Nix environment setup"
#     fi
# else
#     print_warning "Fish config file not found at $FISH_CONFIG_FILE"
# fi

print_status "Modern bash and other Nix tools will now take precedence in new shells"
print_status "Verify with: /usr/bin/env bash --version (should show 5.2.x)"

# Change default shell to fish
print_status "Setting up fish as default shell..."

# Store current shell for restoration (used by uninstall script)
if [[ ! -f "${HOME}/.dotfiles/.shell_backup" ]]; then
  CURRENT_SHELL=$(dscl . -read "/Users/$USER" UserShell | cut -d' ' -f2)
  echo "ORIGINAL_SHELL=$CURRENT_SHELL" >"$HOME/.dotfiles/.shell_backup"
fi

# Add Nix fish to /etc/shells if not already there
FISH_PATH="$HOME/.nix-profile/bin/fish"
if ! grep -q "$FISH_PATH" /etc/shells; then
  print_status "Adding fish to /etc/shells..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# Change default shell to fish
print_status "Changing default shell to fish..."
chsh -s "$FISH_PATH" || print_warning "Failed to change default shell to fish"

# Verify the change
NEW_SHELL=$(dscl . -read "/Users/$USER" UserShell | cut -d' ' -f2)
if [[ "${NEW_SHELL}" = "${FISH_PATH}" ]]; then
  print_status "✅ Default shell changed to fish successfully"
  print_status "New terminals will use fish with starship prompt"
else
  print_warning "Shell change may not have taken effect immediately"
fi

# On macOS, install Homebrew if not present and then install GUI apps
if [[ "$(uname)" = "Darwin" ]]; then
  # Check if Homebrew is installed and working
  if [[ -f "/opt/homebrew/bin/brew" ]] || [[ -f "/usr/local/bin/brew" ]]; then
    print_status "Homebrew is already installed"
    # Source Homebrew environment
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # Install GUI apps via Brewfile
    print_status "Installing GUI apps via Brewfile..."
    brew bundle --file="$HOME/.dotfiles/brew/Brewfile" || print_warning "brew bundle failed"
  else
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    print_status "Configuring Homebrew in PATH..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    if command -v is_ci &>/dev/null && is_ci; then
      print_status "Homebrew installed! Continuing in CI mode..."
      # Export Homebrew PATH to GitHub Actions for subsequent steps
      if [[ -n "${GITHUB_PATH}" ]]; then
        echo "/opt/homebrew/bin" >>"${GITHUB_PATH}"
        echo "/usr/local/bin" >>"${GITHUB_PATH}"
      fi
      # Install GUI apps via Brewfile
      brew bundle --file="$HOME/.dotfiles/brew/Brewfile" || print_warning "brew bundle failed"
    else
      print_status "Homebrew installed! Please restart your terminal and run this script again."
      exit 0
    fi
  fi
fi

# Set up PyUNO integration for unoserver (macOS with LibreOffice)
setup_pyuno_macos

# Ensure Nix experimental features are enabled for flakes and nix-command
mkdir -p "$HOME/.config/nix"
if ! grep -q 'experimental-features = nix-command flakes' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  echo 'experimental-features = nix-command flakes' >>"$HOME/.config/nix/nix.conf"
  print_status "Enabled Nix experimental features: nix-command flakes in ~/.config/nix/nix.conf"
fi

# Ensure pnpm is available (workaround for broken Nix package)
if ! command -v pnpm >/dev/null 2>&1; then
  print_status "pnpm not found via Nix; installing globally with npm as a workaround..."
  npm install -g pnpm
else
  print_status "pnpm is already installed."
fi

# Install Cloudflare Wrangler via npm (Nix package has large downloads)
print_status "Installing Cloudflare Wrangler..."
if ! command -v wrangler >/dev/null 2>&1; then
  npm install -g wrangler@latest
  print_status "Wrangler installed successfully"
else
  print_status "Wrangler is already installed"
fi

# Configure uv to use Nix Python (avoid Homebrew Python conflicts)
UV_CONFIG_SCRIPT="$SCRIPT_DIR/scripts/configure-uv.sh"
if [[ -f "$UV_CONFIG_SCRIPT" ]]; then
  print_status "Configuring uv to use Nix Python..."
  if "$UV_CONFIG_SCRIPT"; then
    print_status "uv configured successfully"
  else
    print_warning "uv configuration failed (non-critical)"
  fi
fi

# Set up Python development tools using uv (ultra-fast Python package manager)
# This installs common Python development tools in isolated environments
print_status "Setting up Python development tools..."
PYTHON_TOOLS_SCRIPT="$SCRIPT_DIR/scripts/setup-python-tools-uv.sh"
if [[ -f "$PYTHON_TOOLS_SCRIPT" ]]; then
  print_status "Running Python tools setup with uv (this may take a few minutes)..."
  if "$PYTHON_TOOLS_SCRIPT"; then
    print_status "Python development tools installed successfully"
  else
    print_warning "Python tools setup encountered issues (non-critical)"
  fi
else
  print_warning "Python tools setup script not found (skipping)"
fi

# Optional: Set up OpenHands (AI coding assistant)
if [[ "${SETUP_OPENHANDS:-}" == "true" ]]; then
  print_status "Setting up OpenHands AI coding assistant..."
  if [[ -x "$HOME/.dotfiles/scripts/setup-openhands.sh" ]]; then
    "$HOME/.dotfiles/scripts/setup-openhands.sh" install
    print_status "OpenHands setup complete!"
    print_status "Access at: http://localhost:3030"
    print_status "Remember to add your API keys in ~/.config/openhands/config.env"
  else
    print_warning "OpenHands setup script not found or not executable"
  fi
else
  print_status "Tip: Set SETUP_OPENHANDS=true to install OpenHands AI coding assistant"
fi

print_status "Bootstrap completed!"

# Final bash check if we were running with old bash
if [[ -n "${BASH_VERSION}" ]] && [[ "${BASH_MAJOR_VERSION}" -lt 4 ]]; then
  if [[ -x "$HOME/.nix-profile/bin/bash" ]]; then
    MODERN_BASH_VERSION=$("$HOME/.nix-profile/bin/bash" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [[ -n "$MODERN_BASH_VERSION" ]]; then
      echo ""
      echo "🎉 Modern Bash ${MODERN_BASH_VERSION} is now available!"
      echo "   New terminal sessions will automatically use it."
      echo "   To use it in the current session: exec $HOME/.nix-profile/bin/bash"
    fi
  fi
fi

print_status "Your system is now fully configured. Enjoy!"
echo "Bootstrap completed at $(date)"
echo "Log saved to: $BOOTSTRAP_LOG"
