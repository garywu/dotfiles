#!/usr/bin/env bash
# Test documentation link patterns to prevent regressions
# This specifically tests the patterns that caused GitHub Pages + Astro issues

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOCS_DIR="${DOCS_DIR:-docs}"
CONTENT_DIR="$DOCS_DIR/src/content/docs"
CONFIG_FILE="$DOCS_DIR/astro.config.mjs"

ERRORS=0
WARNINGS=0

echo -e "${BLUE}Documentation Link Pattern Validation${NC}"
echo "======================================="
echo ""

# Function to report error
error() {
  echo -e "${RED}✗ ERROR: $1${NC}"
  ((ERRORS++))
}

# Function to report warning
warning() {
  echo -e "${YELLOW}⚠ WARNING: $1${NC}"
  ((WARNINGS++))
}

# Function to report success
success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# Function to report info
info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

# Test 1: Check Astro base configuration
test_astro_base_config() {
  info "Testing Astro base path configuration..."

  if [[[ ! -f "$CONFIG_FILE" ]]]; then
    error "Astro config file not found: $CONFIG_FILE"
    return
  fi

  # Check for base configuration
  if grep -q "base:" "$CONFIG_FILE"; then
    local base_value
    base_value=$(grep "base:" "$CONFIG_FILE" | head -1)
    echo "  Found: $base_value"

    # Validate base path format
    if echo "$base_value" | grep -q 'base: ['\''"]\/[^\/]'; then
      success "Base path correctly configured"
    else
      error "Base path format incorrect. Should be '/repository-name'"
    fi
  else
    error "No base path configured in astro.config.mjs"
  fi
}

