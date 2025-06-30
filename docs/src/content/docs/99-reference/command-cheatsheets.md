---
title: Command Cheatsheets & Quick Reference
description: Quick reference for all configured aliases, shortcuts, and productivity commands
---

# Command Aliases & Shortcuts ⚡

Quick reference for all configured aliases, shortcuts, and productivity commands in your development environment.

## 🐟 **Fish Shell Aliases**

### **File Operations**
```bash
ls              # eza (modern ls with colors and icons)
ll              # eza -l (detailed list view)
la              # eza -la (all files, detailed)
cat             # bat (syntax highlighting file viewer)
find            # fd (modern find replacement)
grep            # rg (ripgrep - ultra-fast search)
```

### **Enhanced Commands**
```bash
# These are the modern replacements available:
eza             # Modern ls replacement
bat             # Syntax highlighted cat
fd              # User-friendly find
rg              # Ripgrep for fast text search
btop            # Modern system monitor
ncdu            # Interactive disk usage
zoxide          # Smart directory navigation
fzf             # Fuzzy finder
delta           # Enhanced git diff
lazygit         # Git terminal UI
```

## 🚀 **Productivity Shortcuts**

### **Navigation**
```bash
z <partial>     # Jump to directory (zoxide)
zi              # Interactive directory selection
..              # cd ..
...             # cd ../..
....            # cd ../../..

# Quick project navigation (create these aliases)
alias proj='cd ~/projects'
alias dots='cd ~/.dotfiles'
alias docs='cd ~/Documents'
```

### **Git Shortcuts**
```bash
lazygit         # Interactive git TUI
gh              # GitHub CLI
glab            # GitLab CLI

# Create these useful git aliases:
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glg='git log --oneline --graph'
```

### **Development**
```bash
# Language version managers
nvm             # Node version manager
pyenv           # Python version manager
rustup          # Rust version manager

# Package managers
npm             # Node package manager
pip             # Python package manager
cargo           # Rust package manager
brew            # Homebrew (macOS packages)
```

## 🤖 **AI Tools Commands**

### **Local AI (Ollama)**
```bash
ollama serve                    # Start Ollama service
ollama list                     # List installed models
ollama run <model>              # Run a model interactively
ollama pull <model>             # Download a model
ollama rm <model>               # Remove a model
ollama ps                       # Show running models
ollama stop <model>             # Stop a running model

# Quick model access
alias ai-code='ollama run qwen2.5-coder:7b-instruct'
alias ai-chat='ollama run llama3.2:8b'
alias ai-quick='ollama run llama3.2:3b'
```

### **ChatGPT CLI Tools**
```bash
chatgpt                         # Interactive ChatGPT CLI
chatblade                       # ChatGPT Swiss Army knife
litellm                         # Universal LLM API

# Useful ChatBlade examples:
chatblade -c "Explain this code" < file.py
chatblade -f file.py "Add error handling"
chatblade "Write a Python function for..."
```

## 🖥️ **Terminal Multiplexing (Tmux)**

### **Session Management**
```bash
tmux                            # Start new session
tmux new -s <name>              # Named session
tmux ls                         # List sessions
tmux a -t <name>                # Attach to session
tmux kill-session -t <name>     # Kill session

# Useful tmux aliases
alias tls='tmux list-sessions'
alias ta='tmux attach-session -t'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
```

### **Tmux Key Bindings**
```bash
Ctrl-b d        # Detach session
Ctrl-b c        # New window
Ctrl-b n        # Next window
Ctrl-b p        # Previous window
Ctrl-b %        # Split vertically
Ctrl-b "        # Split horizontally
Ctrl-b arrow    # Navigate panes
Ctrl-b z        # Zoom pane
```

## 🔍 **Search & Filter Workflows**

### **File Search Patterns**
```bash
# Find files by type
fd -e py                        # Python files
fd -e js -e ts                  # JavaScript/TypeScript
fd -e md                        # Markdown files
fd -t d                         # Directories only

# Content search patterns
rg "TODO|FIXME|HACK"           # Find code comments
rg "import.*requests"          # Find specific imports
rg -w "function"               # Whole word matches
rg -i "error"                  # Case insensitive
```

### **Combined Search Commands**
```bash
# Find and edit
alias fv='fd -t f | fzf | xargs nvim'
alias fe='fd -e py | fzf | xargs nvim'

# Search and view
alias sv='rg -l "TODO" | fzf | xargs bat'
alias recent='fd -t f --changed-within=1day'

# Project analysis
alias count-lines='fd -e py -x wc -l | sort -nr'
alias find-large='fd -t f -x ls -lh | sort -k5 -hr | head -10'
```

## 📊 **System Monitoring**

### **Resource Monitoring**
```bash
btop            # Interactive system monitor
htop            # Alternative system monitor
ncdu            # Disk usage analyzer
df -h           # Disk free space
free -h         # Memory usage (Linux)

# macOS specific
top             # System monitor
du -sh *        # Directory sizes
```

### **Process Management**
```bash
# Find and kill processes
alias pf='ps aux | fzf'
alias pk='pkill'

# Network monitoring
alias ports='lsof -i -P | grep LISTEN'
alias network='lsof -i'
```

## 🌐 **Network & HTTP**

### **HTTP Clients**
```bash
http            # HTTPie - user-friendly HTTP client
curl            # Traditional HTTP client
wget            # File downloader

# HTTPie examples
alias api-get='http GET'
alias api-post='http POST'
alias json-pretty='http --print=HhBb'
```

