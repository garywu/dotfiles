#!/bin/bash

# uninstall.sh (aka unbootstrap.sh)
# This script will completely remove all tools, dotfiles, and configs installed by the bootstrap process.
# It is intended to fully "unbootstrap" your system and restore it to a clean state.
# Use with caution! You will be prompted for confirmation before anything is removed.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Reboot flag (set when an action requires a reboot to complete)
NEEDS_REBOOT=0

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
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Function to verify shell change
verify_shell_change() {
    local target_shell="$1"
    if [ "$(dscl . -read /Users/$USER UserShell | cut -d' ' -f2)" != "$target_shell" ]; then
        print_error "Failed to change shell to $target_shell"
        return 1
    fi
    return 0
}

# Function to restore default shell
restore_default_shell() {
    print_status "Restoring default shell..."
    
    # First, check if we're using fish
    if [[ "$SHELL" == *"fish"* ]]; then
        print_status "Changing from fish to zsh..."
        chsh -s /bin/zsh
        if ! verify_shell_change "/bin/zsh"; then
            print_error "Failed to change shell to zsh"
            return 1
        fi
    fi
}

# Function to stop Nix daemon
stop_nix_daemon() {
    print_status "Stopping Nix daemon..."
    
    # Try to stop the daemon using launchctl
    if [ -f "/Library/LaunchDaemons/org.nixos.nix-daemon.plist" ]; then
        print_status "Stopping Nix daemon service..."
        sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist || true
        sudo launchctl bootout system/org.nixos.nix-daemon || true
    fi
    
    # Kill any running nix-daemon processes
    if pgrep -f "nix-daemon" > /dev/null; then
        print_status "Killing any running nix-daemon processes..."
        sudo pkill -f "nix-daemon" || true
    fi
    
    # Kill any Nix installer repair processes
    print_status "Checking for Nix installer repair processes..."
    NIX_REPAIR_PIDS=$(ps aux | grep "nix-installer repair" | grep -v grep | awk '{print $2}')
    if [ -n "$NIX_REPAIR_PIDS" ]; then
        print_status "Found Nix installer repair processes: $NIX_REPAIR_PIDS"
        for pid in $NIX_REPAIR_PIDS; do
            print_status "Killing Nix installer repair process $pid..."
            sudo kill -9 "$pid" || true
        done
    fi
    
    # Kill any wait4path processes for Nix
    print_status "Checking for Nix wait4path processes..."
    NIX_WAIT_PIDS=$(ps aux | grep "wait4path /nix" | grep -v grep | awk '{print $2}')
    if [ -n "$NIX_WAIT_PIDS" ]; then
        print_status "Found Nix wait4path processes: $NIX_WAIT_PIDS"
        for pid in $NIX_WAIT_PIDS; do
            print_status "Killing Nix wait4path process $pid..."
            sudo kill -9 "$pid" || true
        done
    fi
    
    # Wait a moment for processes to stop
    sleep 2
    
    # Verify no Nix processes are running
    if pgrep -f "(nix-daemon|nix-installer|wait4path.*nix)" > /dev/null; then
        print_warning "Some Nix processes are still running. You may need to restart your computer."
        return 1
    fi
    
    return 0
}

# Function to handle system processes preventing unmount
handle_unmount_blockers() {
    print_status "Checking for processes preventing unmount..."
    
    # Get the list of processes using the Nix volume
    BLOCKERS=$(lsof +D /nix 2>/dev/null | grep -v "COMMAND" | awk '{print $2}')
    if [ -n "$BLOCKERS" ]; then
        print_status "Found processes using Nix volume: $BLOCKERS"
        for pid in $BLOCKERS; do
            # Skip system processes (PPID 1)
            if [ "$(ps -o ppid= -p $pid)" = "1" ]; then
                print_warning "System process $pid is using Nix volume. A restart may be required."
                continue
            fi
            print_status "Killing process $pid..."
            sudo kill -9 "$pid" || true
        done
    fi
    
    # Wait a moment for processes to stop
    sleep 2
}

