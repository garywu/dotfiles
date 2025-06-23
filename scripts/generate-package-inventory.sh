#!/bin/bash
# shellcheck disable=SC2129  # Multiple redirects to same file is intentional for readability

# generate-package-inventory.sh - Generate package inventory documentation
# This script creates a comprehensive inventory of all packages installed via Nix and Homebrew

set -euo pipefail

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/docs/src/content/docs/reference"
OUTPUT_FILE="${OUTPUT_DIR}/package-inventory.md"

# Source helpers if available
if [[[ -f "${SCRIPT_DIR}/ci-helpers.sh" ]]]; then
  # shellcheck source=/dev/null
  source "${SCRIPT_DIR}/ci-helpers.sh"
fi

# Ensure output directory exists
mkdir -p "${OUTPUT_DIR}"

# Function to get installed version
get_installed_version() {
  local package="$1"
  local source="$2"

  if [[[ "$source" == "nix" ]]]; then
    # Try to get version from nix-store
    if command -v "$package" >/dev/null 2>&1; then
      local cmd_path
      cmd_path=$(command -v "$package")
      if [[ "$cmd_path" =~ /nix/store/[^/]+-([^/]+)/ ]]; then
        echo "${BASH_REMATCH[1]}" | cut -d- -f1
        return
      fi
    fi

    # Fallback: try direct version command
    case "$package" in
    git | rustc | cargo | ffmpeg)
      if command -v "$package" >/dev/null 2>&1; then
        "$package" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.?[0-9]*' | head -1 || echo "unknown"
      else
        echo "unknown"
      fi
      ;;
    python311)
      if command -v python3.11 >/dev/null 2>&1; then
        python3.11 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.?[0-9]*' | head -1 || echo "unknown"
      else
        echo "unknown"
      fi
      ;;
    nodejs_20)
      if command -v node >/dev/null 2>&1; then
        node --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.?[0-9]*' | head -1 || echo "unknown"
      else
        echo "unknown"
      fi
      ;;
    go)
      if command -v go >/dev/null 2>&1; then
        go version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.?[0-9]*' | head -1 || echo "unknown"
      else
        echo "unknown"
      fi
      ;;
    imagemagick)
      if command -v magick >/dev/null 2>&1; then
        magick --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+-[0-9]+' | head -1 || echo "unknown"
      else
        echo "unknown"
      fi
      ;;
    *)
      # Try common version flags
      for cmd in "$package" "${package%-*}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
          for flag in "--version" "-version" "version" "-v"; do
            version=$("$cmd" "$flag" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.?[0-9]*' | head -1)
            if [[[ -n "$version" ]]]; then
              echo "$version"
              return
            fi
          done
        fi
      done
      echo "unknown"
      ;;
    esac
  elif [[[ "$source" == "brew" ]]]; then
    if command -v brew >/dev/null 2>&1; then
      brew list --versions "$package" 2>/dev/null | awk '{print $2}' || echo "unknown"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

# Function to check if update is available (simplified for now)
check_update_status() {
  local installed="$1"
  local latest="$2"

  if [[[ "$installed" == "unknown" ]]] || [[[ "$latest" == "unknown" ]]]; then
    echo "❓ Unknown"
  elif [[[ "$installed" == "$latest" ]]]; then
    echo "✅ Current"
  else
    echo "⚠️ Update available"
  fi
}

# Start generating the documentation
cat >"$OUTPUT_FILE" <<'EOF'
---
title: Package Inventory
description: Comprehensive list of all packages installed via Nix and Homebrew
---

# Package Inventory

EOF

echo "Last updated: $(date -u '+%Y-%m-%d %H:%M:%S UTC' || true)" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"

# Parse Nix packages
echo "## Nix Packages" >>"$OUTPUT_FILE"
# Initialize current section
current_section=""

# Track if we're inside programs block
in_programs_block=0

# Read home.nix and extract packages with their sections
while IFS= read -r line; do
  # Check if entering programs block
  if [[ "$line" =~ ^[[:space:]]*programs[[:space:]]*=[[:space:]]*\{ ]]; then
    in_programs_block=1
    current_section=""
    continue
  fi

  # Check if exiting programs block
  if [[[ $in_programs_block -eq 1 ]]] && [[ "$line" =~ ^[[:space:]]*\}[[:space:]]*\;[[:space:]]*$ ]]; then
    in_programs_block=0
    continue
  fi

  # Skip lines inside programs block
  if [[[ $in_programs_block -eq 1 ]]]; then
    continue
  fi

  # Check for section comments
  if [[ "$line" =~ ^[[:space:]]*#[[:space:]](.+) ]]; then
    comment="${BASH_REMATCH[1]}"
    if [[ "$comment" =~ [Tt]ools|[Uu]tilities ]]; then
      current_section="$comment"
      echo "" >>"$OUTPUT_FILE"
      echo "### $current_section" >>"$OUTPUT_FILE"
      echo "" >>"$OUTPUT_FILE"
      echo "| Package | Installed Version | Source | Description |" >>"$OUTPUT_FILE"
      echo "|---------|-------------------|--------|-------------|" >>"$OUTPUT_FILE"
    fi
  # Extract package names
  elif [[[ -n "$current_section" ]]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*#?(.*)$ ]]; then
      package="${BASH_REMATCH[1]}"
      description="${BASH_REMATCH[2]}"
      # Clean up description
      description="${description# }"
      description="${description% }"

      # Skip certain patterns and configuration lines
      if [[ "$package" =~ ^(home|programs|with|in|let|if|then|else|builtins|config|pkgs|nodePackages|pythonPackages|};|]|end|set|eval|source|enable|userName|userEmail|aliases|st|co|br|ci|extraConfig|init|pull|push|shellAliases|ls|ll|la|cat|find|grep|shellInit|settings|add_newline|character|success_symbol|error_symbol|directory|truncation_length|truncate_to_repo|style)$ ]]; then
        continue
      fi

      # Skip if line contains = or {
      if [[[ "$line" =~ = ]]] || [[[ "$line" =~ \{ ]]]; then
        continue
      fi

      # Get installed version
      version=$(get_installed_version "$package" "nix")

      echo "| $package | $version | Nix | $description |" >>"$OUTPUT_FILE"
    fi
  fi
done <"${PROJECT_ROOT}/nix/home.nix"

# Parse Homebrew packages
echo "" >>"$OUTPUT_FILE"
echo "## Homebrew Packages" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"

echo "### Casks (GUI Applications)" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
echo "| Package | Installed Version | Source | Description |" >>"$OUTPUT_FILE"
echo "|---------|-------------------|--------|-------------|" >>"$OUTPUT_FILE"

# Extract cask packages
while IFS= read -r line; do
  if [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\"[[:space:]]*#?(.*)$ ]]; then
    package="${BASH_REMATCH[1]}"
    description="${BASH_REMATCH[2]}"
    description="${description# }"
    description="${description% }"

    version=$(get_installed_version "$package" "brew")
    echo "| $package | $version | Brew Cask | $description |" >>"$OUTPUT_FILE"
  fi
done <"${PROJECT_ROOT}/brew/Brewfile"

echo "" >>"$OUTPUT_FILE"
echo "### Brew Formulas" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
echo "| Package | Installed Version | Source | Description |" >>"$OUTPUT_FILE"
echo "|---------|-------------------|--------|-------------|" >>"$OUTPUT_FILE"

# Extract brew formulas
while IFS= read -r line; do
  if [[ "$line" =~ ^brew[[:space:]]+\"([^\"]+)\"[[:space:]]*#?(.*)$ ]]; then
    package="${BASH_REMATCH[1]}"
    description="${BASH_REMATCH[2]}"
    description="${description# }"
    description="${description% }"

    version=$(get_installed_version "$package" "brew")
    echo "| $package | $version | Brew | $description |" >>"$OUTPUT_FILE"
  fi
done <"${PROJECT_ROOT}/brew/Brewfile"

echo "" >>"$OUTPUT_FILE"
echo "### Mac App Store" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
echo "| Package | App ID | Source | Description |" >>"$OUTPUT_FILE"
echo "|---------|--------|--------|-------------|" >>"$OUTPUT_FILE"

# Extract mas apps
while IFS= read -r line; do
  if [[ "$line" =~ ^mas[[:space:]]+\"([^\"]+)\",[[:space:]]*id:[[:space:]]*([0-9]+) ]]; then
    package="${BASH_REMATCH[1]}"
    app_id="${BASH_REMATCH[2]}"

    echo "| $package | $app_id | Mac App Store | |" >>"$OUTPUT_FILE"
  fi
done <"${PROJECT_ROOT}/brew/Brewfile"

# Add summary statistics
echo "" >>"$OUTPUT_FILE"
echo "## Summary" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"

# Count packages
nix_count=$(grep -c "^[[:space:]]*[a-zA-Z0-9_-]*[[:space:]]*#" "${PROJECT_ROOT}/nix/home.nix" || true)
brew_count=$(grep -cE "^(cask|brew|mas)" "${PROJECT_ROOT}/brew/Brewfile" || true)

echo "- **Total Nix packages**: ~$nix_count" >>"$OUTPUT_FILE"
echo "- **Total Homebrew packages**: $brew_count" >>"$OUTPUT_FILE"
echo "- **Total packages**: ~$((nix_count + brew_count))" >>"$OUTPUT_FILE"

echo "" >>"$OUTPUT_FILE"
echo "## Notes" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
echo "- Version information may be incomplete for some packages" >>"$OUTPUT_FILE"
echo "- Some packages may be installed but not actively used" >>"$OUTPUT_FILE"
echo "- GUI applications are primarily managed through Homebrew on macOS" >>"$OUTPUT_FILE"
echo "- Development tools and CLI utilities are primarily managed through Nix" >>"$OUTPUT_FILE"

echo "✅ Package inventory generated at: $OUTPUT_FILE"
