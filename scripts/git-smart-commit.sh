#!/usr/bin/env bash
# git-smart-commit.sh - Smart commit with automatic pre-commit fixes

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Check if we have changes to commit
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${YELLOW}No changes to commit${NC}"
    exit 0
fi

# Run pre-commit fixes
echo -e "${GREEN}Running pre-commit fixes...${NC}"
if [[ -f scripts/pre-commit-fix.sh ]]; then
    ./scripts/pre-commit-fix.sh
elif command -v make &> /dev/null && grep -q "pre-commit-fix:" Makefile 2>/dev/null; then
    make pre-commit-fix
else
    # Fallback to basic fixes
    echo "Running basic fixes..."
    # Fix trailing whitespace
    find . -type f \( -name "*.sh" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -print0 | \
        xargs -0 -I {} sed -i.bak 's/[[:space:]]*$//' {} && \
        find . -name "*.bak" -delete

    # Add newline at end of files
    find . -type f \( -name "*.sh" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -print0 | \
        while IFS= read -r -d '' file; do
            if [[ -n $(tail -c 1 "$file") ]]; then
                echo >> "$file"
            fi
        done
fi

# Stage all changes (including fixes)
git add -A

# Show what will be committed
echo -e "\n${GREEN}Changes to be committed:${NC}"
git status --short

# Commit with user's message
if [[ $# -eq 0 ]]; then
    echo -e "\n${YELLOW}Usage: $0 \"commit message\"${NC}"
    echo "Or use with git alias: git smart-commit \"commit message\""
    exit 1
fi

# Try to commit
echo -e "\n${GREEN}Committing...${NC}"
if git commit -m "$*"; then
    echo -e "${GREEN}✓ Commit successful!${NC}"
else
    echo -e "${RED}✗ Commit failed${NC}"
    echo -e "${YELLOW}If pre-commit hooks are still failing, you can:${NC}"
    echo "  1. Fix the specific issues shown above"
    echo "  2. Run: git commit --no-verify -m \"$*\" (use sparingly!)"
    exit 1
fi
