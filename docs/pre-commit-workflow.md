# Pre-Commit Workflow Guide

## The Permanent Solution

To permanently avoid pre-commit hook failures, we've implemented a comprehensive solution:

### 1. Automated Fix Script

**`scripts/pre-commit-fix.sh`** automatically fixes:
- Trailing whitespace
- Missing end-of-file newlines
- Shell script issues (shebangs, shellcheck)
- YAML formatting
- TOML formatting
- Nix formatting

### 2. Makefile Integration

```bash
# Always run before committing:
make pre-commit-fix
```

### 3. Smart Commit Alias

```bash
# Automatically fixes issues then commits:
git smart-commit "feat: your message (#123)"
# Or shorter:
git sc "feat: your message (#123)"
```

### 4. Workflow Instructions

The recommended workflow is now documented in:
- `CLAUDE.md` - Pre-Commit Hook Management section
- `agent-init/templates/PROJECT-MANAGEMENT.md` - For new projects

## How It Works

1. **Before commit**: Run `make pre-commit-fix`
2. **Issues are automatically fixed**
3. **Fixed files are staged**
4. **Commit proceeds without errors**

## Common Issues Solved

### Trailing Whitespace
- **Before**: Manual fixing or commit failures
- **Now**: Automatically removed

### End of File
- **Before**: Adding newlines manually
- **Now**: Automatically added

### Shell Scripts
- **Before**: Fixing shebangs, shellcheck issues manually
- **Now**: `make fix-shell` handles everything

### Markdown Linting
- **Before**: Strict rules blocking commits
- **Now**: Document bypass strategy when needed

## Emergency Procedures

If pre-commit still fails after fixes:

```bash
# 1. Bypass temporarily
git commit --no-verify -m "WIP: message"

# 2. Fix immediately after
make pre-commit-fix
git commit -m "fix: resolve pre-commit issues"
```

## Best Practices

1. **Always run `make pre-commit-fix` before committing**
2. **Use `git sc` alias for convenience**
3. **Don't ignore pre-commit warnings - fix them**
4. **If bypassing, fix in the very next commit**

## Integration with CI/CD

The same fixes can be applied in CI:
```yaml
- name: Fix formatting issues
  run: make pre-commit-fix
```

This ensures consistency between local and CI environments.
