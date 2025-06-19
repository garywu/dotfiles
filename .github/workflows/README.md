# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the dotfiles repository.

## Workflows

### `test-bootstrap.yml`

Tests the bootstrap and unbootstrap process across multiple platforms:

- **macOS**: Full test including Homebrew
- **Ubuntu**: Linux compatibility test
- **WSL**: Windows Subsystem for Linux test

Triggers on:

- Pull requests that modify bootstrap-related files
- Manual workflow dispatch

### `deploy-docs.yml`

Deploys the documentation site to GitHub Pages.

- Builds Astro/Starlight documentation
- Deploys to GitHub Pages
- Updates live documentation site

### `release.yml`

Handles automated releases with semantic versioning.

- Creates GitHub releases
- Generates changelogs
- Updates documentation

### `lint.yml`

Code quality and style checking:

- **Runs**: All linting tools from Makefile
- **Checks**: Shell, Nix, YAML, Markdown, TOML, Fish files
- **Output**: Detailed summary of results
- **Behavior**: Fails if any linting issues found

Triggers on:

- Push to any branch
- Pull requests
- Manual workflow dispatch

### `security.yml`

Security vulnerability scanning:

- **Secret detection**: Gitleaks, TruffleHog
- **Dependency scanning**: Trivy
- **Static analysis**: Semgrep
- **License compliance**: Checks package licenses
- **Outdated dependencies**: Identifies updates needed
- **Security policy**: Validates security files

Triggers on:

- Push to main/develop
- Pull requests
- Daily schedule (2 AM UTC)
- Manual workflow dispatch

## Configuration Files

### `../.github/dependabot.yml`

Automated dependency updates:

- GitHub Actions: Weekly updates
- npm (docs site): Weekly updates
- Automatic PRs with proper labels
- Conventional commit messages

## CI Mode

The bootstrap and unbootstrap scripts support CI mode when these environment variables are set:

- `CI=true`
- `GITHUB_ACTIONS=true`

In CI mode:

- Interactive prompts are automatically answered with safe defaults
- Confirmations are auto-accepted
- Progress pauses are skipped

## Testing Locally

You can test the CI behavior locally:

```bash
# Test bootstrap in CI mode
CI=true ./bootstrap.sh

# Test unbootstrap in CI mode
CI=true ./scripts/unbootstrap.sh

# Run the test suite
./scripts/test-bootstrap.sh
```

## Adding New Tests

To add new tests:

1. Update `scripts/test-bootstrap.sh` with new test cases
2. Ensure the test works across all platforms
3. Add any platform-specific logic as needed

## Required Repository Settings

For these workflows to function properly:

1. **GitHub Pages**: Enable GitHub Pages from Actions
2. **Secrets**: No additional secrets required (uses GITHUB_TOKEN)
3. **Branch Protection**: Recommended to require status checks
4. **Permissions**: Workflows need write permissions for security events
