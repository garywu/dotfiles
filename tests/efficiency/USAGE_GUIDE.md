# CLI Tool Efficiency Testing - Usage Guide

## 🎯 Quick Start

### Run All Benchmarks

```bash
./tests/efficiency/tools/benchmark_runner.sh
```

### Run Specific Categories

```bash
# Search operations only (rg vs grep)
./tests/efficiency/tools/benchmark_runner.sh --search

# File operations only (eza, fd, bat)
./tests/efficiency/tools/benchmark_runner.sh --file-ops

# Quick mode (skip large datasets)
./tests/efficiency/tools/benchmark_runner.sh --quick

# Generate reports from existing results
./tests/efficiency/tools/benchmark_runner.sh --report-only
```

## 📊 Understanding Results

### Result Location

- **Latest results**: `tests/efficiency/results/latest/`
- **Historical results**: `tests/efficiency/results/historical/`

### Key Files

1. **efficiency_summary_report.md** - Overall summary with recommendations
2. **human_efficiency_*.md** - Character count and cognitive load analysis
3. **\*_runtime_results.md** - Performance benchmark tables
4. **\*_efficiency_report.md** - Detailed analysis for each tool category

## 🔍 Interpreting Benchmarks

### Human Efficiency Metrics

#### Character Count

- Measures keystrokes required
- Lower is better
- Example: `rg pattern` (10 chars) vs `grep -r pattern .` (18 chars)

#### Cognitive Load

- Number of concepts to remember
- Flags, syntax patterns, defaults
- Example: fd auto-excludes .gitignore, find requires explicit exclusions

#### Discoverability

- How easy to figure out the right command
- Quality of --help documentation
- Sensible defaults vs required flags

### Runtime Efficiency Metrics

#### Execution Time

- Measured with hyperfine (10 runs, 3 warmup)
- Shows mean, min, max, and relative performance
- Consider both small and large dataset results

#### Performance Notes

- Small overhead often acceptable for better features
- Interactive use vs scripting considerations
- Platform differences may affect results

## 📈 Using Results for Tool Selection

### Decision Framework

1. **Interactive Use**: Prioritize human efficiency
    - Syntax highlighting (bat)
    - Better defaults (fd, rg)
    - Integrated features (eza --git)

2. **Scripting**: Consider runtime efficiency
    - POSIX compatibility needs
    - Performance critical paths
    - Available tool guarantees

3. **Context Matters**
    - Team familiarity
    - Platform constraints
    - Specific feature requirements

### Example Recommendations

#### Text Search

```bash
# ✅ Recommended
rg "TODO"                    # Searches recursively by default
rg -i "error"                # Case insensitive
rg -C 3 "function"           # Show context

# ⚠️  Traditional (when needed)
grep -r "TODO" .             # When rg unavailable
```

#### File Finding

```bash
# ✅ Recommended
fd README                    # Find by name
fd -e py                     # Find by extension
fd -e log --changed-within 1d # Recent files

# ⚠️  Traditional (when needed)
find . -name "README*"       # POSIX scripts
```

#### File Viewing

```bash
# ✅ Recommended
bat config.yaml              # Syntax highlighted
bat -r 10:20 script.py       # View line range
bat -d modified.js           # Show git changes

# ⚠️  Traditional (when needed)
cat large.log | grep ERROR   # Streaming performance
```

#### Directory Listing

```bash
# ✅ Recommended
eza -la                      # Better formatting
eza -la --git                # Git status integration
eza --tree -L 2              # Tree view

# ⚠️  Traditional (when needed)
ls -la                       # POSIX compliance
```

## 🔄 Continuous Improvement

### Adding New Benchmarks

1. Create benchmark script in `benchmarks/` directory
2. Follow existing patterns for consistency
3. Include both human and runtime measurements
4. Add extensive comments for context preservation
5. Update runner to include new category

### Benchmark Script Template

```bash
#!/usr/bin/env bash
# CLI Tool Efficiency Testing: [Category]
#
# PURPOSE: Measure efficiency differences between [tools]
# CONTEXT: Part of Issue #20 - systematic measurement
#
# BACKGROUND:
# [Explain why this comparison matters]
#
# EFFICIENCY TYPES MEASURED:
# 1. Human Efficiency: [what aspects]
# 2. Runtime Efficiency: [what metrics]

# ... implementation following existing patterns
```

### CI Integration

The efficiency tests run automatically:

- **Weekly**: Full benchmark suite on Sunday 2 AM UTC
- **PR**: Quick benchmarks on test modifications
- **Manual**: Via GitHub Actions workflow dispatch

Results are stored as artifacts for 90 days.

## 🎓 Learning from Results

### Key Insights

1. **Good defaults matter more than features**
    - rg searches recursively by default
    - fd respects .gitignore automatically
    - eza shows human-readable sizes

2. **Cognitive load compounds**
    - Each flag to remember adds friction
    - Consistent syntax reduces mistakes
    - Discoverable commands get used more

3. **Small overheads are often worth it**
    - Syntax highlighting aids debugging
    - Better error messages save time
    - Integrated features reduce tool switching

### Adoption Strategy

1. **Start with clear wins**
    - Use rg for all text searches
    - Replace find with fd for file finding
    - Try bat for code viewing

2. **Build muscle memory gradually**
    - Alias traditional commands initially
    - Use modern tools in new scripts
    - Share efficiency gains with team

3. **Know when to use traditional tools**
    - POSIX compliance requirements
    - Performance critical paths
    - Limited environment constraints

## 🤝 Contributing

### Suggesting New Tools

1. Open issue describing the tool comparison
2. Explain expected efficiency benefits
3. Provide example use cases

### Improving Benchmarks

1. Fork and create feature branch
2. Add comprehensive tests with documentation
3. Ensure context preservation in comments
4. Submit PR with results

## 📚 Additional Resources

- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)
- [Command Line Interface Guidelines](https://clig.dev/)
- [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line)

---

**Remember**: The goal isn't to use every modern tool, but to make informed decisions based on measured efficiency gains.
