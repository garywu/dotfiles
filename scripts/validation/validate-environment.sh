#!/bin/bash
# validate-environment.sh - Validate shell environment and configurations

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source helpers
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Expected configurations
EXPECTED_SHELLS=(
  "fish"
  "bash"
)

EXPECTED_CONFIGS=(
  "$HOME/.config/home-manager/home.nix"
  "$HOME/.config/fish/config.fish"
  "$HOME/.local/share/chezmoi"
)

EXPECTED_ENV_VARS=(
  "PATH"
  "HOME"
  "USER"
)

# Function to check PATH order
check_path_order() {
  local nix_position=-1
  local homebrew_position=-1
  local position=0

  IFS=':' read -ra PATH_ARRAY <<<"$PATH"

  for path in "${PATH_ARRAY[@]}"; do
    if [[ "$path" =~ \.nix-profile|/nix/store ]] && [[ $nix_position -eq -1 ]]; then
      nix_position=$position
    elif [[ "$path" =~ /opt/homebrew|/usr/local ]] && [[ $homebrew_position -eq -1 ]]; then
      homebrew_position=$position
    fi
    ((position++))
  done

  if [[ $nix_position -eq -1 ]]; then
    log_error "Nix paths not found in PATH"
    return 1
  fi

  if [[ $homebrew_position -ne -1 ]] && [[ $homebrew_position -lt $nix_position ]]; then
    log_warn "Homebrew paths come before Nix in PATH (positions: Homebrew=$homebrew_position, Nix=$nix_position)"
    log_info "This may cause Homebrew packages to take precedence over Nix packages"
    return 1
  fi

  log_success "PATH order is correct (Nix before Homebrew)"
  return 0
}

# Function to check shell configuration
check_shell_config() {
  local current_shell
  current_shell=$(basename "$SHELL")

  log_info "Current shell: $current_shell"

  # Check if fish is the default shell
  if [[ "$current_shell" == "fish" ]]; then
    log_success "Fish is the default shell"

    # Check fish configuration
    if [[ -f "$HOME/.config/fish/config.fish" ]]; then
      log_success "Fish configuration exists"

      # Check for important fish configurations
      if grep -q "starship init fish" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        log_success "Starship prompt is configured"
      else
        log_warn "Starship prompt not found in fish config"
      fi
    else
      log_error "Fish configuration not found at ~/.config/fish/config.fish"
    fi
  else
    log_warn "Default shell is $current_shell (expected fish)"
  fi

  # Check if shells are available
  for shell in "${EXPECTED_SHELLS[@]}"; do
    if command_exists "$shell"; then
      local shell_path
      shell_path=$(command -v "$shell")
      log_success "$shell available at: $shell_path"
    else
      log_warn "$shell not available"
    fi
  done
}

# Function to check Home Manager status
check_home_manager() {
  if ! command_exists home-manager; then
    log_error "Home Manager not found in PATH"
    return 1
  fi

  log_success "Home Manager is available"

  # Check if home.nix is linked correctly
  if [[ -L "$HOME/.config/home-manager/home.nix" ]]; then
    local link_target
    link_target=$(readlink "$HOME/.config/home-manager/home.nix")
    if [[ "$link_target" == "$DOTFILES_ROOT/nix/home.nix" ]]; then
      log_success "home.nix is correctly linked to dotfiles"
    else
      log_error "home.nix is linked to wrong location: $link_target"
    fi
  elif [[ -f "$HOME/.config/home-manager/home.nix" ]]; then
    log_warn "home.nix exists but is not a symlink (may cause sync issues)"
  else
    log_error "home.nix not found"
  fi

  # Check last generation
  if home-manager generations 2>/dev/null | head -1 | grep -q "current"; then
    log_success "Home Manager has active generations"
  else
    log_warn "No Home Manager generations found"
  fi
}

# Function to check environment variables
check_env_vars() {
  for var in "${EXPECTED_ENV_VARS[@]}"; do
    if [[ -n "${!var:-}" ]]; then
      log_success "$var is set"
      log_debug "$var=${!var}"
    else
      log_error "$var is not set"
    fi
  done

  # Check specific PATH entries
  if [[ "$PATH" =~ \.nix-profile/bin ]]; then
    log_success "Nix profile bin is in PATH"
  else
    log_error "Nix profile bin not found in PATH"
  fi

  if [[ "$PATH" =~ \.npm-global/bin ]]; then
    log_success "NPM global bin is in PATH"
  else
    log_warn "NPM global bin not in PATH (may affect npm global packages)"
  fi

  if [[ "$PATH" =~ \.local/bin ]]; then
    log_success "User local bin is in PATH"
  else
    log_warn "User local bin not in PATH (may affect pipx and other user tools)"
  fi
}

# Function to check Git configuration
check_git_config() {
  if ! command_exists git; then
    log_error "Git not found"
    return 1
  fi

  # Check user configuration
  local git_user
  local git_email
  git_user=$(git config --global user.name 2>/dev/null || echo "")
  git_email=$(git config --global user.email 2>/dev/null || echo "")

  if [[ -n "$git_user" ]]; then
    log_success "Git user configured: $git_user"
  else
    log_error "Git user.name not configured"
  fi

  if [[ -n "$git_email" ]]; then
    log_success "Git email configured: $git_email"
  else
    log_error "Git user.email not configured"
  fi

  # Check default branch
  local default_branch
  default_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "")
  if [[ "$default_branch" == "main" ]]; then
    log_success "Git default branch is 'main'"
  else
    log_warn "Git default branch is not 'main' (current: ${default_branch:-not set})"
  fi
}

# Function to check dotfiles repository status
check_dotfiles_status() {
  if [[ ! -d "$DOTFILES_ROOT/.git" ]]; then
    log_error "Dotfiles directory is not a git repository"
    return 1
  fi

  cd "$DOTFILES_ROOT" || return 1

  # Check for uncommitted changes
  if git diff --quiet && git diff --staged --quiet; then
    log_success "No uncommitted changes in dotfiles"
  else
    log_warn "Uncommitted changes found in dotfiles"
    if is_fix_mode; then
      log_info "Run 'git status' in $DOTFILES_ROOT to review changes"
    fi
  fi

  # Check if we're on a known branch
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  if [[ "$current_branch" =~ ^(main|stable|beta)$ ]]; then
    log_success "On standard branch: $current_branch"
  else
    log_warn "On non-standard branch: $current_branch"
  fi

  cd - >/dev/null || return 1
}

# Main validation
main() {
  print_section "ENVIRONMENT VALIDATION"

  # Check PATH order
  print_section "PATH Configuration"
  check_path_order

  # Check shell configuration
  print_section "Shell Configuration"
  check_shell_config

  # Check Home Manager
  print_section "Home Manager Status"
  check_home_manager

  # Check environment variables
  print_section "Environment Variables"
  check_env_vars

  # Check Git configuration
  print_section "Git Configuration"
  check_git_config

  # Check dotfiles status
  print_section "Dotfiles Repository Status"
  check_dotfiles_status

  # Summary
  print_summary
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --fix)
    export FIX_MODE=true
    shift
    ;;
  --json)
    export JSON_OUTPUT=true
    shift
    ;;
  --debug)
    export LOG_LEVEL=$LOG_DEBUG
    shift
    ;;
  -h | --help)
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --fix     Attempt to fix issues automatically"
    echo "  --json    Output results in JSON format"
    echo "  --debug   Enable debug output"
    echo "  -h, --help Show this help message"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Run main validation
main
