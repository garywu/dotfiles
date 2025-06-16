#!/bin/sh

# Check for old Bash and handle compatibility
if [ -n "$BASH_VERSION" ]; then
    BASH_MAJOR_VERSION=$(echo $BASH_VERSION | cut -d. -f1)
    if [ "$BASH_MAJOR_VERSION" -lt 4 ]; then
        echo "⚠️  Detected old Bash version: $BASH_VERSION"
        echo "   macOS ships with Bash 3.2 (2007) due to licensing."
        echo "   Modern features may not work properly."
        echo ""
        echo "🔧 Installing modern Bash via Nix (will be available after bootstrap)..."
        echo ""
    fi
fi

# Setup logging
BOOTSTRAP_LOG="$HOME/.dotfiles/logs/bootstrap-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$(dirname "$BOOTSTRAP_LOG")"

# Function to log and display
log_and_echo() {
    echo "$1" | tee -a "$BOOTSTRAP_LOG"
}

echo "Bootstrap started at $(date)" | tee "$BOOTSTRAP_LOG"
echo "System: $(uname -a)" | tee -a "$BOOTSTRAP_LOG"
echo "User: $(whoami)" | tee -a "$BOOTSTRAP_LOG"
echo "PWD: $(pwd)" | tee -a "$BOOTSTRAP_LOG"
echo "PATH: $PATH" | tee -a "$BOOTSTRAP_LOG"
echo "Log file: $BOOTSTRAP_LOG" | tee -a "$BOOTSTRAP_LOG"
echo "---" | tee -a "$BOOTSTRAP_LOG"

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
        if [ -f "$backup_file" ]; then
            found_backups=true
            print_warning "Found Nix backup file: $backup_file"
        fi
    done

    if [ "$found_backups" = true ]; then
        echo ""
        echo "According to the official Nix documentation, these backup files contain"
        echo "your original system configuration and should be restored."
        echo ""
        echo "The Nix installer cannot proceed with these backup files present."
        echo "Following official documentation, the recommended action is to restore"
        echo "the backup files to their original locations."
        echo ""
        printf "Restore backup files as recommended by official Nix docs? [Y/n]: "
        read -r response

        case "$response" in
            [nN]|[nN][oO])
                print_warning "Moving backup files to /tmp (you can restore them later)"
                local timestamp=$(date +%s)
                for backup_file in "${official_backups[@]}"; do
                    if [ -f "$backup_file" ]; then
                        local basename=$(basename "$backup_file")
                        sudo mv "$backup_file" "/tmp/${basename}.${timestamp}" 2>/dev/null && \
                            echo "  → Moved $backup_file to /tmp/${basename}.${timestamp}"
                    fi
                done
                ;;
            *)
                print_status "Restoring backup files (following official Nix documentation)..."

                # Follow exact commands from official docs
                if [ -f "/etc/zshrc.backup-before-nix" ]; then
                    sudo mv /etc/zshrc.backup-before-nix /etc/zshrc && \
                        print_status "  → Restored /etc/zshrc"
                fi

                if [ -f "/etc/zsh/zshrc.backup-before-nix" ]; then
                    sudo mv /etc/zsh/zshrc.backup-before-nix /etc/zsh/zshrc && \
                        print_status "  → Restored /etc/zsh/zshrc"
                fi

                if [ -f "/etc/bashrc.backup-before-nix" ]; then
                    sudo mv /etc/bashrc.backup-before-nix /etc/bashrc && \
                        print_status "  → Restored /etc/bashrc"
                fi

                if [ -f "/etc/bash.bashrc.backup-before-nix" ]; then
                    sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc && \
                        print_status "  → Restored /etc/bash.bashrc"
                fi

                print_status "Backup files restored per official documentation."
                print_status "System is now clean for a fresh Nix installation."
                ;;
        esac
    fi

    # Clean up other remnants (also from official docs)
    if [ -f "/etc/nix/nix.conf" ]; then
        print_warning "Removing leftover Nix configuration..."
        sudo rm -rf /etc/nix 2>/dev/null || print_warning "Could not remove /etc/nix"
    fi

    if [ -f "/Library/LaunchDaemons/org.nixos.nix-daemon.plist" ]; then
        print_warning "Removing leftover Nix daemon service..."
        sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
        sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || \
            print_warning "Could not remove daemon plist"
    fi

    if [ -f "/Library/LaunchDaemons/org.nixos.darwin-store.plist" ]; then
        print_warning "Removing leftover Darwin store service..."
        sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true
        sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || \
            print_warning "Could not remove darwin-store plist"
    fi

    print_status "Cleanup completed following official documentation"
}

