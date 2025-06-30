#!/usr/bin/env bash
# doc-coverage-report.sh - Generate a report of tools that need documentation

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCS_DIR="$DOTFILES_ROOT/docs/src/content/docs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Extract all tools from home.nix
echo -e "${BLUE}Documentation Coverage Report${NC}"
echo -e "${BLUE}============================${NC}"
echo ""

# Get unique package names from home.nix
echo "Analyzing home.nix packages..."
packages=$(rg -o '^\s*([a-zA-Z0-9_-]+)\s*(#|$)' "$DOTFILES_ROOT/nix/home.nix" | \
  sed 's/^\s*//' | \
  sed 's/\s*#.*//' | \
  grep -v '^$' | \
  grep -v -E '^(pkgs|with|let|in|if|then|else|home|programs|config|texlive)$' | \
  grep -v -E 'Packages\.' | \
  sort -u)

# Check each package
documented=()
undocumented=()

for pkg in $packages; do
  # Skip certain patterns
  case "$pkg" in
    nodePackages*|python[0-9]*|texlive*)
      continue
      ;;
  esac

  # Search for the package in docs
  if rg -q -i "\b$pkg\b" "$DOCS_DIR" 2>/dev/null; then
    documented+=("$pkg")
  else
    undocumented+=("$pkg")
  fi
done

# Summary
echo ""
echo -e "${GREEN}Documented tools: ${#documented[@]}${NC}"
echo -e "${RED}Undocumented tools: ${#undocumented[@]}${NC}"
echo ""

# Show undocumented tools by category
if [[ ${#undocumented[@]} -gt 0 ]]; then
  echo -e "${YELLOW}Tools missing from documentation:${NC}"
  echo ""

  # Categorize tools
  dev_tools=()
  build_tools=()
  cli_tools=()
  other_tools=()

  for tool in "${undocumented[@]}"; do
    case "$tool" in
      rust*|cargo*|go*|python*|node*|npm*|yarn*|pnpm*|bun*|fnm*)
        dev_tools+=("$tool")
        ;;
      gcc*|clang*|cmake*|make*|sccache*|protoc*)
        build_tools+=("$tool")
        ;;
      rg|fd|bat|eza|fzf|tmux|vim*|nvim*|git*|gh|hub|glab*)
        cli_tools+=("$tool")
        ;;
      *)
        other_tools+=("$tool")
        ;;
    esac
  done

  # Print by category
  if [[ ${#dev_tools[@]} -gt 0 ]]; then
    echo "Development Tools:"
    printf '  - %s\n' "${dev_tools[@]}"
    echo ""
  fi

  if [[ ${#build_tools[@]} -gt 0 ]]; then
    echo "Build Tools:"
    printf '  - %s\n' "${build_tools[@]}"
    echo ""
  fi

  if [[ ${#cli_tools[@]} -gt 0 ]]; then
    echo "CLI Tools:"
    printf '  - %s\n' "${cli_tools[@]}"
    echo ""
  fi

  if [[ ${#other_tools[@]} -gt 0 ]]; then
    echo "Other Tools:"
    printf '  - %s\n' "${other_tools[@]}"
    echo ""
  fi

  echo -e "${BLUE}Suggested documentation locations:${NC}"
  echo "- reference/cli-utilities.md - For command-line tools"
  echo "- reference/package-inventory.md - For package listing"
  echo "- 03-cli-tools/modern-replacements.md - For modern tool replacements"
  echo "- 99-reference/command-cheatsheets.md - For usage examples"
fi
