# [](https://github.com/garywu/dotfiles/compare/v0.0.1...v) (2025-06-17)


### Bug Fixes

* apply pre-commit formatting to shell scripts ([23b71ca](https://github.com/garywu/dotfiles/commit/23b71caa530aaf70f1cd1db4da30a3b49d49598d)), closes [#11](https://github.com/garywu/dotfiles/issues/11) [#4](https://github.com/garywu/dotfiles/issues/4)
* resolve linting issues in bootstrap.sh and config files ([#8](https://github.com/garywu/dotfiles/issues/8)) ([7363143](https://github.com/garywu/dotfiles/commit/73631434bff8f14a497e52849280d65c72217891))
* sync package-lock.json with package.json ([0853dfe](https://github.com/garywu/dotfiles/commit/0853dfe6afbcf6670c70df288d6230b401f85544))


### Features

* add developer productivity CLI tools ([#10](https://github.com/garywu/dotfiles/issues/10)) ([fbba0bc](https://github.com/garywu/dotfiles/commit/fbba0bc58aafc79319f3fd88f6d22ad9c77bd5fd))
* add linting infrastructure and Cloudflare CLI tools ([#6](https://github.com/garywu/dotfiles/issues/6), [#7](https://github.com/garywu/dotfiles/issues/7)) ([83ad63b](https://github.com/garywu/dotfiles/commit/83ad63b29a000df97ecccc81cd30dcbb145cd883))
* complete Dotfiles Academy migration from Docusaurus to Starlight ([#12](https://github.com/garywu/dotfiles/issues/12)) ([cd75b43](https://github.com/garywu/dotfiles/commit/cd75b4342a1901d83adbffac5243a388bf0f9626))
* implement automated release management system ([03adc6f](https://github.com/garywu/dotfiles/commit/03adc6f593a441a223afcdf5c25b012dd439b80d))
* implement Git email privacy protection ([eadcc71](https://github.com/garywu/dotfiles/commit/eadcc7180285f98727f1b080fd7e2374ba844cb4))



# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub issue templates for bugs, features, documentation, and refactoring (#5)
- Pull request template with comprehensive checklist (#5)
- CONTRIBUTING.md with development guidelines (#5)
- CODE_OF_CONDUCT.md for community standards (#5)
- SECURITY.md for vulnerability reporting (#5)
- CLAUDE.md for AI assistant session tracking and workflow (#3)
- Issue-driven development workflow (#3)
- GitHub labels for issue organization: priority, type, and status (#5)
- Professional development standards and processes (#4)
- Linting and formatting tools configuration (#6)
  - ShellCheck, shfmt, nixpkgs-fmt, yamllint, markdownlint, taplo
  - Configuration files for each linter
  - Makefile for running linters and formatters
  - Pre-commit hooks for automated checking
  - EditorConfig for consistent coding style
- Cloudflare command line tools (#7)
  - cloudflared for Cloudflare Tunnel management
  - flarectl for Cloudflare API interactions
  - wrangler installation via npm in bootstrap.sh

### Changed
- Documentation structure improvements
- Updated CONTRIBUTING.md with linting commands and requirements (#6)

### Known Issues
- Temporarily disabled keepassxc, git-credential-keepassxc, and statix due to gpgme-1.24.2 broken package issue

## [0.0.1] - 2025-06-17

### Added
- Pre-commit hooks configuration with automatic code formatting
- Architecture documentation (ARCHITECTURE.md) explaining tool separation
- Example Chezmoi templates for secrets management (SSH config, git config)

### Changed
- **BREAKING**: Separated Nix/Home Manager from Chezmoi management
  - Moved home.nix from chezmoi/ to nix/ directory
  - Home Manager config now directly managed, not through Chezmoi
  - Chezmoi now only handles secrets and machine-specific templates
- Updated bootstrap.sh to create proper Home Manager symlink
- Simplified workflow: edit nix/home.nix directly, no more double-management

### Fixed
- Removed blocking changelog pre-commit hook that prevented commits
- Fixed Fish shell Homebrew path detection for Apple Silicon Macs
  - Now checks /opt/homebrew/bin/brew first (Apple Silicon)
  - Falls back to /usr/local/bin/brew (Intel)
  - Uses test -e instead of test -d for more reliable detection

## [0.1.0] - 2024-03-19

### Added
- Initial project setup
- Nix/Home Manager configuration
- Chezmoi dotfile management
- Fish shell configuration
- Development environment tools
- Documentation structure
