# CLAUDE.md - AI Assistant Session Tracking and Workflow

## Self-Reflection and Error Prevention Protocol

### Before Starting Any Task

1. **Review Recent History**
   - Re-read the last 10-20 messages in the conversation
   - Identify any patterns of errors or corrections
   - Note specific instructions that were given and may have been forgotten

2. **Check for Common Self-Induced Errors**
   - **Path errors**: Verify file paths before using them
   - **Assumption errors**: Don't assume file contents or structure - always check
   - **Instruction drift**: Re-read the original request to ensure staying on track
   - **Context loss**: Review what was already tried to avoid repeating failures

3. **Memory Checkpoint Questions**
   - What was the user's original request?
   - What specific constraints or preferences were mentioned?
   - Have I made this type of error before in this session?
   - Am I following the established patterns in this codebase?

4. **Error Pattern Recognition**
   Common self-induced errors to watch for:
   - Forgetting to read a file before writing to it
   - Using wrong file paths or assuming directory structures
   - Ignoring user corrections and repeating the same mistake
   - Missing important context from earlier in the conversation
   - Making changes that contradict established patterns

5. **Verification Before Action**
   - Double-check file paths exist with `ls` or `find`
   - Verify assumptions about file contents with `Read` tool
   - Confirm understanding of requirements before implementing
   - Test commands in a safe way before executing destructive operations

### During Task Execution

- **Pause and reflect** when errors occur - don't just retry blindly
- **Read error messages carefully** - they often contain the solution
- **Check conversation history** when confused about requirements
- **Acknowledge patterns** - if making similar errors, adjust approach

### After Completing Tasks

- **Review what was done** against original requirements
- **Note any errors made** for future reference
- **Update relevant documentation** if patterns were discovered

## Project Management Workflow

### 0. Project Setup - Permanent Management Issues

For every new project, create these 9 permanent management issues that should **NEVER be closed**:

1. **📋 Project Roadmap & Planning** - Central planning and milestone tracking
2. **🔗 Issue Cross-Reference Index** - Master list of all issue relationships
3. **📚 Research & Discovery Log** - Document all findings and investigations
4. **🏗️ Architecture Decisions** - Track design choices and rationale
5. **🐛 Known Issues & Workarounds** - Catalog of ongoing challenges
6. **📖 Documentation Tasks** - Track what needs documenting
7. **🔧 Technical Debt Registry** - List of improvements needed
8. **💡 Ideas & Future Features** - Backlog of enhancements
9. **📊 Project Health & Metrics** - Performance and quality tracking

### 1. System Health Check

- **Start sessions with validation** - Run `./scripts/validation/validate-packages.sh`
- **Fix any issues** before starting work
- **Check after major changes** to ensure system stays clean

### 2. Issue Management Best Practices

#### Creating Issues
- **Be specific and targeted** - One clear goal per issue
- **Use templates** - Bug, Feature, Documentation, Refactor
- **Add labels** - Priority, type, component affected
- **Link related issues** - Use "Related to #X", "Blocks #Y", "Blocked by #Z"
- **Assign milestones** - Group related work

#### Interlinking Issues
- **Reference parent issues**: "Part of #X"
- **Link dependencies**: "Requires #Y to be completed first"
- **Cross-reference**: "See also #Z for related discussion"
- **Use task lists** in parent issues:
  ```markdown
  - [ ] Sub-task 1 (#101)
  - [ ] Sub-task 2 (#102)
  - [ ] Sub-task 3 (#103)
  ```

#### Continuous Documentation
- **Comment when starting work**: "Beginning investigation of X"
- **Document findings immediately**:
  ```markdown
  Discovered that the issue is caused by:
  - Finding 1: [details]
  - Finding 2: [details]
  - Potential solution: [approach]
  ```
- **Update status regularly**: "Progress update: Completed X, working on Y"
- **Link to commits**: "Implemented in abc123"
- **Document blockers**: "Blocked by #X - waiting for resolution"

### 3. Atomic Commit Practices

#### Making Atomic Commits
- **One logical change per commit** - If you need "and" in your description, split it
- **Commit frequently** - Don't accumulate large changes
- **Complete but minimal** - Each commit should work independently
- **Test before committing** - Ensure each commit doesn't break the build