# Check if we're in a fresh shell with Nix environment
if ! command_exists nix; then
    handle_nix_remnants

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

    # Install Home Manager
    nix-shell '<home-manager>' -A install || print_error "Failed to install Home Manager"

    print_status "Home Manager installed! Please restart your terminal and run this script again."
    exit 0
fi

# Set NIX_PATH if not set (needed for home-manager to work properly)
if [ -z "$NIX_PATH" ]; then
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
fi

# Setup Home Manager configuration link
print_status "Setting up Home Manager configuration..."
mkdir -p ~/.config/home-manager
if [ -f ~/.config/home-manager/home.nix ] && [ ! -L ~/.config/home-manager/home.nix ]; then
    print_warning "Backing up existing home.nix..."
    mv ~/.config/home-manager/home.nix ~/.config/home-manager/home.nix.backup
fi
ln -sf ~/.dotfiles/nix/home.nix ~/.config/home-manager/home.nix

# Install chezmoi temporarily to get dotfiles, then Home Manager will manage it
if ! command_exists chezmoi; then
    print_status "Installing chezmoi temporarily..."
    nix-env -iA nixpkgs.chezmoi || print_error "Failed to install chezmoi"
fi

# Get the repository URL
if [ -d .git ]; then
    REPO_URL=$(git remote get-url origin 2>/dev/null) || print_error "Not a git repository or no remote 'origin' found"
else
    print_error "Not a git repository"
fi

print_status "Using repository: $REPO_URL"

# Sync chezmoi-managed files from repo to Chezmoi's source directory
rsync -a --delete "$HOME/.dotfiles/chezmoi/" "$HOME/.local/share/chezmoi/"

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

# Ensure Nix tools (including modern bash) take precedence in PATH
print_status "Configuring shell environment for Nix tools..."
NIX_PROFILE_PATH="$HOME/.nix-profile/bin"

# Add to shell configuration files to ensure proper PATH ordering
for shell_config in "$HOME/.zprofile" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$shell_config" ] || [ "$shell_config" = "$HOME/.zprofile" ]; then
        # Remove any existing nix profile path entries to avoid duplicates
        if [ -f "$shell_config" ]; then
            grep -v "/.nix-profile/bin" "$shell_config" > "$shell_config.tmp" && mv "$shell_config.tmp" "$shell_config"
        fi
        # Add nix profile path at the beginning (prepend to PATH)
        echo "# Nix package manager - ensure modern tools take precedence" >> "$shell_config"
        echo "export PATH=\"$NIX_PROFILE_PATH:\$PATH\"" >> "$shell_config"
        print_status "  → Updated $shell_config"
    fi
done

# Configure fish shell specifically for Nix environment
# print_status "Configuring fish shell for Nix environment..."
# FISH_CONFIG_DIR="$HOME/.config/fish"
# FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
#
# if [ -f "$FISH_CONFIG_FILE" ]; then
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
if [ ! -f "$HOME/.dotfiles/.shell_backup" ]; then
  CURRENT_SHELL=$(dscl . -read "/Users/$USER" UserShell | cut -d' ' -f2)
  echo "ORIGINAL_SHELL=$CURRENT_SHELL" > "$HOME/.dotfiles/.shell_backup"
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
if [ "$NEW_SHELL" = "$FISH_PATH" ]; then
    print_status "✅ Default shell changed to fish successfully"
    print_status "New terminals will use fish with starship prompt"
else
    print_warning "Shell change may not have taken effect immediately"
fi

# On macOS, install Homebrew if not present and then install GUI apps
if [ "$(uname)" = "Darwin" ]; then
    # Check if Homebrew is installed and working
    if [ -f "/opt/homebrew/bin/brew" ] || [ -f "/usr/local/bin/brew" ]; then
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
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"

        print_status "Homebrew installed! Please restart your terminal and run this script again."
        exit 0
    fi
fi

# Ensure Nix experimental features are enabled for flakes and nix-command
mkdir -p "$HOME/.config/nix"
if ! grep -q 'experimental-features = nix-command flakes' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
  print_status "Enabled Nix experimental features: nix-command flakes in ~/.config/nix/nix.conf"
fi

# Ensure pnpm is available (workaround for broken Nix package)
if ! command -v pnpm >/dev/null 2>&1; then
    print_status "pnpm not found via Nix; installing globally with npm as a workaround..."
    npm install -g pnpm
else
    print_status "pnpm is already installed."
fi

print_status "Bootstrap completed!"
print_status "Your system is now fully configured. Enjoy!"
echo "Bootstrap completed at $(date)"
echo "Log saved to: $BOOTSTRAP_LOG"
