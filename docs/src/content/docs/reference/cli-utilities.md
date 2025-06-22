---
title: Command-Line Utilities Reference
description: Complete list of command-line utilities available across all platforms
---

# Command-Line Utilities Reference

This page lists all command-line utilities installed through Nix and Homebrew across different platforms.

## File Operations

### Navigation & Listing
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `eza` | Modern ls replacement with colors and git integration | Nix | All |
| `fd` | Fast and user-friendly alternative to find | Nix | All |
| `zoxide` | Smarter cd command that learns your habits | Nix | All |
| `broot` | Interactive directory tree navigation | Nix | All |

### Text Processing
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `rg` (ripgrep) | Ultra-fast text search tool | Nix | All |
| `bat` | Cat with syntax highlighting and git integration | Nix | All |
| `sd` | Intuitive find and replace tool | Nix | All |
| `choose` | Better alternative to cut/awk for field selection | Nix | All |

### File Monitoring
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `fswatch` | File system event monitor | Nix | All |
| `watchexec` | Execute commands when files change | Nix | All |

## Document Conversion

### Universal Converters
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `pandoc` | Universal document converter (Markdown, HTML, PDF, DOCX) | Nix | All |
| `soffice` | LibreOffice command-line interface | Homebrew | macOS |
| `soffice` | LibreOffice command-line interface | Nix | Linux/WSL |
| `unoconv` | LibreOffice-based document converter | Nix | Linux/WSL |
| `unoserver` | Modern document conversion server | PyUNO Setup | macOS |
| `unoconvert` | Modern document conversion client | PyUNO Setup | macOS |

### Text Utilities
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `hexyl` | Command-line hex viewer with colors | Nix | All |

## Development Tools

### Version Control
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `git` | Distributed version control system | Nix | All |
| `lazygit` | Terminal UI for git commands | Nix | All |
| `gitui` | Fast terminal UI for git | Nix | All |
| `tig` | Text-mode interface for git | Nix | All |
| `delta` | Enhanced git diff viewer | Nix | All |
| `gitleaks` | Detect secrets in git repositories | Nix | All |

### Programming Languages
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `python3` | Python 3.11 interpreter | Nix | All |
| `node` | Node.js runtime (v20) | Nix | All |
| `bun` | Fast JavaScript runtime and package manager | Nix | All |
| `go` | Go programming language | Nix | All |
| `rustc` | Rust compiler | Nix | All |
| `cargo` | Rust package manager | Nix | All |

### Package Managers
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `pipx` | Install Python CLI tools in isolated environments | Nix | All |
| `npm` | Node.js package manager | Nix | All |

## System Utilities

### Process & System Monitoring
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `procs` | Modern replacement for ps | Nix | All |
| `dust` | More intuitive disk usage analyzer (du replacement) | Nix | All |
| `duf` | Modern disk free utility | Nix | All |

### Network Tools
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `cloudflared` | Cloudflare Tunnel daemon and toolkit | Nix | All |
| `flarectl` | Cloudflare CLI for account management | Nix | All |

## Data Processing

### JSON & Structured Data
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `jq` | Command-line JSON processor | Nix | All |
| `jless` | Interactive JSON viewer | Nix | All |
| `gron` | Make JSON greppable | Nix | All |
| `fx` | Interactive JSON viewer and processor | Nix | All |

### CSV & Tabular Data
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `tidy-viewer` | Pretty-print CSV files in the terminal | Nix | All |

## Cloud & DevOps

### AWS Tools
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `aws` | AWS Command Line Interface v2 | Nix | All |

### Google Cloud
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `gcloud` | Google Cloud SDK | Nix | All |

## Security & Quality

### Security Scanning
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `trivy` | Vulnerability scanner for containers and filesystems | Nix | All |
| `hadolint` | Dockerfile linter | Nix | All |

### Code Quality
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `tokei` | Count lines of code by language | Nix | All |
| `hyperfine` | Command-line benchmarking tool | Nix | All |

## Linting & Formatting

### Shell & Scripts
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `shellcheck` | Shell script static analysis | Nix | All |
| `shfmt` | Shell script formatter | Nix | All |