#### Commit Workflow
```bash
# After each logical change:
1. git add -p  # Stage specific changes interactively
2. git diff --staged  # Review what you're committing
3. git commit  # Write descriptive message

# Don't wait to accumulate changes!
```

#### Examples of Atomic Commits
```bash
# ✅ GOOD - Atomic commits
feat(validation): add check_nix_daemon function (#71)
feat(validation): add Nix daemon status to environment check (#71)
docs: add Nix daemon explanation to troubleshooting (#71)
fix(validation): remove set -e for better error handling (#71)

# ❌ BAD - Too many changes in one commit
feat: add validation and fix errors and update docs (#71)
```

### 4. Implementation Phase

- **Reference the issue** being worked on
- **Make atomic commits** after each logical change
- **Comment on progress** in the issue after each commit
- **Document problems** as you encounter them
- **Create new issues** for discovered problems
- **Before committing shell scripts**: Run `make fix-shell`
- **Test each commit** independently

## Shell Script Standards

### Shebang Requirements

**ALWAYS use `#!/usr/bin/env bash`** for bash scripts, never `#!/bin/bash`:

```bash
# ✅ CORRECT - finds modern bash in PATH
#!/usr/bin/env bash

# ❌ WRONG - uses ancient macOS bash 3.2 from 2007
#!/bin/bash
```

**Why this matters:**
- macOS ships with bash 3.2.57 (from 2007) at `/bin/bash` for GPL licensing reasons
- Modern bash 5.2+ is installed via Nix at `~/.nix-profile/bin/bash`
- Bash 3.2 lacks many modern features like associative arrays (`declare -A`)
- Using `env bash` ensures scripts use the modern version from PATH

**Enforcement:**
- Pre-commit hook will reject commits with hardcoded bash paths
- Run `make fix-shell` before committing (includes automatic shebang fix)
- Or run `./scripts/fix-shebangs.sh` to fix just shebangs

# Committing Changes with Git

## Pre-Commit Hook Management

### Preventing Pre-Commit Failures

**ALWAYS run these commands before committing:**

```bash
# Quick fix for all common issues
make pre-commit-fix

# Or manually:
make fix-shell       # Fix shell scripts
make format          # Format all code
git add -u           # Stage fixes
```

### Common Pre-Commit Issues and Solutions

1. **Trailing Whitespace / End of File**
   - Auto-fixed by `make pre-commit-fix`
   - Or run: `pre-commit run trailing-whitespace --all-files`

2. **Shell Script Issues**
   - Auto-fixed by `make fix-shell`
   - Includes: shebang fixes, shellcheck issues, formatting

3. **Markdown Linting**
   - Most strict rules - if blocking:
   - Review with: `markdownlint CLAUDE.md`
   - Last resort: `git commit --no-verify` (use sparingly!)

4. **YAML/TOML/Nix Formatting**
   - Auto-fixed by `make format`

### Recommended Commit Workflow

```bash
# 1. Make your changes
vim file.sh

# 2. Pre-commit fix (ALWAYS DO THIS!)
make pre-commit-fix

# 3. Review what will be committed
git diff --staged

# 4. Commit with confidence
git commit -m "feat: add new feature (#123)"
```

### Emergency Bypass (Use Rarely!)

