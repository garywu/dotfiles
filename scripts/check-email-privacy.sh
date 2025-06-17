#!/usr/bin/env bash
# Check for potential email exposure in commits and files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Email patterns to check (customize as needed)
EMAIL_PATTERNS=(
    # Common personal email domains
    '@gmail\.com'
    '@yahoo\.com'
    '@hotmail\.com'
    '@outlook\.com'
    '@icloud\.com'
    '@me\.com'
    '@mac\.com'
    # Generic pattern for email addresses (but allow noreply addresses)
    '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
)

# Allowed email patterns (won't trigger warnings)
ALLOWED_PATTERNS=(
    '@users\.noreply\.github\.com'
    '@example\.com'
    'your\.email@example\.com'
    'user@example\.com'
    'admin@example\.com'
    'noreply@'
    'no-reply@'
)

# Check if an email is allowed
is_allowed_email() {
    local email="$1"
    for pattern in "${ALLOWED_PATTERNS[@]}"; do
        if echo "$email" | grep -qE "$pattern"; then
            return 0
        fi
    done
    return 1
}

# Check staged files for email addresses
check_staged_files() {
    local found_issues=0

    echo "Checking staged files for email addresses..."

    # Get list of staged files
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM)

    if [[ -z "$staged_files" ]]; then
        echo "No staged files to check."
        return 0
    fi

    while IFS= read -r file; do
        if [[ ! -f "$file" ]]; then
            continue
        fi

        # Skip binary files
        if file "$file" | grep -q "binary"; then
            continue
        fi

        # Check for email patterns
        for pattern in "${EMAIL_PATTERNS[@]}"; do
            matches=$(grep -nE "$pattern" "$file" 2>/dev/null || true)
            if [[ -n "$matches" ]]; then
                while IFS= read -r match; do
                    # Extract the email from the match
                    email=$(echo "$match" | grep -oE "$pattern" | head -1)

                    # Check if it's an allowed email
                    if ! is_allowed_email "$email"; then
                        echo -e "${RED}Potential email exposure in $file:${NC}"
                        echo "$match"
                        found_issues=1
                    fi
                done <<< "$matches"
            fi
        done
    done <<< "$staged_files"

    return $found_issues
}

# Check commit message for email addresses
check_commit_message() {
    local commit_msg_file="$1"
    local found_issues=0

    echo "Checking commit message for email addresses..."

    if [[ ! -f "$commit_msg_file" ]]; then
        return 0
    fi

    for pattern in "${EMAIL_PATTERNS[@]}"; do
        matches=$(grep -nE "$pattern" "$commit_msg_file" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            while IFS= read -r match; do
                email=$(echo "$match" | grep -oE "$pattern" | head -1)
                if ! is_allowed_email "$email"; then
                    echo -e "${RED}Potential email exposure in commit message:${NC}"
                    echo "$match"
                    found_issues=1
                fi
            done <<< "$matches"
        fi
    done

    return $found_issues
}

# Main execution
main() {
    local mode="${1:-files}"
    local found_issues=0

    case "$mode" in
        "files")
            check_staged_files || found_issues=1
            ;;
        "commit-msg")
            check_commit_message "${2:-}" || found_issues=1
            ;;
        *)
            echo "Usage: $0 [files|commit-msg] [commit-msg-file]"
            exit 1
            ;;
    esac

    if [[ $found_issues -eq 1 ]]; then
        echo -e "\n${YELLOW}⚠️  Warning: Potential email exposure detected!${NC}"
        echo "Consider using GitHub's privacy email: username@users.noreply.github.com"
        echo "Or add the email to ALLOWED_PATTERNS in this script if it's intentional."
        echo -e "\n${YELLOW}To bypass this check (not recommended), use --no-verify${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ No email privacy issues found.${NC}"
    fi
}

main "$@"
