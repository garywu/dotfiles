#!/bin/bash
# Test: Verify Cleanup/Unbootstrap
# This test verifies that unbootstrap properly removes installations

set -uo pipefail

# Get test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test_helpers.sh"

print_test_header "Verify Cleanup"

# Track test results
test_passed=true
cleanup_warnings=0

# Check Nix removal
print_section "Nix Removal"

if is_macos; then
  # On macOS, /nix requires reboot to fully remove
  if [[ -d /nix ]]; then
    print_warning "⚠ /nix directory still exists (macOS requires reboot for full removal)"
    ((cleanup_warnings++))
  else
    print_success "✓ /nix directory removed"
  fi
else
  # On Linux, /nix should be removed
  if assert_not_exists "/nix" "Nix directory"; then
    print_success "✓ /nix directory removed"
  else
    test_passed=false
  fi
fi

# Check config removals
print_section "Configuration Removal"

configs_to_check=(
  "$HOME/.config/fish"
  "$HOME/.config/home-manager"
  "$HOME/.config/starship.toml"
  "$HOME/.nix-profile"
  "$HOME/.nix-defexpr"
  "$HOME/.nix-channels"
)

# In CI on macOS, some Nix-related items may persist due to volume/daemon issues
for config in "${configs_to_check[@]}"; do
  if [[ -e $config ]]; then
    if is_ci && is_macos && [[ $config == *".nix"* ]]; then
      print_warning "⚠ $config still exists (may require reboot in CI)"
      ((cleanup_warnings++))
    else
      print_error "✗ $config still exists"
      test_passed=false
    fi
  else
    print_info "✓ $config removed"
  fi
done

# Check shell configs for Nix entries
print_section "Shell Configuration Cleanup"

shell_configs=(
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
  "$HOME/.zshrc"
  "$HOME/.profile"
)

for config in "${shell_configs[@]}"; do
  if [[ -f $config ]]; then
    if grep -q "nix" "$config" 2>/dev/null; then
      print_warning "⚠ Nix entries found in $config"
      ((cleanup_warnings++))
    else
      print_info "✓ $config clean of Nix entries"
    fi
  fi
done

# Check PATH
print_section "PATH Cleanup"

if echo "$PATH" | grep -q "nix"; then
  print_warning "⚠ PATH still contains Nix entries (restart shell to update)"
  ((cleanup_warnings++))
else
  print_info "✓ PATH clean of Nix entries"
fi

# Check for running Nix processes
print_section "Process Cleanup"

if is_macos; then
  if pgrep -f "nix-daemon" >/dev/null 2>&1; then
    print_warning "⚠ Nix daemon still running (requires reboot)"
    ((cleanup_warnings++))
  else
    print_info "✓ No Nix daemon processes"
  fi
fi

# Platform-specific checks
if is_macos; then
  print_section "macOS-specific Cleanup"

  # Check launchd services
  if sudo launchctl list | grep -E "(nix|darwin-store)" >/dev/null 2>&1; then
    print_warning "⚠ Nix launchd services still registered (requires reboot)"
    ((cleanup_warnings++))
  else
    print_info "✓ No Nix launchd services"
  fi

  # Check /etc/synthetic.conf
  if [[ -f /etc/synthetic.conf ]] && grep -q "^nix" /etc/synthetic.conf 2>/dev/null; then
    print_warning "⚠ /etc/synthetic.conf still contains nix entry (requires reboot)"
    ((cleanup_warnings++))
  else
    print_info "✓ /etc/synthetic.conf clean"
  fi
fi

# Final result
print_section "Cleanup Summary"
echo "Warnings: $cleanup_warnings"

if [[ $test_passed == "true" ]]; then
  if [[ $cleanup_warnings -gt 0 ]]; then
    print_warning "Cleanup completed with warnings (some items require reboot)"
  else
    print_success "All cleanup verification tests passed!"
  fi
  exit 0
else
  print_error "Some cleanup verification tests failed!"
  exit 1
fi
