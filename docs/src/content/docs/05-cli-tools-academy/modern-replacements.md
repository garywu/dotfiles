---
title: Modern CLI Replacements
description: Complete guide to modern command-line tools that replace traditional Unix utilities
---

# Modern CLI Replacements 🚀

Replace traditional Unix tools with modern, feature-rich alternatives. All these tools are already installed and configured with fish aliases.

## 🗂️ **File Listing & Navigation**

### **eza (ls replacement)**
Modern `ls` with colors, icons, and git integration

```bash
# Basic usage (via alias)
ls          # eza with default options
ll          # eza -l (detailed list)
la          # eza -la (all files, detailed)

# Advanced eza features
eza --tree                    # Tree view
eza --git                     # Show git status
eza --long --header           # Detailed with headers
eza --sort=size               # Sort by file size
eza --sort=modified           # Sort by modification time
eza --group-directories-first # Directories first
eza --icons                   # Show file type icons

# Useful combinations
eza -la --git --header        # Detailed view with git status
eza --tree --level=2          # Tree view, 2 levels deep
eza -la --sort=size           # Detailed, sorted by size
```

### **zoxide (cd replacement)**
Smart directory navigation with frecency

```bash
# Basic navigation
z Documents           # Jump to Documents directory
z doc                # Partial match works
z ~/proj/my-app      # Full path also works

# Interactive selection
zi                   # Interactive fuzzy search

# Add current directory
zoxide add .         # Manually add current dir

# List tracked directories
zoxide query -l      # List all directories
zoxide query -l proj # List directories matching "proj"

# Remove from database
zoxide remove ~/old-project
```

## 🔍 **Search & Content**

### **ripgrep (grep replacement)**
Ultra-fast text search with smart defaults

```bash
# Basic search (via alias 'rg' or 'grep')
rg "function"                    # Search for "function" in all files
rg -i "error"                    # Case insensitive search
rg "TODO" --type py             # Search only in Python files
rg "api" --type-not md          # Exclude markdown files

# Advanced patterns
rg "class \w+"                  # Regex patterns
rg -w "word"                    # Whole word matches
rg -A 3 -B 3 "error"           # Show 3 lines before/after match

# File type filters
rg "import" --type js           # JavaScript files only
rg "def " --type py             # Python files only
rg "function" --type ts         # TypeScript files only

# Useful flags
rg -n "pattern"                 # Show line numbers
rg -c "pattern"                 # Count matches only
rg --files-with-matches "error" # Just show file names
rg --hidden "config"            # Include hidden files

# Context and formatting
rg -C 5 "error"                 # 5 lines of context
rg --color=always "pattern"     # Force color output
rg --no-heading "pattern"       # Don't group by file
```

### **fd (find replacement)**
Simple, fast, user-friendly alternative to find

```bash
# Basic usage (via alias 'find' or direct 'fd')
fd filename                     # Find files named 'filename'
fd -e py                        # Find all Python files
fd -e js -e ts                  # Find JavaScript and TypeScript files

# Pattern matching
fd "\.py$"                      # Regex: files ending in .py
fd "test.*\.js$"               # Test JavaScript files
fd -i readme                   # Case insensitive search

# Directory operations
fd -t d config                 # Find directories named 'config'
fd -t f -e md                  # Find files with .md extension
fd -t l                        # Find symlinks

# Advanced features
fd -H config                   # Include hidden files
fd -I node_modules             # Include ignored files (like node_modules)
fd -E "*.pyc"                 # Exclude pattern
fd -x wc -l                   # Execute command on each result

# Useful combinations
fd -e py -x grep -l "import requests"  # Find Python files containing "import requests"
fd -t f -e log -x tail -n 10          # Show last 10 lines of all log files
```

## 📄 **File Content Viewing**

### **bat (cat replacement)**
Syntax highlighting and git integration

```bash
# Basic usage (via alias 'cat')
cat file.py                    # View file with syntax highlighting
bat file.js                    # Direct bat usage

# Advanced features
bat -n file.py                 # Show line numbers
bat -A file.py                 # Show all characters (tabs, spaces)
bat --paging=never file.py     # Don't use pager for short files
bat --style=numbers,changes    # Custom style

# Multiple files
bat *.py                       # View multiple files
bat src/**/*.js               # Recursive pattern

# Integration with other tools
fd -e py | head -5 | xargs bat # View first 5 Python files
rg -l "TODO" | xargs bat       # View files containing TODO
```

## 🚀 **System Monitoring**

