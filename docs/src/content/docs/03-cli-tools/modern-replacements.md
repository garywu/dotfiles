---
title: Modern CLI Replacements
description: Modern command-line tools that replace traditional Unix utilities
---

import { LearningPath, CommandComparison, ToolSelector } from '../../../components';

# Modern CLI Replacements

<LearningPath
  level="intermediate"
  time="45 minutes"
  prerequisites={[
    "Basic command-line knowledge",
    "Understanding of Unix utilities",
    "Fish shell basics"
  ]}
  nextSteps={[
    "CLI Code Golf techniques",
    "Session patterns and workflows",
    "Advanced tool combinations"
  ]}
/>

Modern alternatives to traditional Unix tools with enhanced performance and features. All tools are installed via Home Manager and configured with fish aliases.

## File Listing & Navigation

### eza (ls replacement)
File listing with colors, icons, and git integration

```bash
# Basic usage (via alias)
ls          # eza with default options
ll          # eza -l (detailed list)
la          # eza -la (all files, detailed)

# Advanced features
eza --tree                    # Tree view
eza --git                     # Show git status
eza --long --header           # Detailed with headers
eza --sort=size               # Sort by file size
eza --sort=modified           # Sort by modification time
eza --group-directories-first # Directories first
eza --icons                   # Show file type icons

# Common combinations
eza -la --git --header        # Detailed view with git status
eza --tree --level=2          # Tree view, 2 levels deep
eza -la --sort=size           # Detailed, sorted by size
```

<CommandComparison
  traditional={{
    command: "ls -la --color=auto",
    description: "Basic file listing with colors"
  }}
  modern={{
    command: "eza -la --git --icons",
    description: "Enhanced listing with git status and icons"
  }}
  improvement="Git integration, file icons, better performance, and more intuitive output"
/>

### zoxide (cd replacement)
Directory navigation with frecency-based jumping

```bash
# Navigation
z Documents           # Jump to Documents directory
z doc                # Partial match
z ~/proj/my-app      # Full path

# Interactive selection
zi                   # Interactive fuzzy search

# Directory management
zoxide add .         # Add current directory
zoxide query doc     # Show matching directories
zoxide remove docs   # Remove from database
```

## File Viewing & Editing

### bat (cat replacement)
File viewer with syntax highlighting

```bash
# Basic viewing
bat file.py                    # View with syntax highlighting
bat README.md                  # Markdown rendering
bat -n script.sh              # Show line numbers

# Advanced options
bat --style=plain file.txt    # No decorations
bat --style=numbers,grid      # Line numbers with grid
bat --paging=never           # Disable pager
bat --theme=Dracula          # Change color theme

# Multiple files
bat file1.py file2.py        # View multiple files
bat src/*.js                 # View all JS files

# Integration with other tools
git diff | bat               # Syntax highlight diffs
man ls | bat -l man          # Highlight man pages
```

### delta (diff viewer)
Enhanced diff viewer for git

```bash
# Git integration (automatic)
git diff                     # Uses delta automatically
git show                     # Enhanced commit viewing
git log -p                   # Better patch viewing

# Standalone usage
delta file1.txt file2.txt    # Compare two files
diff -u a.txt b.txt | delta  # Process unified diff

# Features
# - Syntax highlighting
# - Line numbers
# - Side-by-side view
# - File headers
```

## Searching & Finding

### ripgrep (grep replacement)
Fast text search with smart defaults

```bash
# Basic search
rg "pattern"                 # Search in current directory
rg "TODO"                    # Find all TODOs
rg -i "error"               # Case-insensitive search

# File type filtering
rg "import" -t py           # Python files only
rg "console.log" -t js      # JavaScript files only
rg "SELECT" -t sql          # SQL files only

# Advanced patterns
rg "func\w+"                # Regex search
rg -w "test"                # Whole word matching
rg -v "debug"               # Invert match

# Context and formatting
rg -C 3 "error"             # Show 3 lines context
rg -N "pattern"             # No line numbers
rg --heading "TODO"         # Group by file

# Performance options
rg -j 4 "pattern"           # Use 4 threads
rg -m 10 "error"            # Max 10 matches per file
```

