#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if running in git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    print_error "Not in a git repository"
    exit 1
fi

# Get the latest version from CHANGELOG.md
latest_version=$(grep -m 1 '^## \[[0-9]' CHANGELOG.md | sed 's/^## \[\(.*\)\].*/\1/')

# Get all commits since the last version
commits=$(git log --pretty=format:"%s" $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD)

# Categorize commits
added=()
fixed=()
changed=()
removed=()
deprecated=()
security=()
other=()

while IFS= read -r commit; do
    case "$commit" in
        feat*|feat!*|feat\(*\)*)
            added+=("$commit")
            ;;
        fix*|fix!*|fix\(*\)*)
            fixed+=("$commit")
            ;;
        perf*|perf!*|perf\(*\)*)
            changed+=("$commit")
            ;;
        refactor*|refactor!*|refactor\(*\)*)
            changed+=("$commit")
            ;;
        style*|style!*|style\(*\)*)
            changed+=("$commit")
            ;;
        chore*|chore!*|chore\(*\)*)
            other+=("$commit")
            ;;
        docs*|docs!*|docs\(*\)*)
            other+=("$commit")
            ;;
        test*|test!*|test\(*\)*)
            other+=("$commit")
            ;;
        build*|build!*|build\(*\)*)
            other+=("$commit")
            ;;
        ci*|ci!*|ci\(*\)*)
            other+=("$commit")
            ;;
        revert*|revert!*|revert\(*\)*)
            other+=("$commit")
            ;;
        *)
            other+=("$commit")
            ;;
    esac
done <<< "$commits"

# Update CHANGELOG.md
print_status "Updating CHANGELOG.md..."

# Create temporary file
temp_file=$(mktemp)

# Write header
cat > "$temp_file" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF

# Write categorized changes
if [ ${#added[@]} -gt 0 ]; then
    echo "### Added" >> "$temp_file"
    for commit in "${added[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

if [ ${#fixed[@]} -gt 0 ]; then
    echo "### Fixed" >> "$temp_file"
    for commit in "${fixed[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

if [ ${#changed[@]} -gt 0 ]; then
    echo "### Changed" >> "$temp_file"
    for commit in "${changed[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

if [ ${#removed[@]} -gt 0 ]; then
    echo "### Removed" >> "$temp_file"
    for commit in "${removed[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

if [ ${#deprecated[@]} -gt 0 ]; then
    echo "### Deprecated" >> "$temp_file"
    for commit in "${deprecated[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

if [ ${#security[@]} -gt 0 ]; then
    echo "### Security" >> "$temp_file"
    for commit in "${security[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

if [ ${#other[@]} -gt 0 ]; then
    echo "### Other" >> "$temp_file"
    for commit in "${other[@]}"; do
        echo "- $commit" >> "$temp_file"
    done
    echo "" >> "$temp_file"
fi

# Append existing changelog content
sed -n '/^## \[[0-9]/,$p' CHANGELOG.md >> "$temp_file"

# Replace original file
mv "$temp_file" CHANGELOG.md

print_status "Changelog updated successfully!"
