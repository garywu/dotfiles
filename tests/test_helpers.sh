#!/bin/bash
# Test Helper Functions
# Common functions used across all test suites

# Colors (re-exported for test scripts)
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# Print functions
print_header() {
  if [[ "$QUIET" != "true" ]]; then
    echo -e "${BLUE}=== $1 ===${NC}"
  fi
}

print_section() {
  if [[ "$QUIET" != "true" ]]; then
    echo -e "${BLUE}--- $1 ---${NC}"
  fi
}

print_test_header() {
  if [[ "$QUIET" != "true" ]]; then
    echo -e "${BLUE}[TEST] $1${NC}"
  fi
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

print_info() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo -e "$1"
  fi
}

# Test assertion functions
assert_command_exists() {
  local cmd=$1
  local name=${2:-$1}

  if command -v "$cmd" &>/dev/null; then
    print_info "✓ $name is installed"
    return 0
  else
    print_error "✗ $name is NOT installed"
    return 1
  fi
}

assert_directory_exists() {
  local dir=$1
  local name=$2

  if [[ -d "$dir" ]]; then
    print_info "✓ $name exists at $dir"
    return 0
  else
    print_error "✗ $name does NOT exist at $dir"
    return 1
  fi
}

assert_file_exists() {
  local file=$1
  local name=$2

  if [[ -f "$file" ]]; then
    print_info "✓ $name exists at $file"
    return 0
  else
    print_error "✗ $name does NOT exist at $file"
    return 1
  fi
}

assert_symlink_exists() {
  local link=$1
  local name=$2

  if [[ -L "$link" ]]; then
    print_info "✓ $name symlink exists at $link"
    return 0
  else
    print_error "✗ $name symlink does NOT exist at $link"
    return 1
  fi
}

assert_path_contains() {
  local path_component=$1
  local description=$2

  if echo "$PATH" | grep -q "$path_component"; then
    print_info "✓ PATH contains $description"
    return 0
  else
    print_error "✗ PATH does NOT contain $description"
    return 1
  fi
}

assert_not_exists() {
  local path=$1
  local name=$2

  if [[ ! -e "$path" ]]; then
    print_info "✓ $name does not exist (as expected)"
    return 0
  else
    print_error "✗ $name still exists at $path"
    return 1
  fi
}

# Platform detection
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname)" == "Linux" ]]
}

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

# CI helpers
is_ci() {
  [[ "${CI:-}" == "true" ]] || [[ "${GITHUB_ACTIONS:-}" == "true" ]]
}

# Skip test function
skip_test() {
  local reason=$1
  print_warning "SKIPPED: $reason"
  ((TESTS_SKIPPED++))
  exit 0
}

# Setup and teardown helpers
setup_test_environment() {
  # Create temporary test directory
  export TEST_TEMP_DIR=$(mktemp -d)
  print_info "Created temp dir: $TEST_TEMP_DIR"
}

teardown_test_environment() {
  # Clean up temporary test directory
  if [[ -n "${TEST_TEMP_DIR:-}" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
    rm -rf "$TEST_TEMP_DIR"
    print_info "Cleaned up temp dir"
  fi
}

# Trap to ensure cleanup on exit
trap teardown_test_environment EXIT