### **Network Tools**
```bash
ping            # Network connectivity
dig             # DNS lookup
netstat         # Network statistics
ssh             # Secure shell
mosh            # Mobile shell (robust SSH)
```

## 🔧 **Development Workflows**

### **Project Setup**
```bash
# Create project aliases
alias new-py='mkdir -p ~/projects/$1 && cd ~/projects/$1 && python -m venv .venv'
alias new-js='mkdir -p ~/projects/$1 && cd ~/projects/$1 && npm init -y'
alias new-rust='cargo new ~/projects/$1 && cd ~/projects/$1'

# Environment activation
alias activate='source .venv/bin/activate'
alias deactivate='deactivate'
```

### **Testing & Building**
```bash
# Language-specific commands
alias pytest='python -m pytest'
alias black='python -m black'
alias flake8='python -m flake8'
alias mypy='python -m mypy'

alias jest='npm test'
alias eslint='npm run lint'
alias build='npm run build'

alias cargo-test='cargo test'
alias cargo-build='cargo build'
alias cargo-run='cargo run'
```

## 🎯 **Workflow Combinations**

### **Daily Development**
```bash
# Start development session
alias dev-start='tmux new -s dev && cd ~/projects'

# Code review workflow
alias review='lazygit && gh pr list'

# Clean up workflow
alias cleanup='ncdu && brew cleanup && ollama list'
```

### **Deployment & Production**
```bash
# SSH shortcuts (customize for your servers)
alias prod='ssh user@production-server'
alias staging='ssh user@staging-server'
alias logs='ssh user@server "tail -f /var/log/app.log"'

# Docker shortcuts
alias dps='docker ps'
alias dimg='docker images'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'

# Container & Kubernetes Tools
act                             # Run GitHub Actions locally
act -l                          # List available workflows
act push                        # Run push event workflows
dive nginx:latest               # Analyze Docker image layers
k9s                            # Terminal UI for Kubernetes

# Advanced container workflows
alias act-ci='act -W .github/workflows/ci.yml'
alias dive-local='dive $(docker images -q | head -1)'
alias k9s-prod='k9s --context production'
```

## 🔄 **System Management**

### **Package Management**
```bash
# Nix/Home Manager
alias hm='home-manager'
alias hms='home-manager switch'
alias hmg='home-manager generations'

# System updates
alias update-all='brew update && brew upgrade && home-manager switch'
alias check-system='~/.dotfiles/check.sh'
```

### **Maintenance**
```bash
# Cleanup commands
alias clean-brew='brew cleanup'
alias clean-npm='npm cache clean --force'
alias clean-pip='pip cache purge'
alias clean-cargo='cargo clean'

# Check sizes
alias size-brew='brew list --formula | xargs brew info --size'
alias size-ollama='du -sh ~/.ollama/models'
alias size-node='du -sh ~/projects/*/node_modules'
```

## 🎨 **Customization Tips**

### **Create Custom Aliases**
Add to `~/.config/fish/config.fish`:

```fish
# Custom project aliases
alias myproject='cd ~/projects/important-project && tmux new -s myproject'

# Quick edits
alias edit-fish='nvim ~/.config/fish/config.fish'
alias edit-tmux='nvim ~/.tmux.conf'
alias edit-git='nvim ~/.gitconfig'

# Deployment shortcuts
alias deploy-staging='git push staging main'
alias deploy-prod='git push production main'

# AI-assisted development
alias code-review='fd -e py | head -5 | xargs cat | ollama run qwen2.5-coder:7b "Review this code"'
alias explain-code='bat $argv | ollama run qwen2.5-coder:7b "Explain this code"'
```

### **Function Examples**
```fish
# Function to create and enter directory
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Function to backup file
function backup
    cp $argv[1] $argv[1].backup.(date +%Y%m%d_%H%M%S)
end

# Function to extract archives
function extract
    switch $argv[1]
        case '*.tar.gz'
            tar -xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*'
            echo "Unsupported format"
    end
end
```

## 🟢 **Best Practices: Python venv & direnv Workflow**

### **Why use direnv?**
- Automatically activates your Python venv when you `cd` into a project directory
- Ensures your shell always has the correct PATH before activating the venv
- Avoids global venv activation, keeping your shell clean and reproducible

### **Recommended Setup**
1. **Install direnv** (already in your Nix/Home Manager config)
2. **Enable direnv in fish:**
   ```fish
   # Add to ~/.config/fish/config.fish
   direnv hook fish | source
   ```

3. **In your project directory, create a `.envrc` file:**
   ```bash
   # For Python venv:
   layout python
   # or, if you use a custom venv:
   source .venv/bin/activate
   ```

4. **Allow direnv to load the file:**
   ```bash
   direnv allow
   ```

5. **Now, when you `cd` into the project, the venv is auto-activated!**

### **Troubleshooting: Fish Shell, Nix, and PATH**
- If you see missing tools, ensure your Home Manager config includes:
  ```nix
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
      source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
    end
    direnv hook fish | source
  '';
  ```
- Always open a new terminal after running `home-manager switch`
- Do **not** activate a venv globally in your shell config—let direnv handle it per project

---

**💡 Pro Tip**: Start by memorizing the most common aliases (ls, cat, grep), then gradually add custom aliases for your specific workflows. Use `alias` command to see all current aliases!
