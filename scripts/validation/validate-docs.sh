#!/usr/bin/env bash
# validate-docs.sh - Validate that documentation is up-to-date with installed tools

set -uo pipefail  # No -e for better error handling

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCS_DIR="$DOTFILES_ROOT/docs/src/content/docs"

# Source helpers
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Arrays to track findings
declare -a MISSING_IN_DOCS=()
declare -a TOOLS_CHECKED=()

# Function to extract tool names from home.nix
get_nix_tools() {
  local home_nix="$DOTFILES_ROOT/nix/home.nix"

  # Extract package names between home.packages = with pkgs; ([ and ]);
  # This is a simplified extraction - focuses on common tool patterns
  rg -o '^\s*([a-zA-Z0-9_-]+)\s*(#|$)' "$home_nix" | \
    sed 's/^\s*//' | \
    sed 's/\s*#.*//' | \
    grep -v '^$' | \
    grep -v -E '^(pkgs|with|let|in|if|then|else|home|programs|config)$' | \
    sort -u
}

# Function to check if a tool is documented
check_tool_in_docs() {
  local tool="$1"
  local found=false

  # Skip certain patterns that aren't actual tools
  case "$tool" in
    nodePackages*|python[0-9]*Packages*|texlive*)
      return 0
      ;;
  esac

  # Search for the tool in documentation files
  # Look for the tool name in various contexts
  if rg -q -i "\b$tool\b" "$DOCS_DIR" 2>/dev/null; then
    found=true
  fi

  if [[ $found == false ]]; then
    # Special cases - check for alternative names
    case "$tool" in
      "k9s")
        rg -q -i "kubernetes.*dashboard\|k9s" "$DOCS_DIR" 2>/dev/null && found=true
        ;;
      "dive")
        rg -q -i "docker.*layer\|dive" "$DOCS_DIR" 2>/dev/null && found=true
        ;;
      "act")
        rg -q -i "github.*actions.*local\|act" "$DOCS_DIR" 2>/dev/null && found=true
        ;;
    esac
  fi

  if [[ $found == false ]]; then
    MISSING_IN_DOCS+=("$tool")
  fi

  TOOLS_CHECKED+=("$tool")
}

# Function to check specific important tools
check_important_tools() {
  print_section "Checking Important Tools Documentation"

  # Key development tools that should definitely be documented
  local important_tools=(
    "git"
    "gh"
    "act"
    "dive"
    "k9s"
    "ripgrep"
    "fd"
    "bat"
    "eza"
    "fzf"
    "tmux"
    "neovim"
    "lazygit"
    "starship"
    "fish"
    "chezmoi"
    "fnm"
    "bun"
    "yarn"
    "pnpm"
    "go"
    "gopls"
    "rustc"
    "cargo"
    "rustfmt"
    "clippy"
    "rust-analyzer"
    "cloudflared"
    "awscli2"
    "google-cloud-sdk"
    "jq"
    "yq"
    "htop"
    "btop"
    "glow"
    "delta"
    "zoxide"
    "direnv"
    "mkcert"
    "httpie"
    "sops"
    "age"
    "playwright-test"
    "ffmpeg"
    "imagemagick"
    "pandoc"
    "rclone"
    "ollama"
  )

  local missing_count=0
  local found_count=0

  for tool in "${important_tools[@]}"; do
    # Special case handling for tools that might be documented differently
    local search_pattern="$tool"
    case "$tool" in
      "awscli2")
        search_pattern="(awscli2|aws-cli|aws cli|AWS CLI)"
        ;;
      "google-cloud-sdk")
        search_pattern="(google-cloud-sdk|gcloud|Google Cloud SDK)"
        ;;
      "rust-analyzer")
        search_pattern="(rust-analyzer|rust analyzer)"
        ;;
      "playwright-test")
        search_pattern="(playwright-test|playwright test|Playwright)"
        ;;
    esac

    if rg -q -i "$search_pattern" "$DOCS_DIR" 2>/dev/null; then
      ((found_count++))
      log_debug "$tool is documented"
    else
      ((missing_count++))
      log_warn "$tool is not documented"
    fi
  done

  log_success "Found $found_count/$((found_count + missing_count)) important tools documented"

  if [[ $missing_count -gt 0 ]]; then
    log_warn "$missing_count important tools are missing from documentation"
  fi
}

