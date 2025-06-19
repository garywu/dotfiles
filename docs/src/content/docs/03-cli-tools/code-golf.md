---
title: CLI Code Golf Patterns
description: Ultra-concise command patterns that showcase modern CLI tool efficiency
---

# CLI Code Golf Patterns

Ultra-concise command patterns that demonstrate the power and efficiency of modern CLI tools. Each example shows the modern approach versus traditional commands.

## Search & Replace Patterns

### Find and Replace Across All Files
```bash
# Modern (29 chars)
fd -x sd 'old' 'new' {}

# Traditional (58 chars)
find . -type f -exec sed -i 's/old/new/g' {} \;
```

### Search TODO in Python Files Only
```bash
# Modern (19 chars)
fd -e py -x rg TODO {}

# Traditional (48 chars)
find . -name "*.py" -exec grep -H "TODO" {} \;
```

### Count All TODOs
```bash
# Modern (17 chars)
rg -c TODO | wc -l

# Traditional (28 chars)
grep -r "TODO" . | wc -l
```

## File Discovery Patterns

### Find Recently Modified Files
```bash
# Modern (20 chars)
fd -t f --changed-within 1d

# Traditional (35 chars)
find . -type f -mtime -1
```

### List All Test Files
```bash
# Modern (13 chars)
fd 'test.*\.sh$'

# Traditional (31 chars)
find . -regex ".*test.*\.sh$"
```

### Find Large Files
```bash
# Modern with dust (4 chars!)
dust

# Traditional (36 chars)
find . -type f -size +10M -exec ls -lh {} \;
```

## Interactive Patterns

### Select and Edit a File
```bash
# Modern (24 chars)
fd | gum choose | xargs $EDITOR

# Traditional (would require a script)
# No simple equivalent
```

### Confirm Before Delete
```bash
# Modern (35 chars)
fd -e tmp | gum choose --no-limit | xargs rm

# Traditional (complex script needed)
find . -name "*.tmp" -exec bash -c 'read -p "Delete $1? " -n 1 -r; echo; [[ $REPLY =~ ^[Yy]$ ]] && rm "$1"' _ {} \;
```

## Data Processing Patterns

### Extract JSON Field from Multiple Files
```bash
# Modern (27 chars)
fd -e json -x jq -r '.version'

# Traditional (55+ chars)
find . -name "*.json" -exec grep -oP '"version":\s*"\K[^"]+' {} \;
```

### Sum Numbers from Output
```bash
# Modern (24 chars)
rg -o '\d+' | paste -sd+ | bc

# Traditional (41 chars)
grep -o '[0-9]\+' | awk '{s+=$1} END {print s}'
```

## System Information Patterns

### Show Disk Usage by Directory
```bash
# Modern (4 chars)
dust

# Traditional (11 chars)
du -sh * | sort -h
```

### Monitor File Changes
```bash
# Modern (15 chars)
fd | entr -c make

# Traditional (requires inotify-tools)
while inotifywait -e modify .; do make; done
```

## Git Patterns

### Show Changed Files
```bash
# Modern (27 chars)
git status -s | choose 1 | uniq

# Traditional (35 chars)
git status -s | awk '{print $2}' | uniq
```

### Interactive Commit
```bash
# Modern (31 chars)
git status -s | gum choose | xargs git add

# Traditional (no simple equivalent)
```

## Pipeline Patterns

### Find, Filter, Count
```bash
# Modern (32 chars)
fd -e log | rg -l ERROR | wc -l

# Traditional (56 chars)
find . -name "*.log" -exec grep -l "ERROR" {} \; | wc -l
```

### Search, Extract, Sort
```bash
# Modern (36 chars)
rg 'import (.+)' -or '$1' | sort -u

# Traditional (52 chars)
grep -h "import .*" -r . | sed 's/import \(.*\)/\1/' | sort -u
```

## Advanced Combinations

### Find Duplicate Files by Content
```bash
# Modern (38 chars)
fd -x sha256sum {} | sort | uniq -d -w64

# Traditional (60+ chars)
find . -type f -exec sha256sum {} \; | sort | uniq -d -w64
```

### Parallel Processing
```bash
# Modern (29 chars)
fd -e py | parallel -j4 pylint {}

# Traditional (52 chars)
find . -name "*.py" | xargs -P4 -I {} pylint {}
```

### Quick Backup
```bash
# Modern (31 chars)
fd -e conf -x cp {} {}.bak

# Traditional (49 chars)
find . -name "*.conf" -exec cp {} {}.bak \;
```

## One-Character Improvements

### View with Syntax
```bash
# Modern (7 chars)
bat f.py

# Traditional (12 chars)
cat f.py | less
```

### List Details
```bash
# Modern (3 chars)
eza

# Traditional (5 chars)
ls -l
```

### Search Pattern
```bash
# Modern (7 chars)
rg TODO

# Traditional (16 chars)
grep -r TODO .
```

## Real-World Workflow Examples

### Clean Build Artifacts
```bash
# Modern (31 chars)
fd -e o -e tmp -x rm {} \; -j 8

# Traditional (54 chars)
find . \( -name "*.o" -o -name "*.tmp" \) -delete
```

### Check All Scripts
```bash
# Modern (28 chars)
fd -e sh -x shellcheck {} +

# Traditional (44 chars)
find . -name "*.sh" -exec shellcheck {} +
```

### Archive Old Logs
```bash
# Modern (42 chars)
fd -e log --changed-before 30d -x gzip {}

# Traditional (52 chars)
find . -name "*.log" -mtime +30 -exec gzip {} \;
```

## Efficiency Metrics

### Character Count Comparison
| Task | Traditional | Modern | Savings |
|------|------------|---------|---------|
| Find files | `find . -name "*.txt"` (21) | `fd -e txt` (10) | **52%** |
| Search text | `grep -r "TODO" .` (17) | `rg TODO` (7) | **59%** |
| List files | `ls -la` (7) | `eza -la` (7) | *Better output* |
| View file | `cat file | less` (16) | `bat file` (8) | **50%** |
| Count lines | `wc -l $(find . -name "*.py")` (30) | `fd -e py -x wc -l` (18) | **40%** |

### Cognitive Load Reduction
- **Fewer flags to remember**: Sensible defaults
- **Consistent syntax**: Similar patterns across tools
- **Better errors**: Tools guide you to correct usage
- **Readable output**: Colors and formatting by default

## The Ultimate Code Golf

### Task: Find all Python files with TODOs, show line numbers, sorted by filename
```bash
# Modern (34 chars)
fd -e py -x rg -n TODO {} | sort

# Traditional (67 chars)
find . -name "*.py" -exec grep -n "TODO" {} /dev/null \; | sort
```

**Result**: 49% fewer characters, clearer intent, faster execution!

## Tips for Maximum Efficiency

1. **Learn the defaults** - Modern tools have smart defaults
2. **Use single letters** - `fd` not `find`, `rg` not `ripgrep`
3. **Chain with `-x`** - fd's `-x` is powerful for batch operations
4. **Embrace interactivity** - `gum` for user-friendly scripts
5. **Measure everything** - Use our efficiency framework to prove gains

Remember: Every character counts in code golf, but readability matters in real code. Modern CLI tools give you both!
