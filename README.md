# Modern Development Environment Setup

This repository contains a complete, automated setup for a modern development environment using **Nix**, **Home Manager**, **Chezmoi**, and **Homebrew** (macOS). It provides a single-command bootstrap process that sets up everything you need for development.

## 🚀 Quick Start

**One-Command Setup** - Run this on any fresh machine:

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script will:
1. Install Nix (cross-platform package manager)
2. Install Home Manager (declarative user environment)
3. Install Chezmoi (dotfiles management)
4. Apply your dotfiles configuration
5. Install development tools via Nix
6. Install GUI apps via Homebrew (macOS only)
7. Log everything to timestamped files

**After each major installation step, restart your terminal and run `./bootstrap.sh` again to continue.**

## 🎯 Philosophy & Approach

### Why This Architecture?

This setup is built on a **"Nix-first, platform-specific supplements"** philosophy that prioritizes **reproducibility** and **cross-platform compatibility** while acknowledging platform-specific needs.

### 🔧 Nix + Home Manager (The Foundation)
**Handles**: All CLI tools, development languages, shell configuration, and core utilities

**Why Nix?**
- ✅ **Reproducible**: Exact same versions across all machines and platforms
- ✅ **Declarative**: Your entire environment is defined in configuration files
- ✅ **Cross-platform**: Works identically on macOS, Linux, and WSL
- ✅ **Atomic**: Upgrades and rollbacks are safe and instant
- ✅ **No conflicts**: Multiple versions can coexist peacefully

**Examples**: Python, Node.js, Git, fish shell, CLI tools like `bat`, `fd`, `ripgrep`

### 🍺 Homebrew (Platform-Specific Supplements)
**Handles**: GUI applications and macOS-specific tools only

**Why Homebrew for GUI apps?**
- ✅ **Native integration**: Apps integrate properly with macOS
- ✅ **System optimization**: Built for Mac hardware and features
- ✅ **App Store access**: Can install Mac App Store apps via `mas`
- ✅ **Cask ecosystem**: Largest collection of Mac GUI apps

**Examples**: Docker Desktop, iTerm2, Postman, TablePlus, Xcode

### 🏗️ The Result: Best of Both Worlds

```
┌─────────────────────────────────────────────────────┐
│                 Your Development Environment        │
├─────────────────────────────────────────────────────┤
│  🖥️  GUI Apps (Homebrew)                           │
│      • Docker Desktop, iTerm2, IDEs               │
│      • Platform-optimized, native integration     │
├─────────────────────────────────────────────────────┤
│  🛠️  CLI Tools & Languages (Nix + Home Manager)   │
│      • Python, Node.js, Git, shell tools          │
│      • Reproducible across all platforms          │
│      • Declarative configuration                  │
└─────────────────────────────────────────────────────┘
```

### 🎯 Core Benefits

1. **Maximum Portability**: Your CLI environment is identical on any platform
2. **Zero Conflicts**: Nix prevents dependency hell and version conflicts  
3. **Instant Recovery**: New machine? Clone repo, run bootstrap, get exact environment
4. **Safe Experimentation**: Try new tools without breaking your setup
5. **Team Consistency**: Everyone gets exactly the same development tools

This approach ensures that your **development workflow** (CLI tools, languages, shell) is consistent everywhere, while your **platform experience** (GUI apps, system integration) remains optimized for your specific OS.

## ✨ What Gets Installed

### 🛠️ Development Tools (via Nix)
- **Languages**: Python 3.11, Node.js 20, Bun, Go, Rust
- **Version Managers**: nvm, pyenv, rbenv, asdf-vm
- **Cloud Tools**: AWS CLI, Google Cloud SDK
- **Shell**: Fish shell with Starship prompt
- **Modern CLI Tools**: eza, bat, fd, ripgrep, fzf, zoxide, delta, lazygit, btop
- **Development**: Neovim, tmux, Git, GitHub CLI, htop, jq, yq
- **Security**: sops, age, pass, gnupg

### 🤖 AI/ML Tools (via Nix)
- **ollama**: Local LLM inference server (CLI)
- **chatblade**: CLI Swiss Army Knife for ChatGPT
- **chatgpt-cli**: Interactive CLI for ChatGPT
- **litellm**: Use any LLM as drop-in replacement for GPT-3.5-turbo

### 🖥️ GUI Applications (via Homebrew - macOS only)
- **Development**: Docker Desktop, iTerm2, Postman, Insomnia
- **Databases**: TablePlus, DBeaver Community
- **Utilities**: WebTorrent, aria2
- **Mac App Store**: Xcode, Slack

### 🏠 Environment Management
- **Home Manager**: Declarative configuration for packages and dotfiles
- **Chezmoi**: Dotfiles management and templating
- **Fish Shell**: User-friendly shell with aliases and integrations
- **Starship**: Fast, customizable prompt with Git integration

## 📁 Project Structure

```
~/.dotfiles/
├── bootstrap.sh              # 🚀 Main installation script
├── unbootstrap.sh            # 🗑️  Complete removal/rollback script  
├── chezmoi/
│   └── dot_config/
│       └── private_home-manager/
│           └── home.nix      # 📦 Home Manager configuration (single source of truth)
├── brew/
│   └── Brewfile             # Homebrew packages (macOS GUI apps)
├── scripts/
│   └── uninstall.sh         # Core uninstallation logic (unbootstrap.sh → this)
├── logs/                    # Bootstrap execution logs
│   ├── README.md
│   └── *.log               # Timestamped log files
└── README.md               # This file
```

