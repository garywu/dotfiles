# Maintaining Validation Scripts

This guide explains how to keep validation scripts up-to-date with system changes.

## When to Update Validation Scripts

Update validation scripts whenever you:

1. **Add new packages** to `nix/home.nix`
2. **Install new tools** via Homebrew
3. **Change configurations** that affect tool behavior
4. **Discover missing validations** during troubleshooting
5. **Update tool versions** that change command interfaces

## Validation Script Overview

| Script | Purpose | Update When |
|--------|---------|-------------|
| `validate-environment.sh` | Shell, PATH, Nix daemon | Shell config changes, daemon issues |
| `validate-packages.sh` | Duplicate package detection | New package installations |
| `validate-dev-tools.sh` | Development tools (Rust, Go, etc.) | New dev tools added |
| `validate-python.sh` | Python installations | Python version changes |
| `validate-playwright.sh` | Browser automation | Playwright updates |
| `validate-multiversion.sh` | Version managers | New language versions |

## Adding New Validations

### 1. Identify What Needs Validation

After adding tools to `home.nix`:

```bash
# Extract tool names from recent changes
git diff nix/home.nix | grep "^\+" | grep -v "^+++"
```

### 2. Determine Validation Type

- **Command exists**: Basic check with `command_exists`
- **Version check**: Extract and validate version numbers
- **Configuration**: Check for config files or environment variables
- **Integration**: Test tool interactions

### 3. Add to Appropriate Script

Example adding a new Rust tool:

```bash
# In validate-dev-tools.sh, add to RUST_TOOLS array:
RUST_TOOLS=(
  # ... existing tools ...
  "new-tool-name"
)
```

### 4. Test the Validation

```bash
# Run specific validation
./scripts/validation/validate-dev-tools.sh

# Run all validations
./scripts/validate-all.sh
```

## Validation Audit Process

### Monthly Audit Checklist

1. **Review recent home.nix changes**:

   ```bash
   git log -p --since="1 month ago" -- nix/home.nix
   ```

2. **Check for unvalidated commands**:

   ```bash
   # List all executables from Nix
   ls ~/.nix-profile/bin/ | sort > /tmp/nix-commands.txt

   # Extract validated commands from scripts
   grep -h "command_exists\|TOOLS=\|_TOOLS=" scripts/validation/*.sh | \
     grep -o '"[^"]*"' | tr -d '"' | sort -u > /tmp/validated-commands.txt

   # Find unvalidated commands
   comm -23 /tmp/nix-commands.txt /tmp/validated-commands.txt
   ```

3. **Update validation scripts** for any missing tools

4. **Run comprehensive validation**:

   ```bash
   ./scripts/validate-all.sh --verbose
   ```

### After Major Updates

After system updates or major tool installations:

1. **Run validation with auto-fix**:

   ```bash
   ./scripts/validate-all.sh --fix
   ```

2. **Check for new validation failures**

3. **Update scripts for any changed behavior**

## Testing Validation Scripts

### Unit Testing Approach

Create test scenarios:

```bash
# Test missing tool detection
PATH=/usr/bin:/bin ./scripts/validation/validate-dev-tools.sh

# Test fix mode
./scripts/validation/validate-environment.sh --fix

# Test JSON output
./scripts/validation/validate-packages.sh --json
```

### Integration Testing

```bash
# Full system validation
time ./scripts/validate-all.sh

# Quick validation (essential checks only)
./scripts/validate-all.sh --quick
```

## Common Patterns

### Adding Version Checks

```bash
# Pattern for version extraction
if command_exists "tool"; then
  version=$(tool --version 2>/dev/null | grep -o '[0-9.]*' | head -1 || echo "unknown")
  log_success "tool ($version)"
fi
```

### Checking Configurations

```bash
# Check for config file
if [[ -f "$HOME/.toolrc" ]]; then
  log_success "tool configuration found"
else
  log_warn "tool not configured"
  log_info "  Create ~/.toolrc for custom settings"
fi
```

### Environment Variables

```bash
# Validate environment setup
if [[ -n ${TOOL_HOME:-} ]]; then
  log_success "TOOL_HOME is set: $TOOL_HOME"
else
  log_error "TOOL_HOME not set"
  log_info "  Add to shell: export TOOL_HOME=\$HOME/.tool"
fi
```

## Validation Script Best Practices

1. **Be specific** in error messages - include fix commands
2. **Check dependencies** before checking dependent tools
3. **Use consistent** naming for arrays and functions
4. **Include version** information where possible
5. **Provide --fix** suggestions even in non-fix mode
6. **Test thoroughly** after changes

## Automated Validation Tracking

Consider adding to `.github/workflows/`:

```yaml
name: Validation Audit
on:
  pull_request:
    paths:
      - 'nix/home.nix'
      - 'brew/Brewfile'

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check for validation updates
        run: |
          # Script to verify validation coverage
          ./scripts/check-validation-coverage.sh
```

## Troubleshooting

### Validation Script Issues

- **False positives**: Tool installed but not in PATH
  - Check PATH configuration in validation script
  - Ensure proper sourcing of shell configs

- **Version detection fails**: Command doesn't support --version
  - Try alternative version flags (-v, -V, version)
  - Use fallback to "installed" if version unavailable

- **Platform differences**: Tool behaves differently on macOS/Linux
  - Add platform-specific checks
  - Use `uname -s` for OS detection

### Getting Help

1. Check existing validation scripts for patterns
2. Review git history for similar additions
3. Test in isolation before adding to main script
4. Create issues for complex validation needs
