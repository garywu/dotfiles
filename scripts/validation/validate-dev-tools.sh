#!/usr/bin/env bash
# validate-dev-tools.sh - Validate development tools installation

set -uo pipefail  # Removed -e for better error handling

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source helpers
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Expected Rust tools
RUST_TOOLS=(
  "rustc"
  "cargo"
  "rustfmt"
  "clippy"
  "rust-analyzer"
  "cargo-watch"
  "cargo-nextest"
)

# Optional Rust tools
RUST_TOOLS_OPTIONAL=(
  "cargo-edit"
)

# Expected Go tools
GO_TOOLS=(
  "go"
  "gopls"
  "golangci-lint"
  "dlv"
  "gofumpt"
  "gomodifytags"
  "impl"
  "gotests"
)

# Expected build tools
BUILD_TOOLS=(
  "sccache"
  "protoc"
)

# Expected Node.js tools
NODE_TOOLS=(
  "node"
  "npm"
  "yarn"
  "pnpm"
  "bun"
  "fnm"
)

# Expected container & Kubernetes tools
CONTAINER_TOOLS=(
  "act"
  "dive"
  "k9s"
)

# Function to check Rust tools
check_rust_tools() {
  print_section "Rust Development Tools"

  for tool in "${RUST_TOOLS[@]}"; do
    # Special handling for cargo subcommands
    if [[ $tool == "cargo-"* ]]; then
      local subcommand="${tool#cargo-}"
      if cargo --list 2>/dev/null | grep -q "^[[:space:]]*$subcommand"; then
        log_success "$tool is available as 'cargo $subcommand'"
      else
        if [[ $tool == "cargo-edit" ]]; then
          log_warn "$tool not found (optional)"
          log_info "  Install with: cargo install $tool"
        else
          log_error "$tool not found"
          log_info "  Install with: cargo install $tool"
        fi
      fi
    elif [[ $tool == "clippy" ]] && cargo --list 2>/dev/null | grep -q "^[[:space:]]*clippy"; then
      # Special case for clippy which is a cargo subcommand
      local version=$(cargo clippy --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
      log_success "$tool ($version)"
    elif command_exists "$tool"; then
      local version
      case "$tool" in
        rustc)
          version=$(rustc --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
          ;;
        cargo)
          version=$(cargo --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
          ;;
        rustfmt)
          version=$(rustfmt --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
          ;;
        clippy)
          if cargo --list 2>/dev/null | grep -q "^[[:space:]]*clippy"; then
            version=$(cargo clippy --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
          else
            version=""
          fi
          ;;
        *)
          version="installed"
          ;;
      esac
      log_success "$tool ($version)"
    else
      log_error "$tool not found"
    fi
  done

  # Check cargo registry
  if [[ -f "$HOME/.cargo/config.toml" ]] || [[ -f "$HOME/.cargo/config" ]]; then
    log_success "Cargo configuration found"
  else
    log_info "No custom cargo configuration"
  fi
}

# Function to check Go tools
check_go_tools() {
  print_section "Go Development Tools"

  for tool in "${GO_TOOLS[@]}"; do
    if command_exists "$tool"; then
      local version
      case "$tool" in
        go)
          version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "unknown")
          ;;
        gopls)
          version=$(gopls version 2>/dev/null | grep -o 'v[0-9.]*' | head -1 || echo "installed")
          ;;
        *)
          version="installed"
          ;;
      esac
      log_success "$tool ($version)"
    else
      log_error "$tool not found"
      if [[ $tool != "go" ]]; then
        log_info "  Install with: go install <package>"
      fi
    fi
  done

  # Check GOPATH and GOBIN
  if [[ -n ${GOPATH:-} ]]; then
    log_success "GOPATH is set: $GOPATH"
  else
    log_info "GOPATH not set (using default)"
  fi

  if [[ -n ${GOBIN:-} ]]; then
    log_success "GOBIN is set: $GOBIN"
  else
    log_info "GOBIN not set (using GOPATH/bin)"
  fi
}

