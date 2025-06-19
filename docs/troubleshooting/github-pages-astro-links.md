# GitHub Pages + Astro Documentation Link Issues

## Problem Summary

When deploying Astro sites with Starlight to GitHub Pages, internal documentation links often break due to base path configuration issues. This is a complex problem that can take multiple attempts to resolve if not understood properly.

## Root Cause

**Core Issue**: GitHub Pages serves sites at `https://username.github.io/repository-name/`, but internal links often don't account for the `/repository-name` base path.

### Technical Details

1. **GitHub Pages URL Structure**: `https://garywu.github.io/dotfiles/`
2. **Astro Base Configuration**: `base: '/dotfiles'` in `astro.config.mjs`  
3. **Link Resolution**: Internal links must work with this base path

## Broken Link Patterns ❌

### Pattern 1: Absolute Paths Without Base
```markdown
<!-- BREAKS in GitHub Pages -->
[Getting Started](/01-introduction/getting-started/)
[CLI Tools](/03-cli-tools/modern-replacements/)
```
**Why it breaks**: Resolves to `https://garywu.github.io/01-introduction/getting-started/` (missing `/dotfiles`)

### Pattern 2: Homepage Action Buttons
```javascript
// astro.config.mjs - BROKEN
actions: [
  {
    text: 'Getting Started',
    link: '/01-introduction/getting-started/', // ❌ Absolute path
    icon: 'right-arrow',
  }
]
```

### Pattern 3: Cross-Reference Links
```markdown
<!-- BROKEN cross-references -->
- [ChatBlade Integration](/06-ai-tools/chatblade/)
- [OpenHands Setup](/06-ai-tools/openhands/)
```

## Working Link Patterns ✅

### Pattern 1: Relative Paths from Homepage
```markdown
<!-- WORKS in GitHub Pages -->
[Getting Started](./01-introduction/getting-started/)
[CLI Tools](./03-cli-tools/modern-replacements/)
```

### Pattern 2: Fixed Homepage Action Buttons
```javascript
// astro.config.mjs - FIXED
actions: [
  {
    text: 'Getting Started',
    link: './01-introduction/getting-started/', // ✅ Relative path
    icon: 'right-arrow',
  }
]
```

### Pattern 3: Relative Cross-References
```markdown
<!-- WORKING cross-references -->
- [ChatBlade Integration](../chatblade/)
- [OpenHands Setup](../openhands/)
```

## Configuration Requirements

### 1. Astro Configuration
```javascript
// astro.config.mjs
export default defineConfig({
  site: 'https://username.github.io',
  base: '/repository-name',          // Critical: matches GitHub Pages path
  integrations: [
    starlight({
      title: 'Documentation',
      sidebar: [
        {
          label: 'Getting Started',
          autogenerate: { directory: '01-introduction' }, // ✅ Use autogenerate
        },
      ],
    }),
  ],
});
```

### 2. Package.json Scripts
```json
{
  "scripts": {
    "build": "astro sync && astro build", // Always sync before build
    "dev": "astro dev",
    "preview": "astro preview"
  }
}
```

### 3. GitHub Pages Workflow
```yaml
# .github/workflows/deploy.yml
- name: Build
  run: |
    cd docs
    npm ci
    npm run build  # Includes astro sync
```

## Testing Strategy

### 1. Local Testing
```bash
# Test with base path
cd docs
npm run dev
# Visit: http://localhost:4321/repository-name/

# Test all internal links
./tests/docs/test_links.sh local
```

### 2. Production Testing
```bash
# After deployment
./tests/docs/test_production_links.sh
```

### 3. Automated Link Testing
```bash
#!/bin/bash
# tests/docs/test_links.sh
BASE_URL="${1:-http://localhost:4321}"
SITE_BASE="/dotfiles"

# Test critical pages
test_link() {
    local path="$1"
    local url="${BASE_URL}${SITE_BASE}${path}"
    if curl -sI "$url" | head -1 | grep -q "200 OK"; then
        echo "✅ $path"
    else
        echo "❌ $path"
        return 1
    fi
}

test_link "/01-introduction/getting-started/"
test_link "/03-cli-tools/modern-replacements/"
# ... more tests
```

