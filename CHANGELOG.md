# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial changelog setup
- Pre-commit hook for changelog maintenance

### Fixed
- Improved Homebrew path detection in fish configuration
  - Now explicitly checks for /opt/homebrew and /usr/local directories
  - Adds Homebrew bin directory to PATH before evaluating shellenv
  - Handles both Apple Silicon and Intel Mac paths correctly

## [0.1.0] - 2024-03-19

### Added
- Initial project setup
- Nix/Home Manager configuration
- Chezmoi dotfile management
- Fish shell configuration
- Development environment tools
- Documentation structure