# Test 2: Scan for problematic absolute link patterns
test_absolute_link_patterns() {
  info "Scanning for problematic absolute link patterns..."

  local problematic_files=()

  # Find markdown files with absolute internal links
  while IFS= read -r -d '' file; do
    if grep -q '\]\(/[^)]*\)' "$file"; then
      problematic_files+=("$file")
    fi
  done < <(find "$CONTENT_DIR" \( -name "*.md" -o -name "*.mdx" \) -print0 2>/dev/null || true)

  if [[ ${#problematic_files[@]} -eq 0 ]]; then
    success "No problematic absolute links found in content"
  else
    error "Found ${#problematic_files[@]} files with absolute internal links:"
    for file in "${problematic_files[@]}"; do
      echo "    $file"
      grep -n '\]\(/[^)]*\)' "$file" | head -3 | while IFS= read -r line; do
        echo "      $line"
      done
    done
    echo ""
    echo "  These should use relative paths instead:"
    echo "  ❌ [Link](/section/page/) -> ✅ [Link](./section/page/) or [Link](../section/page/)"
  fi
}

# Test 3: Check homepage action button configurations
test_homepage_action_links() {
  info "Testing homepage action button link patterns..."

  # Check astro.config.mjs for action links
  if grep -A 10 -B 2 "actions:" "$CONFIG_FILE" | grep -q "link:.*'/"; then
    error "Found absolute paths in homepage action buttons"
    grep -A 10 -B 2 "actions:" "$CONFIG_FILE" | grep "link:" | while IFS= read -r line; do
      echo "    $line"
    done
    echo "  These should use relative paths: link: './section/page/'"
  else
    success "Homepage action links use proper relative paths"
  fi

  # Check index.mdx for action links
  local index_file="$CONTENT_DIR/index.mdx"
  if [[[ -f "$index_file" ]]] && grep -A 5 -B 2 "actions:" "$index_file" | grep -q "link:.*'/"; then
    error "Found absolute paths in index.mdx action buttons"
    grep -A 5 -B 2 "actions:" "$index_file" | grep "link:" | while IFS= read -r line; do
      echo "    $line"
    done
  fi
}

# Test 4: Validate sidebar configuration
test_sidebar_configuration() {
  info "Testing sidebar configuration patterns..."

  # Check for manual sidebar links vs autogenerate
  if grep -A 20 "sidebar:" "$CONFIG_FILE" | grep -q "link:"; then
    warning "Manual sidebar links found - consider using autogenerate for better base path handling"
    grep -A 20 "sidebar:" "$CONFIG_FILE" | grep "link:" | head -3 | while IFS= read -r line; do
      echo "    $line"
    done
  else
    success "Sidebar uses autogenerate (recommended for base path compatibility)"
  fi
}

# Test 5: Check for GitHub Pages deployment requirements
test_github_pages_requirements() {
  info "Testing GitHub Pages deployment requirements..."

  # Check for package.json build script
  local package_file="$DOCS_DIR/package.json"
  if [[[ -f "$package_file" ]]]; then
    if grep -q '"build".*astro sync' "$package_file"; then
      success "Build script includes astro sync"
    else
      warning "Build script should include 'astro sync' before 'astro build'"
    fi
  else
    error "Package.json not found in docs directory"
  fi

  # Check for GitHub Pages workflow
  local workflow_file=".github/workflows/deploy-docs.yml"
  if [[[ -f "$workflow_file" ]]]; then
    success "GitHub Pages deployment workflow exists"

    # Check if it builds correctly
    if grep -q "npm run build" "$workflow_file"; then
      success "Workflow uses npm run build"
    else
      warning "Workflow should use npm run build (which includes astro sync)"
    fi
  else
    error "GitHub Pages deployment workflow not found"
  fi
}

# Test 6: Validate cross-reference patterns
test_cross_reference_patterns() {
  info "Testing cross-reference link patterns..."

  local invalid_patterns=0

  # Check for references to deleted sections (most important check)
  if grep -r '/05-cli-tools-academy/' "$CONTENT_DIR" --include="*.md" >/dev/null 2>&1; then
    ((invalid_patterns++))
    echo "  Found references to deleted /05-cli-tools-academy/ section"
  fi

  # Check for absolute AI tools references
  if grep -r '](/06-ai-tools/' "$CONTENT_DIR" --include="*.md" >/dev/null 2>&1; then
    ((invalid_patterns++))
    echo "  Found absolute cross-references in AI tools"
  fi

  if [[[ $invalid_patterns -eq 0 ]]]; then
    success "Cross-reference patterns are valid"
  else
    error "Found $invalid_patterns types of invalid cross-reference patterns"
  fi
}

# Test 7: Test local build validation
test_local_build() {
  info "Testing local build process..."

  if [[[ ! -d "$DOCS_DIR/node_modules" ]]]; then
    warning "Node modules not installed - run 'npm install' in docs directory"
    return
  fi

  # Check if dist directory exists (previous build)
  if [[[ -d "$DOCS_DIR/dist" ]]]; then
    # Check if critical files exist
    if [[[ -f "$DOCS_DIR/dist/index.html" ]]]; then
      success "Previous build found - homepage exists"

      # Check for base path in generated files
      if grep -q '/dotfiles/' "$DOCS_DIR/dist/index.html" 2>/dev/null; then
        success "Base path correctly applied in build"
      else
        warning "Base path may not be correctly applied"
      fi
    else
      warning "Dist directory exists but homepage not found"
    fi
  else
    warning "No previous build found - run 'npm run build' in docs directory to test"
  fi
}

# Test 8: Validate specific problematic patterns from previous issues
test_known_problem_patterns() {
  info "Testing for known problematic patterns..."

  # Pattern 1: Homepage action buttons with absolute paths
  if grep -r "link: ['\"]/" "$DOCS_DIR" --include="*.mjs" --include="*.mdx"; then
    error "Found absolute paths in action buttons (known GitHub Pages issue)"
  else
    success "No absolute paths in action buttons"
  fi

  # Pattern 2: Cross-references to deleted sections
  if grep -r "/05-cli-tools-academy/" "$CONTENT_DIR" --include="*.md" 2>/dev/null; then
    error "Found references to deleted /05-cli-tools-academy/ section"
  else
    success "No references to deleted sections"
  fi

  # Pattern 3: Missing relative path indicators
  local missing_relative=()
  while IFS= read -r -d '' file; do
    if grep -q '\](/' "$file" && ! grep -q '\](\.\/' "$file" && ! grep -q '\](\.\.\/' "$file"; then
      missing_relative+=("$file")
    fi
  done < <(find "$CONTENT_DIR" -name "*.md" -print0 2>/dev/null || true)

  if [[ ${#missing_relative[@]} -gt 0 ]]; then
    warning "Files potentially missing relative path indicators:"
    for file in "${missing_relative[@]:0:3}"; do # Show first 3
      echo "    $(basename "$file")"
    done
  fi
}

# Main test execution
main() {
  echo "Starting comprehensive link pattern validation..."
  echo ""

  test_astro_base_config
  echo ""
  test_absolute_link_patterns
  echo ""
  test_homepage_action_links
  echo ""
  test_sidebar_configuration
  echo ""
  test_github_pages_requirements
  echo ""
  test_cross_reference_patterns
  echo ""
  test_local_build
  echo ""
  test_known_problem_patterns
  echo ""

  # Summary
  echo "======================================="
  echo "Validation Summary"
  echo "======================================="
  echo "Errors: $ERRORS"
  echo "Warnings: $WARNINGS"

  if [[[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]]; then
    echo -e "${GREEN}✓ All link patterns are valid!${NC}"
    echo "Documentation should deploy correctly to GitHub Pages."
  elif [[[ $ERRORS -eq 0 ]]]; then
    echo -e "${YELLOW}⚠ Minor warnings found but no critical errors${NC}"
    echo "Documentation should deploy correctly but consider addressing warnings."
  else
    echo -e "${RED}✗ Critical errors found!${NC}"
    echo "Fix these errors before deploying to prevent link issues."
    exit 1
  fi
}

# Run validation
main "$@"