```bash
# Only when you understand why it's failing
# and plan to fix in next commit
git commit --no-verify -m "WIP: emergency commit"

# IMMEDIATELY follow with:
make pre-commit-fix
git commit -m "fix: resolve pre-commit issues"
```

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description (#issue-number)

[optional body]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests
- `chore`: Maintain tasks, dependency updates

### Commit Process

1. **Stage changes selectively**:
   ```bash
   git add -p  # Interactive staging
   # OR
   git add specific-file.sh  # Stage specific files
   ```

2. **Review staged changes**:
   ```bash
   git diff --staged
   ```

3. **Create atomic commit**:
   ```bash
   git commit -m "feat(tools): add act for local GitHub Actions testing (#64)

   - Added act to nix/home.nix for running GH Actions locally
   - Enables testing workflows without pushing to GitHub
   - Version 0.2.78 from nixpkgs

   🤖 Generated with [Claude Code](https://claude.ai/code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

4. **Update issue immediately**:
   ```bash
   gh issue comment 64 --body "Implemented in commit abc123:
   - Added act to nix/home.nix
   - Tool allows local GitHub Actions testing
   - Next: Update documentation"
   ```

### Multi-Commit Workflow Example

```bash
# Working on issue #64: Add container tools

# First atomic commit
git add nix/home.nix
git commit -m "feat(nix): add act for GitHub Actions local testing (#64)"
gh issue comment 64 --body "Added act to home.nix in commit abc123"

# Second atomic commit
git add nix/home.nix
git commit -m "feat(nix): add dive for Docker image analysis (#64)"
gh issue comment 64 --body "Added dive to home.nix in commit def456"

# Third atomic commit
git add nix/home.nix
git commit -m "feat(nix): add k9s for Kubernetes management (#64)"
gh issue comment 64 --body "Added k9s to home.nix in commit ghi789"

# Documentation commit
git add CLAUDE.md
git commit -m "docs: add usage examples for container tools (#64)"
gh issue comment 64 --body "Documented all three tools in commit jkl012"

# Validation commit
git add scripts/validation/validate-dev-tools.sh
git commit -m "feat(validation): add container tools validation (#64)"
gh issue comment 64 --body "Added validation in commit mno345. All tasks complete!"
```

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

# IMPORTANT: Before committing shell scripts, fix issues
make fix-shell
git add -u

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

# Fix shell script issues automatically (RECOMMENDED before commit)
make fix-shell

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

#### Dealing with ShellCheck Issues

**IMPORTANT**: If you encounter shellcheck errors during commit:

1. **Quick Fix** (Recommended):

   ```bash
   make fix-shell
   git add -u
   git commit
   ```

2. **Manual Fix** for specific issues:
   - SC2310: Function in negation - separate the check:

     ```bash
     # Instead of: if ! command_exists foo; then
     command_exists foo
     local exists=$?
     if [[ $exists -ne 0 ]]; then
     ```

   - SC2086: Quote variables: `"$var"` instead of `$var`
   - SC2292: Use `[[ ]]` instead of `[ ]`

3. **Permanent Prevention**:
   - Always run `make fix-shell` before committing shell scripts
   - Use `shellcheck <script.sh>` while developing
   - Copy from existing scripts that already pass checks

### Environment Validation

```bash
# IMPORTANT: Run regularly to detect issues early!

# Check for duplicate packages between Nix and Homebrew
./scripts/validation/validate-packages.sh

# Auto-fix duplicate package issues
./scripts/validation/validate-packages.sh --fix

# Run comprehensive validation
./scripts/validate-all.sh

# Run with auto-fix mode
./scripts/validate-all.sh --fix

# Individual validation scripts
./scripts/validation/validate-packages.sh    # Check for duplicate packages
./scripts/validation/validate-environment.sh  # Check environment health
./scripts/validation/validate-playwright.sh   # Check Playwright installation
./scripts/validation/validate-docs.sh        # Check documentation coverage
./scripts/validation/doc-coverage-report.sh  # Generate doc coverage report

# View validation reports
ls -la logs/validation/
```

### Update Management

```bash
# Check for updates across all package managers
./scripts/check-updates.sh

# Update everything at once
./scripts/update-all.sh

# Update specific package managers
nix-channel --update && home-manager switch  # Nix/Home Manager
brew update && brew upgrade                   # Homebrew
npm update -g                                 # NPM packages

# Update Ollama specifically
brew upgrade ollama  # If installed via Homebrew
# OR
curl -fsSL https://ollama.ai/install.sh | sh  # Official installer

# Clean up old versions
brew cleanup --prune=all              # Homebrew
nix-collect-garbage --delete-older-than 30d  # Nix
```

#### Package Management Notes

- **Primary strategy**: Nix-first for all development tools
- **Acceptable exceptions**: Dependencies required by Homebrew formulas (e.g., python@3.12 for ra-aid)
- **Run validation after**:
  - Installing new packages
  - Running `brew update` or `brew upgrade`
  - Major system updates
  - Suspicious PATH behavior

### Browser Automation and Testing

```bash
# Playwright - End-to-end testing framework
playwright --help                    # Show all available commands
playwright install                   # Install browser binaries (Chrome, Firefox, Safari)
playwright codegen https://example.com  # Generate test code interactively
playwright test                      # Run tests
playwright test --ui                 # Run tests with UI mode
playwright show-report               # Show HTML test report

# Screenshot and PDF generation
playwright screenshot https://example.com screenshot.png
playwright pdf https://example.com page.pdf

# Validation and setup
./scripts/validation/validate-playwright.sh --verbose
./scripts/validation/validate-playwright.sh --install-browsers
./scripts/validation/validate-playwright.sh --generate-sample
```

### Productivity Tools

```bash
# Ollama - Local LLM Server
ollama serve                 # Start server (auto-starts at boot)
ollama pull llama3.2         # Download a model
ollama run llama3.2          # Run a model interactively
ollama list                  # List installed models
ollama ps                    # Show running models
curl http://localhost:11434/api/tags  # Check API status

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

# JavaScript Package Managers (all available after shell restart)
npm install          # Node Package Manager (via fnm)
yarn install         # Yarn Classic package manager
pnpm install         # Fast, disk space efficient package manager
bun install          # Ultra-fast all-in-one runtime & package manager

# LaTeX/Document Processing
pdflatex file.tex    # Compile LaTeX to PDF
latex file.tex       # Compile LaTeX to DVI
bibtex file          # Process bibliography
pandoc -o out.pdf in.md  # Convert markdown to PDF (requires LaTeX)

# Cloud Storage Sync
rclone sync local remote:path  # Sync local to remote
rclone copy local remote:path  # Copy local to remote (no delete)
rclone mount remote: ~/mnt     # Mount remote as filesystem
rclone ls remote:              # List files on remote
rsync -av src/ dest/          # Local/network sync with progress

# AI/ML Tools
gemini                       # Google Gemini CLI for AI-powered workflows
ollama                       # Local LLM server (auto-starts at boot)
# Note: Other AI tools can be installed with pip/pipx:
# pipx install chatblade      # CLI for ChatGPT
# pipx install litellm        # Multi-LLM CLI

# Container & Kubernetes Tools
act                          # Run GitHub Actions locally
act -l                       # List available workflows
act push                     # Run push event workflows
act -W .github/workflows/ci.yml  # Run specific workflow
dive docker-image:tag        # Analyze Docker image layers
dive --source docker-archive image.tar  # Analyze from tar
k9s                          # Kubernetes CLI dashboard
k9s --context prod           # Connect to specific context
k9s --namespace web          # Start in specific namespace

# Network Monitoring & Remote Access
ssh user@host                # SSH remote access
scp file user@host:/path     # Secure copy over SSH
sftp user@host               # Interactive file transfer
yt-dlp "url"                 # Download videos from various sites

# BitTorrent Clients
# GUI: qBittorrent.app      # GUI client installed at /Applications/qBittorrent.app
transmission-remote host     # CLI BitTorrent remote control
transmission-cli             # CLI BitTorrent client

# Network Monitoring (Linux only - available on Linux systems)
nethogs                       # Monitor per-process network usage
bmon                         # Real-time network bandwidth monitor
iftop                        # Display network usage by hosts
nload                        # Console network traffic monitor

# macOS Network Monitoring Alternatives
nettop                       # Built-in macOS network monitor
lsof -i                      # Show network connections
netstat -rn                  # Show routing table
# Install via Homebrew: brew install nethogs iftop nload bmon
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

## Current Session (2025-06-24)

### Completed

1. **Resolved duplicate package installations** (Issue #52):
   - Removed duplicate AWS CLI, Google Cloud SDK, and Python 3.13 from Homebrew
   - All primary commands now use Nix versions
   - Documented acceptable exceptions (python@3.12 and ripgrep for ra-aid)
   - Updated CLAUDE.md with validation script usage

2. **Added LaTeX/pdflatex support** (Issue #56):
   - Added texlive.combined.scheme-basic to nix/home.nix
   - Provides pdflatex, latex, bibtex, and other TeX tools
   - Updated CLAUDE.md with LaTeX commands in productivity tools section
   - Verified installation with test compilation

3. **Added Calibre e-book CLI tools** (Issue #58):
   - Added calibre to brew/Brewfile for macOS (GUI + CLI)
   - Created scripts/setup-calibre.sh for cross-platform CLI installation
   - Supports Linux (apt/dnf/pacman/apk), macOS (Homebrew), Windows (winget/choco)
   - Commented out broken Nix package with explanation
   - Bootstrap.sh automatically runs calibre setup
   - Provides: ebook-convert, calibredb, ebook-meta, ebook-viewer

4. **Added archive, PDF, and audio tools** (Issue #59):
   - Added p7zip (7z command) for high-compression archives
   - Added ghostscript (gs command) for PostScript/PDF processing
   - Added lame for MP3 encoding
   - All installed via Nix for cross-platform availability

5. **Added network monitoring and remote access tools** (Issue #61):
   - Added openssh for SSH/SCP/SFTP support (Nix - cross-platform)
   - Added yt-dlp for video downloads (Nix - cross-platform)
   - Added Linux-specific network monitoring tools to nix/home.nix:
     - nethogs, bmon, iftop, nload, transmission-remote-gtk
   - Added macOS support via brew/Brewfile for network tools
   - Updated CLAUDE.md with usage examples and platform notes
   - Created atomic commits for each component

6. **Added qBittorrent GUI client** (Issue #62):
   - Added qBittorrent cask to brew/Brewfile
   - Installed version 5.0.5 via Homebrew
   - Provides advanced BitTorrent features alongside WebTorrent
   - Updated documentation with BitTorrent clients section

7. **Fixed triple bracket multiplication bug in agent-init**:
   - Fixed critical bug: `[[[` syntax errors in 4 shell scripts
   - Total 31 instances fixed across setup.sh, copy-templates.sh, etc.
   - All scripts now pass bash syntax validation
   - Committed fix to agent-init repository

8. **Installed and configured Playwright** (Issue #multidev-10):
   - Added playwright-test to nix/home.nix
   - Created validation script: validate-playwright.sh
   - Added browser installation to bootstrap.sh
   - Updated documentation with Playwright commands

9. **Implemented multi-version development environment**:
   - **Go**: Native toolchain management (Go 1.21+) with GOTOOLCHAIN=auto
   - **Node.js**: Added fnm (Fast Node Manager) for version management
   - **Rust**: Configured for future oxalica/rust-overlay integration
   - **Bun**: Kept alongside fnm for fast package management
   - Created comprehensive validation script: validate-multiversion.sh
   - Generated example projects in ~/multiversion-examples/

### Multi-Version Development Commands

```bash
# Go - Native toolchain management (1.21+)
go version                          # Check current version
go mod edit -go=1.22               # Change project Go version
go mod edit -toolchain=go1.22.0    # Use specific toolchain

# Node.js - fnm (Fast Node Manager)
fnm --version                       # Check fnm installation
fnm list                           # List installed versions
fnm install 20.11.0                # Install specific version
fnm use                            # Use version from .nvmrc
fnm install --lts                  # Install latest LTS
fnm default 20.11.0                # Set default version

# Bun - Fast JavaScript runtime
bun --version                      # Check Bun version
bun install                        # Fast package installation
bunx <package>                     # Run packages without installing

# Rust - Currently single version via Nix
rustc --version                    # Check Rust version
cargo --version                    # Check Cargo version
# For multi-version: See oxalica/rust-overlay setup

# Validation
./scripts/validation/validate-multiversion.sh --create-examples
```

### Key Validation Commands

```bash
# Quick system health check
./scripts/validation/validate-packages.sh

# If duplicates found, auto-fix
./scripts/validation/validate-packages.sh --fix
```

## Previous Session (2025-06-19)

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

## Current Session (2025-06-19)

### Completed

1. Fixed critical documentation site issues (Issue #15):

   - Resolved "only building homepage and 404 page" problem
   - Fixed cross-platform rollup dependencies in GitHub Actions
   - Solution: Added `astro sync` to build process
   - Solution: Modified GitHub Actions to regenerate package-lock.json
   - All 17 pages now build correctly

2. Updated CLAUDE.md with documentation commands

3. Created detailed GitHub issue documenting failed attempts and solution

4. Analyzed claude-init's three-branch Git workflow:
   - **stable** branch - Production releases (green)
   - **beta** branch - Weekly beta releases from main (orange)
   - **main** branch - Active development (red)
   - Automated workflows for releases and synchronization

5. Created standardization issues:
   - Issue #24: Adopt Claude-Init's Three-Branch Git Workflow
   - Issue #10 in claude-init: Enhance Git Workflow Documentation for Universal Adoption

6. Successfully implemented three-branch Git workflow:
   - Created and pushed `stable`, `beta`, and updated `main` branches
   - Updated README with workflow declaration and badges
   - All branches synchronized with latest code
   - Repository now follows claude-init's proven workflow pattern

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
- #24 - Adopt Claude-Init's Three-Branch Git Workflow

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
