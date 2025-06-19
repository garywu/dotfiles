---
title: CLI Patterns from This Session
description: Actual command patterns used during the dotfiles development session
---

# CLI Patterns from This Session

These are the exact modern CLI tool commands used during our dotfiles development session, showing real-world usage patterns.

## File Discovery Patterns

### Finding Markdown Files
```bash
# What I used
fd -e md -E docs -E node_modules -E .git | head -20

# Instead of traditional
find . -name "*.md" -not -path "./docs/*" -not -path "./node_modules/*" -not -path "./.git/*" | head -20
```

### Finding Files in Templates
```bash
# What I used
fd . templates/ -e md

# Error I made and learned from
fd -e md templates/    # Wrong: fd complained about path separator
fd . templates/ -e md  # Correct: search pattern first, then directory
```

### Excluding Directories
```bash
# What I used
fd README.md -E docs -E node_modules -E external

# Traditional equivalent
find . -name "README.md" -not -path "./docs/*" -not -path "./node_modules/*" -not -path "./external/*"
```

## Search Patterns

### Finding Tool Usage
```bash
# What I used to find where we use modern tools
rg -l "macOS|Ubuntu|WSL" templates/*.md

# Finding specific patterns with context
rg -A 5 -B 5 "changelog|CHANGELOG" .github/workflows/release.yml

# Searching for tool names
rg "lazygit" nix/home.nix
```

### Quick File Checks
```bash
# Checking frontmatter format
rg "^---" docs/src/content/docs/01-introduction/getting-started.md | head -5

# Finding all target
rg "^all:" Makefile
```

## Directory Exploration

### Tree Views with eza
```bash
# What I used
eza -la --tree docs/src/content/docs/ --level=2
eza -la --tree docs/src/content/docs/ --level=1

# Instead of
tree -L 2 docs/src/content/docs/
ls -la docs/src/content/docs/
```

## File Viewing

### Using bat for Previews
```bash
# What I used
bat docs/src/content/docs/01-introduction/getting-started.md | head -10
bat tests/efficiency/README.md | head -20

# Instead of
cat docs/src/content/docs/01-introduction/getting-started.md | head -10
head -20 tests/efficiency/README.md
```

## Counting and Statistics

### Counting Documentation Files
```bash
# What I used
fd . docs/src/content/docs -e md -e mdx | wc -l

# Instead of
find docs/src/content/docs -name "*.md" -o -name "*.mdx" | wc -l
```

## Text Processing

### Adding Frontmatter (What I Attempted)
```bash
# Attempted with sd (didn't work due to multiline)
sd '^# CLI Tool Efficiency Testing Framework' '---\ntitle: CLI Tool Efficiency Testing\n---\n\n# CLI Tool Efficiency Testing Framework' file.md

# Had to fall back to
echo '---
title: CLI Tool Efficiency Testing
description: Framework for measuring benefits
---

' | cat - file.md > /tmp/file.md && mv /tmp/file.md file.md
```

## Combined Patterns

### File Discovery + Action
```bash
# List all markdown files in platform setup
fd . docs/src/content/docs/02-platform-setup/ -e md -x echo {}

# Copy multiple files
fd -e md templates/ | rg -v claude-init | xargs -I {} cp {} destination/
```

### Search + Context
```bash
# Find bash version warning
rg -C 3 "bash.*warn" bootstrap.sh

# Find section in workflow
rg -A 10 "Install dependencies" .github/workflows/release.yml
```

## Lessons Learned

### 1. fd Syntax Matters
```bash
# Wrong
fd templates/ -e md     # Path separator error

# Right
fd . templates/ -e md   # Pattern first, then path
fd -e md . templates/   # Or extension flag first
```

### 2. Default Behaviors Save Typing
```bash
# ripgrep is recursive by default
rg "pattern"            # Searches current directory recursively

# fd searches from current directory by default
fd -e py                # Finds all Python files from here
```

### 3. Modern Tools Chain Well
```bash
# Find files and search within them
fd -e sh | xargs rg "TODO"

# Find files and count matches
fd -e md | xargs rg -c "pattern" | awk -F: '{sum+=$2} END {print sum}'
```

## Efficiency Gains Observed

### Character Savings
- Finding files: `find . -name "*.md"` (19 chars) → `fd -e md` (8 chars) = **58% reduction**
- Searching: `grep -r "TODO" .` (17 chars) → `rg "TODO"` (9 chars) = **47% reduction**
- Listing: `ls -la --color` (14 chars) → `eza -la` (7 chars) = **50% reduction**

### Time Savings
- No need to remember flags (recursive is default)
- No need to quote glob patterns
- No need to specify current directory
- Better error messages guide correct usage

## My Commitment Going Forward

Based on this session's patterns, I've updated CLAUDE.md to always use:

```bash
# File Operations
eza -la              # NOT ls -la
fd pattern           # NOT find . -name pattern
bat file             # NOT cat file

# Search Operations
rg pattern           # NOT grep -r pattern .
rg -l pattern        # NOT grep -rl pattern .

# Data Processing
sd 'find' 'replace'  # NOT sed 's/find/replace/g'
jq '.field'          # NOT grep/awk for JSON
```

These patterns are now documented for all future Claude CLI sessions!
