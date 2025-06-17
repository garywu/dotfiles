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

### Changed
- Documentation structure improvements

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