### Configuration Files
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `nixpkgs-fmt` | Nix code formatter | Nix | All |
| `yamllint` | YAML linter | Nix | All |
| `taplo` | TOML formatter and linter | Nix | All |
| `markdownlint-cli` | Markdown linter | Nix | All |

### Git Hooks
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `pre-commit` | Git hook framework for code quality | Nix | All |

## Backup & Storage

### Backup Tools
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `borgbackup` | Deduplicating backup program | Nix | All |

## Special Platform Tools

### macOS-Only (via Homebrew)
| Command | Description | Source | Platforms |
|---------|-------------|--------|-----------|
| `mas` | Mac App Store command line interface | Homebrew | macOS |
| `aria2` | Lightweight download utility | Homebrew | macOS |

## Usage Examples

### Document Conversion
```bash
# Convert Word document to PDF (all platforms)
pandoc document.docx -o document.pdf

# LibreOffice conversion (macOS)
soffice --headless --convert-to pdf document.docx

# LibreOffice conversion (Linux/WSL)
unoconv -f pdf document.docx
soffice --headless --convert-to pdf document.docx

# Modern unoserver (macOS with custom setup)
unoserver &
unoconvert document.docx document.pdf
```

### File Operations
```bash
# Modern file listing
eza -la --git --icons

# Fast file search
fd -e py  # Find Python files
rg "function" --type python  # Search in Python files

# Better cat
bat README.md --style=numbers,changes
```

### Development Workflow
```bash
# Git with modern tools
lazygit  # Interactive git UI
delta  # Enhanced diff viewer

# Code quality
tokei  # Count lines of code
hyperfine "old_command" "new_command"  # Benchmark

# JSON processing
curl api.example.com | jq '.data[]'
echo '{"key": "value"}' | fx  # Interactive exploration
```

## Special Setups

### PyUNO Setup for unoserver (macOS)

The `unoserver` and `unoconvert` commands on macOS require special PyUNO (Python-UNO) setup to integrate with LibreOffice. This is handled automatically by the bootstrap process.

#### How it works:
1. **Isolated Environment**: Creates dedicated virtual environment at `~/.local/libreoffice-venv`
2. **LibreOffice Integration**: Configures PYTHONPATH to include LibreOffice's UNO libraries
3. **Transparent Wrappers**: Creates wrapper scripts that activate the environment automatically
4. **User Experience**: Commands work exactly like native tools - no complexity exposed

#### Setup Process:
```bash
# Automatic during bootstrap (macOS only)
# 1. Create isolated venv
python3 -m venv ~/.local/libreoffice-venv

# 2. Install unoserver in venv
source ~/.local/libreoffice-venv/bin/activate
pip install unoserver

# 3. Create wrapper scripts in ~/.local/bin/
# - unoserver wrapper
# - unoconvert wrapper

# 4. Set PYTHONPATH to LibreOffice UNO libraries
export PYTHONPATH="/Applications/LibreOffice.app/Contents/Resources:/Applications/LibreOffice.app/Contents/Frameworks:$PYTHONPATH"
```

#### Requirements:
- LibreOffice installed via Homebrew (`brew install --cask libreoffice`)
- Python 3 available via Nix
- `~/.local/bin` in PATH (handled by Nix configuration)

#### Verification:
```bash
# Verify installation
unoconvert --version
# Should output: unoconvert 3.2

# Usage workflow
unoserver &                           # Start server in background
unoconvert document.docx document.pdf # Convert document
killall unoserver                     # Stop server when done
```

#### Benefits:
- ✅ **Zero user complexity** - commands work like native tools
- ✅ **Isolated environment** - no impact on global Python
- ✅ **Automatic setup** - handled by bootstrap process
- ✅ **Platform-specific** - only installs where needed

## Installation Notes

- **Nix packages**: Installed via home-manager configuration
- **Homebrew packages**: macOS-specific GUI apps and tools not available in Nix
- **PyUNO setup**: Special LibreOffice-Python integration for document conversion on macOS
- **Platform differences**: Some tools only available on specific platforms due to nixpkgs limitations

For the complete package inventory with versions, see the [Package Inventory](./package-inventory.md) page.
