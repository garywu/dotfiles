---
title: WSL2 Setup Guide
description: Optimized setup guide for Windows Subsystem for Linux 2
---

# WSL2 Development Environment Setup

Complete setup guide for Windows Subsystem for Linux 2 (WSL2) with Ubuntu, optimized for development workflow.

## Prerequisites

- Windows 10 version 2004+ or Windows 11
- WSL2 enabled with Ubuntu distribution
- Windows Terminal (recommended)
- Admin privileges on Windows

## Quick Setup (Recommended)

```bash
# 1. Update WSL Ubuntu
sudo apt update && sudo apt upgrade -y

# 2. Install essential dependencies
sudo apt install -y curl wget git build-essential

# 3. Run the minimal installer
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/minimal_install.sh | bash

# 4. Install WSL-specific optimizations
sudo apt install -y wslu
```

## WSL2 Initial Setup

### Enable WSL2 (run in PowerShell as Administrator)

```powershell
# Enable WSL feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart computer, then set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu from Microsoft Store or via command
wsl --install -d Ubuntu
```

### Configure WSL2 Settings

Create/edit `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true

[experimental]
sparseVhd=true
autoMemoryReclaim=gradual
```

## Manual Setup

### 1. Update System and Install Dependencies

```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential build tools and WSL utilities
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
  xz-utils \
  wslu \
  ubuntu-wsl
```

### 2. Install Nix Package Manager

```bash
# Single-user installation (recommended for WSL)
curl -L https://nixos.org/nix/install | sh

# Source the Nix profile
. ~/.nix-profile/etc/profile.d/nix.sh

# Add to your shell profile
echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc
```

### 3. Install chezmoi and Setup Dotfiles

```bash
# Install chezmoi via Nix
nix-env -iA nixpkgs.chezmoi

# Initialize dotfiles
chezmoi init --apply yourusername/dotfiles
```

### 4. Configure Shell

```bash
# Fish should be installed via Nix, add to shells
echo ~/.nix-profile/bin/fish | sudo tee -a /etc/shells

# Set Fish as default shell
chsh -s ~/.nix-profile/bin/fish
```

## WSL2-Specific Configurations

### X11 Forwarding Setup

```bash
# Install X11 utilities
sudo apt install -y \
  x11-apps \
  x11-xserver-utils \
  xauth \
  xvfb

# Create .xsessionrc for X11 forwarding
echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2; exit}"):0.0' >> ~/.bashrc
echo 'export LIBGL_ALWAYS_INDIRECT=1' >> ~/.bashrc
```

### Install X Server for Windows (choose one)

**Option 1: VcXsrv (Free)**
- Download from: https://sourceforge.net/projects/vcxsrv/
- Run with: "Disable access control" checked

**Option 2: X410 (Paid, Microsoft Store)**
- More integrated with Windows
- Better performance

### WSL Integration Tools

```bash
# Install WSL utilities
sudo apt install -y wslu

# Examples of WSL integration
wslview https://github.com  # Open URLs in Windows browser
wslpath 'C:\Users'          # Convert Windows paths to WSL paths
```

### File System Optimization

```bash
# Create symlinks to Windows directories
ln -s /mnt/c/Users/$USER/Desktop ~/Desktop
ln -s /mnt/c/Users/$USER/Documents ~/Documents
ln -s /mnt/c/Users/$USER/Downloads ~/Downloads

# Set up development directory on faster WSL filesystem
mkdir -p ~/dev
# Avoid working in /mnt/c for better performance
```

## Development Environment

### Git Configuration for WSL

```bash
# Configure Git to use Windows credential manager
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"

# Or use Git Credential Manager Core
git config --global credential.helper "$(wslpath 'C:\Program Files\Git\mingw64\bin\git-credential-manager.exe')"

# Set up SSH keys (store in WSL, not Windows)
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Docker Setup

```bash
# Install Docker Engine
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Configure Docker daemon
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "hosts": ["unix:///var/run/docker.sock"],
  "iptables": false
}
EOF

# Start Docker service
sudo service docker start

# Auto-start Docker (add to ~/.bashrc)
echo 'if ! pgrep -x "dockerd" > /dev/null; then sudo service docker start; fi' >> ~/.bashrc
```

### Node.js Development

```bash
# Node.js installed via Nix, but for WSL optimization:
# Set npm cache to WSL filesystem
npm config set cache ~/.npm-cache

