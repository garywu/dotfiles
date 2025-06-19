---
title: Modern CLI Tools Usage Gallery
description: Real-world examples and code golf patterns for modern CLI tools
---

# Modern CLI Tools Usage Gallery

This gallery showcases actual usage patterns from our dotfiles, demonstrating the efficiency gains of modern CLI tools through real examples.

## Search Operations

### ripgrep (rg) - The Modern grep

```bash
# Basic search (36% fewer characters than grep)
rg "TODO"                    # Instead of: grep -r "TODO" .

# Common patterns from our codebase
rg -c "TODO|FIXME"          # Count matches
rg -l "pattern"             # List files only
rg -n "function"            # Show line numbers
rg -i "error"               # Case insensitive

# Advanced patterns we use
rg "(eza|bat|fd|rg|sd|gum)" --type sh -B1 -A1    # Search with context
rg -B2 -A2 "fd " --type sh                        # Show surrounding lines
TODO_COUNT=$(rg -c "TODO|FIXME" . 2>/dev/null | wc -l | tr -d ' ')

# Replaces these verbose commands:
grep -r "pattern" .         → rg "pattern"
grep -rn "pattern" .        → rg -n "pattern"
grep -rl "pattern" .        → rg -l "pattern"
```

### fd - The Intuitive find

```bash
# Find files by extension
fd -e md                    # Instead of: find . -name "*.md"
fd -e sh -e bash            # Multiple extensions

# Find in specific directory
fd . templates/ -e md       # Modern syntax
fd -t f . /path/to/dir      # Files only

# Pattern matching
fd "README"                 # Find by name pattern
fd "config.fish"            # Find specific file

# Our actual usage examples
fd -e py | head -20         # Find Python files, limit output
fd README.md -E docs -E node_modules    # Exclude directories
```

## File Operations

### eza - The Modern ls

```bash
# Our Fish aliases (from config.fish)
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"

# Tree view with levels
eza -la --tree docs/ --level=2    # Beautiful tree output

# Replaces:
ls -la                      → eza -la
ls -lah                     → eza -lah
tree -L 2                   → eza --tree --level=2
```

### bat - cat with Wings

```bash
# View files with syntax highlighting
bat file.md                 # Instead of: cat file.md

# Preview with line numbers
bat -n script.sh            # Built-in line numbers

# Our Fish alias
alias cat="bat"             # Drop-in replacement
```

## Text Processing

### sd - Simpler sed

```bash
# Find and replace
sd 'find' 'replace' file    # Instead of: sed -i 's/find/replace/g' file

# Multiple files
fd -e txt -x sd 'old' 'new' {}    # Combine with fd

# No regex escaping needed
sd '(' '[' file             # Just works, unlike sed
```

### choose - Intuitive cut/awk

```bash
# Select columns
choose 0 2                  # Instead of: cut -f1,3 or awk '{print $1,$3}'
choose -1                   # Last field
choose 1:3                  # Range of fields
```

## Interactive Tools

### gum - Beautiful CLI Prompts

```bash
# User input
NAME=$(gum input --placeholder "Enter your name")

# Selection menu
OPTION=$(gum choose "Option 1" "Option 2" "Option 3")

# Confirmation
gum confirm "Continue?" && echo "Proceeding..."

# Progress indicator
gum spin --spinner dot --title "Loading..." -- sleep 3

# Replaces:
read -p "Enter name: " NAME → NAME=$(gum input --placeholder "Enter your name")
```

## System Information

### Modern Monitoring Tools

```bash
# Disk usage
dust                        # Instead of: du -sh *
dust -d 2                   # Depth limit

# Disk free
duf                         # Instead of: df -h

# Process viewer
procs                       # Instead of: ps aux
btop                        # Instead of: htop
```

## Development Tools

### Code Analysis

```bash
# Count lines of code
tokei                       # Instead of: cloc or wc -l

# Benchmark commands
hyperfine "rg TODO" "grep -r TODO ."    # Compare performance

# Watch for changes
watchexec -e py pytest      # Run tests on Python file changes
```

### Git Enhancements

```bash
# Interactive git
lazygit                     # Full TUI for git
gitui                       # Fast git interface
tig                         # Text-mode interface

# Better diffs
delta                       # Syntax-highlighting pager for git
```

## Real-World Combinations

### From Our Test Scripts

```bash
# Count TODOs in session tracking
TODO_COUNT=$(rg -c "TODO|FIXME" . 2>/dev/null | wc -l | tr -d ' ')

# Find and process files
fd -e sh -e bash . scripts/ | while read -r script; do
    echo "Processing $script"
done

# Search with context
rg -B2 -A2 "error" --type log | bat    # Search logs and view with syntax
```

### From Our Efficiency Tests

```bash
# Benchmark search operations
hyperfine --warmup 3 --runs 10 \
    "rg 'TODO' dataset/" \
    "grep -r 'TODO' dataset/" \
    "ag 'TODO' dataset/"

# Find test files
fd -e test.sh . tests/ -x bash {}
```

## Code Golf Examples

### One-Liners That Save Time

```bash
# Find all TODOs in Python files
fd -e py -x rg -n "TODO" {}

# Replace all occurrences across files
fd -e md -x sd 'oldpattern' 'newpattern' {}

# Interactive file selection and editing
fd -e txt | gum choose | xargs $EDITOR

# Tree view of markdown files only
fd -e md | eza --tree --stdin

# Count lines in all shell scripts
fd -e sh -x tokei {}
```

## Efficiency Metrics

From our efficiency testing framework (Issue #20):

### Character Count Savings
- `grep -r "TODO" .` (22 chars) → `rg "TODO"` (14 chars) = **36% reduction**
- `find . -name "*.py"` (20 chars) → `fd -e py` (9 chars) = **55% reduction**
- `ls -la` (7 chars) → `eza -la` (7 chars) = **Same, but better output**

### Cognitive Load Reduction
- **rg**: No need to remember `-r` flag (recursive by default)
- **fd**: No need for `-name` or quotes
- **eza**: Consistent colors and formatting across platforms
- **bat**: Automatic syntax detection, no need for `less` piping

## Integration in Our Dotfiles

### Fish Config Aliases
```fish
# From config.fish
alias ls="eza"
alias cat="bat"
alias grep="rg"
alias find="fd"
```

### Makefile Integration
```makefile
# Using rg for searching
search:
    @rg "$(PATTERN)" --type-add 'nix:*.nix' --type nix

# Using fd for file operations
clean-backups:
    @fd -e backup -x rm {}
```

## Tips for Adoption

1. **Start with aliases** - Map old commands to new ones
2. **Use interactively first** - Get comfortable before scripting
3. **Leverage defaults** - Modern tools have sensible defaults
4. **Combine tools** - `fd` + `rg` + `sd` = powerful pipelines
5. **Check our benchmarks** - See `tests/efficiency/` for proof

Remember: These tools are already installed via `home-manager`. Just start using them!
