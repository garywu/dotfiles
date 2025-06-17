---
title: CLI Tools Academy
description: Master modern command-line tools that replace traditional Unix utilities
---

# CLI Tools Academy 🚀

Welcome to the CLI Tools Academy! Here you'll learn to replace traditional Unix tools with modern, feature-rich alternatives that are faster, more intuitive, and more powerful.

## Why Modern CLI Tools?

Traditional Unix tools like `ls`, `grep`, and `cat` were created decades ago. Modern alternatives offer:

- ⚡ **Better Performance** - Built with modern languages and algorithms
- 🎨 **Enhanced UX** - Colored output, better defaults, intuitive interfaces  
- 🔍 **Smart Features** - Fuzzy finding, git integration, syntax highlighting
- 🛡️ **Safety** - Better error messages, safer defaults
- 🔧 **Extensibility** - Plugin systems and customization options

## Tool Categories

### 📁 **File Navigation & Listing**
- [`eza`](/05-cli-tools-academy/file-navigation/eza/) → Modern `ls` with colors and git integration
- [`zoxide`](/05-cli-tools-academy/file-navigation/zoxide/) → Smart `cd` with frecency algorithm
- [`broot`](/05-cli-tools-academy/file-navigation/broot/) → Interactive directory tree navigator

### 🔍 **Search & Content**
- [`ripgrep`](/05-cli-tools-academy/text-processing/ripgrep/) → Ultra-fast `grep` replacement
- [`fd`](/05-cli-tools-academy/file-navigation/fd/) → Simple, fast `find` alternative
- [`fzf`](/05-cli-tools-academy/productivity/fzf/) → Command-line fuzzy finder

### 📄 **File Content & Viewing**
- [`bat`](/05-cli-tools-academy/text-processing/bat/) → `cat` with syntax highlighting
- [`less`](/05-cli-tools-academy/text-processing/less/) → Enhanced pager
- [`hexyl`](/05-cli-tools-academy/text-processing/hexyl/) → Beautiful hex viewer

### 🚀 **System Monitoring**
- [`htop`](/05-cli-tools-academy/system-monitoring/htop/) → Interactive process viewer
- [`btop`](/05-cli-tools-academy/system-monitoring/btop/) → Modern system monitor
- [`dust`](/05-cli-tools-academy/system-monitoring/dust/) → More intuitive `du`
- [`duf`](/05-cli-tools-academy/system-monitoring/duf/) → Better `df` alternative

### 🌐 **Network & Downloads**
- [`httpie`](/05-cli-tools-academy/productivity/httpie/) → Human-friendly HTTP client
- [`curl`](/05-cli-tools-academy/productivity/curl/) → Enhanced with modern features
- [`wget`](/05-cli-tools-academy/productivity/wget/) → Reliable downloader

### 🔧 **Development Tools**
- [`delta`](/05-cli-tools-academy/git-workflow/delta/) → Enhanced git diff viewer
- [`lazygit`](/05-cli-tools-academy/git-workflow/lazygit/) → Terminal UI for git
- [`jq`](/05-cli-tools-academy/data-tools/jq/) → JSON processor and formatter

## Learning Paths

### 🎯 **Essential Tools (Start Here)**
Master the daily-use tools that will immediately improve your productivity:

1. [File Navigation with eza](/05-cli-tools-academy/file-navigation/eza/)
2. [Fast Search with ripgrep](/05-cli-tools-academy/text-processing/ripgrep/)
3. [Smart cd with zoxide](/05-cli-tools-academy/file-navigation/zoxide/)
4. [Enhanced cat with bat](/05-cli-tools-academy/text-processing/bat/)

### 🚀 **Productivity Boost**
Advanced tools for power users:

1. [Fuzzy Finding with fzf](/05-cli-tools-academy/productivity/fzf/)
2. [Interactive Tree with broot](/05-cli-tools-academy/file-navigation/broot/)
3. [System Monitoring with htop](/05-cli-tools-academy/system-monitoring/htop/)
4. [Git Workflow with delta & lazygit](/05-cli-tools-academy/git-workflow/)

### 💻 **Developer Workflow**
Specialized tools for development:

1. [JSON Processing with jq](/05-cli-tools-academy/data-tools/jq/)
2. [HTTP Testing with httpie](/05-cli-tools-academy/productivity/httpie/)
3. [Performance Analysis](/05-cli-tools-academy/system-monitoring/)
4. [Automation Scripts](/08-automation-scripts/)

## Before & After Examples

### File Listing
```bash
# Before: Basic ls
$ ls -la
drwxr-xr-x  10 user  staff   320 Jan 15 10:30 .
drwxr-xr-x   5 user  staff   160 Jan 15 10:25 ..
-rw-r--r--   1 user  staff  1234 Jan 15 10:30 README.md

# After: eza with colors, git status, and icons
$ eza -la --git --icons
drwxr-xr-x  - user 15 Jan 10:30  📁 .
drwxr-xr-x  - user 15 Jan 10:25  📁 ..
.rw-r--r-- 1.2k user 15 Jan 10:30  📄 README.md [M]
```

### Text Search
```bash
# Before: grep with complex flags
$ grep -r -n --include="*.py" "function" .

# After: ripgrep with smart defaults
$ rg "function" --type py
```

### File Finding
```bash
# Before: find with complex syntax
$ find . -name "*.js" -type f -not -path "./node_modules/*"

# After: fd with simple syntax
$ fd -e js -E node_modules
```

## Installation Status

All these tools are **already installed and configured** in your environment through the bootstrap process! 

- ✅ Installed via Nix for reproducible package management
- ✅ Fish shell aliases configured for familiar commands
- ✅ Optimal configurations pre-applied
- ✅ Ready to use immediately

## Quick Reference

| Traditional Tool | Modern Alternative | Key Benefits |
|-----------------|-------------------|--------------|
| `ls` | `eza` | Colors, git status, tree view |
| `cd` | `zoxide` | Smart jumping, frecency |
| `grep` | `ripgrep` | 10x faster, smart defaults |
| `find` | `fd` | Simpler syntax, faster |
| `cat` | `bat` | Syntax highlighting, git integration |
| `top` | `htop`/`btop` | Interactive, colorful |
| `du` | `dust` | Tree view, intuitive |
| `curl` | `httpie` | Human-friendly syntax |

## What's Next?

1. **Start with the essentials** - Begin with [Modern Replacements Overview](/05-cli-tools-academy/modern-replacements/)
2. **Practice daily** - Use these tools for your regular tasks
3. **Learn combinations** - See how tools work together in workflows
4. **Customize** - Adapt configurations to your preferences
5. **Share** - Teach others about these amazing tools!

Ready to revolutionize your command-line experience? Let's begin! 🎯