# Function to remove Nix APFS volume
remove_nix_volume() {
    print_status "Removing Nix APFS volume..."
    
    # Find the Nix volume
    NIX_VOLUME=$(diskutil list | grep "Nix Store" | awk '{print $NF}')
    if [ -n "$NIX_VOLUME" ]; then
        print_status "Found Nix volume: $NIX_VOLUME"
        
        # Handle any processes preventing unmount
        handle_unmount_blockers
        
        # First try to unmount the volume
        print_status "Unmounting Nix volume..."
        sudo diskutil unmountDisk force "/dev/$NIX_VOLUME" || true
        
        # Wait a moment for unmount to complete
        sleep 2
        
        # Then try to remove the volume
        print_status "Removing Nix volume..."
        sudo diskutil apfs deleteVolume "/dev/$NIX_VOLUME" || true
        
        # Wait a moment for removal to complete
        sleep 2
        
        # Verify the volume is gone
        if diskutil list | grep -q "Nix Store"; then
            print_warning "Nix volume still exists. A system restart may be required."
            return 1
        fi
    else
        print_status "No Nix volume found"
    fi
    
    return 0
}

# Function to remove synthetic mount entry for /nix (single-user install)
remove_synthetic_nix() {
    # Return 0 if nothing was changed so callers can decide what to do
    if [ ! -f /etc/synthetic.conf ]; then
        return 0
    fi

    if ! sudo grep -q '^nix$' /etc/synthetic.conf; then
        return 0
    fi

    echo "==> Removing synthetic mount for /nix (entry found in /etc/synthetic.conf)"
    echo "    A reboot will be required before /nix disappears from the filesystem."

    # Backup existing file first
    sudo cp /etc/synthetic.conf /etc/synthetic.conf.backup

    # Remove the nix line
    sudo sed -i '' '/^nix$/d' /etc/synthetic.conf

    # If file is now empty, delete it to avoid leaving an empty synthetic.conf around
    if [ ! -s /etc/synthetic.conf ]; then
        sudo rm /etc/synthetic.conf
    fi

    NEEDS_REBOOT=1
    return 0
}

# Function to remove Nix
remove_nix() {
    echo "==> Removing Nix..."
    
    # Stop Nix daemon and kill any related processes
    echo "==> Stopping Nix daemon..."
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
    sudo pkill -f nix-daemon 2>/dev/null || true
    
    # Check for and kill any Nix installer repair processes
    echo "==> Checking for Nix installer repair processes..."
    sudo pkill -f "nix-installer.*repair" 2>/dev/null || true
    
    # Check for and kill any Nix wait4path processes
    echo "==> Checking for Nix wait4path processes..."
    sudo pkill -f "wait4path.*nix" 2>/dev/null || true
    
    # Remove Nix configuration files
    echo "==> Removing Nix configuration files..."
    sudo rm -rf /etc/nix
    sudo rm -f /etc/profile.d/nix.sh
    sudo rm -f /etc/profile.d/nix-daemon.sh
    
    # Remove Nix from fstab
    sudo sed -i '' '/nix/d' /etc/fstab 2>/dev/null || true
    
    # Remove Nix from shell configurations
    for file in ~/.bash_profile ~/.bashrc ~/.zshrc ~/.profile; do
        if [ -f "$file" ]; then
            sed -i '' '/nix/d' "$file" 2>/dev/null || true
        fi
    done
    
    # Remove Nix directories
    echo "==> Removing Nix directories..."

    # Attempt to remove synthetic mount entry first (may require reboot)
    remove_synthetic_nix

    # First try to unmount /nix if it's mounted
    if mount | grep -q "on /nix"; then
        echo "Found mounted Nix directory, attempting to unmount..."
        sudo umount -f /nix 2>/dev/null || true
    fi
    
    # Check if Nix is on root filesystem (single-user installation)
    if df -h /nix | grep -q "/dev/disk"; then
        echo "Warning: Nix is installed in single-user mode on root filesystem"
        echo "This is not recommended for macOS. After removal, please reinstall using:"
        echo "sh <(curl -L https://nixos.org/nix/install) --daemon"
        echo ""
        
        # Try to remove with diskutil first
        echo "Attempting to remove with diskutil..."
        NIX_DEVICE=$(df -h /nix | grep "/dev/disk" | awk '{print $1}')
        if [ -n "$NIX_DEVICE" ]; then
            echo "Found Nix device: $NIX_DEVICE"
            sudo diskutil unmountDisk force "$NIX_DEVICE" 2>/dev/null || true
            sudo diskutil eraseVolume "Free Space" "$NIX_DEVICE" 2>/dev/null || true
        fi
        
        # If diskutil fails, try direct removal
        if [ -d "/nix" ]; then
            echo "Attempting direct removal..."
            sudo chflags -R nouchg,noschg /nix 2>/dev/null || true
            sudo chmod -R 777 /nix 2>/dev/null || true
            sudo rm -rf /nix
            
            if [ -d "/nix" ]; then
                echo "Error: Could not remove Nix directory"
                echo "Please try the following steps:"
                echo "1. Restart your computer"
                echo "2. Run this script again"
                echo "3. If it still fails, you may need to boot into Recovery Mode"
                echo "   and disable SIP temporarily to remove the directory"
                return 1
            fi
        fi
    else
        # Handle APFS volume case (multi-user installation)
        if [ -d "/nix" ]; then
            sudo rm -rf /nix
        fi
        
        # Try to unmount and remove the Nix volume
        if diskutil list | grep -q "Nix Store"; then
            echo "Found Nix APFS volume, attempting to remove..."
            sudo diskutil unmountDisk /dev/disk3 2>/dev/null || true
            sudo diskutil eraseVolume "Free Space" /dev/disk3 2>/dev/null || true
        fi
    fi
    
    # Verify cleanup
    if [ -d "/nix" ] || [ -d "$HOME/.nix-profile" ] || [ -d "$HOME/.nix-defexpr" ]; then
        echo "Warning: Some Nix directories still exist. Attempting to remove..."
        sudo rm -rf /nix "$HOME/.nix-profile" "$HOME/.nix-defexpr"
        
        if [ -d "/nix" ] || [ -d "$HOME/.nix-profile" ] || [ -d "$HOME/.nix-defexpr" ]; then
            echo "Warning: Could not remove all Nix directories"
            echo "Some components may require a system restart to be fully removed"
            echo "Please restart your computer and run this script again to complete the cleanup"
        fi
    fi
}

