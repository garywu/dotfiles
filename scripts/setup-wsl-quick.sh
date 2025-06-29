#!/usr/bin/env bash
# Quick WSL Setup Script

echo "=== WSL Quick Setup for Remote Access ==="
echo ""
echo "This script will help you set up your WSL for remote access."
echo "You'll need to enter your password when prompted."
echo ""

# Update and install essentials
echo "1. Updating system and installing tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    openssh-server \
    curl \
    wget \
    git \
    build-essential \
    tmux \
    mosh \
    net-tools

# Configure and start SSH
echo ""
echo "2. Setting up SSH server..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Show network info
echo ""
echo "3. Your network information:"
echo "Hostname: $(hostname)"
echo "IP Addresses:"
ip -4 addr show | grep inet | grep -v 127.0.0.1

# Check SSH status
echo ""
echo "4. SSH Server Status:"
sudo systemctl status ssh --no-pager

# Install Tailscale (optional)
echo ""
echo "5. Would you like to install Tailscale for easier connectivity? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update
    sudo apt install -y tailscale
    echo "Tailscale installed! Run 'sudo tailscale up' to authenticate."
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "To connect from your Mac:"
echo "  ssh $(whoami)@$(hostname -I | awk '{print $1}')"
echo ""
echo "If you installed Tailscale:"
echo "  1. Run: sudo tailscale up"
echo "  2. Follow the auth link"
echo "  3. Connect via: ssh $(whoami)@$(hostname)"
