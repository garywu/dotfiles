#!/usr/bin/env bash

# Check Updates Script - Comprehensive update scanner for all installed tools
# This script checks for updates across Nix, Homebrew, npm, and other package managers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
  echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_status() {
  echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
}

print_update() {
  echo -e "${CYAN}↑${NC} $1"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Store results for summary
declare -A UPDATES_AVAILABLE
declare -A CURRENT_VERSIONS
declare -A LATEST_VERSIONS
TOTAL_UPDATES=0

# Check Nix packages
check_nix_updates() {
  print_header "Nix Packages"

  if ! command_exists nix; then
    print_error "Nix not found"
    return 1
  fi

  print_status "Checking Nix channel updates..."

  # Check for channel updates
  if nix-channel --update --dry-run 2>&1 | grep -q "would download"; then
    print_update "Nix channel updates available"
    UPDATES_AVAILABLE["nix-channel"]="true"
    ((TOTAL_UPDATES++))
  else
    print_status "Nix channels are up to date"
  fi

  # Check Home Manager generation
  if command_exists home-manager; then
    print_status "Checking Home Manager packages..."
    # This is a simplified check - full update checking would require more complex logic
    local current_gen=$(home-manager generations | head -1 | awk '{print $1}')
    CURRENT_VERSIONS["home-manager"]="Generation $current_gen"
    print_status "Current Home Manager generation: $current_gen"
  fi
}

# Check Homebrew packages
check_brew_updates() {
  print_header "Homebrew Packages"

  if ! command_exists brew; then
    print_warning "Homebrew not found (macOS only)"
    return 1
  fi

  print_status "Updating Homebrew package database..."
  brew update >/dev/null 2>&1

  print_status "Checking for outdated packages..."
  local outdated=$(brew outdated)

  if [[ -n $outdated ]]; then
    print_update "Homebrew packages with updates:"
    echo "$outdated" | while IFS= read -r line; do
      if [[ -n $line ]]; then
        local pkg=$(echo "$line" | awk '{print $1}')
        local current=$(echo "$line" | awk '{print $2}' | sed 's/[()]//g')
        local latest=$(echo "$line" | awk '{print $4}')

        echo "  - $pkg: $current → $latest"
        UPDATES_AVAILABLE["brew-$pkg"]="$latest"
        CURRENT_VERSIONS["brew-$pkg"]="$current"
        LATEST_VERSIONS["brew-$pkg"]="$latest"
        ((TOTAL_UPDATES++))
      fi
    done
  else
    print_status "All Homebrew packages are up to date"
  fi

  # Check for cask updates
  print_status "Checking for cask updates..."
  local cask_outdated=$(brew outdated --cask)

  if [[ -n $cask_outdated ]]; then
    print_update "Homebrew casks with updates:"
    echo "$cask_outdated" | while IFS= read -r line; do
      if [[ -n $line ]]; then
        local cask=$(echo "$line" | awk '{print $1}')
        local current=$(echo "$line" | awk '{print $2}' | sed 's/[()]//g')
        local latest=$(echo "$line" | awk '{print $4}')

        echo "  - $cask: $current → $latest"
        UPDATES_AVAILABLE["cask-$cask"]="$latest"
        CURRENT_VERSIONS["cask-$cask"]="$current"
        LATEST_VERSIONS["cask-$cask"]="$latest"
        ((TOTAL_UPDATES++))
      fi
    done
  else
    print_status "All Homebrew casks are up to date"
  fi
}

# Check npm global packages
check_npm_updates() {
  print_header "NPM Global Packages"

  if ! command_exists npm; then
    print_warning "npm not found"
    return 1
  fi

  print_status "Checking npm global packages..."

  # Get list of outdated global packages
  local npm_outdated=$(npm outdated -g --parseable 2>/dev/null | grep -v "^$")

  if [[ -n $npm_outdated ]]; then
    print_update "NPM packages with updates:"
    echo "$npm_outdated" | while IFS=: read -r path current wanted latest; do
      if [[ -n $path ]]; then
        local pkg=$(basename "$path")
        echo "  - $pkg: $current → $latest"
        UPDATES_AVAILABLE["npm-$pkg"]="$latest"
        CURRENT_VERSIONS["npm-$pkg"]="$current"
        LATEST_VERSIONS["npm-$pkg"]="$latest"
        ((TOTAL_UPDATES++))
      fi
    done
  else
    print_status "All npm global packages are up to date"
  fi
}

# Check specific tools
check_ollama_updates() {
  print_header "Ollama"

  if ! command_exists ollama; then
    print_warning "Ollama not found"
    return 1
  fi

  local current_version=$(ollama --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
  CURRENT_VERSIONS["ollama"]="$current_version"
  print_status "Current version: $current_version"

  # Check latest version from GitHub API
  if command_exists curl && command_exists jq; then
    local latest_version=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | jq -r '.tag_name' | sed 's/^v//')

    if [[ -n $latest_version ]] && [[ $latest_version != "null" ]]; then
      LATEST_VERSIONS["ollama"]="$latest_version"

      if [[ $current_version != "$latest_version" ]]; then
        print_update "Ollama update available: $current_version → $latest_version"
        UPDATES_AVAILABLE["ollama"]="$latest_version"
        ((TOTAL_UPDATES++))
      else
        print_status "Ollama is up to date"
      fi
    else
      print_warning "Could not fetch latest Ollama version"
    fi
  else
    print_warning "curl or jq not available - cannot check for updates"
  fi
}

# Check Python packages installed via uv
check_uv_tools() {
  print_header "Python Tools (via uv)"

  if ! command_exists uv; then
    print_warning "uv not found"
    return 1
  fi

  print_status "Checking uv-installed tools..."

  # List installed tools
  local tools=$(uv tool list 2>/dev/null | grep -E '^[a-zA-Z]' | awk '{print $1}')

  if [[ -n $tools ]]; then
    echo "$tools" | while IFS= read -r tool; do
      if [[ -n $tool ]]; then
        # For now, just list the tools - uv doesn't have a direct update check yet
        local version=$(uv tool list | grep "^$tool" | awk '{print $2}')
        CURRENT_VERSIONS["uv-$tool"]="$version"
        print_status "$tool: $version"
      fi
    done
  else
    print_status "No uv tools installed"
  fi
}

# Check Go tools
check_go_tools() {
  print_header "Go Tools"

  if ! command_exists go; then
    print_warning "Go not found"
    return 1
  fi

  print_status "Current Go version: $(go version | awk '{print $3}')"

  # Check for common Go tools in PATH
  local go_tools=("gopls" "golangci-lint" "protoc-gen-go" "protoc-gen-go-grpc")

  for tool in "${go_tools[@]}"; do
    if command_exists "$tool"; then
      local version=$("$tool" --version 2>/dev/null | head -1 || echo "version unknown")
      CURRENT_VERSIONS["go-$tool"]="$version"
      print_status "$tool: $version"
    fi
  done
}

# Check Rust/Cargo
check_rust_updates() {
  print_header "Rust Toolchain"

  if ! command_exists rustc; then
    print_warning "Rust not found"
    return 1
  fi

  local rustc_version=$(rustc --version | awk '{print $2}')
  CURRENT_VERSIONS["rust"]="$rustc_version"
  print_status "Rust version: $rustc_version"

  if command_exists cargo; then
    local cargo_version=$(cargo --version | awk '{print $2}')
    CURRENT_VERSIONS["cargo"]="$cargo_version"
    print_status "Cargo version: $cargo_version"
  fi
}

# Generate update commands
generate_update_commands() {
  print_header "Update Commands"

  if [[ $TOTAL_UPDATES -eq 0 ]]; then
    print_status "All tools are up to date! 🎉"
    return 0
  fi

  print_status "Commands to update outdated packages:"
  echo ""

  # Nix updates
  if [[ ${UPDATES_AVAILABLE[nix - channel]} == "true" ]]; then
    echo "# Update Nix channels:"
    echo "nix-channel --update"
    echo "home-manager switch"
    echo ""
  fi

  # Homebrew updates
  local brew_updates=false
  local cask_updates=false

  for key in "${!UPDATES_AVAILABLE[@]}"; do
    if [[ $key == brew-* ]]; then
      brew_updates=true
    elif [[ $key == cask-* ]]; then
      cask_updates=true
    fi
  done

  if [[ $brew_updates == "true" ]] || [[ $cask_updates == "true" ]]; then
    echo "# Update Homebrew packages:"
    if [[ $brew_updates == "true" ]]; then
      echo "brew upgrade"
    fi
    if [[ $cask_updates == "true" ]]; then
      echo "brew upgrade --cask"
    fi
    echo ""
  fi

  # NPM updates
  local npm_updates=false
  for key in "${!UPDATES_AVAILABLE[@]}"; do
    if [[ $key == npm-* ]]; then
      npm_updates=true
      break
    fi
  done

  if [[ $npm_updates == "true" ]]; then
    echo "# Update npm packages:"
    for key in "${!UPDATES_AVAILABLE[@]}"; do
      if [[ $key == npm-* ]]; then
        local pkg="${key#npm-}"
        echo "npm update -g $pkg"
      fi
    done
    echo ""
  fi

  # Ollama update
  if [[ -n ${UPDATES_AVAILABLE[ollama]} ]]; then
    echo "# Update Ollama:"
    if command_exists brew && brew list ollama &>/dev/null; then
      echo "brew upgrade ollama"
    else
      echo "curl -fsSL https://ollama.ai/install.sh | sh"
    fi
    echo ""
  fi

  # Update all command
  echo "# Or update everything at once:"
  echo "./scripts/update-all.sh"
}

# Generate summary report
generate_summary() {
  print_header "Update Summary"

  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local report_file="$HOME/.dotfiles/logs/update-check-$(date +%Y%m%d-%H%M%S).log"

  mkdir -p "$HOME/.dotfiles/logs"

  {
    echo "Update Check Report - $timestamp"
    echo "================================="
    echo ""
    echo "Total updates available: $TOTAL_UPDATES"
    echo ""

    if [[ $TOTAL_UPDATES -gt 0 ]]; then
      echo "Packages with updates:"
      for key in "${!UPDATES_AVAILABLE[@]}"; do
        local current="${CURRENT_VERSIONS[$key]:-unknown}"
        local latest="${LATEST_VERSIONS[$key]:-${UPDATES_AVAILABLE[$key]}}"
        echo "  - $key: $current → $latest"
      done
    else
      echo "All packages are up to date!"
    fi

    echo ""
    echo "Tools checked:"
    echo "  - Nix/Home Manager"
    echo "  - Homebrew (macOS)"
    echo "  - NPM global packages"
    echo "  - Ollama"
    echo "  - UV Python tools"
    echo "  - Go tools"
    echo "  - Rust toolchain"
  } | tee "$report_file"

  echo ""
  print_status "Report saved to: $report_file"
}

# Main execution
main() {
  print_header "Checking for updates across all package managers"

  # Run all checks
  check_nix_updates
  check_brew_updates
  check_npm_updates
  check_ollama_updates
  check_uv_tools
  check_go_tools
  check_rust_updates

  # Generate summary and commands
  generate_summary
  generate_update_commands
}

# Run main function
main "$@"