# Function to remove Homebrew packages
remove_homebrew() {
    print_status "Removing Homebrew packages..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_status "Homebrew is not installed, skipping package removal"
        return 0
    fi
    
    # Uninstall all packages from Brewfile
    if [ -f "$DOTFILES_DIR/brew/Brewfile" ]; then
        cd "$DOTFILES_DIR/brew" && brew bundle cleanup --force
    fi
    
    # Remove Homebrew itself
    print_status "Removing Homebrew..."
    if [ -f "/opt/homebrew/bin/brew" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    else
        print_status "Homebrew not found in standard location, skipping removal"
    fi
}

# Function to remove chezmoi
remove_chezmoi() {
    print_status "Removing chezmoi..."
    
    if command -v chezmoi &> /dev/null; then
        # Remove chezmoi configuration
        rm -rf ~/.config/chezmoi
        rm -rf ~/.local/share/chezmoi
        
        # Remove chezmoi binary
        rm -f ~/.local/bin/chezmoi
    fi
}

# Function to remove dotfiles
remove_dotfiles() {
    print_status "Removing dotfiles..."
    
    # Remove Starship configuration
    rm -f ~/.config/starship.toml
    
    # Remove version manager configurations
    rm -f ~/.config/version-managers.zsh
    
    # Remove NVM
    rm -rf ~/.nvm
    
    # Remove pyenv
    rm -rf ~/.pyenv
    
    # Remove rbenv
    rm -rf ~/.rbenv
    
    # Remove asdf
    rm -rf ~/.asdf
}

# Function to clean up environment variables
cleanup_env() {
    print_status "Cleaning up environment variables..."
    
    # Remove Homebrew from PATH
    if [ -f ~/.zprofile ]; then
        sed -i '' '/brew shellenv/d' ~/.zprofile
    fi
    
    # Remove Nix from PATH
    if [ -f ~/.zprofile ]; then
        sed -i '' '/nix-daemon.sh/d' ~/.zprofile
    fi
    
    # Remove version managers from PATH
    if [ -f ~/.zshrc ]; then
        sed -i '' '/nvm/d' ~/.zshrc
        sed -i '' '/pyenv/d' ~/.zshrc
        sed -i '' '/rbenv/d' ~/.zshrc
        sed -i '' '/asdf/d' ~/.zshrc
    fi
}

# Function to verify cleanup
verify_cleanup() {
    print_status "Verifying cleanup..."
    local failed=0
    
    # Check for Nix directories
    if [ -d "/nix" ]; then
        print_warning "Nix directories still exist. Attempting to remove..."
        if mount | grep -q "/nix"; then
            print_warning "Nix directory is still mounted. A system restart may be required."
            failed=1
        else
            # Check if it's on root filesystem
            if df -h /nix | grep -q "/dev/disk"; then
                print_warning "Nix directory is on root filesystem and may be protected by SIP"
                print_warning "Attempting to remove with elevated privileges..."
                
                # Try to remove with elevated privileges
                sudo chflags -R nouchg /nix
                sudo chflags -R noschg /nix
                sudo chmod -R 777 /nix
                sudo rm -rf /nix/* || true
                sudo rm -rf /nix || true
                
                if [ -d "/nix" ]; then
                    print_warning "Could not remove Nix directory. This is likely due to System Integrity Protection (SIP)"
                    print_warning "You may need to boot into Recovery Mode and disable SIP to remove the directory"
                    print_warning "See: https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection"
                    failed=1
                fi
            else
                sudo rm -rf /nix || {
                    print_warning "Could not remove Nix directories. A system restart may be required."
                    failed=1
                }
            fi
        fi
    fi
    
    # Check for Nix configuration files
    if [ -f "/etc/nix/nix.conf" ] || [ -d "/etc/nix" ]; then
        print_warning "Nix configuration files still exist. Attempting to remove..."
        sudo rm -rf /etc/nix || {
            print_warning "Could not remove Nix configuration files. A system restart may be required."
            failed=1
        }
    fi
    
    # Scan for residual Nix APFS volumes
    NIX_VOLUMES=$(diskutil list | grep "Nix Store" || true)
    if [ -n "$NIX_VOLUMES" ]; then
        print_warning "Nix APFS volume(s) still present:"
        echo "$NIX_VOLUMES"
        failed=1
    fi

    # Scan for synthetic mount entry
    if [ -f /etc/synthetic.conf ] && grep -q '^nix$' /etc/synthetic.conf; then
        print_warning "synthetic.conf still contains an entry for /nix. A reboot may be pending or the entry was not removed."
        failed=1
    fi

    # Scan for active mounts using /nix (should be none)
    if mount | grep -q " on /nix"; then
        print_warning "/nix is still mounted. A reboot may be required to unmount it."
        failed=1
    fi
    
    # Check for Nix in fstab
    if grep -q "nix" /etc/fstab 2>/dev/null; then
        print_warning "Nix entries found in fstab. Attempting to remove..."
        sudo sed -i '' '/nix/d' /etc/fstab || {
            print_warning "Could not remove Nix entries from fstab. A system restart may be required."
            failed=1
        }
    fi
    
    # Check for Nix in shell configuration
    if grep -q "nix" ~/.zshrc 2>/dev/null || grep -q "nix" ~/.bashrc 2>/dev/null; then
        print_warning "Nix entries found in shell configuration. Attempting to remove..."
        sed -i '' '/nix/d' ~/.zshrc 2>/dev/null
        sed -i '' '/nix/d' ~/.bashrc 2>/dev/null
    fi
    
    # Check for Nix in environment
    if echo "$PATH" | grep -q "nix"; then
        print_warning "Nix found in PATH. A shell restart may be required."
        failed=1
    fi
    
    if [ $failed -eq 1 ]; then
        print_warning "Some components require a system restart to be fully removed"
        print_warning "Please restart your computer and run this script again to complete the cleanup"
        return 1
    fi
    
    print_status "Cleanup verified successfully!"
    return 0
}

# Main uninstallation function
uninstall() {
    print_warning "This will remove all installed components. Are you sure? (y/N) "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        exit 0
    fi
    
    print_status "Starting uninstallation process..."
    
    # First, restore default shell before removing anything
    restore_default_shell || {
        print_error "Failed to restore default shell. Aborting."
        exit 1
    }
    
    # Remove components in reverse order of installation
    remove_dotfiles
    remove_chezmoi
    remove_nix
    remove_homebrew
    cleanup_env

    # If a reboot is required (e.g., synthetic mount was removed), inform the user and skip further verification
    if [ "$NEEDS_REBOOT" -eq 1 ]; then
        print_warning "A system restart is required to finish removing /nix."
        print_warning "Please reboot your computer, then run this script again to complete cleanup."
        exit 0
    fi

    # Verify cleanup
    if ! verify_cleanup; then
        print_warning "Some components require a system restart to be fully removed"
        print_warning "Please restart your computer and run this script again to complete the cleanup"
        exit 1
    fi
    
    print_status "Uninstallation completed successfully!"
    print_status "Please restart your terminal to apply all changes"
}

# Run the uninstallation
uninstall 