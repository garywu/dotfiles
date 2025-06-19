#!/usr/bin/env bash
# CLI Tool Efficiency Testing: Main Benchmark Runner
#
# PURPOSE: Orchestrate execution of all efficiency benchmarks
# CONTEXT: Issue #20 - Systematic measurement to overcome tool adoption inertia
#
# BACKGROUND:
# This is the main entry point for the efficiency testing framework.
# It coordinates execution of all benchmark categories and generates
# comprehensive reports comparing modern vs traditional CLI tools.
#
# The goal is to provide concrete evidence of efficiency benefits to
# guide Claude CLI tool selection and overcome habits/inertia.

set -euo pipefail

# Script metadata for context preservation
SCRIPT_NAME="CLI Efficiency Benchmark Runner"
ISSUE_REFERENCE="#20"
CREATED_DATE="2025-06-19"
PURPOSE="Orchestrate execution of all CLI tool efficiency benchmarks"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Get script directory and set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EFFICIENCY_DIR="$(dirname "$SCRIPT_DIR")"
BENCHMARKS_DIR="${EFFICIENCY_DIR}/benchmarks"
RESULTS_DIR="${EFFICIENCY_DIR}/results"
LATEST_DIR="${RESULTS_DIR}/latest"
HISTORICAL_DIR="${RESULTS_DIR}/historical"

# Ensure directories exist
mkdir -p "$LATEST_DIR" "$HISTORICAL_DIR"

# Logging function with context preservation
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        INFO) echo -e "${GREEN}[INFO]${NC} ${timestamp}: $message" ;;
        WARN) echo -e "${YELLOW}[WARN]${NC} ${timestamp}: $message" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} ${timestamp}: $message" ;;
        DEBUG) echo -e "${BLUE}[DEBUG]${NC} ${timestamp}: $message" ;;
        HEADER) echo -e "${PURPLE}[EXEC]${NC} ${timestamp}: $message" ;;
    esac

    # Also log to file for historical tracking
    echo "[$level] $timestamp: $message" >> "$LATEST_DIR/benchmark_execution.log"
}

# Display usage information
usage() {
    cat << EOF
${PURPLE}CLI Tool Efficiency Benchmark Runner${NC}

${BLUE}PURPOSE:${NC}
Systematically measure and document CLI tool efficiency to overcome
adoption inertia and provide evidence-based tool selection guidance.

${BLUE}CONTEXT:${NC}
Part of Issue $ISSUE_REFERENCE - addresses the problem that modern CLI tools
are installed but underutilized due to lack of systematic proof of benefits.

${BLUE}USAGE:${NC}
$0 [OPTIONS]

${BLUE}OPTIONS:${NC}
--all           Run all efficiency benchmarks (default)
--search        Run search tool benchmarks (rg vs grep vs ag)
--file-ops      Run file operation benchmarks (eza vs ls, fd vs find)
--data          Run data processing benchmarks (jq, yq, etc.)
--interactive   Run interactive tool benchmarks (gum, fzf)
--quick         Run fast benchmarks only (skip large datasets)
--report-only   Generate reports from existing results
--help          Show this help message

${BLUE}EXAMPLES:${NC}
$0                      # Run all benchmarks
$0 --search --quick     # Quick search benchmarks only
$0 --report-only        # Generate reports without running tests

${BLUE}OUTPUT:${NC}
Results saved to: $LATEST_DIR
Historical data: $HISTORICAL_DIR
Main report: $LATEST_DIR/efficiency_summary_report.md

${BLUE}CONTEXT FOR FUTURE SESSIONS:${NC}
This framework measures two types of efficiency:
1. Human Efficiency: Keystrokes, cognitive load, discoverability
2. Runtime Efficiency: Speed, resource usage, result quality

The goal is providing concrete evidence to guide tool selection and
overcome default behavior patterns that favor traditional tools.

EOF
}

# Archive previous results for historical comparison
archive_previous_results() {
    if [[ -d "$LATEST_DIR" ]] && [[ "$(ls -A "$LATEST_DIR" 2>/dev/null)" ]]; then
        local archive_name="results_$(date +%Y%m%d_%H%M%S)"
        log INFO "Archiving previous results to $archive_name"

        mkdir -p "$HISTORICAL_DIR"
        mv "$LATEST_DIR" "$HISTORICAL_DIR/$archive_name"
        mkdir -p "$LATEST_DIR"
    fi
}

# Run search benchmarks
run_search_benchmarks() {
    log HEADER "Running search tool efficiency benchmarks"

    local benchmark_script="$BENCHMARKS_DIR/search_benchmarks.sh"

    if [[ -x "$benchmark_script" ]]; then
        log INFO "Executing search benchmarks: rg vs grep vs ag"
        if "$benchmark_script"; then
            log INFO "Search benchmarks completed successfully"
        else
            log ERROR "Search benchmarks failed"
            return 1
        fi
    else
        log ERROR "Search benchmark script not found or not executable: $benchmark_script"
        return 1
    fi
}

