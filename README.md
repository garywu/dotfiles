<div align="center">

<pre>
∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝

                    ∙∙∙ Don't Leave Home Without It ∙∙∙
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙
</pre>

</div>

<!-- Badges -->
<div align="center">

[![Release](https://img.shields.io/github/v/release/garywu/dotfiles?include_prereleases&sort=semver&display_name=tag&style=flat-square)](https://github.com/garywu/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/garywu/dotfiles?style=flat-square)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/garywu/dotfiles?style=flat-square)](https://github.com/garywu/dotfiles/commits/main)
[![Commit Activity](https://img.shields.io/github/commit-activity/w/garywu/dotfiles?style=flat-square)](https://github.com/garywu/dotfiles/graphs/commit-activity)

<!-- GitHub Actions Status -->
[![Documentation](https://img.shields.io/github/actions/workflow/status/garywu/dotfiles/deploy-docs.yml?branch=main&label=docs&style=flat-square)](https://github.com/garywu/dotfiles/actions/workflows/deploy-docs.yml)
[![Tests](https://img.shields.io/github/actions/workflow/status/garywu/dotfiles/test-docs.yml?branch=main&label=tests&style=flat-square)](https://github.com/garywu/dotfiles/actions/workflows/test-docs.yml)
[![Linting](https://img.shields.io/github/actions/workflow/status/garywu/dotfiles/lint.yml?branch=main&label=lint&style=flat-square)](https://github.com/garywu/dotfiles/actions/workflows/lint.yml)
[![Security](https://img.shields.io/github/actions/workflow/status/garywu/dotfiles/security.yml?branch=main&label=security&style=flat-square)](https://github.com/garywu/dotfiles/actions/workflows/security.yml)

<!-- Release Channels - Three-Branch Git Workflow -->
[![Stable](https://img.shields.io/badge/stable-production_releases-green?style=flat-square)](https://github.com/garywu/dotfiles/tree/stable)
[![Beta](https://img.shields.io/badge/beta-weekly_testing-orange?style=flat-square)](https://github.com/garywu/dotfiles/tree/beta)
[![Main](https://img.shields.io/badge/main-active_development-red?style=flat-square)](https://github.com/garywu/dotfiles/tree/main)

<!-- Technology Stack -->
[![Nix](https://img.shields.io/badge/Nix-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org/)
[![Home Manager](https://img.shields.io/badge/Home_Manager-48B9C7?style=flat-square)](https://github.com/nix-community/home-manager)
[![Chezmoi](https://img.shields.io/badge/Chezmoi-0078D4?style=flat-square)](https://www.chezmoi.io/)
[![Fish Shell](https://img.shields.io/badge/Fish-Shell-4AAE46?style=flat-square)](https://fishshell.com/)

<!-- Documentation -->
[![Documentation](https://img.shields.io/badge/docs-github_pages-blue?style=flat-square)](https://garywu.github.io/dotfiles)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

</div>

**A modern, cross-platform development environment that just works.** Zero-config setup with powerful CLI tools, automated package management, and bulletproof synchronization across all your machines.

**Supported Platforms:** macOS (primary), Linux (experimental), Windows WSL (experimental)  
**Tech Stack:** Nix, Home Manager, Chezmoi, Homebrew

## 🔄 Git Workflow

This repository follows the **Claude-Init Three-Branch Strategy** for consistent release management:

- **🔴 `main`** - Active development (latest features)
- **🟠 `beta`** - Weekly releases for testing (stable but experimental)
- **🟢 `stable`** - Production releases (thoroughly tested)

**Development Flow:**
1. Feature work happens on `main`
2. Weekly beta releases from `main`
3. Stable releases promote tested betas
4. Automated sync keeps branches aligned

See [Issue #24](https://github.com/garywu/dotfiles/issues/24) for migration details.

## 🚀 Quick Start

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

- After each major step, restart your terminal and re-run `./bootstrap.sh` if prompted.

## 📁 Project Structure

```text
~/.dotfiles/
├── bootstrap.sh      # Main installation script
├── unbootstrap.sh    # Complete removal script
├── chezmoi/          # Chezmoi-managed files (secrets/meta only)
├── brew/             # Homebrew packages (macOS GUI apps)
├── logs/             # Bootstrap execution logs
└── README.md         # This file
```

## 🧪 Testing & Quality Assurance

This repository includes comprehensive testing infrastructure to prevent documentation link issues and ensure reliable deployments:

- **Link Pattern Validation**: Prevents GitHub Pages + Astro base path issues
- **Automated Testing**: Pre-deployment validation and post-deployment verification
- **Cross-Platform Testing**: Validates builds on multiple platforms
- **Production Verification**: Tests live site links after deployment

Run tests locally:

```bash
# Test documentation patterns
./tests/docs/test_link_patterns.sh

# Test production links
./tests/docs/test_production_links.sh

# Full test suite
cd docs && npm test
```

See [`tests/docs/README.md`](tests/docs/README.md) for comprehensive testing documentation.

## 📝 Documentation

For full documentation, philosophy, architecture, and advanced usage, see:

- **📘 [Complete Documentation](https://garywu.github.io/dotfiles/)** - Comprehensive guides and reference
- **🔧 [Getting Started](https://garywu.github.io/dotfiles/01-introduction/getting-started/)** - Step-by-step setup
- **⚡ [CLI Tools](https://garywu.github.io/dotfiles/03-cli-tools/modern-replacements/)** - Modern command-line tools
