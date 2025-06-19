---
title: CLI Golf Challenges
description: Command-line golf challenges comparing traditional vs modern tools
---

# CLI Golf Challenges

Command-line golf challenges where we minimize keystrokes while maintaining functionality. Each challenge shows traditional vs modern solutions.

## Challenge 1: Find and Count

**Task**: Find all Python files containing "TODO" and count occurrences

```bash
# Traditional (67 chars)
find . -name "*.py" -exec grep -c "TODO" {} \; | awk '{s+=$1} END {print s}'

# Modern (24 chars)
fd -e py -x rg -c TODO | awk -F: '{s+=$2} END {print s}'

# Ultra-modern (17 chars)
rg -tpy -c TODO | wc -l

# Winner: 75% reduction!
```

## Challenge 2: Recent File Search

**Task**: Find files modified in the last 24 hours larger than 1MB

```bash
# Traditional (52 chars)
find . -type f -mtime -1 -size +1M -exec ls -lh {} \;

# Modern (35 chars)
fd -t f --changed-within 1d --size +1m -x ls -lh

# Winner: 33% reduction
```

## Challenge 3: Multi-Pattern Search

**Task**: Find files containing both "error" and "warning"

```bash
# Traditional (68 chars)
find . -type f -exec grep -l "error" {} \; | xargs grep -l "warning"

# Modern (35 chars)
rg -l "error" | xargs rg -l "warning"

# Ultra-modern (31 chars)
rg -l0 error | xargs -0 rg -l warning

# Winner: 54% reduction
```

## Challenge 4: Batch Rename

**Task**: Rename all .txt files to .bak

```bash
# Traditional (56 chars)
for f in $(find . -name "*.txt"); do mv "$f" "${f%.txt}.bak"; done

# Modern (23 chars)
fd -e txt -x mv {} {.}.bak

# Winner: 59% reduction
```

## Challenge 5: Directory Size Sorting

**Task**: Show top 5 largest directories

```bash
# Traditional (35 chars)
du -sh * | sort -rh | head -5

# Modern (13 chars)
dust -n 5

# Winner: 63% reduction!
```

## Challenge 6: Process Management

**Task**: Kill all Python processes

```bash
# Traditional (39 chars)
ps aux | grep python | awk '{print $2}' | xargs kill

# Modern (29 chars)
procs python | awk '{print $1}' | xargs kill

# Interactive modern (15 chars)
procs python | gum choose -m | xargs kill

# Winner: 62% reduction (interactive)
```

## Challenge 7: Log Analysis

**Task**: Find unique IP addresses in access.log

```bash
# Traditional (58 chars)
grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log | sort -u

# Modern (36 chars)
rg -o '\d+\.\d+\.\d+\.\d+' access.log | sort -u

# Winner: 38% reduction
```

## Challenge 8: JSON Processing

**Task**: Extract all "name" fields from JSON array

```bash
# Traditional (52 chars)
grep -o '"name":\s*"[^"]*"' file.json | cut -d'"' -f4

# Modern (27 chars)
jq -r '.[].name' file.json

# Winner: 48% reduction
```

## Challenge 9: Interactive File Selection

**Task**: Select and edit a configuration file

```bash
# Traditional (no simple solution)
find . -name "*.conf" -type f | head -20 # view files
vi ./path/to/selected.conf              # manually type path

# Modern (28 chars)
fd -e conf | fzf | xargs $EDITOR

# Interactive with preview (45 chars)
fd -e conf | fzf --preview 'bat {}' | xargs $EDITOR

# Winner: Infinitely better!
```

## Challenge 10: Parallel Processing

**Task**: Compress all log files older than 7 days

```bash
# Traditional (63 chars)
find . -name "*.log" -mtime +7 -type f -exec gzip {} \;

# Modern with parallel (42 chars)
fd -e log --changed-before 1w -x gzip {}

# Ultra-modern parallel (38 chars)
fd -e log --changed-before 1w | parallel gzip

# Winner: 40% reduction + faster execution
```

## Combination Challenges

### Challenge 11: Find, Filter, Execute

**Task**: Find Python files, show only those with "class", edit the largest

```bash
# Traditional (would require script)
find . -name "*.py" -exec grep -l "class" {} \; > files.tmp
ls -la $(cat files.tmp) | sort -k5 -n | tail -1 | awk '{print $9}' | xargs vi

# Modern (54 chars)
fd -e py -x rg -l class {} | xargs ls -S | head -1 | xargs $EDITOR

# Winner: One line vs script!
```

### Challenge 12: System Cleanup

**Task**: Remove all node_modules directories

```bash
# Traditional (45 chars)
find . -name "node_modules" -type d -exec rm -rf {} +

# Modern (26 chars)
fd -t d node_modules -x rm -rf

# Winner: 42% reduction
```

## Interactive Workflow Challenges

### Challenge 13: Git Workflow

**Task**: Interactive commit of specific files

```bash
# Traditional
git status
git add file1.py
git add file2.py
git commit -m "message"

# Modern (one line!)
git status -s | fzf -m | awk '{print $2}' | xargs git add && git commit

# With gum (more visual)
git status -s | gum choose -m | awk '{print $2}' | xargs git add && gum input --placeholder "Commit message" | xargs git commit -m
```

### Challenge 14: Docker Management

**Task**: Stop and remove selected containers

```bash
# Traditional
docker ps
docker stop container_id1 container_id2
docker rm container_id1 container_id2

# Modern (one line)
docker ps | fzf -m --header-lines=1 | awk '{print $1}' | xargs -r docker stop | xargs -r docker rm
```

## The Ultimate Challenge

**Task**: Find all TODO comments in code, group by file, sort by count, edit the file with most TODOs

```bash
# Traditional (would need complex script)
for file in $(find . -type f -name "*.py" -o -name "*.js"); do
    count=$(grep -c "TODO" "$file" 2>/dev/null || echo 0)
    if [ $count -gt 0 ]; then
        echo "$count $file"
    fi
done | sort -rn | head -1 | awk '{print $2}' | xargs vi

# Modern (42 chars)
rg -c TODO | sort -t: -k2 -rn | head -1 | cut -d: -f1 | xargs $EDITOR

# Winner: 75% reduction + much faster!
```

## Scoring Summary

| Challenge | Traditional | Modern | Reduction |
|-----------|------------|---------|-----------|
| Find & Count | 67 chars | 17 chars | 75% |
| Recent Files | 52 chars | 35 chars | 33% |
| Multi-Pattern | 68 chars | 31 chars | 54% |
| Batch Rename | 56 chars | 23 chars | 59% |
| Dir Sorting | 35 chars | 13 chars | 63% |
| Process Mgmt | 39 chars | 15 chars | 62% |
| Log Analysis | 58 chars | 36 chars | 38% |
| JSON Extract | 52 chars | 27 chars | 48% |
| File Select | N/A | 28 chars | ∞ |
| Parallel | 63 chars | 38 chars | 40% |

**Average reduction: 52%** 🎯

## Key Patterns for Winning

1. **Default recursion** saves `-r` or `find`
2. **Smart globs** eliminate complex regex
3. **Built-in parallelism** beats xargs
4. **Interactive tools** replace multi-step processes
5. **Pipes still matter** but with better tools

## Community Leaderboard

Share your best golf scores:

```bash
# Template for submissions
# Task: [description]
# Traditional: [command] ([X] chars)
# Modern: [command] ([Y] chars)
# Reduction: [Z]%
```

Remember: In real scripts, prioritize readability. In golf, every character counts!
