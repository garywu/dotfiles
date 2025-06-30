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

### macOS / Linux / WSL

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

- After each major step, restart your terminal and re-run `./bootstrap.sh` if prompted.

### Native Windows (No WSL)

```powershell
git clone https://github.com/garywu/dotfiles.git $HOME\.dotfiles
cd $HOME\.dotfiles\windows
.\bootstrap.ps1
```

- See [windows/README.md](windows/README.md) for the native Windows development environment.

## 📁 Project Structure

```text
~/.dotfiles/
├── bootstrap.sh      # Main installation script (Unix)
├── unbootstrap.sh    # Complete removal script
├── nix/              # Nix package declarations
├── chezmoi/          # Chezmoi-managed files (secrets/meta only)
├── brew/             # Homebrew packages (macOS GUI apps)
├── windows/          # Native Windows environment
│   ├── bootstrap.ps1 # Windows installation script
│   ├── packages/     # Scoop package manifests
│   └── powershell/   # PowerShell configuration
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

## 🛠️ Features

### Core Features
- **Zero-Config Setup**: One command to configure your entire development environment
- **Cross-Platform**: Works on macOS, Linux, Windows WSL, and native Windows
- **Declarative Configuration**: All settings in version-controlled Nix files
- **Automated Updates**: Keep all tools current with simple commands
- **Safe Rollbacks**: Revert to any previous configuration instantly

### Included Tools
- **Modern CLI Replacements**: `eza` (ls), `ripgrep` (grep), `fd` (find), `bat` (cat), and more
- **Development Essentials**: Git, SSH, tmux, neovim, starship prompt
- **Language Support**: Node.js, Python, Ruby, Rust, Go environments
- **Cloud Tools**: AWS CLI, Terraform, Docker, Kubernetes utilities
- **Security Tools**: GPG, password managers, SSH key management

## 📝 Documentation

For full documentation, philosophy, architecture, and advanced usage, see:

- **📘 [Complete Documentation](https://garywu.github.io/dotfiles/)** - Comprehensive guides and reference
- **🔧 [Getting Started](https://garywu.github.io/dotfiles/01-introduction/getting-started/)** - Step-by-step setup
- **⚡ [CLI Tools](https://garywu.github.io/dotfiles/03-cli-tools/modern-replacements/)** - Modern command-line tools

## 🚨 Troubleshooting

### Common Issues

**Bootstrap fails with "command not found"**
- Restart your terminal and re-run `./bootstrap.sh`
- The script will continue from where it left off

**Nix installation appears stuck**
- This is normal - Nix downloads can take 10-15 minutes
- Check Activity Monitor/System Monitor for active downloads

**Home Manager won't activate**
- Ensure you've restarted your terminal after Nix installation
- Run `nix-shell -p home-manager --run "home-manager switch"`

**Fish shell not loading properly**
- Run `chsh -s $(which fish)` manually
- Log out and back in for changes to take effect

### Getting Help

1. Check the [documentation](https://garywu.github.io/dotfiles/)
2. Search [existing issues](https://github.com/garywu/dotfiles/issues)
3. Create a [new issue](https://github.com/garywu/dotfiles/issues/new) with:
  - Your OS and version
  - Error messages
  - Steps to reproduce

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles

# Create a feature branch
git checkout -b feature/amazing-feature

# Make changes and test
make lint        # Run linters
make format      # Format code
make test        # Run tests

# Commit with conventional commits
git commit -m "feat: add amazing feature"
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) teams
- [Chezmoi](https://www.chezmoi.io/) for secrets management
- All the amazing CLI tool authors
- Contributors and users of this project

---

<div align="center">
<sub>Built with ❤️ by the community</sub>
</div>