# Function to check build tools
check_build_tools() {
  print_section "Build Acceleration Tools"

  for tool in "${BUILD_TOOLS[@]}"; do
    if command_exists "$tool"; then
      local version
      case "$tool" in
        sccache)
          version=$(sccache --version 2>/dev/null | grep -o '[0-9.]*' | head -1 || echo "installed")
          # Check if sccache is configured
          if [[ -n ${RUSTC_WRAPPER:-} ]] && [[ $RUSTC_WRAPPER == *"sccache"* ]]; then
            log_success "$tool ($version) - configured as RUSTC_WRAPPER"
          else
            log_success "$tool ($version)"
            log_info "  To use: export RUSTC_WRAPPER=sccache"
          fi
          ;;
        protoc)
          version=$(protoc --version 2>/dev/null | cut -d' ' -f2 || echo "installed")
          log_success "$tool ($version)"
          ;;
        *)
          log_success "$tool"
          ;;
      esac
    else
      log_error "$tool not found"
    fi
  done
}

# Function to check Node.js tools
check_node_tools() {
  print_section "Node.js Development Tools"

  for tool in "${NODE_TOOLS[@]}"; do
    if command_exists "$tool"; then
      local version
      case "$tool" in
        node)
          version=$(node --version 2>/dev/null || echo "unknown")
          ;;
        npm)
          version=$(npm --version 2>/dev/null || echo "unknown")
          ;;
        yarn)
          version=$(yarn --version 2>/dev/null || echo "unknown")
          ;;
        pnpm)
          version=$(pnpm --version 2>/dev/null || echo "unknown")
          ;;
        bun)
          version=$(bun --version 2>/dev/null || echo "unknown")
          ;;
        fnm)
          version=$(fnm --version 2>/dev/null || echo "unknown")
          ;;
        *)
          version="installed"
          ;;
      esac
      log_success "$tool ($version)"
    else
      log_error "$tool not found"
    fi
  done

  # Check fnm configuration
  if command_exists fnm; then
    if [[ -f "$HOME/.node-version" ]] || [[ -f "$HOME/.nvmrc" ]]; then
      log_success "Node version file found"
    else
      log_info "No .node-version or .nvmrc file"
    fi
  fi
}

# Function to check language servers
check_language_servers() {
  print_section "Language Servers (LSP)"

  # Only check for LSPs we actually have installed via Nix
  local lsp_servers=(
    "rust-analyzer:Rust"
    "gopls:Go"
  )

  # Optional LSPs (not checked by default)
  # "typescript-language-server:TypeScript"  # npm install -g typescript-language-server
  # "pyright:Python"                         # pipx install pyright

  for entry in "${lsp_servers[@]}"; do
    local cmd="${entry%%:*}"
    local lang="${entry#*:}"
    if command_exists "$cmd"; then
      log_success "$lang LSP: $cmd"
    else
      log_warn "$lang LSP not found: $cmd"
    fi
  done
}

# Function to check container & Kubernetes tools
check_container_tools() {
  print_section "Container & Kubernetes Tools"

  for tool in "${CONTAINER_TOOLS[@]}"; do
    if command_exists "$tool"; then
      local version
      case "$tool" in
        act)
          version=$(act --version 2>/dev/null | grep -o '[0-9.]*' | head -1 || echo "installed")
          log_success "$tool ($version)"
          ;;
        dive)
          version=$(dive --version 2>/dev/null | grep -o 'Version: [0-9.]*' | cut -d' ' -f2 || echo "installed")
          log_success "$tool ($version)"
          ;;
        k9s)
          version=$(k9s version --short 2>/dev/null | grep -o 'Version[[:space:]]*[v0-9.]*' | awk '{print $2}' || echo "installed")
          log_success "$tool ($version)"
          ;;
        *)
          log_success "$tool"
          ;;
      esac
    else
      log_error "$tool not found"
    fi
  done
}

# Main validation
main() {
  print_section "DEVELOPMENT TOOLS VALIDATION"

  # Check each tool category
  check_rust_tools
  check_go_tools
  check_build_tools
  check_node_tools
  check_container_tools
  check_language_servers

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
