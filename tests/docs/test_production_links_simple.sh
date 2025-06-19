#!/usr/bin/env bash
# Simple test for production documentation links

set -euo pipefail

BASE_URL="https://garywu.github.io/dotfiles"
FAILED=0

echo "Testing Production Documentation Links"
echo "====================================="

# Test a few key pages
echo -n "Testing homepage... "
if curl -fs --max-time 5 "$BASE_URL/" > /dev/null; then
    echo "✓"
else
    echo "✗"
    ((FAILED++))
fi

echo -n "Testing getting started... "
if curl -fs --max-time 5 "$BASE_URL/01-introduction/getting-started/" > /dev/null; then
    echo "✓"
else
    echo "✗"
    ((FAILED++))
fi

echo -n "Testing CLI tools... "
if curl -fs --max-time 5 "$BASE_URL/03-cli-tools/modern-replacements/" > /dev/null; then
    echo "✓"
else
    echo "✗"
    ((FAILED++))
fi

echo -n "Testing troubleshooting docs... "
if curl -fs --max-time 5 "$BASE_URL/98-troubleshooting/git-email-privacy/" > /dev/null; then
    echo "✓"
else
    echo "✗"
    ((FAILED++))
fi

echo ""
echo "====================================="
if [[ $FAILED -eq 0 ]]; then
    echo "All key pages are accessible!"
    exit 0
else
    echo "Some pages failed!"
    exit 1
fi
