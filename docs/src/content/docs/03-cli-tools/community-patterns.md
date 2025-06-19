---
title: Community CLI Patterns
description: Advanced usage patterns and one-liners from the CLI community
---

# Community CLI Patterns

A collection of advanced patterns, one-liners, and code golf examples from the wider CLI community.

## Search & Filter Patterns

### ripgrep Advanced Patterns

```bash
# Search specific file types (ultra-short)
rg "TODO" -tpy              # Python files only
rg "TODO" -trust            # Rust files only

# Find files with multiple patterns
rg -l0 "foo" | xargs -0 rg -l "bar"    # Files containing both

# Search and replace (ripgrep style)
rg --passthru -N 'search' -r 'replace'

# Multiline search
rg -U 'pattern\nacross\nlines'

# Zero or more matches
rg 'fast\w*'                # Matches "fast", "faster", "fastest"

# Files without pattern
rg -v "pattern" -l          # List files NOT containing pattern

# Search everything (disable all filters)
rg -uuu "pattern"           # No gitignore, hidden files, binary
```

### fd Advanced Patterns

```bash
# Full path search
fd -p "src/.*test"          # Search based on full path

# Find and execute on all results
fd -e cpp -X rg "pattern"   # Search pattern in all C++ files

# Hidden and ignored files
fd -HI                      # Show hidden and gitignored files
fd -u                       # Unrestricted search (same as -HI)
```

## File Viewing & Navigation

### eza (Modern ls)

```bash
# Advanced eza patterns
eza -D                      # Directories only
eza -f                      # Files and directories
eza -s size                 # Sort by size
eza -R --level 2            # Recursive with depth limit
eza -T                      # Tree view
eza -l --total-size         # Show directory size as sum of contents
eza -l --git                # Show Git status

# Power user alias
alias ll='eza --all --long --group --group-directories-first --icons --header --time-style long-iso'

# With fd/find pipes
find . -name '*.py' | eza -l --stdin
```

### bat Integration

```bash
# fzf with bat preview
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"

# Smart preview (directory or file)
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
```

## Text Processing

### sd (Better sed)

```bash
# Trim whitespace
echo 'lorem ipsum   ' | sd '\s+$' ''

# Replace with capture groups
echo 'cargo +nightly watch' | sd '(\w+)\s+\+(\w+)\s+(\w+)' 'cmd: $1, channel: $2, subcmd: $3'

# In-place file replacement
sd -p 'window.fetch' 'fetch' script.js
```

### jq One-Liners

```bash
# Extract fields with formatting
jq -r '.[] | "\(.name)\t\(.login)"' users.json

# Interactive jq REPL with fzf
echo '' | fzf --print-query --preview 'jq {q} input.json'

# Browse JSON paths interactively
jq -rc paths data.json | fzf --preview 'x={}; jq "getpath($x)" data.json'

# Process API response
curl -s api.url | jq -r '.items[] | select(.score > 100) | .title'
```

## Interactive Tools

### gum Patterns

```bash
# Replace fzf with gum
sha=$(git log --oneline | gum filter --limit=1 | cut -d' ' -f1)

# Interactive process killer
procs "$1" --no-header | gum choose --no-limit | awk '{print $1}' | xargs kill -9

# Menu-driven script
ACTION=$(gum choose "build" "test" "deploy" "clean")
gum confirm "Execute $ACTION?" && make $ACTION

# Styled input
NAME=$(gum input --placeholder "Enter your name" --prompt "> ")
echo "Hello, $NAME!"
```

### fzf Power Patterns

```bash
# Kill processes interactively
ps aux | fzf -m | awk '{print $2}' | xargs kill -9

# Git branch switcher
git branch | fzf | xargs git checkout

# Docker container management
docker ps -a | fzf -m --header-lines=1 | awk '{print $1}' | xargs docker rm

# SSH to selected host
cat ~/.ssh/config | grep "Host " | fzf | awk '{print $2}' | xargs ssh

# Preview with ripgrep matches
rg --color=always "pattern" | fzf --ansi --preview 'bat --color=always {1} --highlight-line {2}'
```

## Benchmarking & Analysis

### hyperfine Usage

```bash
# Basic benchmark
hyperfine 'sleep 0.3'

# Compare commands
hyperfine 'rg TODO' 'grep -r TODO'

# Multiple runs with warmup
hyperfine --warmup 3 --runs 10 'fd -e py' 'find . -name "*.py"'

# Export results
hyperfine --export-json results.json 'cmd1' 'cmd2'
```

### tokei Patterns

```bash
# Count lines in current project
tokei

# Specific languages
tokei -t Python,JavaScript

# Exclude directories
tokei -e target -e node_modules

# Sort by code lines
tokei --sort code
```

## Combined Workflows

### Smart fzf Configuration

```bash
# Complete fzf setup with multiple tools
_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo ${}'" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}
```

### JSON Processing Pipeline

```bash
# API data processing
curl -s api.endpoint | \
  jq '.results[]' | \
  gum filter --limit 10 | \
  jq -r '"\(.id)\t\(.name)"' | \
  column -t
```

### File Search and Edit

```bash
# Find file and edit
fd -e md | fzf --preview 'bat --color=always {}' | xargs $EDITOR

# Search content and edit file
rg -l "TODO" | fzf --preview 'rg --color=always "TODO" {}' | xargs $EDITOR
```

## Ultra-Short Patterns

### The Shortest Commands

```bash
# Disk usage (4 chars!)
dust

# Process viewer (5 chars)
procs

# Directory listing (3 chars)
eza

# Find files (2 chars + pattern)
fd p

# Search text (2 chars + pattern)
rg p
```

### One-Line System Management

```bash
# Find and delete old logs
fd -e log --changed-before 30d -x rm

# Mass rename files
fd -e txt -x sd 'old' 'new' {}

# Check all shell scripts
fd -e sh -x shellcheck

# Compress old files
fd --changed-before 90d -e log -x gzip
```

## Performance Comparisons

Community benchmarks show:

- **ripgrep**: 2-5x faster than grep on large codebases
- **fd**: 2-8x faster than find, especially with gitignore
- **eza**: Similar speed to ls but with better output
- **bat**: Minimal overhead vs cat, huge readability gain
- **sd**: Comparable to sed but easier syntax

## Tips from the Community

1. **Aliases are key**: Start with `alias ls='eza'` and expand
2. **Learn the defaults**: Modern tools have smart defaults
3. **Combine tools**: `fd | fzf | xargs` is a powerful pattern
4. **Use previews**: fzf + bat/eza makes file navigation visual
5. **Benchmark everything**: Use hyperfine to prove efficiency

## Real-World Integration Examples

### Git Workflow
```bash
# Interactive git add
git status -s | fzf -m | awk '{print $2}' | xargs git add

# Browse commits
git log --oneline | fzf --preview 'git show --color=always {1}' | awk '{print $1}'
```

### Docker Management
```bash
# Clean up images
docker images | fzf -m --header-lines=1 | awk '{print $3}' | xargs docker rmi

# Exec into container
docker ps | fzf --header-lines=1 | awk '{print $1}' | xargs -I {} docker exec -it {} bash
```

These patterns represent the collective wisdom of the CLI community, showcasing how modern tools can dramatically improve command-line efficiency!
