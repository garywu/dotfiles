#!/bin/bash
# Test script to verify bootstrap installation

# Note: set -e disabled to allow test functions to fail gracefully
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test a command exists
test_command() {
    local cmd="$1"
    local name="${2:-$1}"

    if command -v "${cmd}" &>/dev/null; then
        echo -e "${GREEN}✓${NC} ${name} is installed"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} ${name} is NOT installed"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test a directory exists
test_directory() {
    local dir="$1"
    local name="$2"

    if [[ -d "${dir}" ]]; then
        echo -e "${GREEN}✓${NC} ${name} exists at ${dir}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} ${name} does NOT exist at ${dir}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test a file exists
test_file() {
    local file="$1"
    local name="$2"

    if [[ -f "${file}" ]]; then
        echo -e "${GREEN}✓${NC} ${name} exists at ${file}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} ${name} does NOT exist at ${file}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "=== Bootstrap Installation Test ==="
echo "Testing on: $(uname -s || true)"
echo ""

# Source Nix environment if available
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]]; then
    # shellcheck source=/dev/null
    source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi

echo "=== Core Tools ==="
# Test Nix
test_command "nix" "Nix"
test_directory "/nix" "Nix store"

# Test Home Manager
test_command "home-manager" "Home Manager"
test_directory "${HOME}/.config/home-manager" "Home Manager config"

# Test Chezmoi
test_command "chezmoi" "Chezmoi"

# Platform-specific tests
if [[ "$(uname || true)" == "Darwin" ]]; then
    echo ""
    echo "=== macOS-specific Tools ==="
    test_command "brew" "Homebrew"
    if ! test_directory "/opt/homebrew" "Homebrew directory"; then
        test_directory "/usr/local/Homebrew" "Homebrew directory"
    fi
fi

echo ""
echo "=== Shell and Terminal Tools ==="
test_command "fish" "Fish shell"
test_command "starship" "Starship prompt"
test_directory "${HOME}/.config/fish" "Fish config"
if ! test_directory "${HOME}/.config/starship" "Starship config"; then
    test_file "${HOME}/.config/starship.toml" "Starship config"
fi

echo ""
echo "=== Development Tools ==="
# Test common CLI tools that should be installed
test_command "eza" "eza (ls replacement)"
test_command "bat" "bat (cat replacement)"
test_command "fd" "fd (find replacement)"
test_command "rg" "ripgrep"
test_command "fzf" "fzf"
test_command "tmux" "tmux"
test_command "htop" "htop"

echo ""
echo "=== Configuration Files ==="
if ! test_file "${HOME}/.config/home-manager/home.nix" "Home Manager home.nix"; then
    test_file "${HOME}/.dotfiles/nix/home.nix" "Dotfiles home.nix"
fi

echo ""
echo "=== Summary ==="
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"

if [[ ${TESTS_FAILED} -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
