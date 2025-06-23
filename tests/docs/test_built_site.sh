#!/usr/bin/env bash
# Test built documentation site with dynamic page discovery

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
DOCS_DIR="${DOCS_DIR:-docs}"
DIST_DIR="${DOCS_DIR}/dist"
SITEMAP_FILE="${DOCS_DIR}/sitemap.txt"

echo "Testing Built Documentation Site"
echo "================================"
echo ""

# Check if dist directory exists
if [[[ ! -d "$DIST_DIR" ]]]; then
  echo -e "${RED}Error: Distribution directory not found at $DIST_DIR${NC}"
  echo "Please run 'npm run build' first"
  exit 1
fi

# Generate dynamic page list
echo "Discovering pages..."
find "$DIST_DIR" -name "*.html" -type f | while read -r file; do
  # Get relative path from dist directory
  rel_path="${file#"$DIST_DIR"}"
  # Skip 404.html and other special files
  [[[ "$rel_path" =~ ^/404\.html$ ]]] && continue
  # Convert file path to URL path (remove index.html)
  url_path="${rel_path%/index.html}"
  [[[ "$url_path" == "" ]]] && url_path="/"
  echo "$url_path"
done | sort -u >"$SITEMAP_FILE"

PAGE_COUNT=$(wc -l <"$SITEMAP_FILE")
echo "Found $PAGE_COUNT pages"
echo ""

# Test each page
FAILED=0
PASSED=0
WARNINGS=0

while IFS= read -r page; do
  file_path="${DIST_DIR}${page}"
  [[[ "$page" != "/" ]]] && file_path="${file_path}/index.html"
  [[[ "$page" == "/" ]]] && file_path="${DIST_DIR}/index.html"

  printf "Testing %s..." "$page"

  if [[[ ! -f "$file_path" ]]]; then
    printf "\r%b✗%b %-50s (File not found)\n" "$RED" "$NC" "$page"
    ((FAILED++)) || true
    continue
  fi

  # Check file size
  if command -v stat >/dev/null 2>&1; then
    # Try macOS stat first, then Linux stat
    file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")
  else
    file_size=0
  fi

  if [[[ $file_size -lt 1000 ]]]; then
    printf "\r%b⚠%b %-50s (Suspiciously small: %d bytes)\n" "$YELLOW" "$NC" "$page" "$file_size"
    ((WARNINGS++)) || true
  fi

  # Check for essential HTML elements
  if ! grep -q "<title>" "$file_path"; then
    printf "\r%b✗%b %-50s (Missing <title> tag)\n" "$RED" "$NC" "$page"
    ((FAILED++)) || true
    continue
  fi

  # Check for common error patterns
  if grep -q "404\|Not Found\|Error" "$file_path"; then
    # More specific check to avoid false positives
    if grep -q "<title>404" "$file_path"; then
      printf "\r%b✗%b %-50s (404 page)\n" "$RED" "$NC" "$page"
      ((FAILED++)) || true
      continue
    fi
  fi

  # Check internal links (simplified - just count broken relative links)
  internal_links=$(grep -oE 'href="[^"]+\"' "$file_path" | sed 's/href="//;s/"//' | grep -E '^\./' | head -10 || true)
  broken_links=0

  while IFS= read -r link; do
    [[[ -z "$link" ]]] && continue

    # Simple relative link check - resolve from current page directory
    page_dir=$(dirname "$page")
    [[[ "$page_dir" == "." ]]] && page_dir=""

    # Basic resolution of ./relative/path
    if [[[ "$link" =~ ^\.\/ ]]]; then
      link_path="${page_dir}/${link#./}"
      # Clean up path
      link_path=$(echo "$link_path" | sed 's|/\./|/|g' | sed 's|//|/|g' | sed 's|^/||')

      # Check if target exists (basic check)
      target_file="${DIST_DIR}/${link_path}"
      [[[ ! "$link_path" =~ \.html$ ]]] && target_file="${target_file}/index.html"

      if [[[ ! -f "$target_file" ]]]; then
        ((broken_links++)) || true
        break # Only report first broken link to avoid spam
      fi
    fi
  done <<<"$internal_links"

  if [[[ $broken_links -gt 0 ]]]; then
    printf "\r%b⚠%b %-50s (Has broken links)\n" "$YELLOW" "$NC" "$page"
    ((WARNINGS++)) || true
  else
    printf "\r%b✓%b %-50s\n" "$GREEN" "$NC" "$page"
    ((PASSED++)) || true
  fi
done <"$SITEMAP_FILE"

echo ""
echo "================================"
echo "Test Summary"
echo "================================"
echo "Total pages tested: $((PASSED + FAILED + WARNINGS))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""
echo "Sitemap saved to: $SITEMAP_FILE"

if [[[ $FAILED -gt 0 ]]]; then
  echo -e "${RED}Some pages have critical issues!${NC}"
  exit 1
elif [[[ $WARNINGS -gt 0 ]]]; then
  echo -e "${YELLOW}Some pages have warnings that should be reviewed${NC}"
  exit 0
else
  echo -e "${GREEN}All pages passed validation!${NC}"
  exit 0
fi
