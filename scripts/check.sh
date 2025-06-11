#!/bin/bash

# check.sh
# Pre-bootstrap system state checker and backup utility
# Checks what's already installed and offers to create backups for restoration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
FOUND_ITEMS=()
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Function to print status messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_found() {
    echo -e "${YELLOW}⚠${NC} $1"
    FOUND_ITEMS+=("$1")
}

print_clean() {
    echo -e "${BLUE}○${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_section() {
    echo ""
    echo -e "${BLUE}==== $1 ====${NC}"
}

# Function to create restore script
create_restore_script() {
    cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
# Auto-generated restore script

echo "🔄 Restoring backed up configurations..."

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Restore shell configs
for config in .zshrc .bashrc .bash_profile .profile; do
    if [ -f "$BACKUP_DIR/$config" ]; then
        cp "$BACKUP_DIR/$config" "$HOME/"
        echo "✓ Restored $config"
    fi
done

# Restore config directories
for dir in config-*; do
    if [ -d "$BACKUP_DIR/$dir" ]; then
        mkdir -p "$HOME/.config"
        cp -r "$BACKUP_DIR/$dir" "$HOME/.config/$(echo $dir | sed 's/config-//')"
        echo "✓ Restored $dir"
    fi
done

echo "✅ Restoration complete!"
EOF

    chmod +x "$BACKUP_DIR/restore.sh"
}

# Function to create full backup
create_full_backup() {
    echo ""
    echo -e "${BLUE}Creating full backup at: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Backup shell configs
    for config in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
        if [ -f "$config" ]; then
            cp "$config" "$BACKUP_DIR/"
            echo "✓ Backed up $(basename $config)"
        fi
    done
    
    # Backup config directories
    for dir in ~/.config/fish ~/.config/zsh ~/.config/starship ~/.config/git; do
        if [ -d "$dir" ]; then
            cp -r "$dir" "$BACKUP_DIR/config-$(basename $dir)"
            echo "✓ Backed up $dir"
        fi
    done
    
    # Backup Homebrew package list
    if command -v brew &> /dev/null; then
        brew bundle dump --file="$BACKUP_DIR/Brewfile.backup" --force
        echo "✓ Backed up Homebrew package list"
    fi
    
    # Create restoration script
    create_restore_script
    
    echo ""
    echo -e "${GREEN}✅ Backup created successfully!${NC}"
    echo "Backup location: $BACKUP_DIR"
    echo "To restore later, run: $BACKUP_DIR/restore.sh"
}

# Function to create selective backup
create_selective_backup() {
    echo ""
    echo "Select items to backup:"
    # This would be expanded with interactive selection
    echo "(Selective backup not implemented yet - creating full backup instead)"
    create_full_backup
}

# Function to clean up found items
cleanup_found_items() {
    echo ""
    echo -e "${RED}⚠️  WARNING: This will delete existing configurations!${NC}"
    echo "This action cannot be undone. The following will be removed:"
    echo ""
    
    # Show what will be deleted
    if [ -d "$HOME/.config/fish" ]; then
        echo "• Fish shell configuration directory"
    fi
    
    # Check for broken symlinks
    BROKEN_COUNT=$(find ~ -maxdepth 3 -type l -exec file {} \; 2>/dev/null | grep "broken" | wc -l | tr -d ' ')
    if [ "$BROKEN_COUNT" -gt 0 ]; then
        echo "• $BROKEN_COUNT broken symlinks"
    fi
    
    # Check for leftover state directories
    for dir in ~/.local/state/nix ~/.local/state/home-manager ~/.cache/nix ~/.config/home-manager; do
        if [ -d "$dir" ]; then
            echo "• $(echo $dir | sed "s|$HOME|~|")"
        fi
    done
    
    echo ""
    echo -e "${RED}Are you absolutely sure you want to delete these items? (yes/no)${NC}"
    read -p "> " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo "Cleanup cancelled."
        return 0
    fi
    
    echo ""
    echo -e "${BLUE}Cleaning up found items...${NC}"
    
    # Remove broken symlinks
    echo "Removing broken symlinks..."
    find ~ -maxdepth 3 -type l -exec sh -c 'test ! -e "$1" && echo "Removing: $1" && rm "$1"' sh {} \; 2>/dev/null || true
    
    # Remove leftover Nix/Home Manager directories
    for dir in ~/.local/state/nix ~/.local/state/home-manager ~/.local/share/home-manager ~/.cache/nix ~/.config/home-manager; do
        if [ -d "$dir" ]; then
            echo "Removing: $(echo $dir | sed "s|$HOME|~|")"
            rm -rf "$dir"
        fi
    done
    
    # Remove empty Fish config directory if it exists but is empty or only has broken symlinks
    if [ -d "$HOME/.config/fish" ]; then
        FISH_FILES=$(find "$HOME/.config/fish" -type f 2>/dev/null | wc -l | tr -d ' ')
        FISH_LINKS=$(find "$HOME/.config/fish" -type l 2>/dev/null | wc -l | tr -d ' ')
        if [ "$FISH_FILES" -eq 0 ] && [ "$FISH_LINKS" -eq 0 ]; then
            echo "Removing empty Fish config directory..."
            rmdir "$HOME/.config/fish" 2>/dev/null || true
        elif [ "$FISH_FILES" -eq 0 ]; then
            echo "Fish config directory contains only symlinks, checking if they're broken..."
            BROKEN_FISH=$(find "$HOME/.config/fish" -type l -exec file {} \; 2>/dev/null | grep "broken" | wc -l | tr -d ' ')
            if [ "$BROKEN_FISH" -eq "$FISH_LINKS" ]; then
                echo "All Fish symlinks are broken, removing directory..."
                rm -rf "$HOME/.config/fish"
            fi
        else
            echo "Removing Fish config directory and all contents..."
            rm -rf "$HOME/.config/fish"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✅ Cleanup completed!${NC}"
    echo ""
    echo -e "${BLUE}Re-running check to verify cleanup...${NC}"
    echo ""
    
    # Clear the found items array and re-run the check
    FOUND_ITEMS=()
    exec "$0"
}

