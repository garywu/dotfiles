# Package Management Architecture

This dotfiles configuration uses a sophisticated **three-tier package management strategy** that provides
reproducible development environments while maintaining native macOS integration.

## Overview

We use three package managers, each with a **specific, non-overlapping role**:

1. **Nix/Home Manager** - Primary development environment
2. **Homebrew** - macOS GUI applications only
3. **Chezmoi** - Secrets and machine-specific configuration

## Package Manager Roles

### 🔧 Nix/Home Manager (Primary Development)

**Purpose**: All development tools and CLI utilities

**What it manages**:

- Programming language runtimes (Python, Node.js, Go, Rust)
- Development tools (Git, AWS CLI, Docker CLI)
- CLI utilities (ripgrep, fd, bat, eza)
- Graphics libraries (Cairo, Pango, GLib)
- System utilities and development dependencies

**Benefits**:

- ✅ **Reproducible** - Exact same versions across machines
- ✅ **Cross-platform** - Works on macOS and Linux
- ✅ **Isolated** - No conflicts between versions
- ✅ **Declarative** - Everything defined in `nix/home.nix`
- ✅ **Secure** - Multi-user daemon mode provides build isolation

**Installation Mode**: We use [multi-user Nix with daemon](./nix-daemon.md) for security and multi-user support.

### 🖥️ Homebrew (macOS GUI Applications)

**Purpose**: Native macOS applications and tools that require GUI integration

**What it manages**:

- GUI applications (Docker Desktop, VS Code, iTerm2)
- macOS-specific tools (mas - Mac App Store CLI)
- Network monitoring tools (Linux-only alternatives in Nix)

**Acceptable exceptions**:

- Dependencies required by Homebrew formulas (e.g., `python@3.12` for `ra-aid`)

### 🔐 Chezmoi (Secrets & Machine-Specific)

**Purpose**: User-specific values and secrets

**What it manages**:

- Git user name/email templates
- SSH configurations with private server details
- API keys and tokens
- Machine-specific paths and values

## PATH Precedence Strategy

The Fish shell configuration implements a **Nix-first policy** to ensure development tools use the correct versions:

```fish
# 1. Load Homebrew paths first (for GUI app discovery)
if test -e /opt/homebrew/bin/brew
  eval (/opt/homebrew/bin/brew shellenv)
end

# 2. Then prioritize Nix paths for development tools
set -gx PATH $HOME/.nix-profile/bin $HOME/.npm-global/bin $HOME/.local/bin $PATH
```

This ensures:

- **Development tools use Nix** (`python3`, `git`, `node`, etc.)
- **GUI apps still work** via Homebrew
- **No conflicts** between package managers

## Python Multi-Version Setup

### Available Python Versions

We maintain multiple Python versions simultaneously using Nix:

```bash
# Check available versions
python3.10 --version  # Python 3.10.17
python3.11 --version  # Python 3.11.12 (default)
python3.12 --version  # Python 3.12.10
python3.13 --version  # Python 3.13.3

# Default Python points to 3.11
python3 --version     # Python 3.11.12
```

### Version-Specific Commands

Each Python version has its own commands:

```bash
# Use specific Python versions
python3.10 -c "print('Hello from 3.10')"
python3.12 -m pip install requests
python3.13 -m venv myproject

# pip is available for all versions
pip3 --version        # Uses Python 3.11 (default)
python3.10 -m pip --version
python3.12 -m pip --version
```

### Implementation Details

The multi-version setup uses wrapper scripts in `~/.local/bin/`:

```nix
# In nix/home.nix
home.file = {
  ".local/bin/python3.10".source = pkgs.writeShellScript "python3.10" ''
    exec ${pkgs.python310}/bin/python3.10 "$@"
  '';
  ".local/bin/pip3.10".source = pkgs.writeShellScript "pip3.10" ''
    exec ${pkgs.python310}/bin/python3.10 -m pip "$@"
  '';
  # ... similar for 3.12 and 3.13
};
```

## Policy Enforcement

### Validation Scripts

Automated validation ensures policy compliance:

```bash
# Check for policy violations
./scripts/validation/validate-packages.sh

# Auto-fix detected issues
./scripts/validation/validate-packages.sh --fix
```

The script checks that development tools use Nix and warns about duplicates.

### Policy Rules

**✅ Correct Usage**:

```bash
# Development tools via Nix
which python3    # /Users/admin/.nix-profile/bin/python3
which git        # /Users/admin/.nix-profile/bin/git
which aws        # /Users/admin/.nix-profile/bin/aws

# GUI apps via Homebrew
ls /Applications | grep Docker    # Docker.app
```

