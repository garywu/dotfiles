#!/bin/bash
# validate-all.sh - Comprehensive validation of dotfiles architecture

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
AUTO_FIX=false
VERBOSE=false
QUICK_MODE=false

# Test counters
TOTAL_VALIDATIONS=0
PASSED_VALIDATIONS=0
FAILED_VALIDATIONS=0

# Function to print colored output
print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}================================================================${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}================================================================${NC}"
  echo ""
}

print_status() {
  local status=$1
  local message=$2
  case $status in
    "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
    "PASS")
      echo -e "${GREEN}[✓]${NC} $message"
      ((PASSED_VALIDATIONS++))
      ;;
    "FAIL")
      echo -e "${RED}[✗]${NC} $message"
      ((FAILED_VALIDATIONS++))
      ;;
    "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
    "SKIP") echo -e "${YELLOW}[SKIP]${NC} $message" ;;
    *) echo -e "${RED}[ERROR]${NC} Unknown status: $status - $message" ;;
  esac
}

# Function to run a validation script
run_validation() {
  local validation_name=$1
  local validation_script=$2
  local optional=${3:-false}

  ((TOTAL_VALIDATIONS++))

  print_status "INFO" "Running $validation_name..."

  if [[ ! -f $validation_script ]]; then
    if [[ $optional == "true" ]]; then
      print_status "SKIP" "$validation_name (script not found: $validation_script)"
      return 0
    else
      print_status "FAIL" "$validation_name (script not found: $validation_script)"
      return 1
    fi
  fi

  if ! [[ -x $validation_script ]]; then
    chmod +x "$validation_script"
  fi

  local output
  local exit_code

  if $VERBOSE; then
    "$validation_script" 2>&1
    exit_code=$?
  else
    output=$("$validation_script" 2>&1)
    exit_code=$?
  fi

  if [[ $exit_code -eq 0 ]]; then
    print_status "PASS" "$validation_name"
    return 0
  else
    print_status "FAIL" "$validation_name"
    if ! $VERBOSE && [[ -n ${output:-} ]]; then
      echo "Error output:"
      echo "$output" | sed 's/^/  /'
    fi
    return 1
  fi
}

# Main execution function
main() {
  echo -e "${BOLD}Dotfiles Package Management Validation${NC}"
  echo "Date: $(date)"
  echo "Mode: $(if $QUICK_MODE; then echo "Quick"; else echo "Comprehensive"; fi)"
  echo ""

  # Run package validations
  print_header "PACKAGE MANAGEMENT VALIDATION"

  local validation_dir="$SCRIPT_DIR/validation"

  # Run package validation
  run_validation "Package Policy" "$validation_dir/validate-packages.sh"

  # Run Python validation
  if ! $QUICK_MODE; then
    run_validation "Python Multi-Version" "$validation_dir/validate-python.sh"
  else
    print_status "SKIP" "Python Multi-Version validation (quick mode)"
  fi

  # Generate final report
  print_header "VALIDATION SUMMARY"

  echo "Validation Results:"
  echo "- Total validations: $TOTAL_VALIDATIONS"
  echo "- Passed: $PASSED_VALIDATIONS"
  echo "- Failed: $FAILED_VALIDATIONS"

  if [[ $TOTAL_VALIDATIONS -gt 0 ]]; then
    echo "- Success rate: $(((PASSED_VALIDATIONS * 100) / TOTAL_VALIDATIONS))%"
  fi
  echo ""

  if [[ $FAILED_VALIDATIONS -eq 0 ]]; then
    print_status "PASS" "All validations passed! ✨"
    return 0
  else
    print_status "FAIL" "Some validations failed"
    if $AUTO_FIX; then
      echo ""
      echo "Attempting auto-fix..."
      if [[ -x "$validation_dir/validate-packages.sh" ]]; then
        "$validation_dir/validate-packages.sh" --fix || true
      fi
    fi
    return 1
  fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -h)
      echo "Usage: $0 [--help] [--fix] [--verbose] [--quick]"
      exit 0
      ;;
    --fix)
      AUTO_FIX=true
      shift
      ;;
    --verbose | -v)
      VERBOSE=true
      shift
      ;;
    --quick | -q)
      QUICK_MODE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Execute main function
main "$@"
