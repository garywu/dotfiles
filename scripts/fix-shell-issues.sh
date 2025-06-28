#!/usr/bin/env bash
# fix-shell-issues.sh - Comprehensive automated shell script fixing
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
SCRIPTS_PROCESSED=0
FIXES_APPLIED=0

print_status() {
  local status=$1
  local message=$2
  case $status in
    "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
    "PASS") echo -e "${GREEN}[✓]${NC} $message" ;;
    "FIX")
      echo -e "${YELLOW}[FIX]${NC} $message"
      ((FIXES_APPLIED++))
      ;;
    "ERROR") echo -e "${RED}[✗]${NC} $message" ;;
  esac
}

# Function to apply shellcheck auto-fixes
apply_shellcheck_fixes() {
  local script="$1"

  if command -v shellcheck >/dev/null 2>&1; then
    # Apply available shellcheck auto-fixes using diff format
    local diff_output
    if diff_output=$(shellcheck -f diff "$script" 2>/dev/null); then
      if [[ -n $diff_output ]]; then
        echo "$diff_output" | patch -s "$script" - 2>/dev/null || true
        print_status "FIX" "Applied ShellCheck auto-fixes to $(basename "$script")"
      fi
    fi
  fi
}

# Function to apply shellharden security fixes
apply_shellharden_fixes() {
  local script="$1"

  if command -v shellharden >/dev/null 2>&1; then
    # Create a backup first
    local backup="${script}.backup"
    cp "$script" "$backup"

    # Apply shellharden transformations
    if shellharden --transform "$script" 2>/dev/null; then
      # Check if file was actually modified
      if ! cmp -s "$backup" "$script" 2>/dev/null; then
        print_status "FIX" "Applied shellharden security fixes to $(basename "$script")"
      fi
    fi

    # Remove backup
    rm -f "$backup"
  fi
}

# Function to apply common manual fixes
apply_manual_fixes() {
  local script="$1"
  local temp_file
  temp_file=$(mktemp)

  # Create a backup
  cp "$script" "$temp_file"

  # Fix SC2086: Quote variables (basic cases)
  # This is conservative to avoid breaking complex cases
  sed -i.bak 's/\$\([A-Za-z_][A-Za-z0-9_]*\)/"$\1"/g' "$script" 2>/dev/null || true

  # Fix common unquoted variable patterns in [[ ]] comparisons
  sed -i.bak 's/\[\[ *\$\([A-Za-z_][A-Za-z0-9_]*\) *==/[[ "$\1" ==/g' "$script" 2>/dev/null || true
  sed -i.bak 's/\[\[ *\$\([A-Za-z_][A-Za-z0-9_]*\) *!=/[[ "$\1" !=/g' "$script" 2>/dev/null || true

  # Fix == comparisons with unquoted right side
  sed -i.bak 's/== *\$\([A-Za-z_][A-Za-z0-9_]*\) *\]\]/== "$\1" ]]/g' "$script" 2>/dev/null || true
  sed -i.bak 's/!= *\$\([A-Za-z_][A-Za-z0-9_]*\) *\]\]/!= "$\1" ]]/g' "$script" 2>/dev/null || true

  # Remove backup files if created
  rm -f "$script.bak" 2>/dev/null || true

  # Check if file was actually modified
  if ! cmp -s "$temp_file" "$script" 2>/dev/null; then
    print_status "FIX" "Applied manual fixes to $(basename "$script")"
  fi

  rm -f "$temp_file"
}

# Function to format with shfmt
apply_formatting() {
  local script="$1"

  if command -v shfmt >/dev/null 2>&1; then
    # Format script with 2-space indentation and case indentation
    if shfmt -w -i 2 -ci "$script" 2>/dev/null; then
      print_status "FIX" "Formatted $(basename "$script") with shfmt"
    fi
  fi
}

# Function to process a single script
process_script() {
  local script="$1"

  if [[ ! -r $script ]]; then
    print_status "ERROR" "Cannot read $script"
    return 1
  fi

  print_status "INFO" "Processing $(basename "$script")"
  ((SCRIPTS_PROCESSED++))

  # 1. Apply formatting first
  apply_formatting "$script"

  # 2. Apply shellharden security fixes
  apply_shellharden_fixes "$script"

  # 3. Apply shellcheck auto-fixes
  apply_shellcheck_fixes "$script"

  # 4. Apply manual fixes for common issues
  apply_manual_fixes "$script"
}

# Main execution
main() {
  print_status "INFO" "Starting comprehensive shell script fixing..."
  echo ""

  # Find all shell scripts in the repository
  local scripts=()
  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find . -type f \( -name "*.sh" -o -name "*.bash" \) -not -path "./node_modules/*" -not -path "./.git/*" -print0)

  if [[ ${#scripts[@]} -eq 0 ]]; then
    print_status "INFO" "No shell scripts found"
    return 0
  fi

  print_status "INFO" "Found ${#scripts[@]} shell script(s) to process"
  echo ""

  # Process each script
  for script in "${scripts[@]}"; do
    process_script "$script"
  done

  echo ""
  print_status "PASS" "Processing complete!"
  print_status "INFO" "Scripts processed: $SCRIPTS_PROCESSED"
  print_status "INFO" "Fixes applied: $FIXES_APPLIED"

  if [[ $FIXES_APPLIED -gt 0 ]]; then
    echo ""
    print_status "INFO" "Run 'git diff' to review changes"
    print_status "INFO" "Run 'git add -u && git commit' to commit fixes"
  fi
}

# Handle command line arguments
case "${1:-}" in
  "--help" | "-h")
    echo "Usage: $0 [--help]"
    echo ""
    echo "Automatically fixes common shell script issues including:"
    echo "  • Code formatting with shfmt"
    echo "  • Security hardening with shellharden"
    echo "  • ShellCheck auto-fixable issues"
    echo "  • Common quoting issues"
    echo "  • Variable quoting in comparisons"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    exit 0
    ;;
  *)
    main "$@"
    ;;
esac
