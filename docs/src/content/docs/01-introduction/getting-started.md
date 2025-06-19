---
title: Getting Started
description: Setup guide for development environment configuration
---

# Getting Started

## Overview

This repository contains development environment configuration using:

- **Nix & Home Manager** - Declarative package management
- **Chezmoi** - Secrets and machine-specific template management
- **Homebrew** - macOS GUI applications
- **Fish Shell** - Command-line shell with autosuggestions
- **Modern CLI Tools** - Performance-oriented replacements for Unix tools

## Setup

### Prerequisites

- macOS 12+ or Linux
- Administrator access
- Internet connection

### Installation

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script performs:

1. Nix package manager installation
2. Home Manager setup for declarative package management
3. Fish shell and CLI tools installation
4. Development environment configuration
5. Homebrew installation and GUI applications (macOS only)

## Installed Tools

### Core Utilities
- `coreutils` - GNU core utilities (timeout, realpath, etc.)
- `curl`, `wget` - HTTP clients
- `git` - Version control
- `jq` - JSON processor
- `tmux` - Terminal multiplexer

### Modern CLI Replacements
- `eza` - File listing with git integration
- `bat` - File viewer with syntax highlighting
- `ripgrep` - Fast text search
- `fd` - File finder
- `sd` - Stream editor (sed replacement)
- `dust` - Disk usage analyzer
- `procs` - Process viewer
- `hyperfine` - Command benchmarking

### Development Languages
- Python 3.11
- Node.js 20
- Go
- Rust
- Bun

### Cloud Tools
- AWS CLI v2
- Google Cloud SDK
- Cloudflare tools (cloudflared, flarectl)

## Configuration Files

### Directory Structure
```
~/.dotfiles/
├── nix/
│   ├── home.nix          # Package declarations
│   └── flake.nix         # Nix flake configuration
├── chezmoi/
│   └── chezmoi.toml      # Machine-specific values
├── brew/
│   └── Brewfile          # macOS GUI applications
└── bootstrap.sh          # Setup script
```

### Home Manager
Packages are declared in `nix/home.nix`. To add packages:
```bash
# Edit nix/home.nix
# Then apply changes:
home-manager switch
```

### Chezmoi Templates
Machine-specific configurations use Chezmoi templates:
```bash
chezmoi edit ~/.gitconfig
chezmoi apply
```

## Post-Installation

### Shell Configuration
Fish shell is set as default. Configuration files:
- `~/.config/fish/config.fish` - Main configuration
- `~/.config/fish/functions/` - Custom functions

### Session Management
Track work sessions:
```bash
make session-start    # Begin session
make session-log MSG="completed task"  # Log progress
make session-end      # End session
```

### Testing
Verify installation:
```bash
make test            # Run all tests
make test-shell      # Test shell scripts
make test-docs       # Test documentation links
```

## Maintenance

### Update Packages
```bash
# Update Nix packages
nix flake update
home-manager switch

# Update Homebrew packages
brew update && brew upgrade
```

### Backup Secrets
```bash
chezmoi cd
# Backup encrypted files to secure location
```

## Troubleshooting

Common issues and solutions are documented in the [troubleshooting section](/98-troubleshooting/homebrew-fish-config/).
