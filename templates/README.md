# OS-Specific Templates

This directory contains OS-specific setup templates for quickly configuring your development environment on different operating systems.

## Available Templates

- **[macOS](./macos.md)** - Complete setup for macOS using Nix + Homebrew
- **[Ubuntu](./ubuntu.md)** - Ubuntu/Debian setup using Nix + apt
- **[WSL2](./wsl2.md)** - Windows Subsystem for Linux setup with optimizations
- **[Secrets Management](./secrets-management.md)** - Environment variables and secrets best practices

## Quick Start

Choose your operating system and follow the corresponding template:

```bash
# macOS
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/macos.md

# Ubuntu/Debian
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/ubuntu.md

# WSL2
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/wsl2.md
```

## Template Structure

Each template includes:
- Prerequisites and system requirements
- Package manager setup
- Essential tool installation
- Dotfiles configuration
- OS-specific optimizations
- Troubleshooting tips

## Contributing

When adding new templates or updating existing ones:
1. Follow the established format
2. Test on the target OS
3. Include common troubleshooting scenarios
4. Update this README with new templates
