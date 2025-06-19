#!/bin/bash
# Test Runner for Dotfiles
# This script runs all tests or specific test suites

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source test helpers
source "$SCRIPT_DIR/test_helpers.sh"

# Function to print usage
usage() {
  echo "Usage: $0 [OPTIONS] [TEST_SUITE]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -v, --verbose    Enable verbose output"
  echo "  -q, --quiet      Suppress non-error output"
  echo "  --ci             Run in CI mode (non-interactive)"
  echo ""
  echo "Test Suites:"
  echo "  all              Run all tests (default)"
  echo "  bootstrap        Run bootstrap tests"
  echo "  cleanup          Run cleanup/unbootstrap tests"
  echo "  integration      Run integration tests"
  echo "  unit             Run unit tests"
  echo ""
  echo "Examples:"
  echo "  $0                    # Run all tests"
  echo "  $0 bootstrap          # Run only bootstrap tests"
  echo "  $0 --ci all          # Run all tests in CI mode"
}

# Parse command line arguments
VERBOSE=false
QUIET=false
CI_MODE=false
TEST_SUITE="all"

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -v | --verbose)
    VERBOSE=true
    shift
    ;;
  -q | --quiet)
    QUIET=true
    shift
    ;;
  --ci)
    CI_MODE=true
    export CI=true
    shift
    ;;
  all | bootstrap | cleanup | integration | unit)
    TEST_SUITE=$1
    shift
    ;;
  *)
    echo "Unknown option: $1"
    usage
    exit 1
    ;;
  esac
done

# Export variables for test scripts
export VERBOSE
export QUIET
export CI_MODE
export DOTFILES_DIR

# Function to run tests in a directory
run_test_suite() {
  local suite_name=$1
  local suite_dir="$SCRIPT_DIR/$suite_name"

  if [[ ! -d "$suite_dir" ]]; then
    print_warning "Test suite '$suite_name' not found"
    return 1
  fi

  print_section "Running $suite_name tests"

  # Find and run all test scripts in the suite
  local test_files
  test_files=$(find "$suite_dir" -name "test_*.sh" -type f | sort)

  if [[ -z "$test_files" ]]; then
    print_warning "No tests found in $suite_name suite"
    return 0
  fi

  while IFS= read -r test_file; do
    local test_name=$(basename "$test_file" .sh)
    print_test_header "$test_name"

    if bash "$test_file"; then
      ((TESTS_PASSED++))
      print_success "✓ $test_name passed"
    else
      ((TESTS_FAILED++))
      print_error "✗ $test_name failed"
    fi

    echo ""
  done <<<"$test_files"
}

# Main test execution
print_header "Dotfiles Test Runner"
echo "Test suite: $TEST_SUITE"
echo "CI mode: $CI_MODE"
echo ""

# Run the appropriate test suite(s)
case $TEST_SUITE in
all)
  for suite in bootstrap cleanup integration unit; do
    run_test_suite "$suite"
  done
  ;;
*)
  run_test_suite "$TEST_SUITE"
  ;;
esac

# Print summary
print_section "Test Summary"
echo -e "Tests passed:  ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests failed:  ${RED}${TESTS_FAILED}${NC}"
echo -e "Tests skipped: ${YELLOW}${TESTS_SKIPPED}${NC}"

# Exit with appropriate code
if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
else
  exit 0
fi
