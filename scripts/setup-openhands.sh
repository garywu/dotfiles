#!/bin/bash

# OpenHands Setup and Management Script
# Provides easy installation, updates, and management of OpenHands

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENHANDS_VERSION="0.43"
CONTAINER_NAME="openhands-app"
STATE_DIR="$HOME/.openhands-state"
CONFIG_DIR="$HOME/.config/openhands"
SERVICE_NAME="openhands"

# Function to print colored output
print_status() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check Docker
check_docker() {
  # Check if docker exists (separate from condition to avoid SC2310)
  command_exists docker
  local docker_exists=$?

  if [[[ $docker_exists -ne 0 ]]]; then
    print_error "Docker is not installed. Please install Docker first."
    return 1
  fi

  if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker."
    return 1
  fi

  print_status "Docker is available"
}

# Function to create directories
create_directories() {
  print_info "Creating OpenHands directories..."
  mkdir -p "$STATE_DIR"
  mkdir -p "$CONFIG_DIR"
  print_status "Directories created"
}

# Function to create configuration file
create_config() {
  cat >"$CONFIG_DIR/config.env" <<EOF
# OpenHands Configuration
OPENHANDS_VERSION=${OPENHANDS_VERSION}
SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:${OPENHANDS_VERSION}-nikolaik
LOG_ALL_EVENTS=true

# Add your API keys here
# ANTHROPIC_API_KEY=your_key_here
# OPENAI_API_KEY=your_key_here
EOF
  print_status "Configuration file created at $CONFIG_DIR/config.env"
  print_info "Edit $CONFIG_DIR/config.env to add your API keys"
}

# Function to pull latest images
pull_images() {
  print_info "Pulling OpenHands images..."
  docker pull "docker.all-hands.dev/all-hands-ai/openhands:${OPENHANDS_VERSION}"
  docker pull "docker.all-hands.dev/all-hands-ai/runtime:${OPENHANDS_VERSION}-nikolaik"
  print_status "Images pulled successfully"
}

# Function to start OpenHands
start_openhands() {
  print_info "Starting OpenHands..."

  # Stop existing container if running
  if docker ps -q --filter "name=${CONTAINER_NAME}" | grep -q .; then
    print_info "Stopping existing OpenHands container..."
    docker stop "${CONTAINER_NAME}" >/dev/null
  fi

  # Remove existing container if exists
  if docker ps -aq --filter "name=${CONTAINER_NAME}" | grep -q .; then
    docker rm "${CONTAINER_NAME}" >/dev/null
  fi

  # Start new container
  docker run -d \
    --name "${CONTAINER_NAME}" \
    --env-file "$CONFIG_DIR/config.env" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$STATE_DIR:/.openhands-state" \
    -p 3030:3000 \
    --add-host host.docker.internal:host-gateway \
    --restart unless-stopped \
    "docker.all-hands.dev/all-hands-ai/openhands:${OPENHANDS_VERSION}"

  print_status "OpenHands started successfully"
  print_info "Access OpenHands at: http://localhost:3030"
}

# Function to stop OpenHands
stop_openhands() {
  if docker ps -q --filter "name=${CONTAINER_NAME}" | grep -q .; then
    print_info "Stopping OpenHands..."
    docker stop "${CONTAINER_NAME}"
    print_status "OpenHands stopped"
  else
    print_info "OpenHands is not running"
  fi
}

# Function to check status
status_openhands() {
  if docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "${CONTAINER_NAME}"; then
    print_status "OpenHands is running"
    docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    print_info "Access at: http://localhost:3030"
  else
    print_warning "OpenHands is not running"
  fi
}

# Function to update OpenHands
update_openhands() {
  print_info "Updating OpenHands..."

  # Check for newer version (simplified - you could check GitHub API)
  print_info "Current version: ${OPENHANDS_VERSION}"

  # Stop current instance
  stop_openhands

  # Pull latest images
  pull_images

  # Start with new version
  start_openhands

  print_status "OpenHands updated successfully"
}

# Function to show logs
logs_openhands() {
  if docker ps -q --filter "name=${CONTAINER_NAME}" | grep -q .; then
    docker logs -f "${CONTAINER_NAME}"
  else
    print_error "OpenHands is not running"
  fi
}

# Function to create systemd service (Linux only)
create_systemd_service() {
  uname_result=$(uname)
  if [[[ "$uname_result" != "Linux" ]]]; then
    print_warning "Systemd service creation is only available on Linux"
    return 0
  fi

  cat >"/tmp/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=OpenHands AI Assistant
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start ${CONTAINER_NAME}
ExecStop=/usr/bin/docker stop ${CONTAINER_NAME}
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

  sudo mv "/tmp/${SERVICE_NAME}.service" "/etc/systemd/system/"
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}"

  print_status "Systemd service created and enabled"
  print_info "Use 'sudo systemctl start/stop/status ${SERVICE_NAME}' to manage"
}

