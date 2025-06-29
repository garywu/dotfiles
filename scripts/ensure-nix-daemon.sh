#!/usr/bin/env bash
# Ensure Nix daemon is running on macOS

set -euo pipefail

# Only run on macOS
if [[ $(uname -s) != "Darwin" ]]; then
    exit 0
fi

# Check if daemon is running
if ! launchctl list | grep -q "org.nixos.nix-daemon"; then
    echo "🔧 Nix daemon not running. Starting it..."

    # Check if plist exists
    if [[ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]]; then
        if sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null; then
            echo "✅ Nix daemon started successfully"
        else
            echo "❌ Failed to start Nix daemon - may already be loaded"
        fi
    else
        echo "❌ Nix daemon plist not found - Nix may not be properly installed"
        exit 1
    fi
else
    echo "✅ Nix daemon is already running"
fi

# Verify it's working
if nix store ping --store daemon 2>/dev/null; then
    echo "✅ Nix daemon is responsive"
else
    echo "⚠️  Nix daemon may not be fully functional"
fi
