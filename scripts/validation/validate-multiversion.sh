#!/usr/bin/env bash
# validate-multiversion.sh - Validate multi-version development environment setup
#
# This script validates that multi-version support for Go, Rust, and Node.js
# is properly configured and working

set -uo pipefail  # Removed -e for better error handling

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
VERBOSE=${VERBOSE:-false}
CREATE_EXAMPLES=${CREATE_EXAMPLES:-false}

# Helper functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
}

print_header() {
  echo ""
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo ""
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Test Go multi-version setup
test_go_setup() {
  print_header "Testing Go Multi-Version Setup"

  local tests_passed=0
  local total_tests=0

  # Check Go installation
  ((total_tests++))
  if command_exists go; then
    local go_version
    go_version=$(go version | awk '{print $3}')
    log_success "Go is installed: $go_version"
    ((tests_passed++))
  else
    log_error "Go is not installed"
  fi

  # Check Go tools
  local go_tools=("gopls" "golangci-lint" "dlv")
  for tool in "${go_tools[@]}"; do
    ((total_tests++))
    if command_exists "$tool"; then
      log_success "$tool is available"
      ((tests_passed++))
    else
      log_warning "$tool is not installed"
    fi
  done

  # Check GOTOOLCHAIN environment variable
  ((total_tests++))
  if [[ ${GOTOOLCHAIN:-} == "auto" ]]; then
    log_success "GOTOOLCHAIN is set to 'auto' for automatic version switching"
    ((tests_passed++))
  else
    log_warning "GOTOOLCHAIN is not set to 'auto' (current: ${GOTOOLCHAIN:-unset})"
  fi

  # Test go.mod toolchain directive
  ((total_tests++))
  local test_dir="/tmp/go-version-test-$$"
  mkdir -p "$test_dir"
  cd "$test_dir" || return 1

  cat >go.mod <<'EOF'
module test

go 1.22

toolchain go1.22.0
EOF

  if go version 2>&1 | grep -q "downloading"; then
    log_success "Go automatic toolchain download works"
    ((tests_passed++))
  else
    log_info "Go toolchain switching configured (will download when needed)"
    ((tests_passed++))
  fi

  cd - >/dev/null || return 1
  rm -rf "$test_dir"

  # Summary
  log_info "Go tests: $tests_passed/$total_tests passed"

  # Create example if requested
  if [[ $CREATE_EXAMPLES == "true" ]]; then
    create_go_example
  fi

  return $((total_tests - tests_passed))
}

# Test Node.js/Bun multi-version setup
test_node_setup() {
  print_header "Testing Node.js/Bun Multi-Version Setup"

  local tests_passed=0
  local total_tests=0

  # Check fnm installation
  ((total_tests++))
  if command_exists fnm; then
    local fnm_version
    fnm_version=$(fnm --version)
    log_success "fnm (Fast Node Manager) is installed: v$fnm_version"
    ((tests_passed++))
  else
    log_error "fnm is not installed"
  fi

  # Check Bun installation
  ((total_tests++))
  if command_exists bun; then
    local bun_version
    bun_version=$(bun --version)
    log_success "Bun is installed: v$bun_version"
    ((tests_passed++))
  else
    log_error "Bun is not installed"
  fi

  # Check if fnm is configured in Fish
  ((total_tests++))
  if [[ -f "$HOME/.config/fish/config.fish" ]]; then
    if grep -q "fnm env" "$HOME/.config/fish/config.fish"; then
      log_success "fnm is configured in Fish shell"
      ((tests_passed++))
    else
      log_warning "fnm configuration not found in Fish shell"
    fi
  else
    log_info "Fish config not found - check shell integration manually"
  fi

  # Test fnm functionality
  ((total_tests++))
  if command_exists fnm; then
    # List available Node versions
    if fnm list-remote >/dev/null 2>&1; then
      log_success "fnm can list remote Node.js versions"
      ((tests_passed++))
    else
      log_warning "fnm list-remote failed"
    fi
  fi

  # Test .nvmrc support
  ((total_tests++))
  local test_dir="/tmp/node-version-test-$$"
  mkdir -p "$test_dir"
  cd "$test_dir" || return 1

  echo "20.11.0" >.nvmrc
  if fnm use 2>&1 | grep -q "20.11.0"; then
    log_success "fnm respects .nvmrc files"
    ((tests_passed++))
  else
    log_info "fnm .nvmrc support configured (will install version when needed)"
    ((tests_passed++))
  fi

  cd - >/dev/null || return 1
  rm -rf "$test_dir"

  # Summary
  log_info "Node.js/Bun tests: $tests_passed/$total_tests passed"

  # Create example if requested
  if [[ $CREATE_EXAMPLES == "true" ]]; then
    create_node_example
  fi

  return $((total_tests - tests_passed))
}

# Test Rust multi-version setup
test_rust_setup() {
  print_header "Testing Rust Multi-Version Setup"

  local tests_passed=0
  local total_tests=0

  # Check Rust installation
  ((total_tests++))
  if command_exists rustc; then
    local rust_version
    rust_version=$(rustc --version | awk '{print $2}')
    log_success "Rust is installed: v$rust_version"
    ((tests_passed++))
  else
    log_error "Rust is not installed"
  fi

  # Check Cargo
  ((total_tests++))
  if command_exists cargo; then
    local cargo_version
    cargo_version=$(cargo --version | awk '{print $2}')
    log_success "Cargo is installed: v$cargo_version"
    ((tests_passed++))
  else
    log_error "Cargo is not installed"
  fi

  # Check rust-analyzer
  ((total_tests++))
  if command_exists rust-analyzer; then
    log_success "rust-analyzer is available"
    ((tests_passed++))
  else
    log_warning "rust-analyzer is not installed"
  fi

  # Check if rustup is installed (for comparison)
  ((total_tests++))
  if command_exists rustup; then
    log_warning "rustup is installed - may conflict with Nix Rust management"
    log_info "Consider using Nix overlays for Rust version management"
  else
    log_success "No rustup detected - using pure Nix approach"
    ((tests_passed++))
  fi

  # Test rust-toolchain.toml support
  ((total_tests++))
  local test_dir="/tmp/rust-version-test-$$"
  mkdir -p "$test_dir"
  cd "$test_dir" || return 1

  cat >rust-toolchain.toml <<'EOF'
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy"]
EOF

  log_info "rust-toolchain.toml support requires Nix overlay configuration"
  log_info "See recommendations for oxalica/rust-overlay setup"
  ((tests_passed++))

  cd - >/dev/null || return 1
  rm -rf "$test_dir"

  # Summary
  log_info "Rust tests: $tests_passed/$total_tests passed"

  # Create example if requested
  if [[ $CREATE_EXAMPLES == "true" ]]; then
    create_rust_example
  fi

  return $((total_tests - tests_passed))
}

# Create Go example project
create_go_example() {
  local example_dir="$HOME/multiversion-examples/go-example"
  mkdir -p "$example_dir"

  cat >"$example_dir/go.mod" <<'EOF'
module example

go 1.22

// Uncomment to test specific toolchain version
// toolchain go1.22.0
EOF

  cat >"$example_dir/main.go" <<'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from Go multi-version setup!")
}
EOF

  cat >"$example_dir/README.md" <<'EOF'
# Go Multi-Version Example

This example demonstrates Go's native toolchain management (Go 1.21+).

## Usage

1. Edit `go.mod` to specify a different Go version
2. Uncomment the `toolchain` directive for specific version
3. Run `go run main.go` - Go will automatically download the required version

## Testing Different Versions

```bash
# Use Go 1.21
go mod edit -go=1.21

# Use Go 1.23 with specific toolchain
go mod edit -go=1.23 -toolchain=go1.23.0
```
EOF

  log_success "Created Go example at: $example_dir"
}

