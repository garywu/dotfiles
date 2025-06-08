# Development Environment Setup

This repository contains configurations and scripts for setting up a modern development environment. It supports multiple development approaches and tools, allowing you to choose the best fit for your needs.

## Uninstall / Rollback

To completely remove all installed tools, dotfiles, and restore your environment, run:

```sh
~/.dotfiles/scripts/unbootstrap.sh
```

This will:
- Remove Homebrew and all installed packages
- Remove Nix, Home Manager, and related configs
- Remove Chezmoi and dotfiles
- Restore your default shell to bash
- Clean up environment variables

**You will be prompted for confirmation before anything is removed.**

## Quick Start

To set up your development environment on a new machine:

### One-Command Setup
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/minimal_install.sh)"
```

### Manual Setup
1. **Install Nix** (if not present):
   ```sh
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. **Install and apply dotfiles**:
   ```sh
   nix profile install nixpkgs#chezmoi
   chezmoi init --apply https://github.com/yourusername/dotfiles.git
   ```

3. **Activate your environment**:
   ```sh
   cd ~/.dotfiles/nix && home-manager switch
   ```

4. **On Mac, install GUI apps**:
   ```sh
   brew bundle --file=~/.dotfiles/brew/Brewfile
   ```

5. **Restart your terminal** to apply all changes.

### What Gets Installed

- **Nix**: Manages all CLI tools and development languages (cross-platform)
- **chezmoi**: Manages your dotfiles and configuration files
- **Homebrew** (Mac only): GUI applications and Mac-specific tools
- **Fish shell** with **Starship prompt** and modern CLI tools

## OS-Specific Setup Templates

For detailed, step-by-step instructions tailored to your operating system:

### 🚀 Smart Setup (Recommended)
Automatically detects your OS and runs the appropriate setup:
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/setup.sh | bash
```

### 📱 macOS
Complete setup for macOS using Nix + Homebrew:
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/macos.md
```
**Includes**: Xcode tools, Homebrew GUI apps, system tweaks, performance optimizations

### 🐧 Ubuntu/Debian
Ubuntu/Debian setup using Nix + apt:
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/ubuntu.md
```
**Includes**: System packages, development dependencies, GUI apps, security configurations

### 🪟 WSL2
Windows Subsystem for Linux setup with optimizations:
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/dotfiles/main/templates/wsl2.md
```
**Includes**: WSL2 optimizations, X11 forwarding, Windows integration, performance tuning

Each template provides:
- **Prerequisites** and system requirements
- **Step-by-step** installation instructions
- **OS-specific** configurations and optimizations
- **Troubleshooting** guides for common issues
- **Performance** tuning recommendations

## Development Environment Options

### 1. Local Development (Recommended for most cases)

Uses modern tools without containers for better performance and simplicity.

**Features**:
- Language-specific project templates (Python, Node.js, Go, Rust)
- Modern package managers (uv, npm, cargo, go)
- Development tools (linters, formatters, test runners)
- Documentation generators
- Pre-commit hooks

**Setup**:
```bash
# Create a new project
./scripts/create-project.sh my-project [python|node|go|rust|ai]
```

### 2. Dev Containers (VS Code)

For isolated, reproducible development environments using VS Code.

**Features**:
- Isolated development environment
- Consistent tools across team
- Multiple language support
- Database (PostgreSQL)
- Cache (Redis)
- Object storage (MinIO)

**Setup**:
1. Install VS Code and "Remote - Containers" extension
2. Open project in VS Code
3. Press F1 and select "Remote-Containers: Reopen in Container"

### 3. GitPod (Cloud Development)

For cloud-based development environments.

**Features**:
- Instant development environments
- Pre-built environments
- Team collaboration
- Persistent workspaces
- Browser-based VS Code

**Setup**:
1. Push code to GitHub
2. Install GitPod browser extension
3. Click GitPod button on repository

### 4. Advanced Options

#### Container Runtimes
- **containerd**: Industry standard, Kubernetes-native
- **CRI-O**: Lightweight, security-focused
- **Podman**: Daemonless, rootless alternative to Docker

#### Build Systems
- **BuildKit**: Faster builds, better caching
- **Buildah**: No daemon, security-focused
- **Nix**: Reproducible builds

#### Security-focused
- **gVisor**: Strong isolation
- **Kata Containers**: VM-like security

## Project Structure