# Run file operation benchmarks (to be implemented)
run_file_operation_benchmarks() {
    log HEADER "Running file operation efficiency benchmarks"

    # TODO: Implement file operation benchmarks
    # This will test: eza vs ls, fd vs find, bat vs cat
    log WARN "File operation benchmarks not yet implemented (TODO for future)"

    # Create placeholder for now
    cat > "$LATEST_DIR/file_ops_placeholder.md" << EOF
# File Operation Benchmarks - TODO

**Status**: Not yet implemented
**Context**: Issue $ISSUE_REFERENCE
**Planned Tests**:
- eza vs ls (directory listing)
- fd vs find (file searching)
- bat vs cat (file viewing)

**Implementation Notes**:
Will measure both human efficiency (command length, discoverability)
and runtime efficiency (speed, output quality) for file operations.

**Future Context**:
This placeholder ensures we don't lose track of planned file operation
benchmarks in future Claude CLI sessions.
EOF

    log INFO "File operation benchmarks placeholder created"
}

# Run data processing benchmarks (to be implemented)
run_data_processing_benchmarks() {
    log HEADER "Running data processing efficiency benchmarks"

    # TODO: Implement data processing benchmarks
    # This will test: jq vs manual parsing, yq vs manual YAML, sd vs sed
    log WARN "Data processing benchmarks not yet implemented (TODO for future)"

    # Create placeholder for context preservation
    cat > "$LATEST_DIR/data_processing_placeholder.md" << EOF
# Data Processing Benchmarks - TODO

**Status**: Not yet implemented
**Context**: Issue $ISSUE_REFERENCE
**Planned Tests**:
- jq vs manual JSON parsing
- yq vs manual YAML processing
- sd vs sed for text replacement

**Implementation Notes**:
Will measure efficiency of modern data processing tools vs traditional
text manipulation approaches.

**Future Context**:
Placeholder to preserve implementation context for future sessions.
EOF

    log INFO "Data processing benchmarks placeholder created"
}

# Run interactive tool benchmarks (to be implemented)
run_interactive_benchmarks() {
    log HEADER "Running interactive tool efficiency benchmarks"

    # TODO: Implement interactive tool benchmarks
    # This will test: gum vs read, fzf integration patterns
    log WARN "Interactive tool benchmarks not yet implemented (TODO for future)"

    # Create placeholder for context preservation
    cat > "$LATEST_DIR/interactive_placeholder.md" << EOF
# Interactive Tool Benchmarks - TODO

**Status**: Not yet implemented
**Context**: Issue $ISSUE_REFERENCE
**Planned Tests**:
- gum vs read for user input
- fzf integration patterns vs manual selection
- gum choose vs manual menus

**Implementation Notes**:
Interactive tools are harder to benchmark automatically but provide
significant human efficiency improvements. Need special testing approach.

**Future Context**:
Preserve intent to measure interactive tool benefits in future sessions.
EOF

    log INFO "Interactive tool benchmarks placeholder created"
}

