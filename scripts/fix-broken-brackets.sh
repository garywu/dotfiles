#!/bin/bash

# Emergency fix script to repair the multiple bracket issue
# This fixes the broken pattern: [[[[[[[[ ... ]]]]]]]] back to [[ ... ]]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
  echo -e "${GREEN}==>${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
  exit 1
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

# Find all shell scripts
find_shell_scripts() {
  find . -type f \( -name "*.sh" -o -name "*.bash" \) -not -path "./.git/*" -not -path "./docs/*" -not -path "./node_modules/*" 2>/dev/null | sort
  # Also check files with bash shebang
  find . -type f -not -path "./.git/*" -not -path "./docs/*" -not -path "./node_modules/*" -exec grep -l "^#!/.*bash" {} \; 2>/dev/null | sort
  # Also include bootstrap.sh and check.sh specifically
  if [[ -f "bootstrap.sh" ]]; then echo "./bootstrap.sh"; fi
  if [[ -f "check.sh" ]]; then echo "./check.sh"; fi
}

fix_brackets() {
  local file="$1"
  local tmp_file="${file}.tmp"

  # Count broken brackets before fix
  local count
  count=$(grep -o '\[\[\[\[\[\[\[\[' "$file" 2>/dev/null | wc -l || echo 0)

  if [[ $count -gt 0 ]]; then
    print_status "Fixing $count instances in: $file"

    # Fix the broken pattern: multiple brackets to double brackets
    sed -E 's/\[\[\[\[\[\[\[\[\[+/[[/g; s/\]\]\]\]\]\]\]\]\]+/]]/g' "$file" > "$tmp_file"

    # Check if the fix worked
    if ! diff -q "$file" "$tmp_file" >/dev/null; then
      mv "$tmp_file" "$file"
      print_status "✓ Fixed: $file"
    else
      rm -f "$tmp_file"
      print_warning "No changes made to: $file"
    fi
  fi
}

main() {
  print_status "Emergency bracket fix script"
  print_status "This will fix the pattern [[[[[[[[...]]]]]]]] to [[...]]"
  echo ""

  local total_files=0
  local fixed_files=0

  # Get unique list of shell scripts
  find_shell_scripts | sort -u | while read -r file; do
    if [[ -f "$file" ]]; then
      ((total_files++)) || true

      # Check if file has the broken pattern
      if grep -q '\[\[\[\[\[\[\[\[\[' "$file" 2>/dev/null; then
        ((fixed_files++)) || true
        fix_brackets "$file"
      fi
    fi
  done

  echo ""
  print_status "Scan complete!"
  print_status "Files scanned: $total_files"
  print_status "Files fixed: $fixed_files"

  # Verify no more broken patterns exist
  echo ""
  print_status "Verifying fix..."
  local scripts
  scripts=$(find_shell_scripts | sort -u)
  if echo "$scripts" | xargs grep -l '\[\[\[\[\[\[\[\[\[' 2>/dev/null; then
    print_error "Some files still contain broken bracket patterns!"
  else
    print_status "✅ All bracket issues have been fixed!"
  fi
}

main "$@"
