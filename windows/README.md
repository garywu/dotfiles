# Windows Native Development Environment

This folder contains a native Windows setup that mirrors the Unix dotfiles environment as closely as possible, without requiring WSL.

## Quick Start

1. **Open PowerShell as Administrator** (recommended) or regular user
2. **Clone this repository**:
   ```powershell
   git clone https://github.com/yourusername/dotfiles.git $HOME\.dotfiles
   cd $HOME\.dotfiles\windows
   ```
3. **Run the bootstrap script**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\bootstrap.ps1
   ```

## What Gets Installed

### Package Manager
- **Scoop** - User-friendly package manager (no admin required)
- Additional buckets: extras, versions, nerd-fonts

### Shell Environment
- **PowerShell 7+** - Modern PowerShell
- **Windows Terminal** - Modern terminal emulator
- **Starship** - Cross-platform prompt (same as Unix)

### Development Tools
Matching the Unix setup:
- **Languages**: Python, Node.js (via fnm), Go, Rust
- **Version Managers**: fnm (Node), rustup (Rust)
- **Package Managers**: npm, yarn, pnpm, bun, pip, cargo

### CLI Tools
All the modern CLI tools from the Unix setup:
- **Better Basics**: eza (ls), bat (cat), fd (find), ripgrep (grep)
- **Git Tools**: gh, lazygit, delta, tig
- **File Navigation**: zoxide (smart cd), fzf (fuzzy finder), broot
- **Development**: jq, yq, httpie, mkcert, act, dive, k9s
- **System Monitoring**: btop, bottom, dust, duf

### Cloud Tools
- AWS CLI, Google Cloud SDK, Cloudflare tools

### Editor
- VS Code with curated extensions

## Key Differences from Unix Setup

| Unix | Windows | Notes |
|------|---------|-------|
| Fish shell | PowerShell 7 | PowerShell profile mimics Fish config |
| Nix packages | Scoop packages | Similar declarative approach |
| ~/.config/ | ~\\.config\\ | Same config structure |
| Homebrew (macOS) | Scoop + winget | GUI apps via winget |
| Terminal.app/iTerm2 | Windows Terminal | Modern, customizable |

## Directory Structure

```
windows/
├── bootstrap.ps1                    # Main setup script
├── packages/
│   └── scoop-packages.json         # Package manifest
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1  # PowerShell config
├── terminal/
│   └── settings.json               # Windows Terminal config
├── config/
│   └── vscode-extensions.txt       # VS Code extensions
└── scripts/
    └── update.ps1                  # Update script (coming soon)
```

## Daily Usage

### Update Everything
```powershell
scoop update
scoop update *
```

### Common Commands
All aliases from Unix work the same:
- `ls`, `ll`, `la` → uses eza
- `cat` → uses bat
- `find` → uses fd
- `grep` → uses ripgrep

### Git Aliases
- `gst` - git status
- `gco` - git checkout
- `glog` - pretty git log

### Smart Navigation
- `z project` - jump to project directory (zoxide)
- `Ctrl+R` - fuzzy search command history (fzf)
- `Ctrl+T` - fuzzy find files (fzf)

## Customization

### Local Overrides
Create `~/.config/powershell/local.ps1` for personal customizations.

### Adding Packages
Edit `packages/scoop-packages.json` and run:
```powershell
scoop install <package-name>
```

## Troubleshooting

### Execution Policy Error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Font Issues
Install a Nerd Font:
```powershell
scoop bucket add nerd-fonts
scoop install CascadiaCode-NF
```

### Path Issues
Restart your terminal after installation to ensure PATH updates.

## Philosophy

This Windows setup aims to provide:
1. **Parity** with Unix dotfiles where possible
2. **Native** Windows solutions (no WSL required)
3. **User-friendly** installation (minimal admin rights)
4. **Modern** tools and practices
5. **Maintainable** configuration

While it can't be 100% identical to the Unix setup (due to OS differences), it gets remarkably close and provides a fantastic native Windows development experience.