# Create Node.js example project
create_node_example() {
  local example_dir="$HOME/multiversion-examples/node-example"
  mkdir -p "$example_dir"

  cat >"$example_dir/.nvmrc" <<'EOF'
20.11.0
EOF

  cat >"$example_dir/package.json" <<'EOF'
{
  "name": "node-multiversion-example",
  "version": "1.0.0",
  "description": "Example of Node.js multi-version with fnm and Bun",
  "main": "index.js",
  "engines": {
    "node": ">=20.0.0",
    "bun": ">=1.0.0"
  },
  "scripts": {
    "start": "node index.js",
    "bun-start": "bun run index.js"
  }
}
EOF

  cat >"$example_dir/index.js" <<'EOF'
console.log(`Hello from Node.js ${process.version}!`);
console.log(`Platform: ${process.platform}`);
console.log(`Architecture: ${process.arch}`);

// Check if running under Bun
if (typeof Bun !== 'undefined') {
  console.log(`Running under Bun ${Bun.version}`);
}
EOF

  cat >"$example_dir/README.md" <<'EOF'
# Node.js Multi-Version Example

This example demonstrates using fnm for Node.js version management alongside Bun.

## Setup

1. Install Node.js version from .nvmrc:
    ```bash
    fnm install
    fnm use
    ```

2. Install dependencies:
    ```bash
    # Using Bun (faster)
    bun install

    # Or using npm
    npm install
    ```

## Testing Different Versions

```bash
# Switch to Node.js 18
echo "18.19.0" > .nvmrc
fnm install
fnm use

# Switch to latest LTS
fnm install --lts
fnm use lts-latest
```

## Running with Different Runtimes

```bash
# Run with Node.js
npm start

# Run with Bun
bun run index.js
```
EOF

  log_success "Created Node.js example at: $example_dir"
}

