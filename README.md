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

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
   ```

2. Run the bootstrap script:
   ```bash
   cd ~/.dotfiles
   ./scripts/bootstrap.sh
   ```

> **To undo all changes, run:**
> ```sh
> ~/.dotfiles/scripts/unbootstrap.sh
> ```

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
├── brew/                  # Homebrew packages
├── nix/                   # Nix configuration
├── scripts/              # Setup and utility scripts
│   ├── bootstrap.sh      # Main setup script
│   ├── create-project.sh # Project template generator
│   └── setup-*.sh        # Various setup scripts
├── starship/             # Shell prompt configuration
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