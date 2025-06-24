#!/bin/bash
# Smoke Test: Check if all expected commands are available
# This is a simple test that verifies commands can be executed

set -uo pipefail

# Get test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test_helpers.sh"

print_test_header "Command Smoke Test"

# Track test results
test_passed=true
commands_found=0
commands_missing=0

# Source Nix environment if available
if is_macos && [[  -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh  ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [[  -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh  ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi

if [[  -f "$HOME/.nix-profile/etc/profile.d/nix.sh"  ]]; then
  source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Function to check command
check_command() {
  local cmd=$1
  local description=${2:-$1}

  if command -v "$cmd" &>/dev/null; then
    ((commands_found++))
    print_info "✓ $description"
  else
    ((commands_missing++))
    print_error "✗ $description not found"
    test_passed=false
  fi
}

# Core Tools
print_section "Core Tools"
check_command "nix" "Nix package manager"
check_command "home-manager" "Home Manager"
check_command "chezmoi" "Chezmoi dotfiles manager"

# Platform-specific
if is_macos; then
  print_section "macOS Tools"
  check_command "brew" "Homebrew"
fi

# Development tools from home.nix
print_section "Development Languages"
check_command "git" "Git"
check_command "python3" "Python 3"
check_command "node" "Node.js"
check_command "bun" "Bun"
check_command "go" "Go"
check_command "rustc" "Rust compiler"
check_command "cargo" "Cargo (Rust)"

# Cloud tools
print_section "Cloud Tools"
check_command "aws" "AWS CLI"
check_command "gcloud" "Google Cloud SDK"
check_command "cloudflared" "Cloudflare Tunnel"
check_command "flarectl" "Cloudflare CLI"

# Shell tools
print_section "Shell Tools"
check_command "fish" "Fish shell"
check_command "starship" "Starship prompt"
check_command "bash" "Bash (modern)"
check_command "eza" "eza (ls replacement)"
check_command "bat" "bat (cat replacement)"
check_command "fd" "fd (find replacement)"
check_command "rg" "ripgrep"
check_command "tldr" "tldr"

# Enhanced search and navigation
print_section "Search & Navigation Tools"
check_command "ag" "silver-searcher"
check_command "broot" "broot"
check_command "lsd" "lsd (ls with icons)"
check_command "procs" "procs (ps replacement)"
check_command "dust" "dust (du replacement)"
check_command "duf" "duf (df replacement)"
check_command "tokei" "tokei (code stats)"
check_command "hyperfine" "hyperfine (benchmarking)"
check_command "watchexec" "watchexec"
check_command "sd" "sd (sed replacement)"

# Developer CLI Tools
print_section "Developer CLI Tools"
check_command "gh" "GitHub CLI"
check_command "hub" "GitHub hub"
check_command "glab" "GitLab CLI"
check_command "jq" "jq (JSON processor)"
check_command "yq" "yq (YAML processor)"
check_command "htop" "htop"
check_command "ncdu" "ncdu (disk usage)"
check_command "tmux" "tmux"
check_command "nvim" "Neovim"
check_command "fzf" "fzf (fuzzy finder)"
check_command "zoxide" "zoxide (smarter cd)"
check_command "direnv" "direnv"
check_command "mkcert" "mkcert"
check_command "http" "httpie"
check_command "wget" "wget"
check_command "curl" "curl"
check_command "tree" "tree"

# Advanced CLI tools
print_section "Advanced CLI Tools"
check_command "mosh" "mosh (remote shell)"
check_command "delta" "delta (git diff)"
check_command "lazygit" "lazygit"
check_command "btop" "btop (resource monitor)"
check_command "glow" "glow (markdown preview)"
check_command "vifm" "vifm (file manager)"

# Git enhancement tools
print_section "Git Enhancement Tools"
check_command "tig" "tig (git TUI)"
check_command "gitui" "gitui"

# File content tools
print_section "File Content Tools"
check_command "gron" "gron (JSON grep)"
check_command "jless" "jless (JSON viewer)"
check_command "hexyl" "hexyl (hex viewer)"
check_command "choose" "choose (cut alternative)"

# Interactive CLI tools
print_section "Interactive CLI Tools"
check_command "gum" "gum (beautiful CLI prompts)"

# Secrets management
print_section "Secrets Management"
check_command "sops" "sops"
check_command "age" "age (encryption)"

# Backup and filesystem monitoring
print_section "Backup & Filesystem Tools"
check_command "borg" "borgbackup (deduplicating backup)"
check_command "fswatch" "fswatch (filesystem monitor)"

# Print summary
print_section "Summary"
echo "Commands found: $commands_found"
echo "Commands missing: $commands_missing"

if [[  "$test_passed" == "true"  ]]; then
  print_success "All commands are available!"
  exit 0
else
  print_error "Some commands are missing!"
  exit 1
fi
