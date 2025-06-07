#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Function to check if Tailscale is installed
check_tailscale() {
    if ! command -v tailscale &> /dev/null; then
        print_error "Tailscale is not installed. Please install it first using Homebrew."
        return 1
    fi
    return 0
}

# Function to start Tailscale
start_tailscale() {
    print_status "Starting Tailscale..."
    sudo tailscale up
}

# Function to stop Tailscale
stop_tailscale() {
    print_status "Stopping Tailscale..."
    sudo tailscale down
}

# Function to check Tailscale status
check_status() {
    print_status "Checking Tailscale status..."
    tailscale status
}

# Function to show Tailscale IP
show_ip() {
    print_status "Your Tailscale IP:"
    tailscale ip
}

# Function to show connected peers
show_peers() {
    print_status "Connected Tailscale peers:"
    tailscale status --peers
}

# Function to enable exit node
enable_exit_node() {
    print_status "Enabling exit node..."
    sudo tailscale up --advertise-exit-node
}

# Function to disable exit node
disable_exit_node() {
    print_status "Disabling exit node..."
    sudo tailscale up --advertise-exit-node=false
}

# Function to show exit node status
show_exit_node_status() {
    print_status "Exit node status:"
    tailscale status --exit-nodes
}

# Function to show help
show_help() {
    echo "Tailscale Management Script"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start           Start Tailscale"
    echo "  stop            Stop Tailscale"
    echo "  status          Show Tailscale status"
    echo "  ip              Show Tailscale IP"
    echo "  peers           Show connected peers"
    echo "  enable-exit     Enable exit node"
    echo "  disable-exit    Disable exit node"
    echo "  exit-status     Show exit node status"
    echo "  help            Show this help message"
}

# Main function
main() {
    # Check if Tailscale is installed
    check_tailscale || exit 1

    # Parse command line arguments
    case "$1" in
        "start")
            start_tailscale
            ;;
        "stop")
            stop_tailscale
            ;;
        "status")
            check_status
            ;;
        "ip")
            show_ip
            ;;
        "peers")
            show_peers
            ;;
        "enable-exit")
            enable_exit_node
            ;;
        "disable-exit")
            disable_exit_node
            ;;
        "exit-status")
            show_exit_node_status
            ;;
        "help"|"")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run the main function
main "$@" 