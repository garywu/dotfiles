#!/usr/bin/env bash
# validate-python.sh - Comprehensive Python multi-version validation

set -uo pipefail  # Removed -e for better error handling

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
EXPECTED_PYTHON_VERSIONS=("3.10" "3.11" "3.12" "3.13")
DEFAULT_PYTHON_VERSION="3.11"

# Function to print colored output
print_status() {
  local status=$1
  local message=$2
  case $status in
    "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
    "PASS")
      echo -e "${GREEN}[✓]${NC} $message"
      ((TESTS_PASSED++))
      ;;
    "FAIL")
      echo -e "${RED}[✗]${NC} $message"
      ((TESTS_FAILED++))
      ;;
    "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
    "SKIP")
      echo -e "${YELLOW}[SKIP]${NC} $message"
      ((TESTS_SKIPPED++))
      ;;
    *) echo -e "${RED}[ERROR]${NC} Unknown status: $status - $message" ;;
  esac
}

# Function to run a test
run_test() {
  local test_name=$1
  local test_command=$2

  print_status "INFO" "Running test: $test_name"

  if eval "$test_command" >/dev/null 2>&1; then
    print_status "PASS" "$test_name"
    return 0
  else
    print_status "FAIL" "$test_name"
    return 1
  fi
}

# Function to test Python version availability
test_python_version() {
  local version=$1
  local python_cmd="python$version"

  if command -v "$python_cmd" >/dev/null 2>&1; then
    local actual_version
    actual_version=$($python_cmd --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
    if [[ $actual_version == $version.* ]]; then
      print_status "PASS" "Python $version available and correct version ($actual_version)"
      return 0
    else
      print_status "FAIL" "Python $version version mismatch: expected $version.*, got $actual_version"
      return 1
    fi
  else
    print_status "FAIL" "Python $version not available in PATH"
    return 1
  fi
}

# Function to test pip for a Python version
test_pip_version() {
  local version=$1
  local python_cmd="python$version"

  if command -v "$python_cmd" >/dev/null 2>&1; then
    if $python_cmd -m pip --version >/dev/null 2>&1; then
      local pip_python_version
      pip_python_version=$($python_cmd -m pip --version | grep -o 'python [0-9]\+\.[0-9]\+' | cut -d' ' -f2)
      if [[ $pip_python_version == $version ]]; then
        print_status "PASS" "pip for Python $version works correctly"
        return 0
      else
        print_status "FAIL" "pip for Python $version uses wrong Python version: $pip_python_version"
        return 1
      fi
    else
      print_status "FAIL" "pip not available for Python $version"
      return 1
    fi
  else
    print_status "SKIP" "Python $version not available, skipping pip test"
    return 0
  fi
}

# Function to test Python package installation
test_package_installation() {
  local version=$1
  local python_cmd="python$version"
  local test_package="requests"

  if ! command -v "$python_cmd" >/dev/null 2>&1; then
    print_status "SKIP" "Python $version not available, skipping package installation test"
    return 0
  fi

  print_status "INFO" "Testing package installation for Python $version"

  # Create a temporary virtual environment
  local temp_venv
  temp_venv=$(mktemp -d)

  if $python_cmd -m venv "$temp_venv" >/dev/null 2>&1; then
    # Activate virtual environment and install package
    if source "$temp_venv/bin/activate" && pip install "$test_package" >/dev/null 2>&1; then
      # Test import
      if python -c "import $test_package" >/dev/null 2>&1; then
        print_status "PASS" "Package installation works for Python $version"
        local result=0
      else
        print_status "FAIL" "Package import failed for Python $version"
        local result=1
      fi
      deactivate
    else
      print_status "FAIL" "Package installation failed for Python $version"
      local result=1
    fi
  else
    print_status "FAIL" "Virtual environment creation failed for Python $version"
    local result=1
  fi

  # Cleanup
  rm -rf "$temp_venv"
  return $result
}

# Function to test PATH precedence
test_path_precedence() {
  print_status "INFO" "Testing PATH precedence for Python tools"

  # Test default python3
  local python3_path
  python3_path=$(command -v python3 2>/dev/null || echo "")

  if [[ $python3_path == *".nix-profile"* ]]; then
    print_status "PASS" "python3 uses Nix: $python3_path"
  elif [[ $python3_path == *"/opt/homebrew"* ]]; then
    print_status "WARN" "python3 uses Homebrew: $python3_path (check PATH order)"
    return 1
  elif [[ $python3_path == *"/usr/bin"* ]]; then
    print_status "WARN" "python3 uses system: $python3_path (check if Nix is properly configured)"
    return 1
  else
    print_status "FAIL" "python3 source unknown: $python3_path"
    return 1
  fi

  # Test default pip3
  local pip3_path
  pip3_path=$(command -v pip3 2>/dev/null || echo "")

  if [[ $pip3_path == *".nix-profile"* ]]; then
    print_status "PASS" "pip3 uses Nix: $pip3_path"
    return 0
  elif [[ $pip3_path == *"/opt/homebrew"* ]]; then
    print_status "WARN" "pip3 uses Homebrew: $pip3_path (check PATH order)"
    return 1
  else
    print_status "FAIL" "pip3 source unknown or missing: $pip3_path"
    return 1
  fi
}

# Function to test Python version consistency
test_version_consistency() {
  print_status "INFO" "Testing Python version consistency"

  # Test that default python3 points to expected version
  if command -v python3 >/dev/null 2>&1; then
    local default_version
    default_version=$(python3 --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+' | head -1)

    if [[ $default_version == "$DEFAULT_PYTHON_VERSION" ]]; then
      print_status "PASS" "Default python3 is correct version: $default_version"
    else
      print_status "FAIL" "Default python3 is wrong version: expected $DEFAULT_PYTHON_VERSION, got $default_version"
      return 1
    fi
  else
    print_status "FAIL" "Default python3 not available"
    return 1
  fi

  # Test that python3.11 and python3 point to the same binary
  if command -v python3.11 >/dev/null 2>&1; then
    local python3_version python311_version
    python3_version=$(python3 --version 2>&1)
    python311_version=$(python3.11 --version 2>&1)

    if [[ $python3_version == $python311_version ]]; then
      print_status "PASS" "python3 and python3.11 are consistent"
    else
      print_status "FAIL" "python3 and python3.11 version mismatch: '$python3_version' vs '$python311_version'"
      return 1
    fi
  else
    print_status "WARN" "python3.11 not available for consistency check"
  fi

  return 0
}

# Function to test Python wrappers
test_python_wrappers() {
  print_status "INFO" "Testing Python wrapper scripts"

  local wrapper_dir="$HOME/.local/bin"
  local wrappers_found=0

  for version in "${EXPECTED_PYTHON_VERSIONS[@]}"; do
    if [[ $version != $DEFAULT_PYTHON_VERSION ]]; then
      local wrapper="$wrapper_dir/python$version"
      if [[ -x $wrapper ]]; then
        print_status "PASS" "Python $version wrapper exists and is executable"
        ((wrappers_found++))
      else
        print_status "WARN" "Python $version wrapper missing: $wrapper"
      fi
    fi
  done

  if [[ $wrappers_found -gt 0 ]]; then
    return 0
  else
    print_status "FAIL" "No Python wrapper scripts found"
    return 1
  fi
}

# Function to test Homebrew conflicts
test_homebrew_conflicts() {
  if ! command -v brew >/dev/null 2>&1; then
    print_status "SKIP" "Homebrew not available, skipping conflict tests"
    return 0
  fi

  print_status "INFO" "Testing for Homebrew Python conflicts"

  # Check for problematic Homebrew Python packages
  local problematic_packages=("python" "python@3.10" "python@3.11" "python@3.13" "awscli" "google-cloud-sdk")
  local conflicts_found=false

  for package in "${problematic_packages[@]}"; do
    if brew list "$package" >/dev/null 2>&1; then
      # Check if it's an acceptable exception
      if [[ $package == "python@3.12" ]] && brew uses "$package" --installed | grep -q "ra-aid"; then
        print_status "PASS" "$package is acceptable exception (required by ra-aid)"
      else
        print_status "FAIL" "Conflicting Homebrew package found: $package"
        conflicts_found=true
      fi
    fi
  done

  if ! $conflicts_found; then
    print_status "PASS" "No problematic Homebrew Python packages found"
    return 0
  else
    return 1
  fi
}

# Function to generate detailed report
generate_report() {
  print_status "INFO" "Generating Python validation report"

  echo ""
  echo "================================="
  echo "  PYTHON VALIDATION REPORT"
  echo "================================="
  echo ""
  echo "System Information:"
  echo "- OS: $(uname -s)"
  echo "- Architecture: $(uname -m)"
  echo "- Date: $(date)"
  echo ""

  echo "Python Versions Found:"
  for version in "${EXPECTED_PYTHON_VERSIONS[@]}"; do
    local python_cmd="python$version"
    if command -v "$python_cmd" >/dev/null 2>&1; then
      local full_version
      full_version=$($python_cmd --version 2>&1)
      local python_path
      python_path=$(command -v "$python_cmd")
      echo "- $python_cmd: $full_version ($python_path)"
    else
      echo "- $python_cmd: Not available"
    fi
  done
  echo ""

  echo "Default Python:"
  if command -v python3 >/dev/null 2>&1; then
    echo "- python3: $(python3 --version 2>&1) ($(command -v python3))"
  else
    echo "- python3: Not available"
  fi

  if command -v pip3 >/dev/null 2>&1; then
    echo "- pip3: $(pip3 --version 2>&1 | head -1) ($(command -v pip3))"
  else
    echo "- pip3: Not available"
  fi
  echo ""

  echo "PATH Information:"
  echo "$PATH" | tr ':' '\n' | head -10 | sed 's/^/  /'
  echo ""

  echo "Test Results:"
  echo "- Passed: $TESTS_PASSED"
  echo "- Failed: $TESTS_FAILED"
  echo "- Skipped: $TESTS_SKIPPED"
  echo "- Total: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
  echo ""

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✅ All tests passed!"
    return 0
  else
    echo "❌ Some tests failed. See details above."
    return 1
  fi
}

# Main execution
main() {
  echo "Starting Python multi-version validation..."
  echo ""

  # Basic availability tests
  print_status "INFO" "Testing Python version availability"
  for version in "${EXPECTED_PYTHON_VERSIONS[@]}"; do
    test_python_version "$version"
  done
  echo ""

  # Pip tests
  print_status "INFO" "Testing pip availability"
  for version in "${EXPECTED_PYTHON_VERSIONS[@]}"; do
    test_pip_version "$version"
  done
  echo ""

  # PATH precedence tests
  test_path_precedence
  echo ""

  # Version consistency tests
  test_version_consistency
  echo ""

  # Wrapper script tests
  test_python_wrappers
  echo ""

  # Homebrew conflict tests
  test_homebrew_conflicts
  echo ""

  # Package installation tests (only if requested)
  if [[ ${1:-} == "--test-installation" ]]; then
    print_status "INFO" "Testing package installation (this may take a while)"
    for version in "${EXPECTED_PYTHON_VERSIONS[@]}"; do
      test_package_installation "$version"
    done
    echo ""
  fi

  # Generate final report
  generate_report
}

# Handle command line arguments
case "${1:-}" in
  "--help" | "-h")
    echo "Usage: $0 [--test-installation] [--help]"
    echo ""
    echo "Options:"
    echo "  --test-installation  Run package installation tests (slower)"
    echo "  --help, -h           Show this help message"
    exit 0
    ;;
  *)
    main "$@"
    ;;
esac
