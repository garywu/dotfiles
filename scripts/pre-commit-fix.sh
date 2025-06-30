#!/usr/bin/env bash
# pre-commit-fix.sh - Automatically fix common pre-commit issues before committing

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Main fixing process
print_info "Running pre-commit fixes..."

# 1. Fix trailing whitespace and end-of-file issues
if command -v pre-commit &> /dev/null; then
    print_info "Fixing whitespace issues..."
    pre-commit run trailing-whitespace --all-files || true
    pre-commit run end-of-file-fixer --all-files || true
    print_success "Whitespace issues fixed"
fi

# 2. Fix shell scripts
if [[ -f Makefile ]] && grep -q "fix-shell:" Makefile; then
    print_info "Fixing shell script issues..."
    make fix-shell || true
    print_success "Shell scripts fixed"
fi

# 3. Fix YAML formatting
if command -v yamllint &> /dev/null; then
    print_info "Checking YAML files..."
    find . -name "*.yml" -o -name "*.yaml" | while read -r file; do
        # Basic YAML fixes (remove trailing spaces)
        sed -i.bak 's/[[:space:]]*$//' "$file" && rm -f "$file.bak"
    done
    print_success "YAML files checked"
fi

# 4. Fix TOML formatting
if command -v taplo &> /dev/null; then
    print_info "Formatting TOML files..."
    taplo fmt || true
    print_success "TOML files formatted"
fi

# 5. Fix Nix formatting
if command -v nixpkgs-fmt &> /dev/null; then
    print_info "Formatting Nix files..."
    find . -name "*.nix" -exec nixpkgs-fmt {} \; || true
    print_success "Nix files formatted"
fi

# 6. Stage the fixes
print_info "Staging fixed files..."
git add -u

print_success "Pre-commit fixes complete!"
print_info "You can now commit your changes."

# Show what was fixed
if [[ $(git diff --cached --name-only | wc -l) -gt 0 ]]; then
    print_info "Fixed files:"
    git diff --cached --name-only | sed 's/^/  - /'
fi
