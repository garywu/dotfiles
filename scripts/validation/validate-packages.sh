#!/bin/bash
# validate-packages.sh - Detect and fix dual package installations

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source helpers
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Package lists
# Critical packages that should only be in one place
CRITICAL_PACKAGES=(
  "python"
  "python3"
  "aws"
  "pipx"
  "pre-commit"
  "git"
  "node"
  "npm"
  "go"
  "rust"
  "cargo"
)

# Packages that should prefer Nix
NIX_PREFERRED=(
  "python"
  "python3"
  "aws"
  "pipx"
  "pre-commit"
  "git"
  "node"
  "npm"
  "go"
  "rust"
  "cargo"
  "chezmoi"
  "gh"
  "jq"
  "yq"
  "ripgrep"
  "fd"
  "bat"
  "eza"
  "starship"
  "fish"
  "tmux"
  "neovim"
  "htop"
  "tree"
  "wget"
  "curl"
)

# Packages that should be in Homebrew (GUI apps)
HOMEBREW_ONLY=(
  "docker"
  "iterm2"
  "postman"
  "insomnia"
  "tableplus"
  "dbeaver-community"
  "chatgpt"
  "cherry-studio"
  "lm-studio"
  "jan"
  "gpt4all"
)

# Function to check package location
check_package_location() {
  local package="$1"
  local found_in=()

  # Check if command exists
  if command_exists "$package"; then
    local cmd_path
    cmd_path=$(command -v "$package")
    local manager
    manager=$(get_package_manager "$package")
    found_in+=("$manager:$cmd_path")
  fi

  # Also check package managers directly
  # Check Nix
  if command_exists nix-env && nix-env -q 2>/dev/null | grep -q "^${package}"; then
    local already_found=false
    for item in "${found_in[@]}"; do
      if [[  "$item" =~ ^nix:  ]]; then
        already_found=true
        break
      fi
    done
    if [[  "$already_found" == false  ]]; then
      found_in+=("nix:package-list")
    fi
  fi

  # Check Homebrew - also check for package aliases
  if command_exists brew; then
    # Check exact match first
    if brew list 2>/dev/null | grep -q "^${package}$"; then
      local already_found=false
      for item in "${found_in[@]}"; do
        if [[  "$item" =~ ^homebrew:  ]]; then
          already_found=true
          break
        fi
      done
      if [[  "$already_found" == false  ]]; then
        found_in+=("homebrew:package-list")
      fi
    # Special case for aws/awscli
    elif [[  "$package" == "aws"  ]] && brew list 2>/dev/null | grep -q "^awscli$"; then
      local already_found=false
      for item in "${found_in[@]}"; do
        if [[  "$item" =~ ^homebrew:  ]]; then
          already_found=true
          break
        fi
      done
      if [[  "$already_found" == false  ]]; then
        found_in+=("homebrew:awscli")
      fi
    fi
  fi

  # Check for Python specific issues
  if [[  "$package" == "python" || "$package" == "python3"  ]]; then
    check_python_specific >/dev/null 2>&1
  fi

  # Return array elements
  if [[ ${#found_in[@]} -gt 0 ]]; then
    printf '%s\n' "${found_in[@]}"
  fi
}

# Special handling for Python
check_python_specific() {
  log_info "Checking Python installations..."

  # Find all python executables
  local pythons=()

  # Check common Python locations
  for py in python python3 python3.{9..13}; do
    if command_exists "$py"; then
      local py_path
      py_path=$(command -v "$py")
      local py_version
      py_version=$("$py" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      pythons+=("$py:$py_path:$py_version")
    fi
  done

  if [[ ${#pythons[@]} -gt 0 ]]; then
    log_info "Found Python installations:"
    for py_info in "${pythons[@]}"; do
      IFS=':' read -r cmd path version <<<"$py_info"
      log_info "  $cmd → $path (v$version)"
    done
  fi

  # Check which Python pip is using
  if command_exists pip; then
    local pip_python
    pip_python=$(pip --version 2>/dev/null | grep -oE 'from [^ ]+' | cut -d' ' -f2 || echo "unknown")
    log_info "pip is using Python from: $pip_python"
  fi

  if command_exists pip3; then
    local pip3_python
    pip3_python=$(pip3 --version 2>/dev/null | grep -oE 'from [^ ]+' | cut -d' ' -f2 || echo "unknown")
    log_info "pip3 is using Python from: $pip3_python"
  fi
}

# Function to validate single package
validate_package() {
  local package="$1"
  local preferred_location="${2:-nix}"
  local locations=()

  # Read locations into array
  while IFS= read -r line; do
    [[  -n "$line"  ]] && locations+=("$line")
  done < <(check_package_location "$package")

  if [[ ${#locations[@]} -eq 0 ]]; then
    log_debug "$package: Not installed"
    return 0
  elif [[ ${#locations[@]} -eq 1 ]]; then
    local location="${locations[0]}"
    local manager="${location%%:*}"

    if [[  "$preferred_location" == "any"  ]]; then
      log_success "$package: Installed via $manager"
    elif [[  "$manager" == "$preferred_location"  ]]; then
      log_success "$package: Correctly installed via $manager"
    else
      log_warn "$package: Installed via $manager (expected $preferred_location)"

      if is_fix_mode && [[  "$preferred_location" == "nix"  ]] && [[  "$manager" == "homebrew"  ]]; then
        log_info "Attempting to fix: Moving $package from Homebrew to Nix..."
        fix_package_location "$package" "homebrew" "nix"
      fi
    fi
  else
    log_error "$package: DUPLICATE - Found in multiple locations:"
    for loc in "${locations[@]}"; do
      log_error "  - ${loc}"
    done

    if is_fix_mode; then
      log_info "Attempting to fix duplicate installation..."
      fix_duplicate_package "$package" "$preferred_location"
    fi
  fi
}

# Function to fix package location
fix_package_location() {
  local package="$1"
  local from_manager="$2"
  local to_manager="$3"

  if [[  "$from_manager" == "homebrew"  ]] && [[  "$to_manager" == "nix"  ]]; then
    # Check if package exists in Nix packages
    if ! safe_run "brew uninstall $package" "Failed to uninstall $package from Homebrew"; then
      return 1
    fi
    log_fix "Removed $package from Homebrew (already in Nix)"
  fi
}

# Function to fix duplicate packages
fix_duplicate_package() {
  local package="$1"
  local preferred="$2"

  if [[  "$preferred" == "nix"  ]]; then
    # Remove from Homebrew if in Nix
    if command_exists brew && brew list 2>/dev/null | grep -q "^${package}$"; then
      if safe_run "brew uninstall $package" "Failed to uninstall $package from Homebrew"; then
        log_fix "Removed $package from Homebrew (keeping Nix version)"
      fi
    fi
  elif [[  "$preferred" == "homebrew"  ]]; then
    # Remove from Nix if in Homebrew
    if nix-env -q 2>/dev/null | grep -q "^${package}"; then
      if safe_run "nix-env -e $package" "Failed to uninstall $package from Nix"; then
        log_fix "Removed $package from Nix (keeping Homebrew version)"
      fi
    fi
  fi
}

# Main validation
main() {
  print_section "PACKAGE MANAGEMENT VALIDATION"

  # Check for package managers
  log_info "Checking package managers..."

  if ! command_exists nix-env; then
    log_error "Nix is not installed or not in PATH"
  else
    log_success "Nix is available"
  fi

  if ! command_exists brew; then
    log_warn "Homebrew is not installed (expected on macOS)"
  else
    log_success "Homebrew is available"
  fi

  # Check critical packages
  print_section "Checking for Duplicate Packages"

  for package in "${CRITICAL_PACKAGES[@]}"; do
    validate_package "$package" "nix"
  done

  # Check Nix-preferred packages
  print_section "Checking Nix-Preferred Packages"

  for package in "${NIX_PREFERRED[@]}"; do
    if [[ ! " ${CRITICAL_PACKAGES[@]} " =~ " ${package} " ]]; then
      validate_package "$package" "nix"
    fi
  done

  # Check Homebrew-only packages
  if command_exists brew; then
    print_section "Checking Homebrew GUI Applications"

    for package in "${HOMEBREW_ONLY[@]}"; do
      local locations
      locations=($(check_package_location "$package"))

      if [[ ${#locations[@]} -eq 0 ]]; then
        log_debug "$package: Not installed (GUI app)"
      elif [[ "${locations[0]%%:*}" == "homebrew" ]]; then
        log_success "$package: Correctly in Homebrew"
      else
        log_warn "$package: Found in ${locations[0]%%:*} (expected Homebrew)"
      fi
    done
  fi

  # Check PATH precedence
  print_section "Checking PATH Precedence"

  log_info "Current PATH order:"
  IFS=':' read -ra PATH_ARRAY <<<"$PATH"
  local nix_found=false
  local brew_found=false

  for i in "${!PATH_ARRAY[@]}"; do
    local path="${PATH_ARRAY[$i]}"
    if [[  "$path" =~ (\.nix-profile|/nix/store)  ]] && [[  "$nix_found" == false  ]]; then
      nix_found=true
      log_info "  $((i + 1)). $path ${GREEN}[Nix]${NC}"
    elif [[  "$path" =~ (/opt/homebrew|/usr/local)  ]] && [[  "$brew_found" == false  ]]; then
      brew_found=true
      log_info "  $((i + 1)). $path ${YELLOW}[Homebrew]${NC}"
    elif [[  $i -lt 5  ]]; then
      log_info "  $((i + 1)). $path"
    fi
  done

  # Check specific Python issues
  print_section "Python Environment Check"
  check_python_specific

  # Summary
  print_summary
}

# Parse arguments
while [[  $# -gt 0  ]]; do
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
