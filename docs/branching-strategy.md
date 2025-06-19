# Branching Strategy

This repository uses Git Flow for release management.

## Branches

### `main`
- **Purpose**: Stable, production-ready releases only
- **Protected**: Yes
- **Direct commits**: Not allowed
- **Merges from**: `release/*` branches and `hotfix/*` branches

### `develop`
- **Purpose**: Integration branch for features
- **Default branch**: Yes
- **Direct commits**: Not allowed
- **Merges from**: `feature/*` branches

### `release/*`
- **Purpose**: Release preparation and beta testing
- **Naming**: `release/vX.Y.Z` (e.g., `release/v0.2.0`)
- **Created from**: `develop`
- **Allowed changes**: Bug fixes only, no new features
- **Merges to**: `main` and `develop` when ready

### `feature/*`
- **Purpose**: New features and enhancements
- **Naming**: `feature/description` (e.g., `feature/add-tmux-config`)
- **Created from**: `develop`
- **Merges to**: `develop` via PR

### `hotfix/*`
- **Purpose**: Emergency fixes for production
- **Naming**: `hotfix/description` (e.g., `hotfix/fix-bootstrap-error`)
- **Created from**: `main`
- **Merges to**: `main` and `develop` via PR

## Release Process

### Beta Release

1. Create release branch:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/v0.3.0
   git push -u origin release/v0.3.0
   ```

2. Tag beta versions:
   ```bash
   git tag v0.3.0-beta.1
   git push origin v0.3.0-beta.1
   gh release create v0.3.0-beta.1 --prerelease --generate-notes
   ```

3. Fix bugs as needed and tag additional betas:
   ```bash
   git tag v0.3.0-beta.2
   git push origin v0.3.0-beta.2
   ```

### Stable Release

1. Merge to main:
   ```bash
   git checkout main
   git merge --no-ff release/v0.3.0
   git tag v0.3.0
   git push origin main --tags
   ```

2. Create GitHub release:
   ```bash
   gh release create v0.3.0 --generate-notes
   ```

3. Merge back to develop:
   ```bash
   git checkout develop
   git merge --no-ff release/v0.3.0
   git push origin develop
   ```

4. Clean up:
   ```bash
   git branch -d release/v0.3.0
   git push origin --delete release/v0.3.0
   ```

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **Pre-releases**:
  - Beta: `vX.Y.Z-beta.N`
  - Release Candidate: `vX.Y.Z-rc.N`

### When to increment:

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## CI/CD Integration

GitHub Actions runs tests on:
- Pull requests to `main` or `develop`
- Pushes to `develop`
- Manual workflow dispatch

All tests must pass before merging.
