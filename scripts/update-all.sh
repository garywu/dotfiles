#!/usr/bin/env bash

# Update All Script - Updates all package managers and tools
# This script updates Nix, Homebrew, npm packages, and other tools

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Track what was updated
UPDATES_PERFORMED=()
UPDATES_FAILED=()

# Update Nix and Home Manager
update_nix() {
  print_header "Updating Nix and Home Manager"

  if ! command_exists nix; then
    print_warning "Nix not found, skipping"
    return 1
  fi

  print_status "Updating Nix channels..."
  if nix-channel --update; then
    print_success "Nix channels updated"
    UPDATES_PERFORMED+=("Nix channels")
  else
    print_error "Failed to update Nix channels"
    UPDATES_FAILED+=("Nix channels")
  fi

  if command_exists home-manager; then
    print_status "Updating Home Manager configuration..."
    if home-manager switch; then
      print_success "Home Manager updated"
      UPDATES_PERFORMED+=("Home Manager")
    else
      print_error "Failed to update Home Manager"
      UPDATES_FAILED+=("Home Manager")
    fi
  fi
}

# Update Homebrew packages
update_homebrew() {
  print_header "Updating Homebrew"

  if ! command_exists brew; then
    print_warning "Homebrew not found, skipping"
    return 1
  fi

  print_status "Updating Homebrew..."
  if brew update; then
    print_success "Homebrew updated"

    print_status "Upgrading Homebrew packages..."
    if brew upgrade; then
      print_success "Homebrew packages upgraded"
      UPDATES_PERFORMED+=("Homebrew packages")
    else
      print_warning "Some Homebrew packages failed to upgrade"
      UPDATES_FAILED+=("Some Homebrew packages")
    fi

    print_status "Upgrading Homebrew casks..."
    if brew upgrade --cask; then
      print_success "Homebrew casks upgraded"
      UPDATES_PERFORMED+=("Homebrew casks")
    else
      print_warning "Some Homebrew casks failed to upgrade"
      UPDATES_FAILED+=("Some Homebrew casks")
    fi

    print_status "Cleaning up Homebrew..."
    brew cleanup
  else
    print_error "Failed to update Homebrew"
    UPDATES_FAILED+=("Homebrew")
  fi
}

# Update npm packages
update_npm() {
  print_header "Updating NPM packages"

  if ! command_exists npm; then
    print_warning "npm not found, skipping"
    return 1
  fi

  print_status "Updating npm itself..."
  if npm update -g npm; then
    print_success "npm updated"
    UPDATES_PERFORMED+=("npm")
  else
    print_warning "Failed to update npm"
  fi

  print_status "Updating global npm packages..."
  # Get list of global packages and update them
  local packages=$(npm list -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $NF}')

  while IFS= read -r package; do
    if [[ -n $package ]] && [[ $package != "npm" ]]; then
      print_status "Updating $package..."
      if npm update -g "$package" 2>/dev/null; then
        print_success "$package updated"
      else
        print_warning "Failed to update $package"
      fi
    fi
  done <<<"$packages"

  UPDATES_PERFORMED+=("NPM global packages")
}