# Use yarn for better WSL performance
npm install -g yarn
```

### Python Development

```bash
# Python installed via Nix, additional WSL optimizations:
# Set pip cache to WSL filesystem
mkdir -p ~/.cache/pip
echo 'export PIP_CACHE_DIR=~/.cache/pip' >> ~/.bashrc
```

## WSL2 Performance Optimizations

### Memory Management

```bash
# Add to ~/.bashrc for better memory management
echo 'export NODE_OPTIONS="--max-old-space-size=4096"' >> ~/.bashrc

# Create swap file if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### File System Performance

```bash
# Use case-insensitive directories for better Windows compatibility
mkdir -p ~/dev
echo 'export COMPOSE_CONVERT_WINDOWS_PATHS=1' >> ~/.bashrc

# Configure Git for better performance
git config --global core.preloadindex true
git config --global core.fscache true
git config --global gc.auto 256
```

## Windows Terminal Configuration

Add to Windows Terminal settings.json:

```json
{
  "profiles": {
    "list": [
      {
        "guid": "{your-wsl-guid}",
        "name": "Ubuntu",
        "source": "Windows.Terminal.Wsl",
        "colorScheme": "One Half Dark",
        "fontFace": "FiraCode Nerd Font",
        "fontSize": 12,
        "startingDirectory": "//wsl$/Ubuntu/home/username"
      }
    ]
  }
}
```

## Font Installation

### Install Nerd Fonts in Windows

```powershell
# Run in PowerShell as Administrator
# Download and install FiraCode Nerd Font
Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip" -OutFile "$env:TEMP\FiraCode.zip"
Expand-Archive -Path "$env:TEMP\FiraCode.zip" -DestinationPath "$env:TEMP\FiraCode"
# Install manually by right-clicking font files
```

### Configure WSL to use Windows fonts

```bash
# Link Windows fonts to WSL
sudo mkdir -p /usr/share/fonts/windows
sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/windows
sudo fc-cache -fv
```

## GUI Applications in WSL2

### Install GUI Applications

```bash
# Install GUI applications via apt/snap/flatpak
sudo apt install -y \
  firefox \
  code \
  nautilus \
  gedit

# Test GUI with simple app
xclock

# Or install via Snap
sudo snap install code --classic
```

### WSLg (Windows 11 22H2+)

If you have WSLg support:
```bash
# No additional X server needed
# GUI apps work out of the box
code .
firefox
```

## Troubleshooting

### WSL2 Issues

```bash
# Restart WSL from PowerShell
wsl --shutdown
wsl

# Check WSL version
wsl -l -v

# Convert distribution to WSL2
wsl --set-version Ubuntu 2
```

### Network Issues

```bash
# Fix DNS resolution
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'
sudo chattr +i /etc/resolv.conf
```

### Performance Issues

```bash
# Check if running on WSL2
uname -r  # Should contain "microsoft"

# Monitor resource usage
htop
df -h

# Clear package cache
sudo apt autoremove
sudo apt autoclean
```

### X11 Issues

```bash
# Test X11 forwarding
echo $DISPLAY
xclock

# Restart X server on Windows side
# Check Windows firewall settings for X server
```

## WSL2-Specific Tips

### File Permissions

```bash
# Fix Windows file permissions
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000
```

### Interoperability

```bash
# Call Windows programs from WSL
cmd.exe /c dir
powershell.exe Get-Process

# Use Windows clipboard
echo "Hello WSL" | clip.exe
```

### Backup and Migration

```bash
# Export WSL distribution
wsl --export Ubuntu C:\backup\ubuntu.tar

# Import on another machine
wsl --import Ubuntu C:\WSL\Ubuntu C:\backup\ubuntu.tar
```

## Security Considerations

```bash
# WSL2 inherits Windows firewall settings
# Configure additional protection
sudo ufw enable

# Use Windows antivirus exclusions for:
# - %USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.*
# - WSL installation directories
```

## Next Steps

1. **Configure Windows Terminal**: Set up profiles and themes
2. **Install VS Code WSL extension**: For seamless development
3. **Set up SSH keys**: Configure for Git and remote access
4. **Optimize workflow**: Create aliases and shortcuts
5. **Backup configuration**: Export WSL settings

## Additional Resources

- [WSL2 Official Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Windows Terminal Documentation](https://docs.microsoft.com/en-us/windows/terminal/)
- [VS Code WSL Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
- [WSL Tips and Tricks](https://github.com/microsoft/WSL/blob/master/README.md)
