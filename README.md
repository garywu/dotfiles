# Modern Development Environment Setup

This repository provides a fully automated, reproducible development environment using Nix, Home Manager, Chezmoi, and Homebrew (macOS).

## 🚀 Quick Start

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

- After each major step, restart your terminal and re-run `./bootstrap.sh` if prompted.

## 📁 Project Structure

```
~/.dotfiles/
├── bootstrap.sh      # Main installation script
├── unbootstrap.sh    # Complete removal script
├── chezmoi/          # Chezmoi-managed files (secrets/meta only)
├── brew/             # Homebrew packages (macOS GUI apps)
├── logs/             # Bootstrap execution logs
└── README.md         # This file
```

## 📝 Documentation

For full documentation, philosophy, architecture, and advanced usage, see:
- `notes/` (in this repo)
- or `docs/` (if using the Docusaurus site)
