#!/bin/bash

# uninstall.sh (aka unbootstrap.sh)
# This script will completely remove all tools, dotfiles, and configs installed by the bootstrap process.
# It is intended to fully "unbootstrap" your system and restore it to a clean state.
# Use with caution! You will be prompted for confirmation before anything is removed.

# Source CI helpers if available
if [[ -f "${HOME}/.dotfiles/scripts/ci-helpers.sh" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.dotfiles/scripts/ci-helpers.sh"
fi

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  print_status "Stopping Nix daemon and related services..."

  # Get all Nix-related launchd services
  print_status "Finding all Nix-related launchd services..."
  NIX_SERVICES=$(sudo launchctl list | grep -E "(nix|darwin-store)" | awk '{print $3}' | grep -v "^-$")

  if [ -n "$NIX_SERVICES" ]; then
    print_status "Found Nix services: $NIX_SERVICES"
    for service in $NIX_SERVICES; do
      print_status "Stopping service: $service"
      sudo launchctl bootout system/$service 2>/dev/null || true
      sudo launchctl unload /Library/LaunchDaemons/$service.plist 2>/dev/null || true
    done
  fi

  # Stop specific known Nix services that might not be caught by the grep
  NIX_SERVICE_LIST=(
    "org.nixos.nix-daemon"
    "org.nixos.darwin-store"
    "systems.determinate.nix-daemon"
    "systems.determinate.nix-store"
    "systems.determinate.nix-installer.nix-hook"
  )

  for service in "${NIX_SERVICE_LIST[@]}"; do
    print_status "Ensuring $service is stopped..."
    sudo launchctl bootout system/$service 2>/dev/null || true
    sudo launchctl unload /Library/LaunchDaemons/$service.plist 2>/dev/null || true
  done

  # Kill any running nix-daemon processes
  if pgrep -f "nix-daemon" >/dev/null; then
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
  NIX_WAIT_PIDS=$(ps aux | grep "wait4path.*nix" | grep -v grep | awk '{print $2}')
  if [ -n "$NIX_WAIT_PIDS" ]; then
    print_status "Found Nix wait4path processes: $NIX_WAIT_PIDS"
    for pid in $NIX_WAIT_PIDS; do
      print_status "Killing Nix wait4path process $pid..."
      sudo kill -9 "$pid" || true
    done
  fi

  # Kill any shell scripts trying to start nix-daemon
  print_status "Checking for shell scripts starting nix-daemon..."
  NIX_SHELL_PIDS=$(ps aux | grep "/bin/sh.*nix-daemon" | grep -v grep | awk '{print $2}')
  if [ -n "$NIX_SHELL_PIDS" ]; then
    print_status "Found shell scripts for nix-daemon: $NIX_SHELL_PIDS"
    for pid in $NIX_SHELL_PIDS; do
      print_status "Killing shell script process $pid..."
      sudo kill -9 "$pid" || true
    done
  fi

  # Wait a moment for processes to stop
  sleep 3

  # Verify no Nix processes are running
  if pgrep -f "(nix-daemon|nix-installer|wait4path.*nix)" >/dev/null; then
    print_warning "Some Nix processes are still running after cleanup attempt."
    print_status "Remaining processes:"
    ps aux | grep -E "(nix-daemon|nix-installer|wait4path.*nix)" | grep -v grep || true
    return 1
  fi

  # Verify no Nix services are still loaded
  REMAINING_SERVICES=$(sudo launchctl list | grep -E "(nix|darwin-store)" | awk '{print $3}' | grep -v "^-$" || true)
  if [ -n "$REMAINING_SERVICES" ]; then
    print_warning "Some Nix services are still loaded: $REMAINING_SERVICES"
    return 1
  fi

  print_status "All Nix processes and services stopped successfully"
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
    if ! sudo diskutil unmountDisk force "/dev/$NIX_VOLUME"; then
      print_warning "Failed to unmount Nix volume. Checking if it's safe to proceed..."

      # Check what process is using it
      BLOCKING_PROCS=$(lsof "/dev/$NIX_VOLUME" 2>/dev/null | grep -v "COMMAND" || true)
      if [ -n "$BLOCKING_PROCS" ]; then
        print_warning "Processes still using the volume:"
        echo "$BLOCKING_PROCS"
        print_error "Cannot safely remove volume while in use. Please restart and run this script again."
        return 1
      else
        print_warning "Unmount failed but no processes detected. Proceeding cautiously..."
      fi
    fi

    # Wait a moment for unmount to complete
    sleep 2

    # Then try to remove the volume
    print_status "Removing Nix volume..."
    if ! sudo diskutil apfs deleteVolume "/dev/$NIX_VOLUME"; then
      print_warning "Failed to remove Nix volume. A system restart may be required."
      return 1
    fi

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

# Function to remove /nix directory
remove_nix_directory() {
  print_status "Removing /nix directory..."
  if [ -d "/nix" ]; then
    # First check if it's mounted
    if mount | grep -q " on /nix"; then
      print_status "Unmounting /nix..."
      if ! sudo umount -f /nix; then
        print_warning "Failed to unmount /nix. Checking for blocking processes..."
        BLOCKING_PROCS=$(lsof +D /nix 2>/dev/null | grep -v "COMMAND" || true)
        if [ -n "$BLOCKING_PROCS" ]; then
          print_warning "Processes still using /nix:"
          echo "$BLOCKING_PROCS"
          print_error "Cannot safely remove /nix while in use. Please restart and run this script again."
          return 1
        else
          print_warning "Unmount failed but no processes detected. Proceeding cautiously..."
        fi
      fi
    fi

    # Remove flags and permissions restrictions
    print_status "Removing file flags and permissions restrictions..."
    sudo chflags -R nouchg /nix 2>/dev/null || true
    sudo chflags -R noschg /nix 2>/dev/null || true
    sudo chmod -R 755 /nix 2>/dev/null || true

    # Try to remove the directory
    print_status "Removing /nix directory..."
    if [ -n "$(ls -A /nix 2>/dev/null)" ]; then
      # Directory has contents, remove them first
      print_status "Removing directory contents..."
      if ! sudo rm -rf /nix/* 2>/dev/null; then
        print_warning "Some files in /nix could not be removed (may be in use)"
      fi
      if ! sudo rm -rf /nix/.* 2>/dev/null; then
        print_warning "Some hidden files in /nix could not be removed"
      fi
    fi

    # Remove the directory itself
    sudo rmdir /nix 2>/dev/null || sudo rm -rf /nix 2>/dev/null || {
      print_warning "Could not remove /nix directory. Checking for system protection..."

      # Check if SIP is enabled and protecting the directory
      if csrutil status 2>/dev/null | grep -q "enabled"; then
        print_warning "System Integrity Protection (SIP) is enabled and may be protecting /nix"
        print_warning "If the directory persists after restart, you may need to:"
        print_warning "1. Boot into Recovery Mode (hold Command+R during startup)"
        print_warning "2. Open Terminal and run: csrutil disable"
        print_warning "3. Restart and run this script again"
        print_warning "4. Boot into Recovery Mode again and run: csrutil enable"
      fi

      # Set flag to require reboot
      NEEDS_REBOOT=1
    }
  fi

  # Verify final cleanup
  if [ ! -d "/nix" ]; then
    print_status "Nix directory successfully removed"
  else
    print_warning "Nix directory still exists - this may require a system restart"
    NEEDS_REBOOT=1
  fi
}

# Function to clean up remaining Nix files
cleanup_nix_files() {
  print_status "Cleaning up remaining Nix configuration files..."

  # Remove Nix configuration files
  sudo rm -rf /etc/nix
  sudo rm -f /etc/profile.d/nix.sh
  sudo rm -f /etc/profile.d/nix-daemon.sh

  # Remove Nix daemon service files
  sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist
  sudo rm -f /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
  sudo rm -f /Library/LaunchDaemons/systems.determinate.nix-store.plist
  sudo rm -f /Library/LaunchDaemons/systems.determinate.nix-installer.nix-hook.plist

  # Restore Nix installer backup files
  if [ -f /etc/bashrc.backup-before-nix ]; then
    print_status "Restoring /etc/bashrc backup..."
    sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
  fi
  if [ -f /etc/bash.bashrc.backup-before-nix ]; then
    print_status "Restoring /etc/bash.bashrc backup..."
    sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc
  fi
  if [ -f /etc/zshrc.backup-before-nix ]; then
    print_status "Restoring /etc/zshrc backup..."
    sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
  fi
  if [ -f /etc/profile.backup-before-nix ]; then
    print_status "Restoring /etc/profile backup..."
    sudo mv /etc/profile.backup-before-nix /etc/profile
  fi

  # Remove Nix from fstab
  if [ -f /etc/fstab ] && grep -q "nix" /etc/fstab 2>/dev/null; then
    print_status "Removing Nix entries from /etc/fstab..."
    sudo sed -i '' '/nix/d' /etc/fstab 2>/dev/null || true
  fi

  # Remove Nix from shell configurations
  for file in ~/.bash_profile ~/.bashrc ~/.zshrc ~/.profile; do
    if [ -f "$file" ]; then
      sed -i '' '/nix/d' "$file" 2>/dev/null || true
    fi
  done

  # Handle synthetic mount entry
  remove_synthetic_nix

  # Remove user-specific Nix directories
  print_status "Removing user-specific Nix directories..."
  rm -rf "$HOME/.nix-profile"
  rm -rf "$HOME/.nix-defexpr"
  rm -rf "$HOME/.nix-channels"

  # Remove Home Manager state directories (often missed)
  print_status "Removing Home Manager state directories..."
  rm -rf "$HOME/.local/state/nix"
  rm -rf "$HOME/.local/state/home-manager"
  rm -rf "$HOME/.local/share/home-manager"
  rm -rf "$HOME/.cache/nix"
  rm -rf "$HOME/.config/home-manager"

  # Remove broken symlinks that point to /nix/store
  print_status "Finding and removing broken symlinks..."
  find "$HOME" -maxdepth 3 -type l -exec sh -c 'test ! -e "$1" && file "$1" | grep -q "nix"' sh {} \; -delete 2>/dev/null || true
}

# Function to remove Nix and Home Manager using official uninstall
remove_nix() {
  print_status "Removing Nix and Home Manager using official uninstall methods..."

  # First, use Home Manager's official uninstall if available
  if command -v nix &>/dev/null; then
    print_status "Using Home Manager official uninstall..."
    if nix --extra-experimental-features "nix-command flakes" run home-manager/release-24.05 -- uninstall 2>/dev/null || true; then
      print_status "Home Manager uninstalled successfully"
    else
      print_warning "Home Manager uninstall command failed or not applicable"
    fi
  fi

  # Stop Nix daemon and services
  stop_nix_daemon || print_warning "Some Nix services may still be running"

  # Remove Nix APFS volumes if they exist
  remove_nix_volume || print_warning "Manual volume cleanup may be required"

  # Remove /nix directory (the main challenge)
  remove_nix_directory

  # Clean up remaining Nix files
  cleanup_nix_files
}

# Function to remove chezmoi using official purge command
remove_chezmoi() {
  print_status "Removing chezmoi using official purge command..."

  if command -v chezmoi &>/dev/null; then
    print_status "Using chezmoi purge to remove all traces..."
    chezmoi purge --binary --force || {
      print_warning "chezmoi purge failed, falling back to manual cleanup"
      # Manual fallback
      rm -rf ~/.config/chezmoi
      rm -rf ~/.local/share/chezmoi
      rm -f ~/.local/bin/chezmoi
    }
    print_status "Chezmoi removed successfully"
  else
    print_status "Chezmoi not found, skipping removal"
  fi
}

# Function to remove Homebrew
remove_homebrew() {
  print_status "Removing Homebrew..."

  # Check if Homebrew is installed
  if ! command -v brew &>/dev/null && [ ! -d "/opt/homebrew" ]; then
    print_status "Homebrew is not installed, skipping removal"
    return 0
  fi

  # If brew command exists, clean up packages first
  if command -v brew &>/dev/null; then
    # Uninstall all packages from Brewfile if it exists
    if [ -f "$DOTFILES_DIR/brew/Brewfile" ]; then
      print_status "Cleaning up Homebrew packages from Brewfile..."
      cd "$DOTFILES_DIR/brew" && brew bundle cleanup --force 2>/dev/null || true
    fi

    # Use official Homebrew uninstall script
    print_status "Using official Homebrew uninstall script..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || {
      print_warning "Official Homebrew uninstall failed, trying manual removal"
      sudo rm -rf /opt/homebrew
    }
  else
    # Manual removal if brew command doesn't exist but directory does
    print_status "Manually removing Homebrew directory..."
    sudo rm -rf /opt/homebrew
  fi

  print_status "Homebrew removal completed"
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

  # Check for /nix directory
  if [ -d "/nix" ]; then
    print_warning "/nix directory still exists"
    failed=1
  fi

  # Check for Nix configuration files
  if [ -d "/etc/nix" ]; then
    print_warning "Nix configuration files still exist in /etc/nix"
    failed=1
  fi

  # Scan for residual Nix APFS volumes
  NIX_VOLUMES=$(diskutil list | grep "Nix Store" 2>/dev/null || true)
  if [ -n "$NIX_VOLUMES" ]; then
    print_warning "Nix APFS volume(s) still present:"
    echo "$NIX_VOLUMES"
    failed=1
  fi

  # Scan for synthetic mount entry
  if [ -f /etc/synthetic.conf ] && grep -q '^nix$' /etc/synthetic.conf; then
    print_warning "synthetic.conf still contains an entry for /nix"
    failed=1
  fi

  # Scan for active mounts using /nix (should be none)
  if mount | grep -q " on /nix"; then
    print_warning "/nix is still mounted"
    failed=1
  fi

  # Check for Nix daemon service files
  if [ -f "/Library/LaunchDaemons/org.nixos.nix-daemon.plist" ]; then
    print_warning "Nix daemon service file still exists"
    failed=1
  fi

  # Check for user Nix directories
  if [ -d "$HOME/.nix-profile" ] || [ -d "$HOME/.nix-defexpr" ] || [ -d "$HOME/.nix-channels" ]; then
    print_warning "User Nix directories still exist"
    failed=1
  fi

  # Check for Nix in fstab
  if grep -q "nix" /etc/fstab 2>/dev/null; then
    print_warning "Nix entries found in fstab"
    failed=1
  fi

  # Check for Nix in shell configuration
  for file in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
    if [ -f "$file" ] && grep -q "nix" "$file" 2>/dev/null; then
      print_warning "Nix entries found in $file"
      failed=1
    fi
  done

  # Check for Nix in environment
  if echo "$PATH" | grep -q "nix"; then
    print_warning "Nix found in PATH environment variable"
    failed=1
  fi

  if [ $failed -eq 1 ]; then
    print_warning "Some components were not fully removed"
    if [ "$NEEDS_REBOOT" -eq 1 ]; then
      print_warning "A system restart is required to complete the cleanup"
      print_warning "Please restart your computer and run this script again"
    fi
    return 1
  fi

  print_status "Cleanup verified successfully!"
  return 0
}

# Main uninstallation function
uninstall() {
  echo ""
  print_error "⚠️  WARNING: This will completely remove your development environment!"
  echo ""
  echo "This will remove:"
  echo "  • All Nix packages and the Nix package manager"
  echo "  • All Homebrew packages and Homebrew itself"
  echo "  • All version managers (nvm, pyenv, rbenv, asdf)"
  echo "  • Dotfiles configurations (starship, etc.)"
  echo "  • Shell configurations and PATH modifications"
  echo ""
  print_error "This action cannot be easily undone!"
  echo ""
  print_warning "Are you absolutely sure you want to continue? (y/N) "
  if command -v is_ci &>/dev/null && is_ci; then
    response="y"
    echo "y [auto-confirmed in CI]"
  else
    read -r response
  fi
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

  # Remove extra files/folders in home directory that should not be there
  EXTRA_ITEMS=(bin brew scripts starship templates README.md unbootstrap.sh bootstrap.sh check.sh fish nix docs notes logs mint.json favicon.svg warp)
  EXTRA_TO_REMOVE=()
  for item in "${EXTRA_ITEMS[@]}"; do
    if [ -e "$HOME/$item" ]; then
      EXTRA_TO_REMOVE+=("$HOME/$item")
    fi
  done

  if [ ${#EXTRA_TO_REMOVE[@]} -gt 0 ]; then
    print_warning "The following extra files/folders will be removed from your home directory:"
    for item in "${EXTRA_TO_REMOVE[@]}"; do
      echo "  $item"
    done
    echo -n "Are you sure you want to delete these items? (yes/no): "
    read confirm
    if [[ "$confirm" == "yes" ]]; then
      for item in "${EXTRA_TO_REMOVE[@]}"; do
        rm -rf "$item"
        print_status "Removed $item"
      done
    else
      print_status "No files were deleted."
    fi
  fi
}

# Run the uninstallation
uninstall