**Symmetric Design**: Setup with `./bootstrap.sh`, teardown with `./unbootstrap.sh` - both in the root for easy discovery.

### 🏗️ Architecture Principles

This setup follows three core principles:

1. **Everything under git control** - All configurations are version controlled
2. **Whole system must be consistent** - No conflicting package managers or configs  
3. **Single source of truth** - One canonical location for each configuration

**Configuration Flow**:
```
Source: chezmoi/dot_config/private_home-manager/home.nix
   ↓ (chezmoi apply)
Deploy: ~/.config/home-manager/home.nix  
   ↓ (home-manager switch)
Result: Installed packages in ~/.nix-profile/
```

## 🔄 Complete Removal/Rollback

To completely remove all installed tools and restore your system:

```bash
./unbootstrap.sh
```

This will:
- Remove Nix and all packages
- Remove Home Manager configuration
- Remove Chezmoi and dotfiles
- Remove Homebrew and packages (macOS)
- Restore backup files created during installation
- Clean up environment variables and shell configurations

**You will be prompted for confirmation before anything is removed.**

## 📊 Logging

Every bootstrap run creates a timestamped log file in `~/.dotfiles/logs/` capturing:
- All command outputs and errors
- System information and environment
- Installation progress and results
- Complete audit trail for debugging

Example log: `~/.dotfiles/logs/bootstrap-20231208-143022.log`

## 🐚 Shell Configuration

### Fish Shell
- Modern, user-friendly shell with excellent defaults
- Smart autocompletions and syntax highlighting
- Configured aliases for modern CLI tools (ls → eza, cat → bat, etc.)
- Integration with zoxide, fzf, and direnv

### Starship Prompt
- Fast, customizable prompt with Git status
- Shows current directory, Git branch, and command status
- Language-specific indicators for development projects

**Note**: To see all prompt icons properly, set your terminal font to a Nerd Font (e.g., "FiraCode Nerd Font") in your terminal preferences.

## 🎯 Package Management Philosophy

This setup follows a **Nix-first approach** for maximum cross-platform compatibility:

- **Nix + Home Manager**: All CLI tools, development languages, and shell configuration
- **Homebrew** (macOS only): GUI applications and Mac-specific tools only

This ensures your development environment is reproducible across macOS, Linux, and WSL.

## 🛠️ Manual Setup (Alternative)

If you prefer to understand each step:

1. **Install Nix**:
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. **Install Home Manager**:
   ```bash
   nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   nix-channel --update
   nix-shell '<home-manager>' -A install
   ```

3. **Install Chezmoi and apply dotfiles**:
   ```bash
   nix-env -iA nixpkgs.chezmoi
   chezmoi init --apply https://github.com/garywu/dotfiles.git
   ```

4. **Activate Home Manager**:
   ```bash
   home-manager switch
   ```

5. **Install GUI apps** (macOS only):
   ```bash
   brew bundle --file=~/.dotfiles/brew/Brewfile
   ```

## 🔄 Maintenance

### Update Everything
```bash
# Update Nix packages
nix-channel --update
home-manager switch

# Update Homebrew packages (macOS)
brew update && brew upgrade
```

### Add New Tools
1. **CLI tools**: Add to `chezmoi/dot_config/private_home-manager/home.nix` in the `home.packages` list
2. **GUI apps**: Add to `brew/Brewfile`
3. **Deploy changes**: `chezmoi apply && home-manager switch`
4. **Commit**: `git add . && git commit -m "Add new tools"`

### Making Configuration Changes

Follow the **principled workflow**:

```bash
# 1. Edit source configuration
vim chezmoi/dot_config/private_home-manager/home.nix

# 2. Deploy via chezmoi  
chezmoi apply

# 3. Apply via Home Manager
home-manager switch

# 4. Commit changes
git add . && git commit -m "Update configuration"
```

## 🚨 Troubleshooting

### Common Issues

**"command not found" after installation**:
- Restart your terminal to load new environment
- Check logs in `~/.dotfiles/logs/` for errors

**Homebrew installation fails**:
- Ensure you have admin privileges
- Check internet connection
- Review bootstrap logs for specific errors

**Home Manager switch fails**:
- Check `chezmoi/dot_config/private_home-manager/home.nix` syntax
- Run `home-manager switch --show-trace` for detailed errors

**Chezmoi conflicts during apply**:
- Press `O` (capital O) to "Overwrite all" when prompted
- Or use `chezmoi apply --force` to skip prompts

### Reset and Retry
```bash
# Complete reset
./unbootstrap.sh

# Fresh start
./bootstrap.sh
```

### Check Home Manager Generations
```bash
# View configuration history
home-manager generations

# Rollback to previous generation if needed
home-manager switch --switch-generation 2
```

## 🤝 Contributing

1. Fork this repository
2. Make your changes
3. Test with `./bootstrap.sh` on a clean system
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

---

**Ready to get started? Just run `./bootstrap.sh` and let the automation handle the rest!** 🚀 