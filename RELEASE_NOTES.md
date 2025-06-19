## [0.2.0-beta.1] - 2025-06-19

### Bug Fixes

- Update docs structure and content ([df2e02d](https://github.com/garywu/dotfiles/commit/df2e02d6570f6b996a8b7f1a9b951577126fd2e5))
- Improve text contrast in docs theme ([a9ac779](https://github.com/garywu/dotfiles/commit/a9ac779d5f4e93a68c85df8472e6256c34132ccb))
- Revert aggressive CSS changes that broke layout ([a7bff0d](https://github.com/garywu/dotfiles/commit/a7bff0db8fd36d5b7bf5f9f25f4b49a351d8dfc5))
- Comprehensive text contrast improvements ([eaa6e03](https://github.com/garywu/dotfiles/commit/eaa6e032890bd328664e439ac6786ed93a0fd545))
- Force light theme as default in Starlight docs ([2016747](https://github.com/garywu/dotfiles/commit/2016747ef99aff1b72adf584268f583dab467d09))
- Update sidebar to explicit links and package versions ([2678ffa](https://github.com/garywu/dotfiles/commit/2678ffab4be2233151a264f6e528d8e5e063ad21))
- Sync package-lock.json for GitHub Actions deployment ([9e7853d](https://github.com/garywu/dotfiles/commit/9e7853d6fd8421e6bd3a4cc0b76cb0307263481f))
- Resolve Starlight build and GitHub Actions deployment issues ([3fe3262](https://github.com/garywu/dotfiles/commit/3fe32621cb39cfa03530e065c760fd6a09053472))
- Add CI mode support to bootstrap and unbootstrap scripts ([374604e](https://github.com/garywu/dotfiles/commit/374604eef8a300f2b48d3d5e589a08c9be472338))
- Allow bootstrap.sh to continue in CI mode instead of exiting ([17c4c9c](https://github.com/garywu/dotfiles/commit/17c4c9c608ff467f58871f3ea5961bfc75bc644b))
- Export PATH to GITHUB_PATH for environment persistence in CI ([07de5e5](https://github.com/garywu/dotfiles/commit/07de5e54690952a2ce39fe31638f5e89617a134f))
- Use relative path to source ci-helpers.sh in CI environment ([b20d853](https://github.com/garywu/dotfiles/commit/b20d85366fc5b281df61c1b5dd819736a58cc9fa))
- Ensure Nix commands are available after installation in CI ([09d4261](https://github.com/garywu/dotfiles/commit/09d4261897ce27954c32fee87653b031da346c54))
- Use correct Nix profile script for macOS (nix-daemon.sh) ([9b618f7](https://github.com/garywu/dotfiles/commit/9b618f7ee5fffd6e5bc69eddc97486ebeb4c0885))
- Use relative paths for Home Manager configuration in CI ([a8d631e](https://github.com/garywu/dotfiles/commit/a8d631e258934914f39dca9183ed27c6fd858e69))
- Add execute permissions to unbootstrap.sh ([7016ceb](https://github.com/garywu/dotfiles/commit/7016cebd4f75b08d272d5259a165e1ef35d36c6c))
- Prevent smoke test from exiting on first missing command ([f6efa80](https://github.com/garywu/dotfiles/commit/f6efa8094c60b64d4bbee41f441741fd0c1f9b21))
- Remove -e flag from smoke test to allow checking all commands ([d549da6](https://github.com/garywu/dotfiles/commit/d549da6759c03286781f0b4062be91c895aae890))
- Remove -e flag from cleanup test to see all remaining configs ([276fa47](https://github.com/garywu/dotfiles/commit/276fa47773a3ccf12b1ba91f4e4387ad99831d16))
- Improve unbootstrap cleanup and test verification ([0655371](https://github.com/garywu/dotfiles/commit/065537108fbed8ce223e902d7948b19078b007ed))
- Unbootstrap script CI mode detection and confirmation ([1bfbade](https://github.com/garywu/dotfiles/commit/1bfbade969bba8daeb172669d50312a398c6d091))
- Handle macOS CI limitations in unbootstrap and cleanup tests ([b6b757f](https://github.com/garywu/dotfiles/commit/b6b757fc7e7c002442ef44517a5db47d524cc8fa))
- Handle reboot requirements gracefully in CI ([2cafb16](https://github.com/garywu/dotfiles/commit/2cafb16cf338926aa2ecfdf7366b2afe03a36d3e))
- Use ci_confirm for extra files cleanup prompt ([c635589](https://github.com/garywu/dotfiles/commit/c635589b49b776291ff19e2be8e2248064b8f327))
- Add explicit exit 0 to prevent exit code 138 ([568f146](https://github.com/garywu/dotfiles/commit/568f14612c28b73c11316c79cb633df3f65d0b59))
- Workaround exit code 138 in CI for macOS unbootstrap ([0a99574](https://github.com/garywu/dotfiles/commit/0a99574364812500e4fab4d7adefd100720097dc))
- Make exit code 138 workaround work with GitHub Actions ([5657b54](https://github.com/garywu/dotfiles/commit/5657b542fc72a5e236375fb49300353f17133fba))
- Use simpler approach to handle unbootstrap exit code ([85410bb](https://github.com/garywu/dotfiles/commit/85410bbe2346f232bc3bef0d8893a6b285a591d4))
- Separate unbootstrap and echo commands to ensure completion message ([a0276b1](https://github.com/garywu/dotfiles/commit/a0276b12c01a4fe3ec1ab014cd94f074b575c7ca))
- Use bash without -e flag for unbootstrap step ([3116ab6](https://github.com/garywu/dotfiles/commit/3116ab6446c805a35ac79c1c3a02296917b77fca))
- Capture unbootstrap exit code in subshell ([16a7ef7](https://github.com/garywu/dotfiles/commit/16a7ef75cf3cce1a6a4dba46f2ad53c4a90c2257))
- Use continue-on-error for unbootstrap step ([257b953](https://github.com/garywu/dotfiles/commit/257b953916306ac6f2abe0aa42392fa056e97aa9))

### Documentation

- Update CLAUDE.md with documentation commands and Issue #15 learnings ([d55d26b](https://github.com/garywu/dotfiles/commit/d55d26bfbf6c278240342b8f1776d8d85d1fdf2f))

### Features

- Add CI testing for bootstrap/unbootstrap process ([db0680d](https://github.com/garywu/dotfiles/commit/db0680d83314ca2fa62394a75fa181258090ec0d))
- Create comprehensive test framework for continuous testing ([83b44ee](https://github.com/garywu/dotfiles/commit/83b44eeb1b8d29891182ed60a69246ad1579eb7d))

### Miscellaneous Tasks

- Clean up unnecessary files and directories ([00c451b](https://github.com/garywu/dotfiles/commit/00c451bfb4d98515a20b92f2b25c3a0d3ac482af))
- V0.2.0 [skip ci] ([66863a7](https://github.com/garywu/dotfiles/commit/66863a7655cd1e27493d9d31e0628db319c25337))

---

🤖 Generated with [git-cliff](https://git-cliff.org)
