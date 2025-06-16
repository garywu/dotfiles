# Architecture: Separation of Concerns

This dotfiles repository uses a clean separation of concerns between configuration management and secrets management.

## Overview

- **Nix/Home Manager**: Manages all packages and dotfile configurations
- **Chezmoi**: Manages only secrets and machine-specific templating
- **Homebrew**: GUI applications on macOS only

## Directory Structure

```
~/.dotfiles/
├── nix/
│   └── home.nix          # All package and configuration declarations
├── chezmoi/
│   ├── chezmoi.toml      # User-specific values and secrets
│   ├── dot_gitconfig.tmpl # Git config with user values
│   └── private_dot_ssh/   # SSH configs with secrets
└── brew/
    └── Brewfile          # macOS GUI apps
```

## Why This Architecture?

### Previous Issues
- Having Chezmoi manage `home.nix` created confusion
- Changes required both `chezmoi apply` and `home-manager switch`
- Two tools managing the same files led to conflicts

### Current Benefits
1. **Clear Separation**: Each tool has a specific, non-overlapping role
2. **Simple Workflow**: Edit `nix/home.nix` directly, run `home-manager switch`
3. **Secrets Safety**: Chezmoi templates keep secrets out of Nix store
4. **No Conflicts**: Tools don't compete over file management

## Workflows

### Adding a Package or Changing Configuration
```bash
# Edit the configuration
$EDITOR ~/.dotfiles/nix/home.nix

# Apply changes
home-manager switch
```

### Managing Secrets
```bash
# Edit secret templates
$EDITOR ~/.dotfiles/chezmoi/chezmoi.toml

# Apply secret changes
chezmoi apply
```

### Initial Setup
```bash
# Clone and run bootstrap
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

## Examples

### Nix/Home Manager (nix/home.nix)
- Package installations
- Shell configurations (fish, bash, zsh)
- Tool configurations (git, starship, etc.)
- Environment variables

### Chezmoi Templates
- Git user name/email
- SSH configs with private server details
- API keys or tokens (if needed)
- Machine-specific paths

## Best Practices

1. **Never put secrets in nix/home.nix** - They end up in world-readable Nix store
2. **Use Chezmoi templates for anything machine-specific or private**
3. **Keep package management in Nix** for reproducibility
4. **Document any new secret variables** in chezmoi.toml comments
