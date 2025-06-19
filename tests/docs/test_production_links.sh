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

# List of pages to test (based on build output)
PAGES=(
    "/"
    "/01-introduction/getting-started/"
    "/01-introduction/architecture-overview/"
    "/02-platform-setup/macos/"
    "/02-platform-setup/ubuntu/"
    "/02-platform-setup/wsl2/"
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
    "/05-cli-tools-academy/"
    "/05-cli-tools-academy/modern-replacements/"
    "/06-ai-tools/"
    "/06-ai-tools/ollama/"
    "/06-ai-tools/openhands/"
    "/07-security/secrets-management/"
    "/07-security/security-policy/"
    "/08-development/contributing/"
    "/08-development/code-of-conduct/"
    "/08-development/ci-cd/"
    "/08-development/testing/"
    "/98-troubleshooting/homebrew-fish-config/"
    "/98-troubleshooting/git-email-privacy/"
    "/99-reference/command-cheatsheets/"
)

FAILED=0
PASSED=0

for page in "${PAGES[@]}"; do
    url="${BASE_URL}${page}"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")

    if [[ "$status_code" == "200" ]]; then
        echo -e "${GREEN}✓${NC} $page"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $page (HTTP $status_code)"
        ((FAILED++))
    fi
done

echo ""
echo "====================================="
echo "Test Summary"
echo "====================================="
echo "Total pages tested: $((PASSED + FAILED))"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Some pages are not accessible!${NC}"
    exit 1
else
    echo -e "${GREEN}All pages are accessible!${NC}"
fi
