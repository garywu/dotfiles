### Bug Fixes

* add CI mode support to bootstrap and unbootstrap scripts ([374604e](https://github.com/garywu/dotfiles/commit/374604eef8a300f2b48d3d5e589a08c9be472338))
* add execute permissions to unbootstrap.sh ([7016ceb](https://github.com/garywu/dotfiles/commit/7016cebd4f75b08d272d5259a165e1ef35d36c6c))
* add explicit exit 0 to prevent exit code 138 ([568f146](https://github.com/garywu/dotfiles/commit/568f14612c28b73c11316c79cb633df3f65d0b59))
* allow bootstrap.sh to continue in CI mode instead of exiting ([17c4c9c](https://github.com/garywu/dotfiles/commit/17c4c9c608ff467f58871f3ea5961bfc75bc644b))
* capture unbootstrap exit code in subshell ([16a7ef7](https://github.com/garywu/dotfiles/commit/16a7ef75cf3cce1a6a4dba46f2ad53c4a90c2257))
* comprehensive text contrast improvements ([eaa6e03](https://github.com/garywu/dotfiles/commit/eaa6e032890bd328664e439ac6786ed93a0fd545))
* ensure Nix commands are available after installation in CI ([09d4261](https://github.com/garywu/dotfiles/commit/09d4261897ce27954c32fee87653b031da346c54))
* export PATH to GITHUB_PATH for environment persistence in CI ([07de5e5](https://github.com/garywu/dotfiles/commit/07de5e54690952a2ce39fe31638f5e89617a134f))
* force light theme as default in Starlight docs ([2016747](https://github.com/garywu/dotfiles/commit/2016747ef99aff1b72adf584268f583dab467d09))
* handle macOS CI limitations in unbootstrap and cleanup tests ([b6b757f](https://github.com/garywu/dotfiles/commit/b6b757fc7e7c002442ef44517a5db47d524cc8fa))
* handle reboot requirements gracefully in CI ([2cafb16](https://github.com/garywu/dotfiles/commit/2cafb16cf338926aa2ecfdf7366b2afe03a36d3e))
* improve text contrast in docs theme ([a9ac779](https://github.com/garywu/dotfiles/commit/a9ac779d5f4e93a68c85df8472e6256c34132ccb))
* improve unbootstrap cleanup and test verification ([0655371](https://github.com/garywu/dotfiles/commit/065537108fbed8ce223e902d7948b19078b007ed))
* make exit code 138 workaround work with GitHub Actions ([5657b54](https://github.com/garywu/dotfiles/commit/5657b542fc72a5e236375fb49300353f17133fba))
* prevent smoke test from exiting on first missing command ([f6efa80](https://github.com/garywu/dotfiles/commit/f6efa8094c60b64d4bbee41f441741fd0c1f9b21))
* remove -e flag from cleanup test to see all remaining configs ([276fa47](https://github.com/garywu/dotfiles/commit/276fa47773a3ccf12b1ba91f4e4387ad99831d16))
* remove -e flag from smoke test to allow checking all commands ([d549da6](https://github.com/garywu/dotfiles/commit/d549da6759c03286781f0b4062be91c895aae890))
* resolve Starlight build and GitHub Actions deployment issues ([3fe3262](https://github.com/garywu/dotfiles/commit/3fe32621cb39cfa03530e065c760fd6a09053472))
* revert aggressive CSS changes that broke layout ([a7bff0d](https://github.com/garywu/dotfiles/commit/a7bff0db8fd36d5b7bf5f9f25f4b49a351d8dfc5))
* separate unbootstrap and echo commands to ensure completion message ([a0276b1](https://github.com/garywu/dotfiles/commit/a0276b12c01a4fe3ec1ab014cd94f074b575c7ca))
* sync package-lock.json for GitHub Actions deployment ([9e7853d](https://github.com/garywu/dotfiles/commit/9e7853d6fd8421e6bd3a4cc0b76cb0307263481f))
* unbootstrap script CI mode detection and confirmation ([1bfbade](https://github.com/garywu/dotfiles/commit/1bfbade969bba8daeb172669d50312a398c6d091))
* update docs structure and content ([df2e02d](https://github.com/garywu/dotfiles/commit/df2e02d6570f6b996a8b7f1a9b951577126fd2e5))
* update sidebar to explicit links and package versions ([2678ffa](https://github.com/garywu/dotfiles/commit/2678ffab4be2233151a264f6e528d8e5e063ad21))
* use bash without -e flag for unbootstrap step ([3116ab6](https://github.com/garywu/dotfiles/commit/3116ab6446c805a35ac79c1c3a02296917b77fca))
* use ci_confirm for extra files cleanup prompt ([c635589](https://github.com/garywu/dotfiles/commit/c635589b49b776291ff19e2be8e2248064b8f327))
* use continue-on-error for unbootstrap step ([257b953](https://github.com/garywu/dotfiles/commit/257b953916306ac6f2abe0aa42392fa056e97aa9))
* use correct Nix profile script for macOS (nix-daemon.sh) ([9b618f7](https://github.com/garywu/dotfiles/commit/9b618f7ee5fffd6e5bc69eddc97486ebeb4c0885))
* use relative path to source ci-helpers.sh in CI environment ([b20d853](https://github.com/garywu/dotfiles/commit/b20d85366fc5b281df61c1b5dd819736a58cc9fa))
* use relative paths for Home Manager configuration in CI ([a8d631e](https://github.com/garywu/dotfiles/commit/a8d631e258934914f39dca9183ed27c6fd858e69))
* use simpler approach to handle unbootstrap exit code ([85410bb](https://github.com/garywu/dotfiles/commit/85410bbe2346f232bc3bef0d8893a6b285a591d4))
* workaround exit code 138 in CI for macOS unbootstrap ([0a99574](https://github.com/garywu/dotfiles/commit/0a99574364812500e4fab4d7adefd100720097dc))


### Features
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