## Common Failed Attempts

### ❌ Attempt 1: Explicit Sidebar Configuration
```javascript
// DON'T DO THIS - harder to maintain
sidebar: [
  {
    label: 'Getting Started',
    items: [
      { label: 'Getting Started', link: '/01-introduction/getting-started/' }, // Still broken
    ],
  },
]
```
**Problem**: Still uses absolute paths, doesn't solve base path issue.

### ❌ Attempt 2: Complex CSS Overrides
```css
/* DON'T DO THIS - unrelated to link issues */
:root {
  --sl-color-accent: custom-color;
}
```
**Problem**: CSS changes don't fix link resolution.

### ❌ Attempt 3: File Structure Changes
**Problem**: Moving files doesn't fix the fundamental base path issue.

## The Complete Fix Process

### Step 1: Fix Homepage Action Links
```javascript
// astro.config.mjs
actions: [
  {
    text: 'Getting Started',
    link: './01-introduction/getting-started/', // Add './'
    icon: 'right-arrow',
    variant: 'primary'
  },
  {
    text: 'CLI Tools', 
    link: './03-cli-tools/modern-replacements/', // Add './'
    icon: 'external'
  }
]
```

### Step 2: Fix Cross-Reference Links
```markdown
<!-- In AI tools pages -->
See also:
- [ChatBlade Integration](../chatblade/) <!-- Use '../' -->
- [OpenHands Setup](../openhands/)     <!-- Use '../' -->
```

### Step 3: Use Sidebar Autogeneration
```javascript
sidebar: [
  {
    label: 'Getting Started',
    autogenerate: { directory: '01-introduction' }, // Let Starlight handle paths
  },
]
```

### Step 4: Always Sync Before Build
```bash
# Ensure content collections are synced
astro sync && astro build
```

## Prevention Checklist

### For New Astro + GitHub Pages Projects

- [ ] Set correct `base` path in `astro.config.mjs`
- [ ] Use relative paths (`./`, `../`) for internal links
- [ ] Use `autogenerate` for sidebar when possible
- [ ] Include `astro sync` in build process
- [ ] Test both local and production environments
- [ ] Set up automated link testing

### Link Pattern Guidelines

- ✅ Homepage links: `./section/page/`
- ✅ Cross-references: `../other-section/`
- ✅ Same-directory: `./other-page/`
- ❌ Absolute paths: `/section/page/`
- ❌ Full URLs: `https://site.com/section/page/`

## When to Use This Guide

This fix applies when you have:

1. **Astro site with Starlight** documentation framework
2. **GitHub Pages deployment** (username.github.io/repository-name)
3. **Internal links returning 404** in production
4. **Links working locally** but breaking in GitHub Pages

## Recovery Commands

If you encounter this issue:

```bash
# 1. Check current configuration
grep -r "base:" docs/astro.config.mjs

# 2. Find broken absolute links
rg "]\(/[^)]*\)" docs/src/content/docs/

# 3. Test locally with base path
cd docs && npm run dev

# 4. Test production links
./tests/docs/test_production_links.sh

# 5. Fix patterns systematically
# - Homepage: absolute → relative (./)
# - Cross-refs: absolute → relative (../)
# - Sidebar: explicit → autogenerate
```

## Key Takeaways

1. **GitHub Pages base paths are complex** - they affect all internal link resolution
2. **Relative paths are safer** than absolute paths for internal links
3. **Always test both environments** - local and production behave differently
4. **Astro's autogenerate** handles base paths better than manual configuration
5. **Content collections require syncing** before building

This issue took multiple attempts because it involves understanding the interaction between Astro's base path configuration, GitHub Pages deployment patterns, and Starlight's link resolution behavior. Following this guide should prevent future occurrences.