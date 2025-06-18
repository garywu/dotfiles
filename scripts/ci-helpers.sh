#!/bin/bash
# CI Helper Functions
# Source this file to get CI-friendly versions of interactive functions

# Check if running in CI
is_ci() {
    [[ "${CI:-}" == "true" ]] || [[ "${GITHUB_ACTIONS:-}" == "true" ]] || [[ "${GITLAB_CI:-}" == "true" ]]
}

# CI-friendly confirmation function
ci_confirm() {
    local prompt="$1"
    local default="${2:-y}"

    if is_ci; then
        echo "${prompt} [auto-confirming with '${default}' in CI]"
        if [[ "${default}" =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    else
        # Interactive mode
        read -r -p "${prompt} " -n 1
        echo
        if [[ ${REPLY} =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}

# CI-friendly pause function
ci_pause() {
    local message="${1:-Press any key to continue...}"

    if is_ci; then
        echo "${message} [skipping in CI]"
        return 0
    else
        read -n 1 -s -r -p "${message}"
        echo
    fi
}

# CI-friendly choice function
ci_choice() {
    local prompt="$1"
    local default="$2"
    shift 2
    local options=("$@")

    if is_ci; then
        echo "${prompt} [auto-selecting '${default}' in CI]"
        echo "${default}"
        return 0
    else
        # Interactive mode
        PS3="${prompt} "
        select opt in "${options[@]}"; do
            if [[ -n "${opt}" ]]; then
                echo "${opt}"
                return 0
            fi
        done
    fi
}

# Export functions
export -f is_ci ci_confirm ci_pause ci_choice
