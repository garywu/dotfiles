# CLAUDE.md - AI Assistant Session Tracking and Workflow

## Workflow Procedure

### 1. Planning Phase

- **Always start with planning** - Never modify code without a clear plan
- **Create GitHub issues** for all planned work
- **Add comments** to issues for clarifications and questions
- **Wait for approval** before proceeding with implementation

### 2. Issue Management

- **Prioritize work** based on GitHub issues
- **Only modify code** when working on a clearly defined GitHub issue
- **Update issues continuously** with progress comments
- **Create sub-issues** for discovered problems or related work
- **Close issues** only when work is complete and verified

### 3. Implementation Phase

- **Reference the issue** being worked on
- **Comment on progress** as work proceeds
- **Document problems** encountered as issue comments
- **Create new issues** for discovered technical debt or improvements
- **Verify completion** before closing issues

## Important Commands

### Home Manager

```bash
# Apply configuration changes
home-manager switch

# Check generation differences
home-manager generations
```

### Chezmoi (for secrets only)

```bash
# Apply secret changes
chezmoi apply

# Edit secrets
chezmoi edit <file>
```

### Git Workflow

```bash
# Check status
git status

# Create commits with issue references
git commit -m "fix: description (#issue-number)"
```

### GitHub CLI

```bash
# List issues
gh issue list

# Create issue
gh issue create --title "Title" --body "Description" --label "label1,label2"

# Comment on issue
gh issue comment <number> --body "Comment"

# View issue
gh issue view <number>

# Close issue
gh issue close <number>
```

### Cloudflare Tools

```bash
# Cloudflared - Tunnel management
cloudflared tunnel create <tunnel-name>
cloudflared tunnel list
cloudflared tunnel run <tunnel-name>

# Wrangler - Workers/Pages CLI
wrangler init <project-name>
wrangler dev
wrangler publish
wrangler pages deploy <directory>

# Flarectl - Account management
flarectl zone list
flarectl dns list --zone <zone-name>
flarectl dns create --zone <zone-name> --type A --name @ --content <ip>
```

### Testing and Linting

```bash
# Run all linters
make lint

# Run all formatters
make format

# Individual linting commands
make lint-shell      # Lint shell scripts
make lint-nix        # Lint Nix files
make lint-yaml       # Lint YAML files
make lint-markdown   # Lint Markdown files
make lint-toml       # Check TOML files
make lint-fish       # Check Fish scripts

# Individual formatting commands
make format-shell    # Format shell scripts
make format-nix      # Format Nix files
make format-toml     # Format TOML files
make format-fish     # Format Fish scripts
```

### Productivity Tools

```bash
# Fast searching
ag "pattern"         # Silver searcher - faster than grep
rg "pattern"         # Ripgrep - even faster (already had)
fd "filename"        # Fast file finder (already had)

# Better command alternatives
sd "find" "replace"  # Better than sed for find/replace
choose 1 3           # Better than cut/awk
dust                 # Better du - disk usage
duf                  # Better df - disk free
procs                # Better ps - process viewer
lsd                  # Better ls with icons

# Git tools
tig                  # Text-mode git interface
gitui                # Fast terminal UI for git
lazygit              # TUI for git (already had)

# File exploration
broot                # New way to navigate directories
hexyl file.bin       # Hex viewer with colors
gron file.json       # Make JSON greppable
jless file.json      # Interactive JSON viewer

# Development
tokei                # Count lines of code
hyperfine "cmd"      # Benchmark commands
watchexec -e py pytest  # Run commands on file change
```

## IMPORTANT: Default Tool Usage for Claude CLI

**ALWAYS use modern CLI tools as the FIRST choice:**

### File Operations
- **USE `eza -la`** instead of `ls -la`
- **USE `fd pattern`** instead of `find . -name pattern`
- **USE `bat file`** instead of `cat file` (when showing content to user)
- **USE `dust`** instead of `du -sh`

### Search Operations
- **USE `rg pattern`** instead of `grep -r pattern .`
- **USE `rg -l pattern`** instead of `grep -rl pattern .`
- **USE `fd -e txt`** instead of `find . -name "*.txt"`

### Data Processing
- **USE `jq`** for JSON instead of grep/sed/awk
- **USE `sd 'find' 'replace'`** instead of `sed 's/find/replace/g'`
- **USE `choose 0 2`** instead of `cut -f1,3` or `awk '{print $1,$3}'`

### Interactive Tools
- **USE `gum choose`** for selection menus
- **USE `gum input`** for user input
- **USE `gum spin`** for progress indicators

