# ShellCheck Issues Analysis

## Summary

Our validation scripts have 22 ShellCheck warnings/errors across 8 categories.
Most are minor style/safety issues, with one error.

## Issues by Category

### 1. **Unassigned Variables (5 issues)** - SC2154

These are variables referenced but not defined in the script:

- `$GREEN`, `$YELLOW`, `$NC` - Color codes used but defined in `validation-helpers.sh`
- `$LOG_DEBUG` - Log level constant used but defined in helpers

**Example:**

```bash
log_info "  $path ${GREEN}[Nix]${NC}"  # GREEN and NC not defined in this file
```

**Fix:** These are actually defined in the sourced helper file, so we need to tell ShellCheck:

```bash
# shellcheck disable=SC2154  # Colors defined in sourced file
```

### 2. **Unused Variables (5 issues)** - SC2034

Variables assigned but never used:

- `preferred_manager` in `check_duplicate_package()` - parameter not used
- `output` in `validate-all.sh` - captured but not used
- `DOTFILES_ROOT` in `validate-packages.sh` - defined but not used
- `EXPECTED_CONFIGS` array - defined but not used

**Example:**

```bash
local output
output=$("$script_path" "$@" 2>&1 | tee "$temp_file")  # output never used
```

**Fix:** Remove unused variables or use them.

### 3. **Return Value Masking (5 issues)** - SC2310/SC2312

Commands in conditions that might mask return values:

**Example:**

```bash
if nix-env -q 2>/dev/null | grep -q "^${package}"; then
```

**Fix:** Add `|| true` if we don't care about the return value:

```bash
if nix-env -q 2>/dev/null | grep -q "^${package}" || true; then
```

### 4. **Array Concatenation Error (1 issue)** - SC2199

This is the only ERROR level issue:

```bash
if [[ ! " ${CRITICAL_PACKAGES[@]} " =~ " ${package} " ]]; then
```

**Fix:** Use `*` instead of `@`:

```bash
if [[ ! " ${CRITICAL_PACKAGES[*]} " =~ " ${package} " ]]; then
```

### 5. **Regex Quote Issue (1 issue)** - SC2076

Quotes on right side of `=~` make it literal match:

```bash
if [[ ! " ${CRITICAL_PACKAGES[@]} " =~ " ${package} " ]]; then
                                    ^-- literal match, not regex
```

**Fix:** Remove quotes for regex or keep for literal match (which we want here).

### 6. **Array Split Issue (1 issue)** - SC2207

```bash
locations=($(check_package_location "$package"))
```

**Fix:** Use mapfile or read:

```bash
mapfile -t locations < <(check_package_location "$package")
```

### 7. **Quote Style (1 issue)** - SC2248

```bash
return $exit_code  # Should be "$exit_code"
```

### 8. **Declare and Assign (1 issue)** - SC2155

```bash
local report_file="$report_dir/validation-$(date +%Y%m%d-%H%M%S).log"
```

**Fix:** Separate declaration and assignment:

```bash
local report_file
report_file="$report_dir/validation-$(date +%Y%m%d-%H%M%S).log"
```

## Severity Levels

- **Errors (1)**: Must fix - SC2199 (array concatenation)
- **Warnings (11)**: Should fix - unused vars, unassigned vars, etc.
- **Info (5)**: Nice to fix - return value masking
- **Style (1)**: Optional - quote style

## Most Common Patterns

1. **Cross-file dependencies**: Variables defined in sourced files trigger warnings
2. **Defensive coding**: Checking commands that might fail in pipelines
3. **Unused parameters**: Functions with parameters for future use
4. **Array handling**: Bash array syntax is tricky

## Recommendations

1. **High Priority**: Fix the SC2199 error (array concatenation)
2. **Medium Priority**: Add shellcheck directives for cross-file variables
3. **Low Priority**: Clean up unused variables
4. **Consider**: Creating a `.shellcheckrc` file for project-wide settings