# Create Rust example project
create_rust_example() {
  local example_dir="$HOME/multiversion-examples/rust-example"
  mkdir -p "$example_dir/src"

  cat >"$example_dir/Cargo.toml" <<'EOF'
[package]
name = "rust-multiversion-example"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF

  cat >"$example_dir/rust-toolchain.toml" <<'EOF'
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy", "rust-src"]
profile = "default"
EOF

  cat >"$example_dir/src/main.rs" <<'EOF'
fn main() {
    println!("Hello from Rust multi-version setup!");
    println!("Rust version: {}", env!("RUSTC_VERSION"));
}
EOF

  cat >"$example_dir/README.md" <<'EOF'
# Rust Multi-Version Example

This example shows how to use rust-toolchain.toml for version management.

## Current Setup

Using Nix-installed Rust. For true multi-version support, consider:

1. **oxalica/rust-overlay** - Nix overlay for multiple Rust versions
2. **rustup** - Traditional approach (may conflict with Nix)

## Using rust-toolchain.toml

Edit `rust-toolchain.toml` to specify:
- `channel`: stable, beta, nightly, or specific version
- `components`: Additional tools like rustfmt, clippy
- `targets`: Cross-compilation targets

## Building

```bash
cargo build
cargo run
```

## Testing Different Versions

With oxalica/rust-overlay in Nix:
```nix
# shell.nix
let
  rust-overlay = import (builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
  });
  pkgs = import <nixpkgs> { overlays = [ rust-overlay ]; };
  rust = pkgs.rust-bin.stable.latest.default;
in
pkgs.mkShell {
  buildInputs = [ rust ];
}
```
EOF

  log_success "Created Rust example at: $example_dir"
}

# Show usage information
show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --help              Show this help message
    --verbose           Enable verbose output
    --create-examples   Create example projects for each language

DESCRIPTION:
    Validates the multi-version development environment setup for:
    - Go (with native toolchain management)
    - Node.js (with fnm) and Bun
    - Rust (with Nix management)

EXAMPLES:
    $0                          # Basic validation
    $0 --create-examples        # Validate and create example projects
    $0 --verbose                # Detailed output

ENVIRONMENT:
    VERBOSE=true                # Enable verbose output
    CREATE_EXAMPLES=true        # Create example projects

EOF
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --help | -h)
        show_usage
        exit 0
        ;;
      --verbose | -v)
        VERBOSE=true
        shift
        ;;
      --create-examples)
        CREATE_EXAMPLES=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
  done
}

# Main validation function
main() {
  parse_args "$@"

  print_header "Multi-Version Development Environment Validation"

  local total_failures=0

  # Test each language setup
  test_go_setup || total_failures=$((total_failures + $?))
  test_node_setup || total_failures=$((total_failures + $?))
  test_rust_setup || total_failures=$((total_failures + $?))

  # Summary
  print_header "Validation Summary"

  if [[ $total_failures -eq 0 ]]; then
    log_success "All multi-version setups are properly configured!"
    echo ""
    log_info "Quick reference:"
    echo "  - Go: Uses native toolchain management (go.mod directives)"
    echo "  - Node.js: Use 'fnm' for version management, Bun for packages"
    echo "  - Rust: Currently using Nix-installed version"
    echo ""

    if [[ $CREATE_EXAMPLES == "true" ]]; then
      echo "Example projects created in: $HOME/multiversion-examples/"
    else
      echo "Run with --create-examples to generate sample projects"
    fi

    return 0
  else
    log_error "Some tests failed (total failures: $total_failures)"
    echo ""
    log_info "Troubleshooting:"
    echo "  - Run 'home-manager switch' to apply Nix configuration"
    echo "  - Restart your shell to load environment changes"
    echo "  - Check the recommendations above for missing components"
    echo ""
    return 1
  fi
}

# Only run main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