**❌ Policy Violations**:

- Installing `awscli` via Homebrew (use Nix `awscli2`)
- Installing Python development tools via Homebrew
- Putting secrets in `nix/home.nix` (use Chezmoi templates)

## Workflows

### Adding Development Tools

1. Add to `nix/home.nix`:

```nix
home.packages = with pkgs; [
  git
  python311
  nodejs_20
  # Add new tool here
  newtool
];
```

1. Apply changes:

```bash
home-manager switch
```

### Adding GUI Applications

1. Add to `brew/Brewfile`:

```ruby
# GUI applications only
cask "new-app"
```

1. Install:

```bash
brew bundle --file=brew/Brewfile
```

### Managing Secrets

1. Edit templates in `chezmoi/`:

```bash
chezmoi edit ~/.gitconfig
```

1. Apply changes:

```bash
chezmoi apply
```

## Troubleshooting

### Python Version Conflicts

If you encounter Python version issues:

```bash
# Check current Python source
which python3
# Should show: /Users/admin/.nix-profile/bin/python3

# If showing Homebrew path, reload shell:
source ~/.config/fish/config.fish

# Or restart terminal
```

### Homebrew GUI Apps Not Working

If GUI applications aren't launching:

```bash
# Ensure Homebrew paths are in PATH
echo $PATH | tr ':' '\n' | grep homebrew
# Should show: /opt/homebrew/bin

# Reload Homebrew environment
eval (/opt/homebrew/bin/brew shellenv)
```

### Package Conflicts

If you have the same package in both Nix and Homebrew:

```bash
# Check for duplicates
./scripts/validation/validate-packages.sh

# Remove from Homebrew (keep Nix version)
brew uninstall problematic-package
```

## Benefits of This Architecture

1. **Reproducibility**: Development environment fully described in `nix/home.nix`
2. **Cross-platform**: Nix configurations work on Linux and macOS
3. **Isolation**: Multiple Python versions without conflicts
4. **Security**: Secrets kept out of world-readable Nix store
5. **Native integration**: GUI apps get full macOS integration
6. **Maintainability**: Clear separation prevents configuration drift

## Best Practices

1. **Always prefer Nix** for development tools and CLI utilities
2. **Use Homebrew only** for GUI applications and macOS-specific tools
3. **Keep secrets in Chezmoi** templates, never in Nix configuration
4. **Run validation regularly** to catch policy violations early
5. **Document exceptions** when Homebrew dependencies are required
6. **Test across Python versions** when developing Python applications

This architecture provides the best of both worlds: Nix's reproducibility for development and
Homebrew's native macOS integration for applications.

## Automated Testing & CI/CD

### Validation Scripts

The dotfiles include comprehensive validation scripts to ensure the package management architecture remains consistent:

```bash
# Run all validations
./scripts/validate-all.sh

# Quick validation (skip slow tests)
./scripts/validate-all.sh --quick

# Auto-fix detected issues
./scripts/validate-all.sh --fix

# Specific Python validation
./scripts/validation/validate-python.sh

# Package policy validation
./scripts/validation/validate-packages.sh
```

### GitHub Actions Integration

The repository includes automated validation via GitHub Actions:

- **`validate-package-management.yml`** - Comprehensive package management testing
- **`test-bootstrap.yml`** - Bootstrap process validation
- **`lint.yml`** - Code quality and linting

These workflows automatically:

- ✅ Test Python multi-version setup
- ✅ Verify PATH precedence
- ✅ Check for package conflicts
- ✅ Validate security practices
- ✅ Run performance benchmarks
- ✅ Generate validation reports

### Daily Monitoring

Scheduled GitHub Actions run daily to catch:

- Package drift over time
- Upstream changes affecting compatibility
- Security vulnerabilities
- Performance degradation

### Validation Features

**Package Policy Enforcement**:

- Detects development tools installed via Homebrew
- Warns about duplicate packages
- Suggests fixes for violations

**Python Multi-Version Testing**:

- Verifies all Python versions are available
- Tests pip functionality for each version
- Validates wrapper scripts
- Checks for conflicts

**Security Validation**:

- Scans for secrets in Nix configuration
- Checks file permissions
- Validates PATH security

**Performance Monitoring**:

- Times home-manager operations
- Measures Python startup performance
- Tracks system resource usage

This automated testing ensures the package management architecture remains reliable and catches issues
before they affect your development workflow.
