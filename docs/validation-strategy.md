# Validation Strategy

## When to Run Validations

### NOT at Pre-commit

**Reasons against pre-commit validation:**

1. **Too slow** - Full validation takes 30+ seconds
2. **Too noisy** - Shows issues unrelated to current changes
3. **Blocks commits** - System issues shouldn't block code commits
4. **False positives** - Environment issues aren't code issues

### Recommended Validation Schedule

#### 1. Manual Validation (Current)

Run when you need to check system health:

```bash
./scripts/validate-all.sh          # Full validation
./scripts/validate-all.sh --quick  # Essential checks only
```

#### 2. Post-Update Hook

Create a git post-merge hook for after pulling updates:

```bash
#!/usr/bin/env bash
# .git/hooks/post-merge
echo "Running quick validation after merge..."
./scripts/validate-all.sh --quick || true
```

#### 3. Scheduled Validation

Add to your shell RC or cron:

```bash
# Daily validation reminder
if [[ -f ~/.dotfiles/scripts/validate-all.sh ]]; then
  if [[ ! -f ~/.last-validation || $(find ~/.last-validation -mtime +7) ]]; then
    echo "💡 It's been a while since validation. Run: ./scripts/validate-all.sh"
  fi
fi
```

#### 4. CI/CD Validation

Add to GitHub Actions for PRs:

```yaml
- name: Run validation
  run: |
    ./scripts/validate-all.sh --quick
```

## What SHOULD Run at Pre-commit

Keep pre-commit fast and focused on code quality:

1. **Linting** (shellcheck, yamllint) - Fast, catches bugs
2. **Formatting** (shfmt, prettier) - Fast, maintains consistency
3. **File checks** (trailing spaces, file size) - Fast, prevents issues
4. **Shebang checks** - Fast, prevents runtime errors

## Creating Validation Aliases

Add to your shell config:

```bash
# Quick validation
alias val="~/.dotfiles/scripts/validate-all.sh --quick"

# Full validation
alias valfull="~/.dotfiles/scripts/validate-all.sh"

# Fix validation issues
alias valfix="~/.dotfiles/scripts/validate-all.sh --fix"
```

## Summary

- **Pre-commit**: Code quality only (fast checks)
- **Manual/Scheduled**: System validation (comprehensive)
- **Post-update**: Quick validation after changes
- **CI/CD**: Validation on pull requests