### **btop (htop/top replacement)**
Modern system monitor with mouse support

```bash
btop                           # Launch interactive system monitor

# Key shortcuts in btop:
# q - quit
# space - pause/resume
# + - select process
# k - kill process
# m - memory view
# n - network view
# d - disk view
```

### **ncdu (du replacement)**
Interactive disk usage analyzer

```bash
ncdu                           # Analyze current directory
ncdu /                         # Analyze entire system
ncdu ~                         # Analyze home directory

# Interactive navigation:
# Enter - enter directory
# Backspace - go up
# d - delete selected item
# q - quit
```

## 🌐 **Network & Downloads**

### **httpie (curl replacement)**
Human-friendly HTTP client

```bash
# GET requests
http GET httpbin.org/json

# POST requests
http POST httpbin.org/post name=John age:=30

# Headers and authentication
http GET api.github.com/user Authorization:"token your_token"

# File uploads
http --form POST httpbin.org/post file@document.pdf

# JSON data
http POST api.example.com/users name=John email=john@example.com
```

## 🔧 **Development Tools**

### **delta (git diff replacement)**
Enhanced git diff with syntax highlighting

```bash
# Already configured in git, but can use directly:
delta file1.py file2.py        # Compare two files
git diff                       # Uses delta automatically
git log -p                     # Git log with delta
git show HEAD                  # Show commit with delta
```

### **lazygit**
Terminal UI for git

```bash
lazygit                        # Launch git TUI

# Key shortcuts:
# Space - stage/unstage
# c - commit
# P - push
# p - pull
# Enter - view details
# q - quit
```

### **fzf (fuzzy finder)**
Command-line fuzzy finder

```bash
# Basic usage
fzf                            # Interactive file finder

# Integration with other commands
fd -t f | fzf                  # Find files with fuzzy search
history | fzf                  # Search command history
git branch | fzf               # Select git branch

# Preview integration
fzf --preview 'bat --color=always {}'  # Preview files with bat
```

## 📁 **File Operations**

### **tree (built-in alternative)**
Directory tree visualization

```bash
tree                           # Show directory tree
tree -a                        # Include hidden files
tree -L 2                      # Limit to 2 levels
tree -I "node_modules|.git"    # Ignore patterns
tree -d                        # Directories only

# Or use eza for tree view
eza --tree --level=3           # Tree with eza
```

## 🎯 **Productivity Workflows**

### **Combined Workflows**

#### **File Search & Edit**
```bash
# Find and edit files
vim $(fd -e py | fzf)

# Search content and edit file
vim $(rg -l "TODO" | fzf)

# Find recent files and edit
vim $(fd -t f --changed-within=1day | fzf)
```

#### **Project Analysis**
```bash
# Find large files
fd -t f -x ls -lh {} | sort -k5 -hr | head -10

# Count lines of code by type
fd -e py -x wc -l | sort -nr
fd -e js -x wc -l | sort -nr

# Find empty files
fd -t f -x test -s {} \; -print
```

#### **Cleanup Workflows**
```bash
# Find large directories
ncdu --exclude=node_modules --exclude=.git

# Find old files
fd -t f --changed-before=30days

# Find duplicate file names
fd -t f | sort | uniq -d
```

## ⚙️ **Configuration Tips**

### **Fish Aliases (Already Configured)**
```bash
# These aliases are already set up:
alias ls eza
alias ll 'eza -l'
alias la 'eza -la'
alias cat bat
alias find fd
alias grep rg
```

### **Environment Variables**
```bash
# Add to fish config for customization
export BAT_THEME="TwoDark"              # Dark theme for bat
export FZF_DEFAULT_OPTS="--height 40%"  # FZF height
export RIPGREP_CONFIG_PATH="~/.ripgreprc"  # Ripgrep config
```

### **Custom Ripgrep Config**
Create `~/.ripgreprc`:
```
# Default ripgrep options
--smart-case
--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--glob=!.venv/*
```

## 🚀 **Performance Tips**

1. **Use type filters**: `rg --type py` is faster than `rg . | grep "\.py"`
2. **Combine tools**: `fd -e py | xargs rg "import"`
3. **Use zoxide**: Let it learn your patterns for faster navigation
4. **Custom aliases**: Create shortcuts for complex commands
5. **Pipe efficiently**: `fd | fzf` instead of `find | grep | fzf`

---

**💡 Pro Tip**: These tools work great together! Use `fd` to find files, `rg` to search content, `fzf` to select interactively, and `bat` to preview - all in one workflow!