```
dotfiles/
├── .devcontainer/          # Dev Container configuration
├── .gitpod/               # GitPod configuration
├── brew/                  # Homebrew packages (macOS GUI apps)
├── nix/                   # Nix configuration (cross-platform CLI tools)
├── scripts/              # Setup and utility scripts
│   ├── bootstrap.sh      # Main setup script
│   ├── create-project.sh # Project template generator
│   └── setup-*.sh        # Various setup scripts
├── templates/            # OS-specific setup templates
│   ├── setup.sh          # Smart setup script (auto-detects OS)
│   ├── macos.md          # macOS setup guide
│   ├── ubuntu.md         # Ubuntu/Debian setup guide
│   └── wsl2.md           # WSL2 setup guide
├── starship/             # Shell prompt configuration
├── fish/                 # Fish shell configuration
└── chezmoi/              # Dotfile management
```

## Language Support

### Python
- Package manager: uv (faster than pip)
- Linting: flake8, mypy
- Formatting: black, isort
- Testing: pytest
- Documentation: Sphinx

### Node.js
- Package manager: npm
- Linting: ESLint
- Formatting: Prettier
- Testing: Jest
- Documentation: TypeDoc

### Go
- Package manager: go mod
- Linting: golangci-lint
- Formatting: gofmt
- Testing: go test
- Documentation: godoc

### Rust
- Package manager: cargo
- Linting: clippy
- Formatting: rustfmt
- Testing: cargo test
- Documentation: rustdoc, mdbook

## Development Tools

### Version Control
- Git with pre-commit hooks
- GitHub CLI
- GitLens

### IDE Integration
- VS Code with extensions
- Language servers
- Debug configurations

### Documentation
- Markdown support
- API documentation generators
- Project documentation tools

### Testing
- Unit testing frameworks
- Coverage tools
- Benchmarking tools

### Security
- Dependency scanning
- Code analysis
- Security linters

## Choosing Your Setup

### For Local Development
- Use project templates for new projects
- Install language-specific tools
- Use pre-commit hooks

### For Team Development
- Use Dev Containers for consistency
- Share VS Code settings
- Use GitPod for quick starts

### For Production
- Use containerd or CRI-O
- Implement security measures
- Use BuildKit for builds

### For Security
- Use Podman or Kata Containers
- Implement gVisor for isolation
- Use security scanning tools

## Terminal Font Setup for Starship Prompt

To see all icons and symbols (like the green arrow ➜) in your Starship prompt, you must use a Nerd Font in your terminal.

1. **Install a Nerd Font:**
   - The bootstrap script will install FiraCode Nerd Font automatically.
   - Or you can download from [Nerd Fonts](https://www.nerdfonts.com/font-downloads)

2. **Set the Font in Terminal:**
   - Open Terminal → Settings → Profiles → Text → Change Font
   - Select your installed Nerd Font (e.g., "FiraCode Nerd Font")
   - Restart Terminal

> **Note:** This step cannot be automated by a script. You must set the font manually in your terminal's preferences.

## Maintenance

### Updating Tools
```bash
# Update Homebrew packages
brew update && brew upgrade

# Update Nix packages
nix-channel --update
nix-env -u '*'

# Update project dependencies
./scripts/update-dependencies.sh
```

### Adding New Tools
1. Add to appropriate configuration file
2. Update bootstrap script
3. Test in clean environment

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Advanced CLI Tools & Features

This setup uses a **Nix-first approach** for cross-platform reproducibility:

### Managed by Nix (Cross-Platform)
All CLI tools and development languages are managed by Nix for reproducibility across macOS, Linux, and WSL:

- **chezmoi**: Dotfiles management and reproducible setup
- **tmux**: Terminal multiplexer for persistent, multi-pane sessions
- **mosh**: Robust remote shell that survives network drops
- **fzf**: Fuzzy finder for files, history, and more
- **zoxide**: Smarter directory jumping
- **fish**: User-friendly shell
- **starship**: Fast, customizable prompt
- **thefuck**: Instantly correct previous command typos
- **eza**: Modern replacement for ls
- **bat**: Modern cat with syntax highlighting
- **fd**: Fast, user-friendly find alternative
- **rg (ripgrep)**: Fast recursive search
- **delta**: Syntax-highlighting pager for git/diff
- **lazygit**: TUI for git
- **btop**: Resource monitor (modern htop alternative)
- **neovim**: Modern Vim-based text editor
- **glow**: Markdown previewer in the terminal
- **vifm**: Terminal file manager with preview support for text and binary files

### Managed by Homebrew (Mac-Only)
Only GUI applications and Mac-specific tools are managed by Homebrew:

- **Docker Desktop**: Container platform for Mac
- **iTerm2**: Advanced terminal emulator
- **Postman/Insomnia**: API testing tools
- **TablePlus/DBeaver**: Database management tools
- **Xcode**: Apple development tools (Mac App Store)
- **Slack**: Team communication (Mac App Store)

This separation ensures maximum **cross-platform compatibility** while keeping Mac-specific apps where they belong.

## Neovim

Neovim is a modern, extensible Vim-based text editor. It is included in this setup and installed automatically by the bootstrap script. 