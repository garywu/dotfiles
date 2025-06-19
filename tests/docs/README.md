# Documentation Testing Suite

This directory contains comprehensive tests for documentation link validation and GitHub Pages deployment issues prevention.

## Overview

The documentation testing suite prevents the complex GitHub Pages + Astro link issues that historically required multiple debugging sessions and failed attempts to resolve.

## Test Scripts

### 1. `test_link_patterns.sh` - Pattern Validation
**Purpose**: Validates link patterns to prevent GitHub Pages + Astro base path issues

**What it tests**:
- ✅ Astro base path configuration
- ✅ Absolute vs relative link patterns
- ✅ Homepage action button links
- ✅ Sidebar configuration
- ✅ Cross-reference patterns
- ✅ Known problematic patterns

**Usage**:
```bash
# Run pattern validation
./tests/docs/test_link_patterns.sh

# From docs directory
npm run test:patterns
```

**Key validations**:
- Detects absolute paths that break with GitHub Pages base paths
- Validates homepage action buttons use relative paths
- Checks for references to deleted sections
- Ensures proper cross-reference patterns

### 2. `test_links.sh` - Local Link Testing
**Purpose**: Tests internal links in built documentation

**What it tests**:
- ✅ All internal links in HTML output
- ✅ Base path handling
- ✅ Local development server
- ✅ Link resolution with Astro base path

**Usage**:
```bash
# Test with local server
./tests/docs/test_links.sh local

# From docs directory
npm run test:links
```

**Process**:
1. Builds documentation with `astro build`
2. Starts preview server
3. Extracts all internal links from HTML
4. Tests each link for 200 response
5. Reports broken links

### 3. `test_production_links.sh` - Production Validation
**Purpose**: Validates links on live GitHub Pages site

**What it tests**:
- ✅ All critical pages return 200
- ✅ GitHub Pages deployment success
- ✅ Base path resolution in production

**Usage**:
```bash
# Test production site
./tests/docs/test_production_links.sh

# From docs directory
npm run test:production
```

**Pages tested**:
- Homepage and all main sections
- Updated to exclude deleted `/05-cli-tools-academy/` paths
- Covers all current documentation structure

## CI/CD Integration

### GitHub Actions Workflows

#### 1. `deploy-docs.yml` - Enhanced Deployment
**Trigger**: Push to main with docs changes

**Process**:
1. **Validate** - Run pattern validation and link tests
2. **Build** - Create production build
3. **Deploy** - Deploy to GitHub Pages
4. **Verify** - Test production links post-deployment

#### 2. `test-docs.yml` - PR Testing
**Trigger**: Pull requests affecting docs

**Jobs**:
- **test-patterns**: Validate link patterns
- **test-build**: Test build process
- **test-links**: Test internal links
- **test-cross-platform**: Test builds on multiple platforms
- **comment-results**: Post results to PR

### Package.json Scripts

Added comprehensive test scripts to `docs/package.json`:

```json
{
  "scripts": {
    "test": "npm run test:patterns && npm run test:build && npm run test:links",
    "test:patterns": "../tests/docs/test_link_patterns.sh",
    "test:build": "npm run build",
    "test:links": "../tests/docs/test_links.sh local",
    "test:production": "../tests/docs/test_production_links.sh",
    "validate": "npm run test"
  }
}
```

## Running Tests

### Local Development

```bash
# Run all tests
cd docs && npm test

# Individual tests
npm run test:patterns  # Validate link patterns
npm run test:build     # Test build process
npm run test:links     # Test internal links
npm run test:production # Test live site

# Manual testing
./tests/docs/test_link_patterns.sh
./tests/docs/test_links.sh local
./tests/docs/test_production_links.sh
```

### Prerequisites

Install required tools:
```bash
# Install GNU coreutils (for timeout command)
# macOS:
brew install coreutils

# Ubuntu (usually pre-installed):
sudo apt-get install coreutils

# Documentation dependencies
cd docs && npm install
```

## Problem Prevention

### Known Issues These Tests Prevent

1. **Absolute Path Issues**
   - ❌ Problem: `[Link](/section/page/)` breaks with GitHub Pages base path
   - ✅ Solution: Tests detect and require `[Link](./section/page/)`

2. **Homepage Action Button Issues**
   - ❌ Problem: `link: '/guides/'` breaks in GitHub Pages
   - ✅ Solution: Tests require `link: './guides/'`

3. **Cross-Reference Breaks**
   - ❌ Problem: References to deleted sections cause 404s
   - ✅ Solution: Tests detect references to removed content

4. **Build Process Issues**
   - ❌ Problem: Missing `astro sync` causes content collection issues
   - ✅ Solution: Tests validate build process includes sync

### Test Coverage

| Issue Type | Detection | Prevention |
|------------|-----------|------------|
| Absolute paths | ✅ Pattern scan | ✅ CI/CD validation |
| Base path config | ✅ Config validation | ✅ Build testing |
| Broken links | ✅ Link testing | ✅ Pre-deployment check |
| Cross-references | ✅ Content scan | ✅ Pattern validation |
| Build process | ✅ Build testing | ✅ CI/CD integration |

## Troubleshooting

### Test Failures

#### Pattern Validation Fails
```bash
# Check specific errors
./tests/docs/test_link_patterns.sh

# Common fixes:
# 1. Convert absolute to relative paths
# 2. Fix homepage action buttons
# 3. Update cross-references
```

#### Link Testing Fails
```bash
# Debug specific links
./tests/docs/test_links.sh local

# Common issues:
# 1. Server not starting - check port 4321
# 2. Build failures - run npm run build separately
# 3. Missing files - check astro sync
```

#### Production Testing Fails
```bash
# Test specific URLs
curl -I "https://garywu.github.io/dotfiles/section/page/"

# Common issues:
# 1. Deployment not complete - wait and retry
# 2. New pages not in test list - update PAGES array
# 3. GitHub Pages cache - may take minutes to update
```

### Manual Validation

```bash
# Quick manual checks
cd docs

# 1. Build test
npm run build && echo "✅ Build successful"

# 2. Base path check
grep -r "base:" astro.config.mjs

# 3. Absolute path scan
grep -r "](/[^)]*)" src/content/docs/

# 4. Production test
curl -I "https://garywu.github.io/dotfiles/"
```

## Integration with Claude-Init

This testing suite is documented in `claude-init` for reuse:

- `external/claude-init/docs/github-pages-astro-troubleshooting.md` - Complete guide
- `external/claude-init/docs/github-pages-astro-quick-reference.md` - Quick fixes

Templates in `claude-init` include test configurations to prevent these issues in new projects.

## Maintenance

### Updating Tests

When adding new documentation sections:

1. **Update production test**: Add new pages to `PAGES` array in `test_production_links.sh`
2. **Update patterns**: Add new validation rules to `test_link_patterns.sh` if needed
3. **Test locally**: Run full test suite before committing

### Monitoring

The CI/CD workflows provide automatic monitoring:
- ✅ Pre-deployment validation prevents broken deployments
- ✅ Post-deployment verification catches deployment issues
- ✅ PR testing prevents problematic changes from merging

This comprehensive testing infrastructure should prevent future multi-attempt debugging sessions for documentation link issues.
