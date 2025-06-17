# Modern Development Environment Setup

<!-- Badges -->
<div align="center">

[![Release](https://img.shields.io/github/v/release/garywu/dotfiles?include_prereleases&sort=semver&display_name=tag&style=flat-square)](https://github.com/garywu/dotfiles/releases/latest)
[![CI/CD](https://img.shields.io/github/actions/workflow/status/garywu/dotfiles/deploy-docs.yml?branch=main&label=docs&style=flat-square)](https://github.com/garywu/dotfiles/actions/workflows/deploy-docs.yml)
[![License](https://img.shields.io/github/license/garywu/dotfiles?style=flat-square)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/garywu/dotfiles?style=flat-square)](https://github.com/garywu/dotfiles/commits/main)
[![Commit Activity](https://img.shields.io/github/commit-activity/w/garywu/dotfiles?style=flat-square)](https://github.com/garywu/dotfiles/graphs/commit-activity)

<!-- Release Channels -->
[![Stable](https://img.shields.io/badge/channel-stable-green?style=flat-square)](https://github.com/garywu/dotfiles/releases/latest)
[![Beta](https://img.shields.io/badge/channel-beta-orange?style=flat-square)](https://github.com/garywu/dotfiles/releases?q=prerelease%3Atrue)
[![Nightly](https://img.shields.io/badge/channel-nightly-red?style=flat-square)](https://github.com/garywu/dotfiles/actions)

<!-- Technology Stack -->
[![Nix](https://img.shields.io/badge/Nix-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org/)
[![Home Manager](https://img.shields.io/badge/Home_Manager-48B9C7?style=flat-square)](https://github.com/nix-community/home-manager)
[![Chezmoi](https://img.shields.io/badge/Chezmoi-0078D4?style=flat-square)](https://www.chezmoi.io/)
[![Fish Shell](https://img.shields.io/badge/Fish-Shell-4AAE46?style=flat-square)](https://fishshell.com/)

<!-- Documentation -->
[![Documentation](https://img.shields.io/badge/docs-github_pages-blue?style=flat-square)](https://garywu.github.io/dotfiles)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

</div>

This repository provides a fully automated, reproducible development environment using Nix, Home Manager, Chezmoi, and Homebrew (macOS).

## 🚀 Quick Start

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

- After each major step, restart your terminal and re-run `./bootstrap.sh` if prompted.

### 🔒 Privacy Note
This repository uses GitHub's privacy-protecting email (`username@users.noreply.github.com`) to prevent email exposure in public commits. See [Git Email Privacy](https://garywu.github.io/dotfiles/98-troubleshooting/git-email-privacy/) for details.

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
