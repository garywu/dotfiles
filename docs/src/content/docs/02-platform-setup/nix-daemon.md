---
title: Understanding the Nix Daemon
description: Comprehensive guide to Nix daemon mode, multi-user vs single-user installations, and troubleshooting
---

# Understanding the Nix Daemon

This guide explains the Nix daemon, why it exists, how it works, and how to troubleshoot common issues.

## What is the Nix Daemon?

The Nix daemon is a system service that manages access to the Nix store (`/nix/store`) in multi-user
installations. It runs with elevated privileges and performs operations on behalf of unprivileged users.

### Key Concepts

- **Nix Store**: Contains all packages, dependencies, and build outputs (typically at `/nix/store`)
- **Store Ownership**: In multi-user mode, owned by root and the `nixbld` group
- **Daemon Socket**: Unix socket at `/nix/var/nix/daemon-socket/socket` for communication
- **Build Users**: Special users (`nixbld1`, `nixbld2`, etc.) that perform isolated builds

## Multi-User vs Single-User Installations

### Multi-User Installation (Recommended)

Our dotfiles use multi-user installation by default:

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

**Characteristics**:

- ✅ **Secure**: Builds run as isolated `nixbld` users
- ✅ **Multi-user support**: All users can share the same Nix store
- ✅ **Space efficient**: Packages are deduplicated across users
- ✅ **Protected store**: Users cannot corrupt the store
- ❌ **Requires daemon**: Must have the daemon running
- ❌ **Needs sudo**: Some operations require elevated privileges

**How it works**:

1. User runs `nix` or `home-manager` command
2. Command connects to daemon via Unix socket
3. Daemon performs the operation with proper permissions
4. Results are returned to the user

### Single-User Installation

Alternative installation without daemon:

```bash
curl -L https://nixos.org/nix/install | sh
```

**Characteristics**:

- ✅ **Simple**: No daemon required
- ✅ **Direct access**: User owns `/nix` directory
- ✅ **No sudo needed**: All operations run as your user
- ❌ **Single user only**: Other users cannot use Nix
- ❌ **Less secure**: Builds run as your user
- ❌ **No sharing**: Cannot share packages between users

## Platform-Specific Daemon Management

### macOS

On macOS, the daemon runs via `launchd`:

```bash
# Check daemon status
launchctl list | grep org.nixos.nix-daemon

# Start daemon
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# Stop daemon
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# Check daemon logs
tail -f /var/log/nix-daemon.log
```

**Common macOS Issues**:

- Daemon stops after system updates
- Daemon doesn't start after reboot
- Permission issues with daemon socket

### Linux

On Linux, the daemon runs via `systemd`:

```bash
# Check daemon status
systemctl status nix-daemon

# Start daemon
sudo systemctl start nix-daemon

# Enable at boot
sudo systemctl enable nix-daemon

# Check daemon logs
journalctl -u nix-daemon -f
```

### WSL2

WSL2 can use systemd on newer versions:

```bash
# Check if systemd is available
if [[ -d /run/systemd/system ]]; then
    sudo systemctl start nix-daemon
else
    # Manual daemon start for older WSL2
    sudo nix-daemon &
fi
```

## Common Daemon Issues and Solutions

### Issue: "cannot connect to socket"

**Error**:

```text
error: cannot connect to socket at '/nix/var/nix/daemon-socket/socket': Connection refused
```

**Solutions**:

1. Start the daemon:

   ```bash
   # macOS
   sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist

   # Linux
   sudo systemctl start nix-daemon
   ```

2. Check socket permissions:

   ```bash
   ls -la /nix/var/nix/daemon-socket/
   ```

### Issue: Daemon not starting at boot

**macOS Solution**:

```bash
# Ensure RunAtLoad is true
plutil -p /Library/LaunchDaemons/org.nixos.nix-daemon.plist | grep RunAtLoad
```

**Linux Solution**:

```bash
sudo systemctl enable nix-daemon
```

### Issue: Daemon crashes

Check logs for errors:

```bash
# macOS
tail -50 /var/log/nix-daemon.log

# Linux
journalctl -u nix-daemon -n 50
```

Common causes:

- Disk space issues
- Corrupted store database
- Permission problems

## Automated Daemon Management

### Helper Script

We provide a helper script to ensure the daemon is running:

```bash
~/.dotfiles/scripts/ensure-nix-daemon.sh
```

### Shell Integration

Add to your shell RC file (`~/.zshrc` or `~/.bashrc`):

```bash
# Auto-ensure Nix daemon is running
if [[ -f ~/.dotfiles/scripts/ensure-nix-daemon.sh ]]; then
    ~/.dotfiles/scripts/ensure-nix-daemon.sh >/dev/null 2>&1
fi
```

### Validation Script

Check daemon status with our validation script:

```bash
# Full environment validation including daemon
~/.dotfiles/scripts/validation/validate-environment.sh

# Auto-fix mode (attempts to start daemon)
~/.dotfiles/scripts/validation/validate-environment.sh --fix
```

## Security Considerations

### Build Isolation

The daemon provides security through build isolation:

- Each build runs as a different `nixbld` user
- Builds cannot interfere with each other
- Builds cannot modify the store directly

### Store Protection

Multi-user mode protects the store:

- Only the daemon can modify `/nix/store`
- Users cannot corrupt packages
- Cryptographic hashes ensure integrity

### Access Control

Control who can use Nix:

```bash
# Restrict to 'nix-users' group
sudo chgrp nix-users /nix/var/nix/daemon-socket
sudo chmod ug=rwx,o= /nix/var/nix/daemon-socket
```

## Troubleshooting Commands

### Diagnostic Commands

```bash
# Test daemon connectivity
nix store ping --store daemon

# Check Nix version
nix --version

# Verify store integrity
nix-store --verify --check-contents

# Show daemon configuration
nix show-config | grep daemon

# List build users
dscl . -list /Users | grep nixbld  # macOS
getent passwd | grep nixbld         # Linux
```

### Emergency Recovery

If the daemon is completely broken:

1. **Try single-user mode temporarily**:

   ```bash
   export NIX_REMOTE=
   nix-build '<nixpkgs>' -A hello
   ```

2. **Rebuild daemon configuration**:

   ```bash
   # macOS
   sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
   sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
   # Reinstall Nix
   ```

3. **Check store permissions**:

   ```bash
   sudo chown -R root:nixbld /nix/store
   sudo chmod 1775 /nix/store
   ```

## Best Practices

1. **Keep daemon running**: Use automation to ensure it starts
2. **Monitor daemon health**: Include in regular system checks
3. **Update carefully**: macOS updates often affect the daemon
4. **Document issues**: Keep notes on daemon problems and solutions
5. **Regular validation**: Run validation scripts after system changes

## Related Documentation

- [Package Management Architecture](./package-management.md)
- [macOS Setup Guide](./macos.md)
- [Troubleshooting Guide](../98-troubleshooting/index.md)
- [Validation Scripts](../reference/validation-scripts.md)