#########################################
# MAIN SCRIPT LOGIC STARTS HERE
#########################################

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

echo "🔍 System State Check - $(date)"
echo "Checking for existing installations and configurations..."

# Check Nix
print_section "Nix Package Manager"
if [ -d "/nix" ]; then
    print_found "Nix directory exists at /nix"
    if command -v nix &> /dev/null; then
        NIX_VERSION=$(nix --version 2>/dev/null | head -1)
        print_found "Nix command available: $NIX_VERSION"
    fi
    if [ -d "$HOME/.nix-profile" ]; then
        print_found "User Nix profile exists"
    fi
    if [ -d "/etc/nix" ]; then
        print_found "System Nix configuration exists"
    fi
else
    print_clean "No Nix installation found"
fi

# Check Home Manager
print_section "Home Manager"
if command -v home-manager &> /dev/null; then
    HM_VERSION=$(home-manager --version 2>/dev/null || echo "unknown")
    print_found "Home Manager installed: $HM_VERSION"
fi
if [ -d "$HOME/.config/home-manager" ]; then
    print_found "Home Manager configuration exists"
fi
if [ -d "$HOME/.local/state/home-manager" ]; then
    print_found "Home Manager state directory exists"
fi
if [ ! -d "$HOME/.config/home-manager" ] && [ ! -d "$HOME/.local/state/home-manager" ] && ! command -v home-manager &> /dev/null; then
    print_clean "No Home Manager installation found"
fi

# Check Homebrew
print_section "Homebrew"
if [ -d "/opt/homebrew" ]; then
    print_found "Homebrew directory exists at /opt/homebrew"
    if command -v brew &> /dev/null; then
        BREW_VERSION=$(brew --version 2>/dev/null | head -1)
        print_found "Homebrew command available: $BREW_VERSION"
        
        # Count packages
        BREW_PACKAGES=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
        BREW_CASKS=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
        if [ "$BREW_PACKAGES" -gt 0 ] || [ "$BREW_CASKS" -gt 0 ]; then
            print_found "Homebrew packages: $BREW_PACKAGES formulae, $BREW_CASKS casks"
        fi
    fi
else
    print_clean "No Homebrew installation found"
fi

# Check Chezmoi
print_section "Chezmoi"
if command -v chezmoi &> /dev/null; then
    CHEZMOI_VERSION=$(chezmoi --version 2>/dev/null | head -1)
    print_found "Chezmoi installed: $CHEZMOI_VERSION"
fi
if [ -d "$HOME/.config/chezmoi" ]; then
    print_found "Chezmoi configuration exists"
fi
if [ -d "$HOME/.local/share/chezmoi" ]; then
    print_found "Chezmoi source directory exists"
fi
if ! command -v chezmoi &> /dev/null && [ ! -d "$HOME/.config/chezmoi" ] && [ ! -d "$HOME/.local/share/chezmoi" ]; then
    print_clean "No Chezmoi installation found"
fi

# Check Shell Configuration
print_section "Shell Configuration"
CURRENT_SHELL=$(echo $SHELL)
DEFAULT_SHELL=$(dscl . -read /Users/$USER UserShell | cut -d' ' -f2)
echo "Current shell: $CURRENT_SHELL"
echo "Default shell: $DEFAULT_SHELL"

if [[ "$DEFAULT_SHELL" == *"fish"* ]]; then
    print_found "Default shell is Fish"
