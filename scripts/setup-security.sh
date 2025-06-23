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
if [[[[[ "$(uname)" != "Darwin" ]]]]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if running as root
if [[[[[ $EUID -eq 0 ]]]]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Function to generate SSH key
generate_ssh_key() {
    local key_type=$1
    local key_name=$2
    local email=$3

    print_status "Generating $key_type SSH key for $email..."

    # Create .ssh directory if it doesn't exist
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Generate the key
    ssh-keygen -t $key_type -b 4096 -C "$email" -f ~/.ssh/$key_name

    # Set correct permissions
    chmod 600 ~/.ssh/$key_name
    chmod 644 ~/.ssh/$key_name.pub

    print_status "SSH key generated: ~/.ssh/$key_name"
    print_status "Public key:"
    cat ~/.ssh/$key_name.pub
}

# Function to set up GPG
setup_gpg() {
    local email=$1
    local name=$2

    print_status "Setting up GPG for $name <$email>..."

    # Generate GPG key
    gpg --full-generate-key

    # Get the key ID
    local key_id=$(gpg --list-secret-keys --keyid-format LONG "$email" | grep sec | awk '{print $2}' | cut -d'/' -f2)

    # Export the public key
    gpg --armor --export $key_id > ~/.gnupg/$key_id.asc

    print_status "GPG key generated with ID: $key_id"
    print_status "Public key exported to: ~/.gnupg/$key_id.asc"
}

# Function to configure Git with GPG
configure_git_gpg() {
    local email=$1
    local name=$2

    print_status "Configuring Git with GPG..."

    # Get the GPG key ID
    local key_id=$(gpg --list-secret-keys --keyid-format LONG "$email" | grep sec | awk '{print $2}' | cut -d'/' -f2)

    # Configure Git
    git config --global user.signingkey $key_id
    git config --global commit.gpgsign true
    git config --global user.name "$name"
    git config --global user.email "$email"

    print_status "Git configured to use GPG key: $key_id"
}

# Function to set up 1Password CLI
setup_1password() {
    print_status "Setting up 1Password CLI..."

    # Check if 1Password CLI is installed
    if ! command -v op &> /dev/null; then
        print_error "1Password CLI is not installed. Please install it first."
        return 1
    }

    # Sign in to 1Password
    op signin

    print_status "1Password CLI setup complete"
}

# Main function
main() {
    print_status "Starting security setup..."

    # Get user information
    read -p "Enter your name: " name
    read -p "Enter your email: " email

    # Generate SSH keys
    generate_ssh_key "ed25519" "id_ed25519" "$email"
    generate_ssh_key "rsa" "id_rsa" "$email"

    # Set up GPG
    setup_gpg "$email" "$name"

    # Configure Git with GPG
    configure_git_gpg "$email" "$name"

    # Set up 1Password CLI
    setup_1password

    print_status "Security setup completed!"
    print_status "Please add your SSH public keys to your GitHub/GitLab accounts"
    print_status "Please add your GPG public key to your GitHub/GitLab accounts"
}

# Run the main function
main
