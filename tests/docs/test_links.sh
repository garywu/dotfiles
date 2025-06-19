#!/usr/bin/env bash
# Test suite for documentation site links

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Base configuration
DOCS_DIR="${DOCS_DIR:-docs}"
BASE_URL="${BASE_URL:-http://localhost:4321}"
SITE_BASE="/dotfiles" # GitHub Pages base path
FAILED_LINKS=()
TOTAL_LINKS=0
VALID_LINKS=0

echo "Documentation Link Test Suite"
echo "============================"
echo ""

# Function to check if URL is valid
check_url() {
  local url="$1"
  local status_code

  # For local testing, use curl
  if [[ "$url" =~ ^http ]]; then
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$status_code" == "200" ]]; then
      return 0
    else
      return 1
    fi
  else
    # For file paths, check if file exists
    if [[ -f "$url" ]]; then
      return 0
    else
      return 1
    fi
  fi
}

# Function to extract links from HTML files
extract_links() {
  local file="$1"
  # Extract href links, excluding anchors and external URLs
  grep -oE 'href="[^"#]+"' "$file" 2>/dev/null |
    sed 's/href="//;s/"$//' |
    grep -v '^https://' |
    grep -v '^http://' |
    grep -v '^#' |
    grep -v '^mailto:' |
    grep -v '^data:' |
    grep -v '\.xml$' |
    grep -v '\.svg$' |
    grep -v '\.ico$' |
    grep -v '_astro/' |
    sort -u
}

# Function to test all links in a file
test_file_links() {
  local file="$1"
  local base_path="$2"
  local links

  echo -e "${YELLOW}Testing: ${file}${NC}"

  set +e
  links=$(extract_links "$file")
  set -e
  if [[ -z "$links" ]]; then
    links=""
  fi

  if [[ -z "$links" ]]; then
    echo "  No internal links found"
    return
  fi

  while IFS= read -r link; do
    ((TOTAL_LINKS++))

    # Handle relative links
    if [[ "$link" =~ ^/dotfiles/ ]]; then
      # Already has base path
      full_url="${BASE_URL}${link}"
    elif [[ "$link" =~ ^/ ]]; then
      # Absolute path from site root - need to add base path
      full_url="${BASE_URL}${SITE_BASE}${link}"
    else
      # Relative to current file
      dir=$(dirname "$base_path")
      full_url="${BASE_URL}${SITE_BASE}${dir}/${link}"
    fi

    if check_url "$full_url"; then
      echo -e "  ${GREEN}✓${NC} $link"
      ((VALID_LINKS++))
    else
      echo -e "  ${RED}✗${NC} $link -> $full_url"
      FAILED_LINKS+=("$file: $link")
    fi
  done <<<"$links"
}

# Function to build and start dev server
start_dev_server() {
  echo "Building documentation site..."
  cd "$DOCS_DIR"
  npm run build || {
    echo -e "${RED}Build failed!${NC}"
    exit 1
  }

  echo "Starting development server..."
  npm run preview &
  SERVER_PID=$!

  # Wait for server to start
  echo "Waiting for server to start..."
  for _ in {1..30}; do
    if curl -s "$BASE_URL$SITE_BASE/" >/dev/null; then
      echo -e "${GREEN}Server started successfully${NC}"
      break
    fi
    sleep 1
  done

  cd - >/dev/null
}

# Function to stop dev server
stop_dev_server() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    echo "Stopping development server..."
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}

# Trap to ensure server is stopped
trap stop_dev_server EXIT

# Main test execution
main() {
  local mode="${1:-local}"

  if [[ "$mode" == "local" ]]; then
    start_dev_server
  elif [[ "$mode" == "production" ]]; then
    BASE_URL="https://garywu.github.io/dotfiles"
    echo "Testing production site: $BASE_URL"
  fi

  echo ""
  echo "Testing all documentation links..."
  echo ""

  # Find all HTML files in the built site
  if [[ "$mode" == "local" ]]; then
    html_files=$(find "$DOCS_DIR/dist" -name "*.html" -type f)
  else
    # For production, we need to test known pages
    # This would need to be expanded based on sitemap
    echo "Production testing not fully implemented yet"
    exit 1
  fi

  # Test each file
  while IFS= read -r file; do
    # Get relative path from dist directory
    rel_path=${file#"$DOCS_DIR/dist"}
    test_file_links "$file" "$rel_path"
    echo ""
  done <<<"$html_files"

  # Summary
  echo "============================"
  echo "Test Summary"
  echo "============================"
  echo "Total links tested: $TOTAL_LINKS"
  echo "Valid links: $VALID_LINKS"
  echo "Failed links: ${#FAILED_LINKS[@]}"

  if [[ ${#FAILED_LINKS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Failed links:${NC}"
    for link in "${FAILED_LINKS[@]}"; do
      echo "  - $link"
    done
    exit 1
  else
    echo -e "${GREEN}All links are valid!${NC}"
  fi
}

# Run tests
main "${1:-local}"
