#!/usr/bin/env bash
# validate-playwright.sh - Validate Playwright installation and functionality
#
# This script validates that Playwright is properly installed and functional

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
VERBOSE=${VERBOSE:-false}
INSTALL_BROWSERS=${INSTALL_BROWSERS:-false}

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

# Test Playwright CLI installation
test_playwright_cli() {
  print_header "Testing Playwright CLI Installation"

  if command_exists playwright; then
    local version
    version=$(playwright --version 2>/dev/null | head -1 || echo "unknown")
    log_success "Playwright CLI is available: $version"
    return 0
  else
    log_error "Playwright CLI not found"
    return 1
  fi
}

# Test browser installation
test_browsers() {
  print_header "Testing Browser Installation"

  local browsers_dir=""
  local missing_browsers=()

  # Try to find Playwright browsers directory
  if [[ -d "$HOME/.cache/ms-playwright" ]]; then
    browsers_dir="$HOME/.cache/ms-playwright"
  elif [[ -d "$HOME/Library/Caches/ms-playwright" ]]; then
    browsers_dir="$HOME/Library/Caches/ms-playwright"
  else
    log_warning "Playwright browsers directory not found"
    if [[ $INSTALL_BROWSERS == "true" ]]; then
      log_info "Installing browsers..."
      playwright install
      return $?
    else
      log_info "Run 'playwright install' to install browsers"
      return 1
    fi
  fi

  log_info "Browsers directory: $browsers_dir"

  # Check for common browsers
  local expected_browsers=("chromium" "firefox" "webkit")

  for browser in "${expected_browsers[@]}"; do
    if [[ -d "$browsers_dir/$browser"* ]] 2>/dev/null; then
      log_success "$browser is installed"
    else
      log_warning "$browser is not installed"
      missing_browsers+=("$browser")
    fi
  done

  if [[ ${#missing_browsers[@]} -eq 0 ]]; then
    log_success "All browsers are installed"
    return 0
  else
    log_warning "Missing browsers: ${missing_browsers[*]}"
    if [[ $INSTALL_BROWSERS == "true" ]]; then
      log_info "Installing missing browsers..."
      playwright install "${missing_browsers[@]}"
      return $?
    else
      log_info "Run 'playwright install' to install missing browsers"
      return 1
    fi
  fi
}

# Test basic functionality
test_functionality() {
  print_header "Testing Basic Functionality"

  # Test screenshot functionality (doesn't require X11)
  local test_url="https://example.com"
  local screenshot_file="/tmp/playwright-test-screenshot.png"

  log_info "Testing screenshot capture..."

  if playwright screenshot "$test_url" "$screenshot_file" 2>/dev/null; then
    if [[ -f $screenshot_file ]]; then
      local file_size
      file_size=$(stat -f%z "$screenshot_file" 2>/dev/null || stat -c%s "$screenshot_file" 2>/dev/null || echo "0")
      if [[ $file_size -gt 1000 ]]; then
        log_success "Screenshot test passed (${file_size} bytes)"
        rm -f "$screenshot_file"
        return 0
      else
        log_error "Screenshot file too small (${file_size} bytes)"
        rm -f "$screenshot_file"
        return 1
      fi
    else
      log_error "Screenshot file not created"
      return 1
    fi
  else
    log_error "Screenshot command failed"
    return 1
  fi
}

# Test Node.js integration
test_node_integration() {
  print_header "Testing Node.js Integration"

  if ! command_exists node; then
    log_error "Node.js not found"
    return 1
  fi

  local node_version
  node_version=$(node --version)
  log_info "Node.js version: $node_version"

  # Create a temporary package.json and test playwright installation
  local temp_dir
  temp_dir=$(mktemp -d)
  local original_dir
  original_dir=$(pwd)

  cd "$temp_dir" || return 1

  # Create minimal package.json
  cat >package.json <<'EOF'
{
  "name": "playwright-test",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@playwright/test": "^1.52.0"
  }
}
EOF

  log_info "Testing npm/Playwright integration..."

  if npm install --silent 2>/dev/null; then
    if [[ -f "node_modules/.bin/playwright" ]]; then
      local local_version
      local_version=$(./node_modules/.bin/playwright --version 2>/dev/null | head -1 || echo "unknown")
      log_success "Local Playwright installation works: $local_version"
      cd "$original_dir" || return 1
      rm -rf "$temp_dir"
      return 0
    else
      log_error "Local Playwright binary not found after npm install"
      cd "$original_dir" || return 1
      rm -rf "$temp_dir"
      return 1
    fi
  else
    log_error "npm install failed"
    cd "$original_dir" || return 1
    rm -rf "$temp_dir"
    return 1
  fi
}

# Test Bun integration
test_bun_integration() {
  print_header "Testing Bun Integration"

  if ! command_exists bun; then
    log_warning "Bun not found, skipping integration test"
    return 0
  fi

  local bun_version
  bun_version=$(bun --version)
  log_info "Bun version: $bun_version"

  # Create a temporary test with Bun
  local temp_dir
  temp_dir=$(mktemp -d)
  local original_dir
  original_dir=$(pwd)

  cd "$temp_dir" || return 1

  # Create minimal package.json for Bun
  cat >package.json <<'EOF'
{
  "name": "playwright-bun-test",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@playwright/test": "^1.52.0"
  }
}
EOF

  log_info "Testing Bun/Playwright integration..."

  if bun install --silent 2>/dev/null; then
    if [[ -f "node_modules/.bin/playwright" ]]; then
      log_success "Bun + Playwright integration works"
      cd "$original_dir" || return 1
      rm -rf "$temp_dir"
      return 0
    else
      log_error "Playwright binary not found after bun install"
      cd "$original_dir" || return 1
      rm -rf "$temp_dir"
      return 1
    fi
  else
    log_error "bun install failed"
    cd "$original_dir" || return 1
    rm -rf "$temp_dir"
    return 1
  fi
}

# Generate sample test file
generate_sample_test() {
  print_header "Generating Sample Test File"

  local test_file="playwright-sample-test.js"

  cat >"$test_file" <<'EOF'
// playwright-sample-test.js - Sample Playwright test
const { test, expect } = require('@playwright/test');

test('basic navigation test', async ({ page }) => {
  // Navigate to a simple page
  await page.goto('https://example.com');

  // Check that the page loaded
  await expect(page).toHaveTitle(/Example Domain/);

  // Take a screenshot
  await page.screenshot({ path: 'example-screenshot.png' });

  console.log('✓ Basic navigation test completed successfully');
});

test('form interaction test', async ({ page }) => {
  // Navigate to a form page
  await page.goto('https://httpbin.org/forms/post');

  // Fill out a form
  await page.fill('input[name="custname"]', 'Test User');
  await page.fill('input[name="custtel"]', '555-1234');
  await page.fill('input[name="custemail"]', 'test@example.com');

  // Take screenshot of filled form
  await page.screenshot({ path: 'form-screenshot.png' });

  console.log('✓ Form interaction test completed successfully');
});
EOF

  log_success "Sample test file created: $test_file"
  log_info "Run with: npx playwright test $test_file"

  return 0
}

# Show usage information
show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --help              Show this help message
    --verbose           Enable verbose output
    --install-browsers  Automatically install missing browsers
    --generate-sample   Generate sample test files

EXAMPLES:
    $0                          # Basic validation
    $0 --install-browsers       # Validate and install browsers if missing
    $0 --generate-sample        # Create sample test files
    $0 --verbose                # Detailed output

PLAYWRIGHT COMMANDS:
    playwright install          # Install all browsers
    playwright install chromium # Install specific browser
    playwright codegen          # Generate test code interactively
    playwright test             # Run tests
    playwright show-report      # Show test report

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
      --install-browsers)
        INSTALL_BROWSERS=true
        shift
        ;;
      --generate-sample)
        GENERATE_SAMPLE=true
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

  print_header "Playwright Installation Validation"

  local tests_passed=0
  local total_tests=0

  # Test CLI installation
  ((total_tests++))
  if test_playwright_cli; then
    ((tests_passed++))
  fi

  # Test browsers
  ((total_tests++))
  if test_browsers; then
    ((tests_passed++))
  fi

  # Test functionality (only if browsers are available)
  if [[ $tests_passed -eq 2 ]]; then
    ((total_tests++))
    if test_functionality; then
      ((tests_passed++))
    fi
  fi

  # Test Node.js integration
  ((total_tests++))
  if test_node_integration; then
    ((tests_passed++))
  fi

  # Test Bun integration
  ((total_tests++))
  if test_bun_integration; then
    ((tests_passed++))
  fi

  # Generate sample test if requested
  if [[ ${GENERATE_SAMPLE:-false} == "true" ]]; then
    ((total_tests++))
    if generate_sample_test; then
      ((tests_passed++))
    fi
  fi

  # Summary
  print_header "Validation Summary"

  if [[ $tests_passed -eq $total_tests ]]; then
    log_success "All tests passed ($tests_passed/$total_tests)"
    echo ""
    log_info "Playwright is ready for use!"
    echo ""
    echo "Next steps:"
    echo "  1. Create a new project: mkdir my-playwright-tests && cd my-playwright-tests"
    echo "  2. Initialize: npm init playwright@latest"
    echo "  3. Run tests: npx playwright test"
    echo "  4. View report: npx playwright show-report"
    echo ""
    return 0
  else
    log_error "Some tests failed ($tests_passed/$total_tests passed)"
    echo ""
    log_info "Common solutions:"
    echo "  - Install browsers: playwright install"
    echo "  - Check Node.js version: node --version"
    echo "  - Verify network connectivity"
    echo ""
    return 1
  fi
}

# Only run main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