### Why This Matters
The efficiency testing framework (Issue #20) proved these tools provide:
- 36% fewer keystrokes (human efficiency)
- Better defaults and discoverability
- More consistent cross-platform behavior
- Better error messages and output formatting

**Remember**: These tools are already installed. There's no compatibility concern. Use them!

## Documentation and Testing Commands

### Documentation Site (Starlight)

```bash
# Development
cd docs
npm run dev              # Start dev server

# Building
npm run build           # Build static site (includes astro sync)
npm run preview         # Preview built site

# Troubleshooting
npx astro sync          # Sync content collections if pages missing
```

## Current Session (2025-06-19)

### Focus: Claude-Init Knowledge Transfer

1. **Analyzed dotfiles for valuable learnings**:
   - Extracted debugging experiences from Issue #15 (Astro docs)
   - Captured CI/CD platform-specific knowledge
   - Documented testing framework patterns

2. **Created comprehensive documentation for claude-init**:
   - Added 7 new documentation guides
   - Captured 3.5 hours of Astro debugging into guide
   - Documented platform-specific CI gotchas
   - Created meta-guide on learning from mistakes

3. **Transformed claude-init philosophy**:
   - Shifted from prescriptive scripts to information resource
   - Added "information over implementation" principle
   - Made debugging-to-documentation process explicit

4. **Key Contributions**:
   - `docs/debugging-and-troubleshooting.md` - Common issues
   - `docs/testing-framework-guide.md` - Complete test patterns
   - `docs/github-actions-multi-platform.md` - CI/CD guide
   - `docs/documentation-site-setup.md` - Astro lessons
   - `docs/learning-from-mistakes.md` - Knowledge capture process

### Commits

- Added linting/formatting reference documentation
- Added core design principle of information over implementation
- Added comprehensive debugging knowledge from real-world experience

## Current Session (2025-06-18)

### Completed

1. Fixed critical documentation site issues (Issue #15):

   - Resolved "only building homepage and 404 page" problem
   - Fixed cross-platform rollup dependencies in GitHub Actions
   - Solution: Added `astro sync` to build process
   - Solution: Modified GitHub Actions to regenerate package-lock.json
   - All 17 pages now build correctly

2. Updated CLAUDE.md with documentation commands

3. Created detailed GitHub issue documenting failed attempts and solution

### Key Learnings from Issue #15

- **Always run `astro sync`** before building Astro sites with content collections
- **Cross-platform CI/CD**: Be careful with package-lock.json between macOS and Linux
- **Debug process**: Check dev server first - if content works there but not in build, likely a sync issue
- **Simplicity wins**: Light theme default was better than complex CSS overrides

## Current Session (2025-06-17)

### Completed

1. Created GitHub Issue #2 - Architecture Separation documentation
2. Initialized CLAUDE.md for workflow tracking
3. Created GitHub Issue #3 - Establish Issue-Driven Development Workflow
4. Created GitHub Issue #4 - Setup Professional Development Processes and Standards
5. Created GitHub Issue #5 - Phase 1: GitHub Repository Setup
6. Established project decisions:

   - Version: Starting at 0.0.1
   - Commit format: Conventional Commits
   - Versioning: Semantic Versioning

7. Implemented Phase 1 (Issue #5):

   - Created all GitHub labels
   - Created issue templates (bug, feature, docs, refactor)
   - Created pull request template
   - Created CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
   - Updated CHANGELOG.md for v0.0.1

8. Committed changes and created v0.0.1 tag

9. Created Issue #6 - Phase 3: Implement Linting and Formatting Tools

10. Implemented Phase 3 (Issue #6):
    - Added linting tools to home.nix
    - Created all configuration files
    - Created Makefile with linting/formatting targets
    - Updated pre-commit hooks
    - Updated documentation

11. Implemented Cloudflare tools (Issue #7):
    - Added cloudflared and flarectl to home.nix
    - Added wrangler installation to bootstrap.sh
    - Documented commands in CLAUDE.md

12. Committed and pushed all changes (commit e57067a)

13. Created Issue #8 - Fix existing linting warnings

14. Created Issue #9 - Phase 4: CI/CD with GitHub Actions

15. Fixed major linting issues in Issue #8:
    - Fixed shellcheck warnings in bootstrap.sh
    - Fixed YAML formatting in .pre-commit-config.yaml
    - Auto-formatted Nix and TOML files

16. Closed Issue #8 with commits ed8f406 and 1006bea

### In Progress

- Ready to work on CI/CD setup (Issue #9)

### Next Steps

1. Implement CI/CD with GitHub Actions (Issue #9)
2. Continue with other phases from Issue #4
3. Consider changelog automation (Phase 2)
4. Address remaining linting issues in other scripts

## Previous Sessions

### Session 1 (Unknown Date)

- Refactored architecture to separate Nix/Home Manager from Chezmoi
- Fixed Fish shell Homebrew path detection
- Created ARCHITECTURE.md documentation
- Updated bootstrap.sh for new workflow

## Issue Tracking

### Open Issues

- #1 - Pre-commit hooks blocking commits with changelog check
- #2 - Architecture Separation: Nix/Home Manager from Chezmoi Management (documentation)
- #3 - Establish Issue-Driven Development Workflow
- #4 - Setup Professional Development Processes and Standards
- #9 - Phase 4: Set up CI/CD with GitHub Actions (sub-issue of #4)

### Completed Issues

- #5 - Phase 1: GitHub Repository Setup - Labels and Templates ✅
- #6 - Phase 3: Implement Linting and Formatting Tools ✅
- #7 - Add Cloudflare Command Line Tools ✅
- #8 - Fix existing linting warnings in codebase ✅

### Project Version

- Current: 0.0.1 (tagged)
- Next: 0.0.2 (after next major feature)

## Notes for Next Session

1. **Always check this file first** to understand context
2. **Run `gh issue list`** to see current priorities
3. **Check `git status`** for any uncommitted changes
4. **Review open issues** before starting new work
5. **Follow the workflow** - Plan → Issue → Implement → Update → Close

## Repository Structure Reference

```text
~/.dotfiles/
├── nix/
│   ├── home.nix          # Package and configuration declarations
│   ├── flake.nix         # Nix flake configuration
│   └── flake.lock        # Flake lock file
├── chezmoi/
│   ├── chezmoi.toml      # User-specific values and secrets only
│   ├── dot_gitconfig.tmpl # Git config template
│   └── private_dot_ssh/   # SSH config templates
├── brew/
│   └── Brewfile          # macOS GUI apps
├── ARCHITECTURE.md       # Architecture documentation
├── CLAUDE.md            # This file - AI assistant tracking
└── bootstrap.sh          # Setup script
```

## Workflow Reminders

- **Never modify code without an issue**
- **Always update issues with progress**
- **Create new issues for discovered problems**
- **Use issue numbers in commit messages**
- **Verify changes before closing issues**
