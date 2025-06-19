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

### `release.yml`

Handles automated releases with semantic versioning.

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
