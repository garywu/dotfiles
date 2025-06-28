#!/usr/bin/env bash

# Ollama Setup Script - Cross-platform installation and auto-start configuration
# This script installs Ollama and configures it to start automatically at boot

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

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
  case "$(uname -s)" in
    Darwin*) OS="macos" ;;
    Linux*) OS="linux" ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) OS="windows" ;;
    *) OS="unknown" ;;
  esac
  echo "$OS"
}

# Install Ollama based on OS
install_ollama() {
  local os="$1"

  print_status "Installing Ollama for $os..."

  case "$os" in
    macos)
      if command_exists brew; then
        print_status "Installing Ollama via Homebrew..."
        brew install ollama
      else
        print_status "Installing Ollama via official installer..."
        curl -fsSL https://ollama.ai/install.sh | sh
      fi
      ;;

    linux)
      print_status "Installing Ollama via official installer..."
      curl -fsSL https://ollama.ai/install.sh | sh
      ;;

    windows)
      print_error "Windows installation should be done via the official Ollama installer"
      print_status "Please download from: https://ollama.ai/download/windows"
      exit 1
      ;;

    *)
      print_error "Unsupported operating system: $os"
      exit 1
      ;;
  esac
}

# Configure Ollama auto-start for macOS
setup_macos_autostart() {
  print_status "Setting up Ollama auto-start for macOS..."

  # Create LaunchAgent directory if it doesn't exist
  mkdir -p ~/Library/LaunchAgents

  # Create LaunchAgent plist file
  local plist_path="$HOME/Library/LaunchAgents/com.ollama.server.plist"

  cat >"$plist_path" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/ollama.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ollama.error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>127.0.0.1:11434</string>
    </dict>
</dict>
</plist>
EOF

  # Update the path if Ollama is installed via Homebrew
  if command_exists brew && brew list ollama &>/dev/null; then
    local ollama_path=$(which ollama)
    sed -i '' "s|/usr/local/bin/ollama|$ollama_path|g" "$plist_path"
  fi

  # Load the LaunchAgent
  launchctl load "$plist_path" 2>/dev/null || {
    print_warning "LaunchAgent might already be loaded, attempting to reload..."
    launchctl unload "$plist_path" 2>/dev/null
    launchctl load "$plist_path"
  }

  print_status "Ollama LaunchAgent installed and loaded"
}

# Configure Ollama auto-start for Linux
setup_linux_autostart() {
  print_status "Setting up Ollama auto-start for Linux..."

  # Create systemd service file
  local service_path="/etc/systemd/system/ollama.service"

  # Check if we have sudo access
  if ! sudo -n true 2>/dev/null; then
    print_error "This script requires sudo access to create systemd service"
    print_status "Please run with sudo or configure sudo access"
    exit 1
  fi

  sudo tee "$service_path" >/dev/null <<'EOF'
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ollama serve
Restart=always
User=%USER%
Environment="OLLAMA_HOST=127.0.0.1:11434"

[Install]
WantedBy=default.target
EOF

  # Replace %USER% with actual username
  sudo sed -i "s/%USER%/$USER/g" "$service_path"

  # Update the path if Ollama is installed elsewhere
  local ollama_path=$(which ollama)
  if [[ $ollama_path != "/usr/local/bin/ollama" ]]; then
    sudo sed -i "s|/usr/local/bin/ollama|$ollama_path|g" "$service_path"
  fi

  # Reload systemd and enable the service
  sudo systemctl daemon-reload
  sudo systemctl enable ollama.service
  sudo systemctl start ollama.service

  print_status "Ollama systemd service installed and started"
}

# Pull default models
pull_default_models() {
  print_status "Pulling default models (this may take a while)..."

  # Wait for Ollama to be ready
  local max_attempts=30
  local attempt=0

  while ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    if [[ $attempt -ge $max_attempts ]]; then
      print_warning "Ollama server not responding after $max_attempts attempts"
      print_status "You can manually pull models later with: ollama pull <model>"
      return 1
    fi

    ((attempt++))
    sleep 2
  done

  # Pull lightweight default models
  local default_models=("llama3.2:3b" "qwen2.5-coder:3b")

  for model in "${default_models[@]}"; do
    print_status "Pulling $model..."
    if ollama pull "$model"; then
      print_status "Successfully pulled $model"
    else
      print_warning "Failed to pull $model"
    fi
  done

  print_status "Default models pulled. You can pull more models with: ollama pull <model>"
  print_status "Popular models: llama3.2, mistral, codellama, gemma2, phi3"
}

# Configure environment variables
setup_environment() {
  print_status "Configuring environment variables..."

  # Create Ollama config directory
  mkdir -p ~/.ollama

  # Add Ollama environment variables to shell configs
  local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")

  for config in "${shell_configs[@]}"; do
    if [[ -f $config ]]; then
      # Check if already configured
      if ! grep -q "OLLAMA_HOST" "$config"; then
        echo "" >>"$config"
        echo "# Ollama configuration" >>"$config"
        echo 'export OLLAMA_HOST="127.0.0.1:11434"' >>"$config"
        echo "export OLLAMA_MODELS=\"$HOME/.ollama/models\"" >>"$config"
        print_status "Updated $config with Ollama environment variables"
      fi
    fi
  done

  # For fish shell
  if [[ -d "$HOME/.config/fish" ]]; then
    local fish_config="$HOME/.config/fish/conf.d/ollama.fish"
    if [[ ! -f $fish_config ]]; then
      cat >"$fish_config" <<'EOF'
# Ollama configuration
set -gx OLLAMA_HOST "127.0.0.1:11434"
set -gx OLLAMA_MODELS "$HOME/.ollama/models"
EOF
      print_status "Created fish shell configuration for Ollama"
    fi
  fi
}

# Main installation flow
main() {
  print_status "Starting Ollama setup..."

  # Detect OS
  OS=$(detect_os)
  print_status "Detected operating system: $OS"

  # Check if Ollama is already installed
  if command_exists ollama; then
    print_status "Ollama is already installed at: $(which ollama)"
    print_status "Version: $(ollama --version)"
  else
    install_ollama "$OS"
  fi

  # Verify installation
  if ! command_exists ollama; then
    print_error "Ollama installation failed"
    exit 1
  fi

  # Set up auto-start based on OS
  case "$OS" in
    macos)
      setup_macos_autostart
      ;;
    linux)
      setup_linux_autostart
      ;;
    *)
      print_warning "Auto-start configuration not available for $OS"
      print_status "You'll need to manually start Ollama with: ollama serve"
      ;;
  esac

  # Configure environment
  setup_environment

  # Start Ollama if not running
  if ! pgrep -x "ollama" >/dev/null; then
    print_status "Starting Ollama server..."
    case "$OS" in
      macos)
        launchctl start com.ollama.server
        ;;
      linux)
        sudo systemctl start ollama.service
        ;;
      *)
        ollama serve &
        ;;
    esac
  fi

  # Pull default models
  pull_default_models

  print_status "Ollama setup completed!"
  print_status ""
  print_status "Ollama is now running at: http://localhost:11434"
  print_status "To check status: curl http://localhost:11434/api/tags"
  print_status "To pull more models: ollama pull <model-name>"
  print_status "To run a model: ollama run <model-name>"
  print_status ""
  print_status "The server will start automatically on system boot."
}

# Run main function
main "$@"
