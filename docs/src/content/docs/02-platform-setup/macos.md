---
title: macOS Setup Guide
description: Complete setup guide for macOS using Nix package manager and Homebrew for GUI applications
---

# macOS Development Environment Setup

Complete setup guide for macOS using Nix package manager and Homebrew for GUI applications.

## Prerequisites

- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools
- Admin privileges

## Quick Setup (Recommended)

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Run the minimal installer
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/minimal_install.sh | bash

# 3. Run the macOS-specific bootstrap
./scripts/bootstrap.sh
```

## Manual Setup

### 1. Install Xcode Command Line Tools

```bash
xcode-select --install
```

### 2. Install Nix Package Manager

```bash
# Multi-user installation (recommended)
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Restart your terminal or source the profile
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### 3. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add to PATH (Intel Macs)
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### 4. Install chezmoi and Setup Dotfiles

```bash
# Install chezmoi via Nix
nix-env -iA nixpkgs.chezmoi

# Initialize dotfiles
chezmoi init --apply yourusername/dotfiles
```

### 5. Install Packages

```bash
# Install Nix packages (CLI tools)
home-manager switch

# Install Homebrew packages (GUI apps)
brew bundle --file=~/.local/share/chezmoi/brew/Brewfile
```

### 6. Configure Shell

```bash
# Set Fish as default shell
echo /nix/var/nix/profiles/default/bin/fish | sudo tee -a /etc/shells
chsh -s /nix/var/nix/profiles/default/bin/fish

# Or if installed via Homebrew
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

## macOS-Specific Configurations

### System Preferences

```bash
# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Disable natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Restart affected applications
killall Finder
killall SystemUIServer
```

### Dock Configuration

```bash
# Auto-hide dock
defaults write com.apple.dock autohide -bool true

# Remove dock delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up dock animation
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Restart Dock
killall Dock
```

## GUI Applications Included

The Homebrew configuration includes:
- **Docker Desktop** - Container management
- **iTerm2** - Terminal emulator
- **Visual Studio Code** - Code editor
- **Postman** - API testing
- **Figma** - Design tool
- **Firefox** - Web browser
- **Slack** - Team communication
- **Spotify** - Music streaming
- **Discord** - Gaming/community chat
- **Obsidian** - Note-taking

## Development Tools

### Programming Languages
- **Python** (via Nix)
- **Node.js** (via Nix)
- **Go** (via Nix)
- **Rust** (via Nix)

### CLI Tools
- **eza** - Modern ls replacement
- **bat** - Cat clone with syntax highlighting
- **fd** - Find replacement
- **ripgrep** - Grep replacement
- **fzf** - Fuzzy finder
- **tmux** - Terminal multiplexer
- **neovim** - Text editor
- **lazygit** - Git TUI
- **btop** - System monitor

## Font Installation

```bash
# FiraCode Nerd Font (via Homebrew)
brew tap homebrew/cask-fonts
brew install font-fira-code-nerd-font

# Or download manually from:
# https://github.com/ryanoasis/nerd-fonts/releases
```

## Troubleshooting

### Nix Issues

```bash
# If Nix commands not found, source the profile
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Repair Nix store if corrupted
sudo nix-store --verify --check-contents --repair
```

### Homebrew Issues

```bash
# Fix permissions
sudo chown -R $(whoami) $(brew --prefix)/*

# Update and cleanup
brew update && brew upgrade && brew cleanup
```

### Shell Issues

```bash
# If Fish shell doesn't work, switch back to zsh temporarily
chsh -s /bin/zsh

# Check available shells
cat /etc/shells

# Verify Fish installation
which fish
fish --version
```

### chezmoi Issues

```bash
# Re-apply dotfiles
chezmoi apply --verbose

# Check status
chezmoi status

# Update from source
chezmoi update
```

## Performance Optimization

### Disable Spotlight Indexing for Development Folders

```bash
# Add development directories to Spotlight exclusions
sudo mdutil -i off ~/Developer
sudo mdutil -i off ~/Projects
```

### Git Performance

```bash
# Enable Git credential helper
git config --global credential.helper osxkeychain

# Enable Git parallel processing
git config --global core.preloadindex true
git config --global core.fscache true
```

## Security Recommendations

```bash
# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Require password immediately after sleep
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
```

## Next Steps

1. **Configure your terminal**: Set up iTerm2 with FiraCode Nerd Font
2. **Customize your prompt**: Modify `~/.config/starship.toml`
3. **Set up your IDE**: Configure VS Code extensions and settings
4. **Version control**: Set up SSH keys for Git repositories
5. **Backup strategy**: Set up Time Machine or cloud backup

## Additional Resources

- [Homebrew Documentation](https://brew.sh/)
- [Nix Package Manager Guide](https://nixos.org/manual/nix/stable/)
- [Fish Shell Tutorial](https://fishshell.com/docs/current/tutorial.html)
- [Starship Prompt Configuration](https://starship.rs/config/)
