### Bug Fixes

* apply pre-commit formatting to shell scripts ([23b71ca](https://github.com/garywu/dotfiles/commit/23b71caa530aaf70f1cd1db4da30a3b49d49598d)), closes [#11](https://github.com/garywu/dotfiles/issues/11) [#4](https://github.com/garywu/dotfiles/issues/4)
* resolve linting issues in bootstrap.sh and config files ([#8](https://github.com/garywu/dotfiles/issues/8)) ([7363143](https://github.com/garywu/dotfiles/commit/73631434bff8f14a497e52849280d65c72217891))
* sync package-lock.json with package.json ([0853dfe](https://github.com/garywu/dotfiles/commit/0853dfe6afbcf6670c70df288d6230b401f85544))


### Features
## [Unreleased]

### Added
### Changed
- Documentation structure improvements
- Updated CONTRIBUTING.md with linting commands and requirements (#6)

### Known Issues
## [0.0.1] - 2025-06-17

### Added
### Changed
- **BREAKING**: Separated Nix/Home Manager from Chezmoi management
  - Moved home.nix from chezmoi/ to nix/ directory
  - Home Manager config now directly managed, not through Chezmoi
  - Chezmoi now only handles secrets and machine-specific templates
- Updated bootstrap.sh to create proper Home Manager symlink
- Simplified workflow: edit nix/home.nix directly, no more double-management

### Fixed
## [0.1.0] - 2024-03-19