### fd (find replacement)
Fast file finder

```bash
# Basic finding
fd pattern                   # Find files matching pattern
fd ".py"                    # Find Python files
fd -e md                    # Find by extension

# Type filtering
fd -t f pattern             # Files only
fd -t d pattern             # Directories only
fd -t l pattern             # Symlinks only

# Advanced options
fd -H pattern               # Include hidden files
fd -I pattern               # Include ignored files
fd -u pattern               # Unrestricted (both -H and -I)

# Size filtering
fd --size +1M               # Files larger than 1MB
fd --size -100k             # Files smaller than 100KB

# Time filtering
fd --changed-within 1d      # Changed in last day
fd --changed-before 1w      # Changed before 1 week

# Execution
fd -e py -x pylint {}       # Run pylint on Python files
fd -t f -x chmod 644 {}     # Change permissions
```

## Text Processing

### sd (sed replacement)
Simple find and replace

```bash
# Basic replacement
sd "old" "new" file.txt              # Replace in file
sd "TODO" "DONE" *.md                # Multiple files
echo "hello world" | sd "world" "sd" # Pipe usage

# Regex patterns
sd "v\d+\.\d+\.\d+" "v2.0.0" *.json  # Version replacement
sd "(\w+)@(\w+)" "$2 at $1" file     # Capture groups

# Practical examples
sd "http:" "https:" *.html           # Update protocols
sd "\r\n" "\n" file.txt              # Fix line endings
sd "  +" " " file.txt                # Collapse spaces
```

### jq (JSON processor)
Command-line JSON processing

```bash
# Basic usage
jq '.' file.json             # Pretty print
jq '.name' data.json         # Extract field
jq '.[]' array.json          # Iterate array

# Filtering
jq '.[] | select(.age > 30)' users.json
jq '.items[] | .name' data.json

# Transformation
jq '.[] | {name: .name, id: .id}' data.json
jq 'map(. + 1)' numbers.json

# Complex operations
jq -r '.[] | [.name, .email] | @csv' users.json
curl api.example.com | jq '.results[0]'
```

## System Monitoring

### htop (top replacement)
Interactive process viewer

```bash
htop                        # Launch htop

# Key bindings:
# F2 - Setup
# F3 - Search
# F4 - Filter
# F5 - Tree view
# F6 - Sort by column
# F9 - Kill process
# F10 - Quit
```

### procs (ps replacement)
Modern process viewer

```bash
# Basic usage
procs                       # List all processes
procs python               # Search for python processes
procs --tree               # Tree view

# Sorting
procs --sortd cpu          # Sort by CPU (descending)
procs --sortd mem          # Sort by memory
procs --sorta pid          # Sort by PID (ascending)

# Filtering
procs --uid 1000           # By user ID
procs --tcp                # TCP connections
procs --udp                # UDP connections

# Watch mode
procs --watch              # Auto-refresh
procs --watch-interval 1   # Refresh every second
```

### dust (du replacement)
Disk usage analyzer

```bash
# Basic usage
dust                       # Current directory
dust ~/Documents          # Specific directory
dust -n 10                # Top 10 entries

# Display options
dust -r                   # Reverse order (smallest first)
dust -p                   # Show percentages
dust -b                   # Show bars
dust -d 3                 # Max depth 3

# Filtering
dust -X node_modules      # Exclude pattern
dust -x                   # Stay on same filesystem
```

### duf (df replacement)
Disk usage viewer

```bash
# Basic usage
duf                       # All filesystems
duf /home                # Specific mount point

# Filtering
duf --local              # Local filesystems only
duf --type ext4,apfs     # Specific filesystem types
duf --json               # JSON output
```

## Git Enhancements

### lazygit
Terminal UI for git

```bash
lazygit                   # Launch in current repo

# Key features:
# - Interactive staging
# - Commit graph
# - Branch management
# - Stash handling
# - Cherry-picking
# - Interactive rebase
```

### gitui
Fast terminal UI for git