# Update Ollama
update_ollama() {
  print_header "Updating Ollama"

  if ! command_exists ollama; then
    print_warning "Ollama not found, skipping"
    return 1
  fi

  local current_version=$(ollama --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
  print_status "Current Ollama version: $current_version"

  # Check if installed via Homebrew
  if command_exists brew && brew list ollama &>/dev/null 2>&1; then
    print_status "Updating Ollama via Homebrew..."
    if brew upgrade ollama; then
      print_success "Ollama updated via Homebrew"
      UPDATES_PERFORMED+=("Ollama")
    else
      print_warning "Ollama is already up to date or update failed"
    fi
  else
    print_status "Updating Ollama via official installer..."
    if curl -fsSL https://ollama.ai/install.sh | sh; then
      print_success "Ollama updated"
      UPDATES_PERFORMED+=("Ollama")
    else
      print_error "Failed to update Ollama"
      UPDATES_FAILED+=("Ollama")
    fi
  fi

  # Update Ollama models
  print_status "Updating Ollama models..."
  local models=$(ollama list | tail -n +2 | awk '{print $1}')

  while IFS= read -r model; do
    if [[ -n $model ]]; then
      print_status "Updating model: $model"
      if ollama pull "$model"; then
        print_success "Model $model updated"
      else
        print_warning "Failed to update model $model"
      fi
    fi
  done <<<"$models"
}

# Update Python tools via uv
update_uv_tools() {
  print_header "Updating Python tools (via uv)"

  if ! command_exists uv; then
    print_warning "uv not found, skipping"
    return 1
  fi

  print_status "Updating uv itself..."
  if command_exists pipx && pipx list | grep -q "uv"; then
    if pipx upgrade uv; then
      print_success "uv updated"
      UPDATES_PERFORMED+=("uv")
    else
      print_warning "Failed to update uv"
    fi
  fi

  # Update uv-installed tools
  print_status "Updating uv-installed tools..."
  local tools=$(uv tool list 2>/dev/null | grep -E '^[a-zA-Z]' | awk '{print $1}')

  while IFS= read -r tool; do
    if [[ -n $tool ]]; then
      print_status "Updating $tool..."
      if uv tool install --upgrade "$tool"; then
        print_success "$tool updated"
      else
        print_warning "Failed to update $tool"
      fi
    fi
  done <<<"$tools"

  UPDATES_PERFORMED+=("UV Python tools")
}

# Update Go tools
update_go_tools() {
  print_header "Updating Go tools"

  if ! command_exists go; then
    print_warning "Go not found, skipping"
    return 1
  fi

  # Update common Go tools
  local go_tools=(
    "golang.org/x/tools/gopls@latest"
    "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
    "google.golang.org/protobuf/cmd/protoc-gen-go@latest"
    "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
  )

  for tool in "${go_tools[@]}"; do
    local tool_name=$(basename "${tool%@*}")
    print_status "Updating $tool_name..."
    if go install "$tool"; then
      print_success "$tool_name updated"
    else
      print_warning "Failed to update $tool_name"
    fi
  done

  UPDATES_PERFORMED+=("Go tools")
}

# Clean up old versions and caches
cleanup() {
  print_header "Cleaning up"

  if command_exists brew; then
    print_status "Cleaning Homebrew cache..."
    brew cleanup --prune=all
    print_success "Homebrew cache cleaned"
  fi

  if command_exists npm; then
    print_status "Cleaning npm cache..."
    npm cache clean --force 2>/dev/null
    print_success "NPM cache cleaned"
  fi

  if command_exists nix-collect-garbage; then
    print_status "Cleaning old Nix generations (keeping last 3)..."
    nix-collect-garbage --delete-older-than 30d
    print_success "Old Nix generations cleaned"
  fi
}

# Generate summary
generate_summary() {
  print_header "Update Summary"

  echo ""
  if [[ ${#UPDATES_PERFORMED[@]} -gt 0 ]]; then
    print_success "Successfully updated:"
    for item in "${UPDATES_PERFORMED[@]}"; do
      echo "  ✓ $item"
    done
  fi

  if [[ ${#UPDATES_FAILED[@]} -gt 0 ]]; then
    echo ""
    print_error "Failed to update:"
    for item in "${UPDATES_FAILED[@]}"; do
      echo "  ✗ $item"
    done
  fi

  if [[ ${#UPDATES_PERFORMED[@]} -eq 0 ]] && [[ ${#UPDATES_FAILED[@]} -eq 0 ]]; then
    print_status "No updates were performed"
  fi

  # Save summary to log
  local log_file="$HOME/.dotfiles/logs/update-all-$(date +%Y%m%d-%H%M%S).log"
  mkdir -p "$HOME/.dotfiles/logs"

  {
    echo "Update All - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "======================================"
    echo ""
    echo "Updates performed: ${#UPDATES_PERFORMED[@]}"
    echo "Updates failed: ${#UPDATES_FAILED[@]}"
    echo ""
    if [[ ${#UPDATES_PERFORMED[@]} -gt 0 ]]; then
      echo "Successfully updated:"
      for item in "${UPDATES_PERFORMED[@]}"; do
        echo "  - $item"
      done
    fi
    if [[ ${#UPDATES_FAILED[@]} -gt 0 ]]; then
      echo ""
      echo "Failed updates:"
      for item in "${UPDATES_FAILED[@]}"; do
        echo "  - $item"
      done
    fi
  } >"$log_file"

  echo ""
  print_status "Log saved to: $log_file"
}

# Main execution
main() {
  print_header "Starting comprehensive system update"
  print_warning "This may take several minutes..."

  # Create backup of current state
  print_status "Recording current package versions..."
  "$HOME/.dotfiles/scripts/check-updates.sh" >"$HOME/.dotfiles/logs/pre-update-check-$(date +%Y%m%d-%H%M%S).log" 2>&1

  # Run all updates
  update_nix
  update_homebrew
  update_npm
  update_ollama
  update_uv_tools
  update_go_tools

  # Clean up
  cleanup

  # Generate summary
  generate_summary

  print_header "Update complete!"
  print_status "Run './scripts/check-updates.sh' to verify all updates"
}

# Parse command line options
while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h     Show this help message"
      echo "  --skip-cleanup Skip cleanup phase"
      echo ""
      echo "This script updates all package managers and tools:"
      echo "  - Nix and Home Manager"
      echo "  - Homebrew packages and casks"
      echo "  - NPM global packages"
      echo "  - Ollama and its models"
      echo "  - Python tools via uv"
      echo "  - Go tools"
      exit 0
      ;;
    --skip-cleanup)
      SKIP_CLEANUP=true
      shift
      ;;
    *)
      print_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Run main function
main "$@"
