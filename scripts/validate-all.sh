#!/bin/bash
# validate-all.sh - Master validation script that runs all validation checks

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
# shellcheck source=/dev/null
source "$SCRIPT_DIR/helpers/validation-helpers.sh"

# Validation scripts to run (in order)
VALIDATION_SCRIPTS=(
    "validation/validate-packages.sh"
    "validation/validate-environment.sh"
    # "validation/validate-tools.sh"      # TODO: Uncomment when created
    # "validation/validate-security.sh"    # TODO: Uncomment when created
)

# Track overall results
TOTAL_ERRORS=0
TOTAL_WARNINGS=0
TOTAL_FIXED=0
FAILED_SCRIPTS=()
PASSED_SCRIPTS=()

# Function to run a validation script
run_validation() {
    local script="$1"
    local script_name
    script_name=$(basename "$script")

    print_section "Running $script_name"

    local script_path="$SCRIPT_DIR/$script"
    if [[ ! -f "$script_path" ]]; then
        log_error "Validation script not found: $script_path"
        FAILED_SCRIPTS+=("$script_name (not found)")
        ((TOTAL_ERRORS++))
        return 1
    fi

    if [[ ! -x "$script_path" ]]; then
        log_warn "Making script executable: $script_path"
        chmod +x "$script_path"
    fi

    # Run the script and capture results
    local exit_code=0
    local output
    local temp_file
    temp_file=$(mktemp)

    # Pass through any arguments (like --fix, --debug)
    if output=$("$script_path" "$@" 2>&1 | tee "$temp_file"); then
        exit_code=0
        PASSED_SCRIPTS+=("$script_name")
        log_success "$script_name completed successfully"
    else
        exit_code=$?
        FAILED_SCRIPTS+=("$script_name")
        log_error "$script_name failed with exit code $exit_code"
    fi

    # Extract counts from output (if available)
    if grep -q "Errors:" "$temp_file"; then
        local errors
        errors=$(grep "Errors:" "$temp_file" | grep -oE '[0-9]+' | head -1)
        ((TOTAL_ERRORS += errors))
    fi

    if grep -q "Warnings:" "$temp_file"; then
        local warnings
        warnings=$(grep "Warnings:" "$temp_file" | grep -oE '[0-9]+' | head -1)
        ((TOTAL_WARNINGS += warnings))
    fi

    if grep -q "Fixed:" "$temp_file"; then
        local fixed
        fixed=$(grep "Fixed:" "$temp_file" | grep -oE '[0-9]+' | head -1)
        ((TOTAL_FIXED += fixed))
    fi

    rm -f "$temp_file"
    return $exit_code
}

# Function to generate summary report
generate_report() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    print_section "VALIDATION SUMMARY REPORT"

    echo "Timestamp: $timestamp"
    echo "Host: $(hostname)"
    echo "User: $USER"
    echo

    echo "Scripts Run: ${#VALIDATION_SCRIPTS[@]}"
    echo "Passed: ${#PASSED_SCRIPTS[@]}"
    echo "Failed: ${#FAILED_SCRIPTS[@]}"
    echo

    if [[ ${#PASSED_SCRIPTS[@]} -gt 0 ]]; then
        echo "✅ Passed Scripts:"
        for script in "${PASSED_SCRIPTS[@]}"; do
            echo "   - $script"
        done
        echo
    fi

    if [[ ${#FAILED_SCRIPTS[@]} -gt 0 ]]; then
        echo "❌ Failed Scripts:"
        for script in "${FAILED_SCRIPTS[@]}"; do
            echo "   - $script"
        done
        echo
    fi

    echo "Total Issues Found:"
    echo "   Errors:   $TOTAL_ERRORS"
    echo "   Warnings: $TOTAL_WARNINGS"
    if [[ $TOTAL_FIXED -gt 0 ]]; then
        echo "   Fixed:    $TOTAL_FIXED"
    fi
    echo

    # Overall status
    if [[ $TOTAL_ERRORS -eq 0 ]] && [[ ${#FAILED_SCRIPTS[@]} -eq 0 ]]; then
        echo "✅ Overall Status: PASSED"
        return 0
    else
        echo "❌ Overall Status: FAILED"
        return 1
    fi
}

# Function to save report to file
save_report() {
    local report_dir="$DOTFILES_ROOT/logs/validation"
    mkdir -p "$report_dir"

    local report_file="$report_dir/validation-$(date +%Y%m%d-%H%M%S).log"

    {
        generate_report
        echo
        echo "Full validation output saved to: $report_file"
    } | tee "$report_file"

    # Keep only last 30 reports
    find "$report_dir" -name "validation-*.log" -type f | sort -r | tail -n +31 | xargs -r rm

    log_info "Report saved to: $report_file"
}

# Main execution
main() {
    local start_time
    start_time=$(date +%s)

    print_section "DOTFILES VALIDATION SYSTEM"

    echo "Starting comprehensive validation..."
    echo "Options: $*"
    echo

    # Run all validation scripts
    for script in "${VALIDATION_SCRIPTS[@]}"; do
        run_validation "$script" "$@" || true  # Continue even if one fails
    done

    # Generate and save report
    echo
    save_report

    # Calculate elapsed time
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - start_time))

    echo
    echo "Validation completed in ${elapsed}s"

    # Exit with appropriate code
    if [[ $TOTAL_ERRORS -eq 0 ]] && [[ ${#FAILED_SCRIPTS[@]} -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Master validation script for dotfiles environment"
    echo
    echo "Options:"
    echo "  --fix       Attempt to fix issues automatically"
    echo "  --json      Output results in JSON format"
    echo "  --debug     Enable debug output"
    echo "  --quiet     Suppress verbose output"
    echo "  -h, --help  Show this help message"
    echo
    echo "Validation Scripts:"
    for script in "${VALIDATION_SCRIPTS[@]}"; do
        echo "  - $script"
    done
    echo
    echo "Reports are saved to: logs/validation/"
}

# Parse arguments
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --fix|--json|--debug|--quiet)
            ARGS+=("$1")
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Run main validation
if [[ ${#ARGS[@]} -gt 0 ]]; then
    main "${ARGS[@]}"
else
    main
fi
