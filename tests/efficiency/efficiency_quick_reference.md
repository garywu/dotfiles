# CLI Tool Efficiency - Quick Reference

## Always Prefer These Tools

| Task | Traditional | Modern | Efficiency Gain |
|------|-------------|---------|-----------------|
| Text Search | `grep -r "pattern" .` | `rg "pattern"` | 36% fewer chars |
| Find Files | `find . -name "*.py"` | `fd -e py` | 58-84% simpler |
| View Code | `cat file.py` | `bat file.py` | Syntax highlighting |
| List Files | `ls -la` | `eza -la` | Better features |

## Command Translations

### Search

- `grep -r` → `rg`
- `grep -ri` → `rg -i`
- `grep -rn` → `rg -n`
- `grep -r -C 3` → `rg -C 3`

### Find

- `find . -name` → `fd`
- `find . -type f -name "*.ext"` → `fd -e ext`
- `find . -mtime -7` → `fd --changed-within 7d`

### View

- `cat` → `bat` (for code)
- `cat -n` → `bat` (line numbers by default)
- `head -20 | tail -10` → `bat -r 10:20`

### List

- `ls -la` → `eza -la`
- `ls -laR` → `eza -la --tree`
- `tree -L 2` → `eza --tree -L 2`

## Remember

- Use modern tools interactively
- Keep traditional tools for scripts
- Always have fallbacks ready
