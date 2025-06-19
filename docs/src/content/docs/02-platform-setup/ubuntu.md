---
title: Ubuntu/Debian Setup Guide
description: Complete setup guide for Ubuntu and Debian-based Linux distributions
---

# Ubuntu Development Environment Setup

Complete setup guide for Ubuntu/Debian using Nix package manager with apt for system packages.

## Prerequisites

- Ubuntu 20.04+ (Focal or later) or Debian 11+
- sudo privileges
- Internet connection

## Quick Setup (Recommended)

```bash
# 1. Update system packages
sudo apt update && sudo apt upgrade -y

# 2. Install essential dependencies
sudo apt install -y curl wget git build-essential

# 3. Run the minimal installer
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/minimal_install.sh | bash

# 4. Install Ubuntu-specific packages
sudo apt install -y ubuntu-restricted-extras
```

## Manual Setup

### 1. Update System and Install Dependencies

```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential build tools and dependencies
sudo apt install -y \
  curl \
  wget \
  git \
  build-essential \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release \
  xz-utils
```

### 2. Install Nix Package Manager

```bash
# Single-user installation
curl -L https://nixos.org/nix/install | sh

# Source the Nix profile
. ~/.nix-profile/etc/profile.d/nix.sh

# Or multi-user installation (recommended for servers)
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 3. Install chezmoi and Setup Dotfiles

```bash
# Install chezmoi via Nix
nix-env -iA nixpkgs.chezmoi

# Initialize dotfiles
chezmoi init --apply yourusername/dotfiles
```

### 4. Install Packages via Nix

```bash
# Install development tools via home-manager
home-manager switch
```

### 5. Configure Shell

```bash
# Fish should be installed via Nix, add to shells
echo ~/.nix-profile/bin/fish | sudo tee -a /etc/shells

# Set Fish as default shell
chsh -s ~/.nix-profile/bin/fish
```

## Ubuntu-Specific Packages

### System Utilities

```bash
# Essential system tools
sudo apt install -y \
  htop \
  tree \
  unzip \
  zip \
  p7zip-full \
  apt-transport-https \
  software-properties-common

# Network tools
sudo apt install -y \
  net-tools \
  traceroute \
  nmap \
  wget \
  curl
```

### Development Dependencies

```bash
# Compiler and build tools
sudo apt install -y \
  gcc \
  g++ \
  make \
  cmake \
  autoconf \
  automake \
  libtool \
  pkg-config

# Library development headers
sudo apt install -y \
  libssl-dev \
  libffi-dev \
  libxml2-dev \
  libxslt1-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libncurses5-dev \
  libncursesw5-dev \
  liblzma-dev
```

### GUI Applications (if using desktop)

```bash
# Add repositories for modern applications
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Snap support (if not already installed)
sudo apt install -y snapd

# Modern applications via Snap
sudo snap install code --classic
sudo snap install discord
sudo snap install slack --classic
sudo snap install postman
sudo snap install figma-linux

# Traditional applications
sudo apt install -y \
  firefox \
  thunderbird \
  libreoffice \
  gimp \
  vlc
```

## Ubuntu-Specific Configurations

### Enable Additional Repositories

```bash
# Enable universe and multiverse repositories
sudo add-apt-repository universe
sudo add-apt-repository multiverse

# Install restricted extras (codecs, fonts)
sudo apt install -y ubuntu-restricted-extras

# Microsoft packages (for VS Code, etc.)
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
```

### System Tweaks

```bash
# Increase file watch limit for development
echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf

# Enable firewall
sudo ufw enable

# Configure Git credential helper
sudo apt install -y libsecret-1-0 libsecret-1-dev
git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
```

### Performance Optimizations

```bash
# Install preload for faster application startup
sudo apt install -y preload

# Configure swappiness (optional, for systems with plenty of RAM)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Enable zram for better memory management
sudo apt install -y zram-config
```

## Docker Installation

```bash
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose standalone
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Font Installation

```bash
# Install Nerd Fonts manually
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download FiraCode Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
unzip FiraCode.zip
rm FiraCode.zip

# Refresh font cache
fc-cache -fv
```

## Development Tools

### Programming Languages (via Nix)
- **Python** with pip and virtualenv
- **Node.js** with npm and yarn
- **Go** compiler and tools
- **Rust** with cargo

### CLI Tools (via Nix)
- **eza** - Modern ls replacement
- **bat** - Cat with syntax highlighting
- **fd** - Find replacement
- **ripgrep** - Grep replacement
- **fzf** - Fuzzy finder
- **tmux** - Terminal multiplexer
- **neovim** - Text editor
- **lazygit** - Git TUI
- **btop** - System monitor

## Terminal Setup

### Install modern terminal emulator

```bash
# Alacritty (via cargo after Rust installation)
cargo install alacritty

# Or Kitty
sudo apt install -y kitty

# Or Terminator
sudo apt install -y terminator
```

### Configure terminal for Nerd Fonts

Add to your terminal's configuration:
- Font: FiraCode Nerd Font
- Font size: 12-14pt
- Enable ligatures (if supported)

## Troubleshooting

### Nix Issues

```bash
# If Nix not found, source the profile
. ~/.nix-profile/etc/profile.d/nix.sh

# Add to shell profile permanently
echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc
# or for Fish shell
echo 'set -gx PATH ~/.nix-profile/bin $PATH' >> ~/.config/fish/config.fish
```

### Package Installation Issues

```bash
# Fix broken packages
sudo apt --fix-broken install

# Update package database
sudo apt update

# Check for held packages
sudo apt-mark showhold
```

### Permission Issues

```bash
# Fix npm global package permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc

# Fix pip user installs
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
```

### Display Issues (for WSL users, see WSL2 template)

```bash
# Install X11 forwarding support
sudo apt install -y x11-apps

# Test X11 forwarding
xclock
```

## Ubuntu-Specific Tips

### Package Management

```bash
# Search for packages
apt search package-name

# Show package information
apt show package-name

# List installed packages
apt list --installed

# Remove orphaned packages
sudo apt autoremove
```

### System Information

```bash
# Check Ubuntu version
lsb_release -a

# Check kernel version
uname -r

# Check system resources
free -h
df -h
```

### Service Management

```bash
# List services
systemctl list-units --type=service

# Check service status
systemctl status service-name

# Enable service at boot
sudo systemctl enable service-name
```

## Security Recommendations

```bash
# Keep system updated
sudo apt update && sudo apt upgrade -y

# Enable automatic security updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Install fail2ban for SSH protection
sudo apt install -y fail2ban

# Configure firewall
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## Next Steps

1. **Reboot**: Restart to ensure all changes take effect
2. **Configure terminals**: Set up your preferred terminal with Nerd Fonts
3. **Set up SSH keys**: Generate and configure SSH keys for Git
4. **Install IDE extensions**: Configure your development environment
5. **Customize shell**: Modify Starship prompt and Fish aliases

## Additional Resources

- [Ubuntu Documentation](https://help.ubuntu.com/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Tmux Guide](https://github.com/tmux/tmux/wiki)
