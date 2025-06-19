---
title: Testing Guide
description: How to run tests and add new test cases
---

# Dotfiles Test Suite

This directory contains comprehensive tests for the dotfiles bootstrap and unbootstrap process.

## Structure

```
tests/
├── test_runner.sh      # Main test runner script
├── test_helpers.sh     # Shared helper functions
├── bootstrap/          # Bootstrap-related tests
│   ├── test_smoke_commands.sh      # Check if commands exist
│   └── test_verify_installations.sh # Detailed installation verification
├── cleanup/            # Cleanup/unbootstrap tests
│   └── test_verify_cleanup.sh      # Verify proper cleanup
├── integration/        # Integration tests (future)
└── unit/              # Unit tests (future)
```

## Running Tests

### Run all tests
```bash
./tests/test_runner.sh
```

### Run specific test suite
```bash
./tests/test_runner.sh bootstrap    # Run only bootstrap tests
./tests/test_runner.sh cleanup      # Run only cleanup tests
```

### Run in CI mode
```bash
./tests/test_runner.sh --ci all     # Non-interactive mode for CI
```

### Options
- `-h, --help`: Show help
- `-v, --verbose`: Enable verbose output
- `-q, --quiet`: Suppress non-error output
- `--ci`: Run in CI mode (non-interactive)

## Adding New Tests

1. Create a new test file in the appropriate directory:
   - Name it `test_<name>.sh`
   - Make it executable: `chmod +x test_<name>.sh`

2. Use the test helpers:
   ```bash
   #!/bin/bash
   set -euo pipefail

   TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$TEST_DIR/../test_helpers.sh"

   print_test_header "My New Test"

   # Your test logic here
   if assert_command_exists "mycommand" "My Command"; then
       print_success "Test passed!"
       exit 0
   else
       print_error "Test failed!"
       exit 1
   fi
   ```

## Test Helpers

### Assertion Functions
- `assert_command_exists`: Check if a command is available
- `assert_directory_exists`: Check if a directory exists
- `assert_file_exists`: Check if a file exists
- `assert_symlink_exists`: Check if a symlink exists
- `assert_path_contains`: Check if PATH contains a component
- `assert_not_exists`: Check that something doesn't exist

### Platform Detection
- `is_macos()`: Check if running on macOS
- `is_linux()`: Check if running on Linux
- `is_wsl()`: Check if running on WSL
- `is_ci()`: Check if running in CI environment

### Output Functions
- `print_header`: Print section header
- `print_success`: Print success message (green)
- `print_error`: Print error message (red)
- `print_warning`: Print warning message (yellow)
- `print_info`: Print info message (verbose only)

## CI Integration

The test suite is integrated with GitHub Actions. See `.github/workflows/test-bootstrap.yml`.

## Future Enhancements

- Integration tests for full bootstrap/unbootstrap cycle
- Unit tests for individual script functions
- Performance benchmarks
- Cross-platform compatibility tests
- Regression tests for specific issues
