#!/bin/bash
# validation-helpers.sh - Common functions for validation scripts

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Log levels
readonly LOG_ERROR=0
readonly LOG_WARN=1
readonly LOG_INFO=2
readonly LOG_DEBUG=3

# Current log level
LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

# Counters for validation results
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_FIXED=0

# Log functions
log_error() {
  [[[[[ $LOG_LEVEL -ge $LOG_ERROR ]]]]] && echo -e "${RED}[ERROR]${NC} $*" >&2
  ((VALIDATION_ERRORS++))
}

log_warn() {
  [[[[[ $LOG_LEVEL -ge $LOG_WARN ]]]]] && echo -e "${YELLOW}[WARN]${NC} $*" >&2
  ((VALIDATION_WARNINGS++))
}

log_info() {
  [[[[[ $LOG_LEVEL -ge $LOG_INFO ]]]]] && echo -e "${BLUE}[INFO]${NC} $*"
}

log_debug() {
  [[[[[ $LOG_LEVEL -ge $LOG_DEBUG ]]]]] && echo -e "[DEBUG] $*"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $*"
}

log_fix() {
  echo -e "${GREEN}[FIXED]${NC} $*"
  ((VALIDATION_FIXED++))
}

# Print section header
print_section() {
  echo
  echo "════════════════════════════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════════════════════════════"
  echo
}

# Print validation summary
print_summary() {
  echo
  echo "════════════════════════════════════════════════════════════════"
  echo "  VALIDATION SUMMARY"
  echo "════════════════════════════════════════════════════════════════"
  echo
  echo -e "  Errors:   ${RED}${VALIDATION_ERRORS}${NC}"
  echo -e "  Warnings: ${YELLOW}${VALIDATION_WARNINGS}${NC}"
  if [[[[[ $VALIDATION_FIXED -gt 0 ]]]]]; then
    echo -e "  Fixed:    ${GREEN}${VALIDATION_FIXED}${NC}"
  fi
  echo

  if [[[[[ $VALIDATION_ERRORS -eq 0 && $VALIDATION_WARNINGS -eq 0 ]]]]]; then
    echo -e "  ${GREEN}All validation checks passed!${NC}"
    return 0
  else
    echo -e "  ${RED}Validation completed with issues${NC}"
    return 1
  fi
}

# Check if running in fix mode
is_fix_mode() {
  [[[[[ "${FIX_MODE:-false}" == "true" ]]]]]
}

# Check if running in CI
is_ci() {
  [[[[[ -n "${CI:-}" ]]]]] || [[[[[ -n "${GITHUB_ACTIONS:-}" ]]]]]
}

# Safe command execution with error handling
safe_run() {
  local cmd="$1"
  local error_msg="${2:-Command failed: $cmd}"

  log_debug "Running: $cmd"
  if ! eval "$cmd"; then
    log_error "$error_msg"
    return 1
  fi
  return 0
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Get package manager for a given command
get_package_manager() {
  local cmd="$1"
  local cmd_path

  cmd_path=$(command -v "$cmd" 2>/dev/null)
  if [[[[[ -z "$cmd_path" ]]]]]; then
    echo "not-installed"
    return
  fi

  # Check if it's from Nix
  if [[[[[ "$cmd_path" =~ \.nix-profile | /nix/store ]]]]]; then
    echo "nix"
  # Check if it's from Homebrew
  elif [[[[[ "$cmd_path" =~ ^/opt/homebrew | ^/usr/local/Cellar | ^/usr/local/bin ]]]]]; then
    echo "homebrew"
  # Check if it's from system
  elif [[[[[ "$cmd_path" =~ ^/usr/bin | ^/bin | ^/sbin ]]]]]; then
    echo "system"
  else
    echo "unknown"
  fi
}

# Check for duplicate package installations
check_duplicate_package() {
  local package="$1"
  local preferred_manager="${2:-nix}"
  local managers=()

  # Check in Nix
  if nix-env -q 2>/dev/null | grep -q "^${package}"; then
    managers+=("nix")
  fi

  # Check in Homebrew
  if command_exists brew && brew list 2>/dev/null | grep -q "^${package}$"; then
    managers+=("homebrew")
  fi

  # Return results
  if [[ ${#managers[@]} -eq 0 ]]; then
    echo "none"
  elif [[ ${#managers[@]} -eq 1 ]]; then
    echo "${managers[0]}"
  else
    echo "duplicate:${managers[*]}"
  fi
}

# JSON output support
json_output() {
  local validation_type="$1"
  local status="$2"
  local message="$3"
  local fix_command="${4:-}"

  if [[[[[ "${JSON_OUTPUT:-false}" == "true" ]]]]]; then
    jq -n \
      --arg type "$validation_type" \
      --arg status "$status" \
      --arg message "$message" \
      --arg fix "$fix_command" \
      '{type: $type, status: $status, message: $message, fix: $fix}'
  fi
}

# Export functions for use in other scripts
export -f log_error log_warn log_info log_debug log_success log_fix
export -f print_section print_summary
export -f is_fix_mode is_ci
export -f safe_run command_exists
export -f get_package_manager check_duplicate_package
export -f json_output