# Function to create launchd service (macOS)
create_launchd_service() {
  uname_result=$(uname)
  if [[[ "$uname_result" != "Darwin" ]]]; then
    print_warning "Launchd service creation is only available on macOS"
    return 0
  fi

  local plist_file="$HOME/Library/LaunchAgents/dev.all-hands.openhands.plist"

  cat >"$plist_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>dev.all-hands.openhands</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/docker</string>
        <string>start</string>
        <string>${CONTAINER_NAME}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

  launchctl load "$plist_file"

  print_status "Launchd service created and loaded"
  print_info "OpenHands will start automatically on login"
}

# Function to uninstall
uninstall_openhands() {
  print_warning "This will remove OpenHands completely"
  read -p "Are you sure? (y/N) " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstall cancelled"
    return 0
  fi

  # Stop and remove container
  stop_openhands
  if docker ps -aq --filter "name=${CONTAINER_NAME}" | grep -q .; then
    docker rm "${CONTAINER_NAME}"
  fi

  # Remove images
  docker rmi "docker.all-hands.dev/all-hands-ai/openhands:${OPENHANDS_VERSION}" 2>/dev/null || true
  docker rmi "docker.all-hands.dev/all-hands-ai/runtime:${OPENHANDS_VERSION}-nikolaik" 2>/dev/null || true

  # Remove directories
  rm -rf "$STATE_DIR"
  rm -rf "$CONFIG_DIR"

  # Remove services
  uname_result=$(uname)
  if [[[ "$uname_result" == "Linux" ]]] && systemctl list-unit-files | grep -q "${SERVICE_NAME}"; then
    sudo systemctl disable "${SERVICE_NAME}"
    sudo rm "/etc/systemd/system/${SERVICE_NAME}.service"
    sudo systemctl daemon-reload
  elif [[[ "$uname_result" == "Darwin" ]]] && [[[ -f "$HOME/Library/LaunchAgents/dev.all-hands.openhands.plist" ]]]; then
    launchctl unload "$HOME/Library/LaunchAgents/dev.all-hands.openhands.plist"
    rm "$HOME/Library/LaunchAgents/dev.all-hands.openhands.plist"
  fi

  print_status "OpenHands uninstalled completely"
}

# Function to show help
show_help() {
  cat <<EOF
OpenHands Management Script

Usage: $0 <command>

Commands:
    install     - Install OpenHands
    start       - Start OpenHands
    stop        - Stop OpenHands
    restart     - Restart OpenHands
    status      - Show OpenHands status
    update      - Update to latest version
    logs        - Show OpenHands logs
    config      - Edit configuration
    service     - Create system service (auto-start)
    uninstall   - Remove OpenHands completely
    help        - Show this help

Examples:
    $0 install      # First time setup
    $0 start        # Start OpenHands
    $0 status       # Check if running
    $0 logs         # View logs

Configuration:
    Edit $CONFIG_DIR/config.env to add API keys

Access:
    http://localhost:3030 (when running)
EOF
}

# Main function
main() {
  case "${1:-help}" in
  "install")
    check_docker
    create_directories
    create_config
    pull_images
    start_openhands
    print_info "Installation complete!"
    print_info "Next steps:"
    print_info "1. Edit $CONFIG_DIR/config.env to add your API keys"
    print_info "2. Visit http://localhost:3030"
    print_info "3. Run '$0 service' to enable auto-start"
    ;;
  "start")
    check_docker
    start_openhands
    ;;
  "stop")
    stop_openhands
    ;;
  "restart")
    stop_openhands
    sleep 2
    start_openhands
    ;;
  "status")
    status_openhands
    ;;
  "update")
    check_docker
    update_openhands
    ;;
  "logs")
    logs_openhands
    ;;
  "config")
    ${EDITOR:-nano} "$CONFIG_DIR/config.env"
    ;;
  "service")
    uname_result=$(uname)
    if [[[ "$uname_result" == "Darwin" ]]]; then
      create_launchd_service
    else
      create_systemd_service
    fi
    ;;
  "uninstall")
    uninstall_openhands
    ;;
  "help" | "--help" | "-h")
    show_help
    ;;
  *)
    print_error "Unknown command: $1"
    show_help
    exit 1
    ;;
  esac
}

# Run main function
main "$@"
