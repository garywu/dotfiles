# Efficiency-Tested Tool Recommendations

This document provides tool recommendations based on systematic efficiency testing.
All recommendations are backed by measured data from the [CLI Tool Efficiency Testing Framework](https://github.com/garywu/.dotfiles/tree/main/tests/efficiency).

## Methodology

Each tool recommendation is based on two types of efficiency measurements:

1. **Human Efficiency**: Character count, cognitive load, discoverability
2. **Runtime Efficiency**: Execution speed, resource usage, output quality

## Validated Tool Recommendations

### File Finding Operations

#### ✅ Use fd instead of find

**Measured Benefits**:

- 58-84% reduction in command length
- Intuitive syntax (no -name, -type flags needed)
- Smart defaults (.gitignore awareness, hidden file exclusion)

**Usage Patterns**:

```bash
# Find by name (instead of: find . -name "*README*")
fd README

# Find by extension (instead of: find . -name "*.py" -type f)
fd -e py

# Find recently modified (instead of: find . -mtime -7)
fd --changed-within 7d

# Exclude directories (instead of: find . -not -path "*/node_modules/*")
fd # automatically respects .gitignore

# Find and execute (instead of: find . -name "*.log" -exec rm {} \;)
fd -e log -x rm
```

**When to use find**: In POSIX scripts or when fd is unavailable.

### File Viewing Operations

#### ✅ Use bat for code viewing instead of cat

**Measured Benefits**:

- Syntax highlighting improves code comprehension
- Built-in line numbers aid debugging
- Git integration shows modifications
- Acceptable performance overhead for interactive use

**Usage Patterns**:

```bash
# View code files (instead of: cat file.py)
bat file.py

# View specific lines (instead of: sed -n '10,20p' file.py)
bat -r 10:20 file.py

# Plain output when needed (instead of: cat file.txt)
bat -p file.txt

# Force language syntax
bat -l yaml config.conf
```

**When to use cat**: For performance-critical scripts, large file streaming, or when bat is unavailable.

### Directory Listing Operations

#### ✅ Use eza for interactive directory browsing instead of ls

**Measured Benefits**:

- Better default formatting (human-readable sizes, colors)
- Integrated features (git status, tree view, icons)
- Consistent cross-platform behavior

**Usage Patterns**:

```bash
# Basic listing (instead of: ls -la)
eza -la

# With git status (no ls equivalent)
eza -la --git

# Tree view (instead of: tree -L 2 or find . -maxdepth 2)
eza --tree -L 2

# Sort by modification time (instead of: ls -lat)
eza -la --sort=modified

# Long listing with icons
eza -la --icons
```

**When to use ls**: In POSIX-compliant scripts or minimal environments.

## Integration Guidelines for Claude CLI

### Decision Framework

1. **Check tool availability first**:

```bash
if command -v rg &> /dev/null; then
    rg "pattern"
else
    grep -r "pattern" .
fi
```

2. **Document efficiency rationale**:

```bash
# Using fd: 58% more efficient than find (see efficiency tests)
fd -e py
```

3. **Provide fallback options**:

```bash
# Modern approach (if tools available)
fd -e log | fzf --preview 'bat --color=always {}'

# Traditional fallback
find . -name "*.log" -type f | head -20
```

### Best Practices

1. **Interactive vs Script Usage**
    - Use modern tools for interactive sessions (better UX)
    - Consider traditional tools for scripts (compatibility)

2. **Performance Considerations**
    - Modern tools often have small overhead
    - This overhead is usually worth it for features
    - Use traditional tools in performance-critical loops

3. **Learning Curve**
    - Modern tools have better defaults
    - This reduces the learning curve
    - Start with basic usage, explore features gradually

## Continuous Validation

These recommendations are continuously validated through automated efficiency testing:

- Weekly benchmarks via GitHub Actions
- Cross-platform testing (macOS, Linux)
- Historical tracking for trend analysis

For the latest results and detailed methodology, see:
[CLI Tool Efficiency Testing Framework](https://github.com/garywu/.dotfiles/tree/main/tests/efficiency)

---

*Generated: $(date)*
*Source: Efficiency test results from $RESULTS_DIR*
