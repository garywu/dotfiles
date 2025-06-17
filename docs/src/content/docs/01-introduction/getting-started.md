---
title: Getting Started
description: Quick start guide to set up your modern development environment
---

# Getting Started

Welcome to Dotfiles Academy! This guide will help you set up a modern, automated development environment in minutes.

## What Is This?

This repository provides a **fully automated, reproducible development environment** using:

- **Nix & Home Manager** - Declarative package management
- **Chezmoi** - Dotfiles and secrets management  
- **Homebrew** - macOS GUI applications
- **Fish Shell** - Modern, user-friendly shell
- **Modern CLI Tools** - Faster, better alternatives to traditional Unix tools

## Quick Setup

### Prerequisites

- **macOS** (tested on macOS 12+)
- **Administrator access** 
- **Internet connection**

### One-Command Installation

```bash
git clone https://github.com/garywu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

That's it! The bootstrap script will:

1. ✅ Install Nix package manager
2. ✅ Set up Home Manager for declarative packages
3. ✅ Install Fish shell and modern CLI tools
4. ✅ Configure development environment
5. ✅ Install macOS GUI applications via Homebrew

## What Gets Installed

### Modern CLI Tools
- `eza` → Modern `ls` with colors and git integration
- `bat` → `cat` with syntax highlighting
- `ripgrep` → Ultra-fast `grep` replacement
- `fd` → Simple, fast `find` alternative
- `fzf` → Fuzzy finder for interactive selection
- `delta` → Better git diff viewer
- `htop` → Enhanced process viewer
- And 50+ more productivity tools!

### Development Tools
- Git, GitHub CLI, and modern git tools
- Node.js, Python, Go, Rust toolchains
- Docker, cloud CLIs (AWS, GCP, Cloudflare)
- AI tools (Ollama, ChatBlade)

### Shell Experience
- **Fish Shell** - Smart autocompletions and syntax highlighting
- **Starship Prompt** - Fast, customizable prompt
- **Optimized aliases** - Shortcuts for common tasks

## After Installation

1. **Restart your terminal** to activate the new shell
2. **Explore the tools** - Try `ls`, `cat`, or `grep` to see the modern alternatives
3. **Learn the basics** - Continue with our [CLI Tools Academy](/05-cli-tools-academy/)
4. **Customize** - Modify configurations in `~/.dotfiles/`

## Need Help?

- 📚 **Browse the documentation** - Each tool has comprehensive guides
- 🐛 **Troubleshooting** - Check our [troubleshooting guide](/99-reference/troubleshooting-guide/)
- 💬 **Get support** - Open an issue on GitHub

## Next Steps

Ready to dive deeper? Here are recommended next steps:

1. [**Understand the Architecture**](/01-introduction/architecture-overview/) - Learn how everything fits together
2. [**Master the Shell**](/04-shell-mastery/) - Get the most out of Fish shell
3. [**Explore CLI Tools**](/05-cli-tools-academy/) - Learn modern command-line tools
4. [**Automation Deep Dive**](/08-automation-scripts/) - Understand the bootstrap process

Let's start your journey to command-line mastery! 🚀