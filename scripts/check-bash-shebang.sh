#!/usr/bin/env bash

# Pre-commit hook to check for hardcoded bash paths in shebangs
# Exit with 0 if all good, 1 if issues found

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

issues_found=0
files_checked=0

# Check all staged shell scripts
while IFS= read -r -d '' file; do
    # Skip if file doesn't exist (deleted)
    if [[ ! -f "$file" ]]; then
        continue
    fi

    # Check if it's a shell script
    if [[ "$file" == *.sh ]] || head -1 "$file" 2>/dev/null | grep -q "^#!.*sh"; then
        files_checked=$((files_checked + 1))

        # Get the shebang line
        shebang=$(head -1 "$file" 2>/dev/null || echo "")

        # Check for hardcoded bash paths
        if [[ "$shebang" == "#!/bin/bash" ]] || [[ "$shebang" == "#!/usr/bin/bash" ]]; then
            echo -e "${RED}ERROR:${NC} Hardcoded bash path in $file"
            echo -e "  Found: ${YELLOW}$shebang${NC}"
            echo -e "  Use:   ${GREEN}#!/usr/bin/env bash${NC}"
            echo ""
            issues_found=$((issues_found + 1))
        fi
    fi
done < <(git diff --cached --name-only -z)

if [[ $files_checked -eq 0 ]]; then
    exit 0
fi

if [[ $issues_found -gt 0 ]]; then
    echo -e "${RED}Found $issues_found file(s) with hardcoded bash paths${NC}"
    echo ""
    echo "Fix options:"
    echo "  1. Run: ${GREEN}./scripts/fix-shebangs.sh${NC}"
    echo "  2. Run: ${GREEN}make fix-shell${NC} (includes shebang fix)"
    echo "  3. Manually change to: ${GREEN}#!/usr/bin/env bash${NC}"
    echo ""
    echo "Why this matters:"
    echo "  - macOS ships with bash 3.2 from 2007 at /bin/bash"
    echo "  - Modern bash 5.2+ is installed via Nix at ~/.nix-profile/bin/bash"
    echo "  - Using 'env bash' finds the correct version in PATH"
    exit 1
else
    if [[ $files_checked -gt 0 ]]; then
        echo -e "${GREEN}✓${NC} All $files_checked shell script(s) use proper shebangs"
    fi
    exit 0
fi