```bash
gitui                     # Launch gitui

# Key bindings:
# Tab - Switch tabs
# Enter - Stage/unstage
# c - Commit
# p - Push
# P - Pull
# f - Fetch
```

## Benchmarking & Analysis

### hyperfine
Command-line benchmarking

```bash
# Basic benchmark
hyperfine 'sleep 0.3'

# Compare commands
hyperfine 'rg TODO' 'grep -r TODO'

# Multiple runs
hyperfine --runs 10 'npm test'
hyperfine --warmup 3 'cargo build'

# Export results
hyperfine --export-json results.json 'cmd1' 'cmd2'
hyperfine --export-markdown results.md 'cmd1' 'cmd2'

# Shell comparison
hyperfine --shell fish 'ls' --shell bash 'ls'
```

### tokei
Code statistics

```bash
# Basic usage
tokei                     # Current directory
tokei src/               # Specific directory

# Filtering
tokei -t Python,JavaScript
tokei --exclude "*.min.js"

# Output formats
tokei --output json
tokei --output yaml

# Sorting
tokei --sort code        # By lines of code
tokei --sort files       # By file count
```

## Network Tools

### dog (dig replacement)
DNS lookup tool

```bash
# Basic queries
dog example.com          # A records
dog example.com MX       # MX records
dog example.com ANY      # All records

# Options
dog example.com @8.8.8.8 # Use specific DNS
dog -J example.com       # JSON output
dog -H example.com       # Short output
```

### xh (HTTPie alternative)
HTTP client

```bash
# GET requests
xh httpbin.org/get
xh localhost:3000/api/users

# POST requests
xh POST httpbin.org/post name=John age=30
xh POST api.example.com/users < user.json

# Headers
xh GET httpbin.org/headers Authorization:"Bearer token"
xh GET example.com Accept:application/json

# Download
xh --download example.com/file.zip
```

## Performance Comparison

### Speed Improvements

| Traditional | Modern | Speed Improvement |
|------------|--------|------------------|
| find | fd | 5-10x faster |
| grep | ripgrep | 2-10x faster |
| ls | eza | Similar speed, more features |
| cat | bat | Similar speed, more features |
| sed | sd | Similar speed, easier syntax |
| cd | zoxide | Instant jumping |
| top | htop/procs | More efficient |
| du | dust | 2-5x faster |

## Container & DevOps Tools

### act
Run GitHub Actions locally

```bash
# List available workflows
act -l

# Run push event workflows
act push

# Run specific workflow
act -W .github/workflows/ci.yml

# Run with specific event
act pull_request

# Dry run
act -n

# Use specific Docker image
act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04
```

### dive
Docker image analyzer

```bash
# Analyze image layers
dive nginx:latest

# Analyze local image
dive myapp:dev

# Build and analyze
dive build -t myapp .

# Analyze from tar
dive --source docker-archive image.tar

# CI mode (non-interactive)
dive --ci nginx:latest

# Show image efficiency score
dive nginx:latest --highestUserWastedPercent 0.1
```

### k9s
Kubernetes terminal UI

```bash
# Connect to default context
k9s

# Specific context
k9s --context production

# Specific namespace
k9s --namespace web

# Read-only mode
k9s --readonly

# Custom config
k9s --kubeconfig ~/custom-config

# Common shortcuts in k9s:
# :ns     - Switch namespace
# :ctx    - Switch context
# :quit   - Exit
# /       - Search resources
# ?       - Show help
```

### Key Advantages

1. **Better Defaults**: Smart ignore patterns, colors, sensible options
2. **Modern Features**: Git integration, syntax highlighting, interactive modes
3. **Performance**: Parallel processing, efficient algorithms
4. **User Experience**: Better error messages, intuitive interfaces
5. **Cross-platform**: Consistent behavior across macOS and Linux

## Configuration

All tools are configured via:
- `~/.config/fish/config.fish` - Aliases and functions
- `~/.gitconfig` - Git tool integration
- Individual tool configs in `~/.config/`

To update tool configurations:
```bash
chezmoi edit ~/.config/fish/config.fish
chezmoi apply
```
