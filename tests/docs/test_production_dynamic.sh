#!/usr/bin/env bash
# Test production site using dynamically generated sitemap

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="https://garywu.github.io/dotfiles"
SITEMAP_FILE="${SITEMAP_FILE:-docs/sitemap.txt}"
MAX_RETRIES=3
TIMEOUT=10

echo "Testing Production Documentation Links"
echo "======================================"
echo ""

# Check if sitemap exists, otherwise fall back to defaults
if [[ -f $SITEMAP_FILE ]]; then
  echo "Using sitemap: $SITEMAP_FILE"
  readarray -t PAGES <"$SITEMAP_FILE"
else
  echo -e "${YELLOW}Warning: Sitemap not found, using default page list${NC}"
  PAGES=(
    "/"
    "/01-introduction/getting-started/"
    "/01-introduction/architecture-overview/"
    "/learning-paths/"
    "/reference/cli-utilities/"
    "/reference/package-inventory/"
  )
fi

echo "Testing ${#PAGES[@]} pages..."
echo ""

FAILED=0
PASSED=0
TIMEOUT_COUNT=0

# Function to test URL with retries
test_url() {
  local url="$1"
  local attempt=1

  while [[ $attempt -le $MAX_RETRIES ]]; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$url" 2>/dev/null || echo "000")

    if [[ $status_code == "200" ]]; then
      return 0
    elif [[ $status_code == "000" ]]; then
      ((attempt++)) || true
      [[ $attempt -le $MAX_RETRIES ]] && sleep 2
    else
      return 1
    fi
  done

  return 1
}

for page in "${PAGES[@]}"; do
  # Ensure trailing slash for directory URLs (GitHub Pages standard)
  normalized_page="$page"
  if [[ $page != "/" && ! $page =~ \.html$ ]]; then
    normalized_page="${page}/"
  fi
  url="${BASE_URL}${normalized_page}"
  printf "Testing %s..." "$normalized_page"

  # shellcheck disable=SC2310
  if test_url "$url" 2>/dev/null; then
    printf "\r%b✓%b %-50s\n" "$GREEN" "$NC" "$normalized_page"
    ((PASSED++)) || true
  else
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")
    if [[ $status_code == "000" ]]; then
      printf "\r%b✗%b %-50s (Timeout)\n" "$RED" "$NC" "$normalized_page"
      ((TIMEOUT_COUNT++)) || true
    else
      printf "\r%b✗%b %-50s (HTTP %s)\n" "$RED" "$NC" "$normalized_page" "$status_code"
    fi
    ((FAILED++)) || true
  fi
done

echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo "Total pages tested: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
[[ $TIMEOUT_COUNT -gt 0 ]] && echo -e "${YELLOW}Timeouts: $TIMEOUT_COUNT${NC}"

if [[ $FAILED -gt 0 ]]; then
  echo -e "\n${RED}Some pages are not accessible!${NC}"
  exit 1
else
  echo -e "\n${GREEN}All pages are accessible!${NC}"
  exit 0
fi