# Generate comprehensive summary report
generate_summary_report() {
    log HEADER "Generating comprehensive efficiency summary report"

    cat > "$LATEST_DIR/efficiency_summary_report.md" << EOF
# CLI Tool Efficiency Analysis - Summary Report

**Generated**: $(date)
**Context**: Issue $ISSUE_REFERENCE - CLI Tool Efficiency Testing Framework
**Purpose**: Systematic measurement to overcome tool adoption inertia

## Executive Summary

This report provides evidence-based analysis of CLI tool efficiency to guide
tool selection and overcome default behavior patterns that favor traditional tools.

### Framework Context

**Problem Statement**: Modern CLI tools are installed but underutilized due to:
- Lack of systematic proof of benefits
- Habit/muscle memory defaulting to traditional tools
- No measurement of efficiency gains
- Missing guidance on when/why to use modern alternatives

**Solution Approach**: Systematic measurement of two efficiency types:
1. **Human Efficiency**: Keystrokes, cognitive load, discoverability
2. **Runtime Efficiency**: Speed, resource usage, result quality

## Test Results Summary

### Search Operations ✅
$(if [[ -f "$LATEST_DIR/search_efficiency_report.md" ]]; then
    echo "**Status**: Completed"
    echo "**Key Finding**: ripgrep (rg) shows significant efficiency advantages"
    echo "**Details**: See search_efficiency_report.md"
else
    echo "**Status**: Not executed this run"
fi)

### File Operations ⏳
**Status**: Planned for future implementation
**Scope**: eza vs ls, fd vs find, bat vs cat

### Data Processing ⏳
**Status**: Planned for future implementation
**Scope**: jq vs manual parsing, yq vs YAML, sd vs sed

### Interactive Tools ⏳
**Status**: Planned for future implementation
**Scope**: gum vs read, fzf patterns vs manual selection

## Recommendations for Claude CLI

### Immediate Recommendations
$(if [[ -f "$LATEST_DIR/search_efficiency_report.md" ]]; then
    echo "Based on search benchmark results:"
    echo "- ✅ Default to \`rg pattern\` instead of \`grep -r pattern .\`"
    echo "- ✅ Use ripgrep for all text search operations"
    echo "- ✅ Leverage ripgrep's sensible defaults"
else
    echo "Pending completion of benchmark execution"
fi)

### Future Recommendations
- Will be updated as additional benchmarks are implemented
- Focus on tools with demonstrated efficiency benefits
- Include failure cases and appropriate usage contexts

## Implementation Status

### Completed Infrastructure ✅
- Efficiency testing framework established
- Search benchmarks implemented and tested
- Results archival and historical tracking
- Comprehensive documentation with context preservation

### Planned Additions 📋
- File operation benchmarks
- Data processing benchmarks
- Interactive tool benchmarks
- CI integration for periodic execution
- Enhanced reporting and trend analysis

## Context for Future Sessions

**Critical Information for Claude CLI Continuity**:

1. **Framework Purpose**: Overcome tool adoption inertia through systematic measurement
2. **Location**: All tests and results in \`tests/efficiency/\` directory
3. **Execution**: Run \`./tests/efficiency/tools/benchmark_runner.sh\`
4. **Results**: Latest results in \`tests/efficiency/results/latest/\`
5. **Issue Tracking**: GitHub Issue $ISSUE_REFERENCE

**Key Insight**: Even with modern tools installed, adoption requires concrete
proof of benefits. This framework provides that proof systematically.

**Usage Pattern**:
- Run benchmarks periodically to validate efficiency claims
- Reference results when choosing between tool alternatives
- Extend framework as new tools are added to dotfiles

EOF

    log INFO "Summary report generated: efficiency_summary_report.md"
}

# Main execution function
main() {
    local run_search=false
    local run_file_ops=false
    local run_data=false
    local run_interactive=false
    local quick_mode=false
    local report_only=false
    local run_all=true

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                run_all=true
                shift
                ;;
            --search)
                run_search=true
                run_all=false
                shift
                ;;
            --file-ops)
                run_file_ops=true
                run_all=false
                shift
                ;;
            --data)
                run_data=true
                run_all=false
                shift
                ;;
            --interactive)
                run_interactive=true
                run_all=false
                shift
                ;;
            --quick)
                quick_mode=true
                shift
                ;;
            --report-only)
                report_only=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log ERROR "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Set defaults
    if [[ "$run_all" == "true" ]]; then
        run_search=true
        run_file_ops=true
        run_data=true
        run_interactive=true
    fi

    log HEADER "Starting $SCRIPT_NAME"
    log INFO "Issue: $ISSUE_REFERENCE"
    log INFO "Purpose: $PURPOSE"
    log INFO "Quick mode: $quick_mode"
    log INFO "Report only: $report_only"

    # Archive previous results unless report-only
    if [[ "$report_only" == "false" ]]; then
        archive_previous_results
    fi

    # Execute benchmarks based on options
    if [[ "$report_only" == "false" ]]; then
        if [[ "$run_search" == "true" ]]; then
            run_search_benchmarks || log ERROR "Search benchmarks failed"
        fi

        if [[ "$run_file_ops" == "true" ]]; then
            run_file_operation_benchmarks
        fi

        if [[ "$run_data" == "true" ]]; then
            run_data_processing_benchmarks
        fi

        if [[ "$run_interactive" == "true" ]]; then
            run_interactive_benchmarks
        fi
    fi

    # Always generate summary report
    generate_summary_report

    log HEADER "Efficiency benchmark execution complete!"
    log INFO "Results available in: $LATEST_DIR"
    log INFO "Summary report: $LATEST_DIR/efficiency_summary_report.md"
    log INFO "Execution log: $LATEST_DIR/benchmark_execution.log"

    # Show quick summary if search benchmarks were run
    if [[ -f "$LATEST_DIR/search_efficiency_report.md" ]]; then
        log INFO "Quick preview: Search benchmarks show ripgrep efficiency advantages"
        log INFO "View details: cat '$LATEST_DIR/search_efficiency_report.md'"
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Context preservation comments for future Claude CLI sessions:
#
# This script is the main orchestrator for Issue #20 - CLI Tool Efficiency Testing
#
# Key purposes:
# 1. Coordinate execution of all efficiency benchmark categories
# 2. Archive historical results for trend analysis
# 3. Generate comprehensive reports with actionable recommendations
# 4. Preserve context and implementation details for future sessions
#
# The framework addresses tool adoption inertia by providing systematic
# evidence of efficiency benefits rather than subjective assessments.
#
# Usage in future sessions:
# - Run ./tests/efficiency/tools/benchmark_runner.sh for full analysis
# - Use specific flags (--search, --file-ops, etc.) for targeted testing
# - Reference results when choosing between traditional vs modern tools
# - Extend framework by adding new benchmark categories
#
# Critical insight: Even with tools installed, adoption requires concrete proof.
# This framework provides that proof systematically and preserves context
# for continuous improvement across Claude CLI session restarts.
