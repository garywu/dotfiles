# WSL Remote Setup Guide

This guide will help you set up your Windows WSL2 system for remote management and dotfiles installation.

## Prerequisites on Windows Host

1. **WSL2 installed** with a Linux distribution (Ubuntu recommended)
2. **Windows Terminal** or another terminal emulator
3. **Administrator access** for some configuration steps

## Step 1: Initial WSL Setup

Open your WSL terminal and run these commands:

```bash
# Update package lists
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y \
  curl \
  git \
  openssh-server \
  build-essential \
  ca-certificates \
  gnupg \
  lsb-release
```

## Step 2: Configure SSH Access

### 2.1 Enable and Configure SSH Server

```bash
# Configure SSH to start automatically
sudo systemctl enable ssh
sudo systemctl start ssh

# Check SSH status
sudo systemctl status ssh

# Get your WSL IP address (note this for later)
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

### 2.2 Configure SSH for Password Authentication (temporary)

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Ensure these settings:
# PasswordAuthentication yes
# PubkeyAuthentication yes
# PermitRootLogin no

# Restart SSH
sudo systemctl restart ssh
```

### 2.3 Set up your user account

```bash
# Create a strong password if you haven't already
sudo passwd $USER

# Add your user to sudo group (if not already)
sudo usermod -aG sudo $USER
```

## Step 3: Install Tailscale on WSL

Tailscale provides secure, zero-config VPN connectivity between your devices.

```bash
# Add Tailscale's GPG key
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | \
  sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

# Add Tailscale repository
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# Install Tailscale
sudo apt update
sudo apt install -y tailscale

# Start Tailscale
sudo tailscale up

# Follow the authentication link that appears
# After authentication, get your Tailscale IP
tailscale ip -4
```

## Step 4: Configure Windows Firewall

On your Windows host (not in WSL), open PowerShell as Administrator:

```powershell
# Allow WSL through Windows Firewall
New-NetFirewallRule -DisplayName "WSL SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
New-NetFirewallRule -DisplayName "WSL Tailscale" -Direction Inbound -Protocol UDP -LocalPort 41641 -Action Allow
```

## Step 5: Set up SSH Keys (from your Mac)

On your Mac, generate and copy SSH key:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy your SSH public key
cat ~/.ssh/id_ed25519.pub

# Test connection using WSL IP address
ssh username@wsl-ip-address

# Or use Tailscale (more reliable)
ssh username@tailscale-hostname
```

On your WSL system, add the SSH key:

```bash
# Create SSH directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key
echo "your-ssh-public-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Disable password authentication (after testing key works!)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart ssh
```

## Step 6: Install Development Tools

```bash
# Install Nix package manager
sh <(curl -L https://nixos.org/nix/install) --daemon

# Restart your shell or source nix
. /etc/profile.d/nix.sh

# Install Home Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Install other useful tools
sudo apt install -y \
  tmux \
  mosh \
  zsh \
  fish
```

## Step 7: Clone and Install Dotfiles

```bash
# Clone your dotfiles
git clone https://github.com/yourusername/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap script
./bootstrap.sh
```

## Step 8: Persistent WSL Configuration

### 8.1 Create WSL configuration file

On Windows host, create `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
localhostForwarding=true
nestedVirtualization=true

[experimental]
autoMemoryReclaim=gradual
```

### 8.2 Enable systemd (for better service management)

In WSL, create `/etc/wsl.conf`:

```bash
sudo nano /etc/wsl.conf
```

Add:

```ini
[boot]
systemd=true

[network]
hostname=your-wsl-hostname
generateResolvConf=true

[interop]
enabled=true
appendWindowsPath=true
```

### 8.3 Restart WSL

On Windows PowerShell:

```powershell
wsl --shutdown
wsl
```

## Step 9: Connect from Mac

You now have multiple ways to connect:

### Option 1: Direct SSH (when on same network)

```bash
ssh username@wsl-ip-address
```

### Option 2: Tailscale (works anywhere)

```bash
# Start Tailscale on Mac if not running
brew services start tailscale
sudo tailscale up

# Connect via Tailscale hostname
ssh username@wsl-tailscale-name
```

### Option 3: Mosh (for unreliable connections)

```bash
mosh username@wsl-tailscale-name
```

### Option 4: SSH + tmux (for persistent sessions)

```bash
ssh username@wsl-tailscale-name -t tmux new -A -s main
```

## Step 10: VS Code Remote Development

Install VS Code on your Mac and add the "Remote - SSH" extension. You can then:

1. Open VS Code
2. Press Cmd+Shift+P → "Remote-SSH: Connect to Host"
3. Enter: `username@wsl-tailscale-name`
4. VS Code will connect and install server components automatically

## Troubleshooting

### WSL IP Address Changes

WSL IP addresses change on restart. Solutions:

1. **Use Tailscale** (recommended) - stable hostname
2. **Port forwarding** via Windows host
3. **Dynamic DNS** script in WSL

### SSH Connection Refused

```bash
# Check SSH is running
sudo systemctl status ssh

# Check firewall
sudo ufw status

# Check SSH logs
sudo journalctl -u ssh -f
```

### Tailscale Not Starting

```bash
# Manual start
sudo tailscaled

# Check status
tailscale status

# Re-authenticate
sudo tailscale up --force-reauth
```

### Performance Issues

1. Increase WSL memory in `.wslconfig`
2. Use WSL2 (not WSL1)
3. Store projects in Linux filesystem (not /mnt/c)

## Security Best Practices

1. **Use SSH keys** instead of passwords
2. **Enable Tailscale ACLs** for network segmentation
3. **Keep WSL updated**: `sudo apt update && sudo apt upgrade`
4. **Use fail2ban** for SSH brute-force protection:

   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban
   ```

## Next Steps

Once connected, you can:

1. **Manage dotfiles**: Update and sync configurations
2. **Run development servers**: Access via Tailscale network
3. **Use GUI apps**: With X11 forwarding or WSLg
4. **Share files**: Via SSH/SFTP or mounted drives

Remember to commit your dotfiles changes back to your repository!
