#!/bin/bash
# Integration Test: Full Bootstrap Cycle
# This test runs the complete bootstrap process and verifies the result

set -euo pipefail

# Get test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test_helpers.sh"

print_test_header "Full Bootstrap Cycle Integration Test"

# This test should only run if specifically requested or in CI
if [[  "${RUN_INTEGRATION_TESTS:-false}" != "true"  ]] && ! is_ci; then
  skip_test "Integration tests must be explicitly enabled with RUN_INTEGRATION_TESTS=true"
fi

# Ensure we're starting from a clean state
print_section "Pre-test Checks"

if command -v nix &>/dev/null; then
  print_error "Nix is already installed. This test requires a clean system."
  print_info "Run './scripts/unbootstrap.sh' first to clean the system."
  exit 1
fi

# Run bootstrap
print_section "Running Bootstrap"

if ! "$DOTFILES_DIR/bootstrap.sh"; then
  print_error "Bootstrap failed!"
  exit 1
fi

# Verify installations using our test suite
print_section "Verifying Bootstrap"

if ! "$TEST_DIR/../bootstrap/test_verify_installations.sh"; then
  print_error "Bootstrap verification failed!"
  exit 1
fi

# Quick smoke test
print_section "Running Smoke Test"

if ! "$TEST_DIR/../bootstrap/test_smoke_commands.sh"; then
  print_error "Command smoke test failed!"
  exit 1
fi

print_success "Full bootstrap cycle completed successfully!"
exit 0
