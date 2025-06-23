#!/bin/bash
# Test: Verify Bootstrap Installations
# This test verifies that all expected tools are installed after bootstrap

set -euo pipefail

# Get test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test_helpers.sh"

print_test_header "Verify Bootstrap Installations"

# Track test results
test_passed=true

# Source Nix environment if needed
if is_macos; then
  # macOS uses nix-daemon.sh for multi-user installation
  if [[[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]]; then
    # shellcheck source=/dev/null
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
else
  # Linux uses nix.sh
  if [[[ -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]]]; then
    # shellcheck source=/dev/null
    source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
  fi
fi

# Also try user profile
if [[[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]]; then
  # shellcheck source=/dev/null
  source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

print_info "Current PATH: $PATH"

# Test Core Tools
print_section "Core Tools"

# Test Nix
if assert_command_exists "nix" "Nix"; then
  nix_version=$(nix --version)
  print_info "  Version: $nix_version"
else
  test_passed=false
fi

assert_directory_exists "/nix" "Nix store" || test_passed=false

# Test Home Manager
if assert_command_exists "home-manager" "Home Manager"; then
  hm_version=$(home-manager --version)
  print_info "  Version: $hm_version"
else
  test_passed=false
fi

assert_directory_exists "${HOME}/.config/home-manager" "Home Manager config" || test_passed=false

# Test Chezmoi
assert_command_exists "chezmoi" "Chezmoi" || test_passed=false

# Platform-specific tests
if is_macos; then
  print_section "macOS-specific Tools"

  if assert_command_exists "brew" "Homebrew"; then
    brew_version=$(brew --version | head -1)
    print_info "  Version: $brew_version"
  else
    test_passed=false
  fi

  if ! assert_directory_exists "/opt/homebrew" "Homebrew directory"; then
    assert_directory_exists "/usr/local/Homebrew" "Homebrew directory" || test_passed=false
  fi
fi

# Test Shell and Terminal Tools
print_section "Shell and Terminal Tools"

assert_command_exists "fish" "Fish shell" || test_passed=false
assert_command_exists "starship" "Starship prompt" || test_passed=false
assert_directory_exists "${HOME}/.config/fish" "Fish config" || test_passed=false

if ! assert_directory_exists "${HOME}/.config/starship" "Starship config"; then
  assert_file_exists "${HOME}/.config/starship.toml" "Starship config" || test_passed=false
fi

# Test Development Tools (from Home Manager packages)
print_section "Development Tools"

# Test common CLI tools that should be installed
assert_command_exists "eza" "eza (ls replacement)" || test_passed=false
assert_command_exists "bat" "bat (cat replacement)" || test_passed=false
assert_command_exists "fd" "fd (find replacement)" || test_passed=false
assert_command_exists "rg" "ripgrep" || test_passed=false
assert_command_exists "fzf" "fzf" || test_passed=false
assert_command_exists "tmux" "tmux" || test_passed=false
assert_command_exists "htop" "htop" || test_passed=false

# Test Configuration Files
print_section "Configuration Files"

if ! assert_file_exists "${HOME}/.config/home-manager/home.nix" "Home Manager home.nix"; then
  assert_symlink_exists "${HOME}/.config/home-manager/home.nix" "Home Manager home.nix symlink" || test_passed=false
fi

# Test PATH configuration
print_section "PATH Configuration"

assert_path_contains ".nix-profile/bin" "Nix profile bin" || test_passed=false
assert_path_contains "/nix/var/nix/profiles/default/bin" "Nix default profile" || test_passed=false

# Final result
if [[[ "$test_passed" == "true" ]]]; then
  print_success "All bootstrap verification tests passed!"
  exit 0
else
  print_error "Some bootstrap verification tests failed!"
  exit 1
fi
