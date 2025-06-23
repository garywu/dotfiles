#!/usr/bin/env bash
# Test production documentation links

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
# YELLOW='\033[0;33m'  # Not used in this script
NC='\033[0m' # No Color

# Base URL for GitHub Pages
BASE_URL="https://garywu.github.io/dotfiles"

echo "Testing Production Documentation Links"
echo "====================================="
echo ""

# List of pages to test (based on current site structure)
PAGES=(
  "/"
  "/01-introduction/getting-started/"
  "/01-introduction/architecture-overview/"
  "/02-platform-setup/macos/"
  "/02-platform-setup/ubuntu/"
  "/02-platform-setup/wsl2/"
  "/03-cli-tools/"
  "/03-cli-tools/modern-replacements/"
  "/03-cli-tools/password-management/"
  "/03-cli-tools/efficiency-testing/"
  "/03-cli-tools/session-patterns/"
  "/03-cli-tools/usage-gallery/"
  "/03-cli-tools/code-golf/"
  "/03-cli-tools/golf-challenges/"
  "/03-cli-tools/community-patterns/"
  "/04-terminal-workflow/tmux/"
  "/05-ai-development/ollama/"
  "/05-ai-development/chatblade/"
  "/06-ai-tools/"
  "/06-ai-tools/ollama/"
  "/06-ai-tools/openhands/"
  "/07-security/secrets-management/"
  "/07-security/security-policy/"
  "/08-development/ci-cd/"
  "/08-development/code-of-conduct/"
  "/08-development/contributing/"
  "/08-development/testing/"
  "/98-troubleshooting/homebrew-fish-config/"
  "/98-troubleshooting/git-email-privacy/"
  "/99-reference/command-cheatsheets/"
  "/learning-paths/"
  "/reference/cli-utilities/"
  "/reference/package-inventory/"
)

FAILED=0
PASSED=0

for page in "${PAGES[@]}"; do
  url="${BASE_URL}${page}"
  printf "Testing %s..." "$page"
  # Use true to prevent exit on curl failure due to set -e
  status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")

  if [[[[[ "$status_code" == "200" ]]]]]; then
    printf "\r%b✓%b %-50s\n" "$GREEN" "$NC" "$page"
    ((PASSED++)) || true
  else
    printf "\r%b✗%b %-50s (HTTP %s)\n" "$RED" "$NC" "$page" "$status_code"
    ((FAILED++)) || true
  fi
done

echo ""
echo "====================================="
echo "Test Summary"
echo "====================================="
echo "Total pages tested: $((PASSED + FAILED))"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [[[[[ $FAILED -gt 0 ]]]]]; then
  printf "%bSome pages are not accessible!%b\n" "$RED" "$NC"
  exit 1
else
  printf "%bAll pages are accessible!%b\n" "$GREEN" "$NC"
fi
