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

### Testing
```bash
# Run linting (find exact command in package.json or project config)
# npm run lint / ruff / etc.

# Run type checking
# npm run typecheck / mypy / etc.
```

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

### In Progress
- Phase 1 implementation complete, awaiting review and commit

### Next Steps
1. Review and commit Phase 1 changes
2. Create first tagged release (v0.0.1)
3. Choose next implementation phase from Issue #4
4. Set up linting and formatting tools

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
- #5 - Phase 1: GitHub Repository Setup - Labels and Templates (sub-issue of #4)

### Completed Issues
- None yet

### Project Version
- Current: 0.0.1 (initial version)

## Notes for Next Session

1. **Always check this file first** to understand context
2. **Run `gh issue list`** to see current priorities
3. **Check `git status`** for any uncommitted changes
4. **Review open issues** before starting new work
5. **Follow the workflow** - Plan → Issue → Implement → Update → Close

## Repository Structure Reference

```
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
