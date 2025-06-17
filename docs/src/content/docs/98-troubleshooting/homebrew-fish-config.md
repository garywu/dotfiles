---
title: Homebrew Fish Configuration Issue
description: Troubleshooting and fixing Homebrew path detection errors in Fish shell configuration
---

# Homebrew Fish Configuration Issue

## Problem Description
When starting a new Fish shell session, the following error appears:
```fish
fish: Unknown command: /usr/local/bin/brew
~/.config/fish/config.fish (line 1):
/usr/local/bin/brew shellenv
^~~~~~~~~~~~~~~~~~^
in command substitution
        called on line 22 of file ~/.config/fish/config.fish
from sourcing file ~/.config/fish/config.fish
        called during startup
```

## Root Cause Analysis
1. **Configuration Generation**:
   - The Fish configuration is managed by Home Manager (Nix)
   - The config file is a symlink to a file in the Nix store
   - The configuration is generated from `home.nix`

2. **Path Detection Issue**:
   - The configuration was checking both Homebrew paths:
     - `/opt/homebrew/bin` (Apple Silicon default)
     - `/usr/local/bin` (Intel Mac default)
   - The check was implemented as two separate `if` statements
   - This could cause errors if the first path check failed

3. **System Context**:
   - Running on Apple Silicon Mac (M1/M2)
   - Homebrew installed at `/opt/homebrew/bin`
   - Configuration trying to use Intel path first

## Solution
Modified the Fish shell initialization in `home.nix` to use a more robust path detection:

```nix
shellInit = ''
  # Load Nix environment if available
  if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
  end
  # Ensure all user-level bins are in PATH
  set -gx PATH $HOME/.nix-profile/bin $HOME/.npm-global/bin $HOME/.local/bin $PATH
  # Add Homebrew to PATH (checking Apple Silicon path first)
  if test -d /opt/homebrew/bin
    eval (/opt/homebrew/bin/brew shellenv)
  else if test -d /usr/local/bin
    eval (/usr/local/bin/brew shellenv)
  end
'';
```

Key changes:
1. Changed to `else if` structure to ensure only one path is checked
2. Prioritized Apple Silicon path check
3. Maintained fallback for Intel Macs

## Implementation Steps
1. Edit `chezmoi/dot_config/private_home-manager/home.nix`
2. Update the `fish.shellInit` section
3. Apply changes with Home Manager:
   ```bash
   export NIXPKGS_ALLOW_BROKEN=1
   home-manager switch --impure
   ```

## Verification
After applying changes:
1. Close and reopen terminal
2. Or run `source ~/.config/fish/config.fish`
3. Verify Homebrew works: `brew --version`

## Prevention
To prevent similar issues:
1. Always check system architecture when configuring paths
2. Use conditional logic that fails gracefully
3. Test configurations on both Intel and Apple Silicon systems
4. Keep Home Manager configuration in version control
5. Document path dependencies clearly

## Related Components
- Home Manager (Nix)
- Fish Shell
- Homebrew
- Chezmoi (dotfile management)

## References
- [Home Manager Fish Module](https://nix-community.github.io/home-manager/options.html#opt-programs.fish.enable)
- [Fish Shell Documentation](https://fishshell.com/docs/current/index.html)
- [Homebrew Installation](https://docs.brew.sh/Installation)