fi

# Check for existing shell configs
for config in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile ~/.config/fish/config.fish; do
    if [ -f "$config" ]; then
        print_found "Shell config exists: $config"
    fi
done

# Check for shell config directories
for dir in ~/.config/fish ~/.config/zsh; do
    if [ -d "$dir" ]; then
        print_found "Shell config directory exists: $dir"
    fi
done

# Check Development Tools
print_section "Development Tools"
# System tools that come with macOS (don't count as problems)
SYSTEM_TOOLS=("git" "python3" "ruby")
# Tools that would be installed by our bootstrap
BOOTSTRAP_TOOLS=("node" "npm" "go" "rust" "cargo" "gh" "bun")

echo "System tools (built into macOS):"
for tool in "${SYSTEM_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        VERSION=$($tool --version 2>/dev/null | head -1 || echo "installed")
        echo "  ✓ $tool: $VERSION"
    fi
done

echo "Bootstrap-managed tools:"
BOOTSTRAP_TOOLS_FOUND=0
for tool in "${BOOTSTRAP_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        VERSION=$($tool --version 2>/dev/null | head -1 || echo "installed")
        print_found "$tool: $VERSION"
        BOOTSTRAP_TOOLS_FOUND=1
    fi
done

if [ "$BOOTSTRAP_TOOLS_FOUND" -eq 0 ]; then
    print_clean "No bootstrap-managed tools found"
fi

# Check Version Managers
print_section "Version Managers"
VERSION_MANAGERS=("nvm" "pyenv" "rbenv" "asdf")
for vm in "${VERSION_MANAGERS[@]}"; do
    if [ -d "$HOME/.$vm" ]; then
        print_found "$vm directory exists"
    fi
    if command -v "$vm" &> /dev/null; then
        print_found "$vm command available"
    fi
done

# Check for broken symlinks (common after failed uninstalls)
print_section "Broken Symlinks"
BROKEN_LINKS=$(find ~ -maxdepth 3 -type l -exec file {} \; 2>/dev/null | grep "broken" | wc -l | tr -d ' ')
if [ "$BROKEN_LINKS" -gt 0 ]; then
    print_found "$BROKEN_LINKS broken symlinks found in home directory"
    echo "   (Run 'find ~ -maxdepth 3 -type l -exec file {} \\; 2>/dev/null | grep broken' to see them)"
else
    print_clean "No broken symlinks found"
fi

# Check for leftover Nix/Home Manager state directories
print_section "Leftover State Directories"
STATE_DIRS_FOUND=0
for dir in ~/.local/state/nix ~/.local/state/home-manager ~/.local/share/home-manager ~/.cache/nix ~/.config/home-manager; do
    if [ -d "$dir" ]; then
        print_found "Leftover directory: $(echo $dir | sed "s|$HOME|~|")"
        STATE_DIRS_FOUND=1
    fi
done

# Check for other common leftover files
LEFTOVER_FILES=(
    "$HOME/.cache/.keep"
    "$HOME/.manpath"
    "$HOME/Applications/Home Manager Apps"
)

for file in "${LEFTOVER_FILES[@]}"; do
    if [ -e "$file" ]; then
        print_found "Leftover file/link: $(echo $file | sed "s|$HOME|~|")"
        STATE_DIRS_FOUND=1
    fi
done

if [ "$STATE_DIRS_FOUND" -eq 0 ]; then
    print_clean "No leftover state directories found"
fi

# Summary
print_section "Summary"
if [ ${#FOUND_ITEMS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ System is clean!${NC}"
    echo "No existing installations or configurations found."
    echo "You can safely run bootstrap without concerns about conflicts."
else
    echo -e "${YELLOW}⚠️  Found ${#FOUND_ITEMS[@]} existing items:${NC}"
    for item in "${FOUND_ITEMS[@]}"; do
        echo "   • $item"
    done
    echo ""
    echo "These items may be:"
    echo "• Overwritten by bootstrap"
    echo "• Cause conflicts during installation"
    echo "• Be lost if you run unbootstrap later"
fi

# Offer action options
if [ ${#FOUND_ITEMS[@]} -gt 0 ]; then
    echo ""
    echo -e "${BLUE}🔧 Action Options:${NC}"
    echo "What would you like to do with the existing items?"
    echo ""
    echo "1) Create full backup (recommended for valuable configs)"
    echo "2) Create selective backup (choose what to backup)"  
    echo "3) Clean up/delete found items (⚠️  destructive)"
    echo "4) Skip and continue as-is"
    echo "5) Exit without making changes"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            create_full_backup
            ;;
        2)
            create_selective_backup
            ;;
        3)
            cleanup_found_items
            ;;
        4)
            echo "Continuing without changes..."
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac
fi 