# Function to check documentation files exist and are non-empty
check_doc_files() {
  print_section "Checking Documentation Files"

  local expected_files=(
    "01-introduction/getting-started.md"
    "03-cli-tools/index.md"
    "03-cli-tools/modern-replacements.md"
    "reference/cli-utilities.md"
    "reference/package-inventory.md"
    "99-reference/command-cheatsheets.md"
  )

  local missing_files=0
  local empty_files=0

  for file in "${expected_files[@]}"; do
    local full_path="$DOCS_DIR/$file"
    if [[ ! -f "$full_path" ]]; then
      log_error "Missing documentation file: $file"
      ((missing_files++))
    elif [[ ! -s "$full_path" ]]; then
      log_error "Empty documentation file: $file"
      ((empty_files++))
    else
      log_debug "Documentation file exists: $file"
    fi
  done

  if [[ $missing_files -eq 0 && $empty_files -eq 0 ]]; then
    log_success "All expected documentation files exist and are non-empty"
  else
    log_error "Documentation issues: $missing_files missing, $empty_files empty"
  fi
}

# Function to check for outdated examples
check_outdated_examples() {
  print_section "Checking for Outdated Examples"

  # Check for common outdated patterns
  local outdated_patterns=(
    "exa:eza:Use 'eza' instead of deprecated 'exa'"
    "node_v[0-9]+:fnm:Use 'fnm' for Node.js version management"
    "pyenv.*install:pipx:Consider 'pipx' for Python tools"
  )

  local issues_found=0

  for pattern_info in "${outdated_patterns[@]}"; do
    IFS=':' read -r pattern replacement message <<< "$pattern_info"

    if rg -q "$pattern" "$DOCS_DIR" 2>/dev/null; then
      log_warn "$message"
      if [[ -n $VERBOSE ]] && [[ $VERBOSE == true ]]; then
        rg -n "$pattern" "$DOCS_DIR" 2>/dev/null | head -5
      fi
      ((issues_found++))
    fi
  done

  if [[ $issues_found -eq 0 ]]; then
    log_success "No outdated examples found"
  else
    log_warn "Found $issues_found outdated patterns in documentation"
  fi
}

# Function to generate documentation index (optional feature)
generate_doc_index() {
  local index_file="$DOTFILES_ROOT/docs/.tool-index"

  log_info "Generating documentation tool index..."

  # Extract all tool mentions from docs
  rg -o -I '\b[a-z0-9_-]+\b' "$DOCS_DIR" | \
    grep -E '^[a-z0-9_-]+$' | \
    sort -u > "$index_file.tmp"

  # Extract all tools from home.nix
  get_nix_tools > "$index_file.nix.tmp"

  # Create index with metadata
  cat > "$index_file" <<EOF
# Documentation Tool Index
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# This file is auto-generated by validate-docs.sh

[metadata]
docs_dir=$DOCS_DIR
home_nix=$DOTFILES_ROOT/nix/home.nix
last_updated=$(date +%s)

[documented_tools]
EOF

  # Add documented tools that are also in home.nix
  comm -12 "$index_file.tmp" "$index_file.nix.tmp" >> "$index_file"

  # Cleanup
  rm -f "$index_file.tmp" "$index_file.nix.tmp"

  log_success "Generated documentation index at $index_file"
}

# Main validation
main() {
  print_section "DOCUMENTATION VALIDATION"

  # Check if docs directory exists
  if [[ ! -d "$DOCS_DIR" ]]; then
    log_error "Documentation directory not found: $DOCS_DIR"
    exit 1
  fi

  # Run checks
  check_doc_files
  check_important_tools
  check_outdated_examples

  # Optional: Generate index if requested
  if [[ ${GENERATE_INDEX:-false} == true ]]; then
    generate_doc_index
  fi

  # Summary
  print_summary

  if [[ ${#MISSING_IN_DOCS[@]} -gt 0 ]]; then
    echo ""
    log_warn "Tools missing from documentation:"
    for tool in "${MISSING_IN_DOCS[@]}"; do
      echo "  - $tool"
    done
    echo ""
    log_info "Consider adding these tools to the relevant documentation files"
  fi
}

# Parse arguments
VERBOSE=false
GENERATE_INDEX=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v)
      VERBOSE=true
      export LOG_LEVEL=$LOG_DEBUG
      shift
      ;;
    --index)
      GENERATE_INDEX=true
      shift
      ;;
    --fix)
      export FIX_MODE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --verbose, -v  Show detailed output"
      echo "  --index        Generate documentation index file"
      echo "  --fix          Attempt to fix issues (not implemented yet)"
      echo "  -h, --help     Show this help message"
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
