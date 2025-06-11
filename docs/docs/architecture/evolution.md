# Evolution of the Bootstrap Script and Architectural Decisions

This document outlines the evolution of the bootstrap script and key architectural decisions made during the project's development. It integrates the git history of bootstrap.sh and highlights significant changes and their rationale.

## Git History of bootstrap.sh

Below is the chronological evolution of the bootstrap.sh script, extracted from git history:

```
* 8e4cebd (HEAD -> main) Canonicalize: Home Manager manages all dotfiles/configs, Chezmoi only for secrets/meta, update README and clean project
* db2a500 Prepare for Chezmoi subfolder workflow: clean up, sync chezmoi source, and update bootstrap logic
* af4a808 (origin/main, origin/HEAD) Fix .shell_backup logic, ensure it is ignored, and verify bootstrap script integrity
* 2826956 Establish single source of truth for Home Manager config - Move nix/home.nix to chezmoi/dot_config/private_home-manager/home.nix - Remove manual copy/link from bootstrap script - Use consistent chezmoi management for all configuration files - Implements principled approach: git control + chezmoi consistency + single source
* b938810 Fix fish shell Nix environment configuration in bootstrap - Use official Nix fish profile script instead of simple PATH setup - Source /nix/var/nix/profiles/default/etc/profile.d/nix.fish for complete environment - Improve duplicate detection to check for nix.fish and NIX_PROFILES - Enhanced cleanup regex to remove all forms of existing Nix config - Prevents duplicate PATH entries and conflicting configurations - Sets up proper NIX_PROFILES, NIX_SSL_CERT_FILE, XDG_DATA_DIRS variables
* 3115274 feat: add automatic shell management to bootstrap/unbootstrap - Bootstrap now changes default shell to fish automatically - Stores original shell in .shell_backup for restoration - Uninstall script restores original shell from backup - Adds fish to /etc/shells if needed - New terminals will use fish + starship by default
* fb61421 fix: ensure modern bash takes precedence for new scripts
* 47d7986 fix: resolve bootstrap errors for future runs - Fix Home Manager config path issue - Remove problematic packages - Handle chezmoi conflict properly
* 75a3893 Fix bootstrap script and add bun to nix configuration - Fix bootstrap.sh: remove fish dependency check that caused restart loops - Add NIX_PATH setup for proper home-manager functionality - Update nix/home.nix: add bun and essential development tools - Remove deprecated packages (thefuck, nvm) that are no longer available - Streamline package installation process
* e81a8b9 docs: add comprehensive philosophy section explaining Nix-first approach and improve bootstrap Home Manager detection
* 6b8f230 feat: finalize bootstrap script with improved Homebrew detection and environment sourcing
* c2864e0 refactor: consolidate installation scripts into single bootstrap.sh
```

## Key Architectural Decisions

1. **Nix-First Approach**: The project prioritizes Nix for package management and environment reproducibility, ensuring cross-platform compatibility and minimizing dependency conflicts.

2. **Home Manager as Single Source of Truth**: All dotfiles and user configurations are managed by Home Manager, providing a declarative and reproducible setup.

3. **Chezmoi for Secrets/Meta**: Chezmoi is used exclusively for managing secrets and meta files, avoiding conflicts with Home Manager-managed configurations.

4. **Bootstrap Script Evolution**: The bootstrap script has evolved from a simple installation script to a comprehensive setup tool that handles shell management, environment configuration, and package installation.

5. **Shell Management**: The bootstrap script now automatically manages the default shell, storing the original shell for restoration and ensuring a consistent environment.

6. **Environment Configuration**: The script uses official Nix profile scripts to ensure a complete and consistent environment setup, preventing duplicate PATH entries and conflicting configurations.

7. **Documentation and Philosophy**: The project includes comprehensive documentation explaining the Nix-first approach and architectural principles, ensuring clarity and maintainability.

## Conclusion

The evolution of the bootstrap script and architectural decisions reflects a commitment to reproducibility, cross-platform compatibility, and simplicity. By leveraging Nix and Home Manager, the project achieves a robust and maintainable development environment. 