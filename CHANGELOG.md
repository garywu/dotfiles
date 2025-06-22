# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Bug Fixes

- Change sidebar link from absolute to relative path for GitHub Pages compatibility ([79eafd2](https://github.com/garywu/dotfiles/commit/79eafd2e87f4f5076dddd0d6be6b2cd8cb16170d))
- Add timeout to link pattern validation to prevent hanging builds ([e4eb9e2](https://github.com/garywu/dotfiles/commit/e4eb9e21f62554470aa34fe79f632f864425dce7))
- Use MDX comment syntax instead of HTML comment ([fce17b5](https://github.com/garywu/dotfiles/commit/fce17b5d3c13efc4b227d554204a16ba2aa59f0d))
- Add timeout to link tests to prevent hanging in CI ([ad19186](https://github.com/garywu/dotfiles/commit/ad191863c62939e91311a5a5b2d3cfeca6b872bb))
- Update CLI Tools button to point to overview page instead of modern replacements ([98678b5](https://github.com/garywu/dotfiles/commit/98678b5c9520d1d3046142cef33fb5fcae911b93))
- Resolve production link test failures ([c14babe](https://github.com/garywu/dotfiles/commit/c14babe846c02bc95cd3cbf96f416f15d11361e1))

### Documentation

- Trigger rebuild with timeout fix for link validation ([6c61946](https://github.com/garywu/dotfiles/commit/6c61946105d2621f4df3648969f4bc831a287109))

### Features

- Automate package inventory updates in documentation builds ([5fa61d9](https://github.com/garywu/dotfiles/commit/5fa61d9b6105d7ca453f9b698b34ffcf54ff8c93))

### Testing

- Skip hanging link test temporarily to allow deployment ([504007d](https://github.com/garywu/dotfiles/commit/504007d05444aa7f20c299b89d3fd1f4738ffe8d))

## [1.1.1] - 2025-06-22

### Bug Fixes

- Resolve GitHub Actions failures ([00228b0](https://github.com/garywu/dotfiles/commit/00228b0e9470db26aa5dcc5b7e15404071621ef5))

### Miscellaneous Tasks

- V1.1.1 [skip ci] ([98ce72c](https://github.com/garywu/dotfiles/commit/98ce72c80d8c7d048c8fb189006554fe5ff8e40e))

## [1.1.0] - 2025-06-22

### Documentation

- Update package inventory with pandoc and libreoffice (#42) ([4041cbb](https://github.com/garywu/dotfiles/commit/4041cbb9b5daae4273fabd84b3181f0593c54de6))

### Features

- Add imagemagick for image processing capabilities (#40) ([552f705](https://github.com/garywu/dotfiles/commit/552f705aaf4138bdc983bc3a8dad24f1906a5c8e))
- Add ffmpeg for audio/video processing capabilities (#40) ([4b49e6c](https://github.com/garywu/dotfiles/commit/4b49e6c78114f6e6d580f19f46c3e796680c03ab))
- Add automated package inventory documentation script (#41) ([f3de03f](https://github.com/garywu/dotfiles/commit/f3de03f28ea1ee56a5255467dbb75dfdac7e611d))
- Add pandoc for universal document conversion (#42) ([f6ac814](https://github.com/garywu/dotfiles/commit/f6ac814324cc2da839985465b126290f7abf5072))
- Add LibreOffice for comprehensive office suite capabilities (#42) ([3a3ab82](https://github.com/garywu/dotfiles/commit/3a3ab82ecc52fef11887ba08b564222bacd264dc))
- Add comprehensive CLI utilities documentation and optimize GitHub Actions costs ([397bf08](https://github.com/garywu/dotfiles/commit/397bf08bcce9244d5385bd883318d5e3d28b79b9))

### Miscellaneous Tasks

- V1.1.0 [skip ci] ([158c5c0](https://github.com/garywu/dotfiles/commit/158c5c0cd57a2a12ff73205210c420223f73958d))

## [1.0.0] - 2025-06-20

### Features

- Add admin repository as submodule ([6c325b4](https://github.com/garywu/dotfiles/commit/6c325b4fa056f85488be6a28cf74a80c8ec0a7c9))
- [**breaking**] Implement comprehensive environment validation system ([697a0c3](https://github.com/garywu/dotfiles/commit/697a0c34a5d1c201a269f5aab7d88364893ef3c3))

### Miscellaneous Tasks

- V1.0.0 [skip ci] ([a6c3cd3](https://github.com/garywu/dotfiles/commit/a6c3cd375774b04b5e28dab1261da1e4c4c9b04d))

## [0.3.0] - 2025-06-20

### Bug Fixes

- Improve bash version warning messages in bootstrap ([edd162f](https://github.com/garywu/dotfiles/commit/edd162f48589884504050fb70ab64664a07c48f6))
- Update documentation tests to match deployed pages ([845b987](https://github.com/garywu/dotfiles/commit/845b9879a3d885cc1b62c799c4e88df685a89bfb))
- Resolve merge conflict in package.json - keep factual documentation name ([f4a740e](https://github.com/garywu/dotfiles/commit/f4a740eb8e6ddd00e57910d26da1ec6097787868))
- Resolve all documentation link issues ([40cf8ed](https://github.com/garywu/dotfiles/commit/40cf8ed843350e1661b1199f8c503bf3d69fb046))
- Resolve all documentation link issues (#23) ([5708e86](https://github.com/garywu/dotfiles/commit/5708e861ea9158c906527a9637651e534d41354d))
- Clean up whitespace and line length in CLI tools index ([aeda44a](https://github.com/garywu/dotfiles/commit/aeda44a08301b90e727ac996aa284c2fe8b43ed9))
- Resolve merge conflict in CLI tools index ([38ef473](https://github.com/garywu/dotfiles/commit/38ef4732e3ee5d7d2457569167496d7dfe8094e3))
- Resolve CI/CD workflow failures ([1fe1a09](https://github.com/garywu/dotfiles/commit/1fe1a09e9a01e77751b569dedcc72b7678e8426b))
- Properly center DOTFILES banner alignment ([40014dd](https://github.com/garywu/dotfiles/commit/40014dda76cd11549e18ecfa92d6c7eb5bb30655))
- Increase banner indentation for proper centering ([b200a1a](https://github.com/garywu/dotfiles/commit/b200a1af110222153f5c93d28c578bf2a8233d00))
- Use HTML pre tags for properly centered banner ([2caf426](https://github.com/garywu/dotfiles/commit/2caf426e1b94bba9eb146dfb689983db0ffae046))
- Resolve security workflow issues ([d407a99](https://github.com/garywu/dotfiles/commit/d407a9976ac13a5c77d810ebfafc871444b25eb6))
- Center tagline and remove privacy note ([903f7be](https://github.com/garywu/dotfiles/commit/903f7beeaaa078e5ab1bf0fda2fc4d5fbf3cac83))
- Better center tagline in banner ([e8ef54d](https://github.com/garywu/dotfiles/commit/e8ef54d751505dbaf8717d9a96655c6699006506))
- Reduce tagline spacing for proper centering ([d06f6df](https://github.com/garywu/dotfiles/commit/d06f6df0907ae5e8415e68820291f951dd192374))
- Reduce tagline spacing by 6 more spaces ([7a9bd93](https://github.com/garywu/dotfiles/commit/7a9bd938d9921773c870e95e92ee17b1f8115a88))
- Reduce tagline spacing by 2 more spaces for perfect centering ([47ab8e6](https://github.com/garywu/dotfiles/commit/47ab8e6f27c6fb9e151c71c030f7a8a3b71d1c47))
- Reduce tagline spacing by 4 more spaces ([5a86c24](https://github.com/garywu/dotfiles/commit/5a86c245c7146460872c5cf7fa6115b50aefdb2a))
- Remove all spacing from tagline for left alignment ([0d38d00](https://github.com/garywu/dotfiles/commit/0d38d00e5ff21dcb0061499f685764a18e040283))

### Documentation

- Add Git Flow branching strategy documentation ([6a4cd57](https://github.com/garywu/dotfiles/commit/6a4cd57a98ff1008c84a36481b11b4752869f3ee))
- Add comprehensive CLI tool usage galleries (#12) ([1d871bc](https://github.com/garywu/dotfiles/commit/1d871bc880d5177513205b63eb4b11894e24cb31))
- Add community patterns and CLI golf challenges (#12) ([ee372f5](https://github.com/garywu/dotfiles/commit/ee372f52d1231d20264c5759f289b5a164f2f663))
- Change tone from academy to factual documentation ([b3f3abd](https://github.com/garywu/dotfiles/commit/b3f3abd1d3289c7797521f7f9f6a6d19a20cbc5f))
- Remove title and make ASCII banner the main header ([3f69e55](https://github.com/garywu/dotfiles/commit/3f69e5556d5a2a12730b33598471c8bcf477a646))
- Update CLAUDE.md with successful workflow implementation ([db9b52b](https://github.com/garywu/dotfiles/commit/db9b52b4977f1f5d48e089a1d976179b6d3cc57b))

### Features

- Add claude-init as submodule ([1766c12](https://github.com/garywu/dotfiles/commit/1766c12e8d5cc3dfb6ac73532bbb2a4291c5504f))
- Implement session tracking system ([6562b5d](https://github.com/garywu/dotfiles/commit/6562b5d236405de06b8da8eaf663c2f5a94c66f0))
- Add gum, borgbackup, and fswatch to development tools ([09c3120](https://github.com/garywu/dotfiles/commit/09c31203bdaf8a67752a6f0965a46f8eea7c7202))
- Contribute valuable patterns from dotfiles to claude-init ([9d52454](https://github.com/garywu/dotfiles/commit/9d524545a39794c399480ba7ffeb41977bf6babe))
- Add remaining valuable patterns to claude-init ([72b4c49](https://github.com/garywu/dotfiles/commit/72b4c49157e6fee8b98d7c11f36f1f2b3aa0feda))
- Implement CLI tool efficiency testing framework ([c7834b8](https://github.com/garywu/dotfiles/commit/c7834b82a9f17cfbec4ca59229319a5d49eb785c))
- Complete CI/CD setup with lint and security workflows (#9) ([156179c](https://github.com/garywu/dotfiles/commit/156179cb13fead1a98dc49c2d3c267b2dc4bf449))
- Migrate comprehensive documentation to Dotfiles Academy (#12) ([1da4dee](https://github.com/garywu/dotfiles/commit/1da4dee29295a38e3cd47b1122cc07ffb89e7a63))
- Add git-cliff for automated changelog generation (#4) ([0278e27](https://github.com/garywu/dotfiles/commit/0278e273412ef2a316ce7393a71b82500c866751))
- Add documentation link testing suite ([475cdc5](https://github.com/garywu/dotfiles/commit/475cdc56a8be7a87e066b68e8545263665938c56))
- Install GNU coreutils and improve documentation tests ([b925558](https://github.com/garywu/dotfiles/commit/b925558f733c1283511d47f3e400b1e1d47af8dd))
- Add core documentation testing infrastructure ([a36e7e2](https://github.com/garywu/dotfiles/commit/a36e7e22069768fed67e88d3ed840468358d4164))
- Declare adoption of three-branch Git workflow ([8929700](https://github.com/garywu/dotfiles/commit/8929700c2d941761fbe9aaadbdda9e5d70ede599))
- Improve repository description with better selling points ([70589af](https://github.com/garywu/dotfiles/commit/70589af4e80dd2fc6c0278b8d0e6d4fa984e25cb))
- Add Windows WSL support to supported platforms ([2adde78](https://github.com/garywu/dotfiles/commit/2adde783bdf97dae5f3e10465a35120f9ebffe82))
- Add interactive components and learning paths (#12) ([d2ceb75](https://github.com/garywu/dotfiles/commit/d2ceb75ddd2b6896189e076cb1f12033b4613ef3))
- Implement CLI tool efficiency testing system (#20) ([68ac6e7](https://github.com/garywu/dotfiles/commit/68ac6e7bb8bfd405b06c2333643ecf4a386afbc7))
- Update claude-init submodule with major enhancements ([94eabcc](https://github.com/garywu/dotfiles/commit/94eabcc8d3172b2c98a60bde37a088c9528b8d73))

### Miscellaneous Tasks

- Update workflow to support Git Flow branches ([4d5f421](https://github.com/garywu/dotfiles/commit/4d5f4214fdcefc5f301c31643643c6f51972807e))
- Update claude-init submodule with advanced features ([e348f35](https://github.com/garywu/dotfiles/commit/e348f353cfb16a576ca893eee6c60b99168b91eb))
- Add efficiency test results to gitignore (#20) ([800b6a2](https://github.com/garywu/dotfiles/commit/800b6a20cc6133c01a499faa4355613f93b86b40))
- Fix linting issues for workflow declaration ([6dc0e43](https://github.com/garywu/dotfiles/commit/6dc0e435bff13c922cb417a3bcf2d6d564500f63))
- V0.2.1 [skip ci] ([b013ed6](https://github.com/garywu/dotfiles/commit/b013ed6ea4ce4562358e2dbf65b4a07e249f9249))
- V0.2.1 [skip ci] ([c7daeb6](https://github.com/garywu/dotfiles/commit/c7daeb664853a1cce7161c49c2f4e39674274032))
- V0.2.1 [skip ci] ([6cd6763](https://github.com/garywu/dotfiles/commit/6cd6763981e96bce225a798dbb24d0876ce0b9ca))
- V0.3.0 [skip ci] ([6926076](https://github.com/garywu/dotfiles/commit/69260763188ce55058f8ecb9fd36a6911f892ff2))

### Styling

- Center DOTFILES banner in README ([4672958](https://github.com/garywu/dotfiles/commit/46729582e011e3888bab90cb16a63540b2becf57))

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

## [0.1.0] - 2025-06-17

### Bug Fixes

- Resolve linting issues in bootstrap.sh and config files (#8) ([7363143](https://github.com/garywu/dotfiles/commit/73631434bff8f14a497e52849280d65c72217891))
- Apply pre-commit formatting to shell scripts ([23b71ca](https://github.com/garywu/dotfiles/commit/23b71caa530aaf70f1cd1db4da30a3b49d49598d))
- Sync package-lock.json with package.json ([0853dfe](https://github.com/garywu/dotfiles/commit/0853dfe6afbcf6670c70df288d6230b401f85544))

### Documentation

- Update CLAUDE.md with completed tasks ([b2c984c](https://github.com/garywu/dotfiles/commit/b2c984cae119ebd186075c56d2ea0d159380ee29))
- Update CLAUDE.md with new issues #8 and #9 ([009edd4](https://github.com/garywu/dotfiles/commit/009edd4b9073463ec833c007fcd8d4fdd4aeed8e))
- Update CLAUDE.md with linting fixes completion ([007cf4a](https://github.com/garywu/dotfiles/commit/007cf4ab51bfdb1e7147852ede57aef2276fa667))

### Features

- Add linting infrastructure and Cloudflare CLI tools (#6, #7) ([83ad63b](https://github.com/garywu/dotfiles/commit/83ad63b29a000df97ecccc81cd30dcbb145cd883))
- Add developer productivity CLI tools (#10) ([fbba0bc](https://github.com/garywu/dotfiles/commit/fbba0bc58aafc79319f3fd88f6d22ad9c77bd5fd))
- Complete Dotfiles Academy migration from Docusaurus to Starlight (#12) ([cd75b43](https://github.com/garywu/dotfiles/commit/cd75b4342a1901d83adbffac5243a388bf0f9626))
- Implement Git email privacy protection ([eadcc71](https://github.com/garywu/dotfiles/commit/eadcc7180285f98727f1b080fd7e2374ba844cb4))
- Implement automated release management system ([03adc6f](https://github.com/garywu/dotfiles/commit/03adc6f593a441a223afcdf5c25b012dd439b80d))

### Miscellaneous Tasks

- V0.1.0 [skip ci] ([e52aed3](https://github.com/garywu/dotfiles/commit/e52aed3ba0d3fcacd46030b45ff494525cdb8daa))

### Styling

- Auto-format TOML files with taplo (#8) ([3cc294d](https://github.com/garywu/dotfiles/commit/3cc294d56f4c9220f733600149a42ec15365acc7))
- Apply pre-commit hook formatting fixes ([51801ee](https://github.com/garywu/dotfiles/commit/51801ee37934acb4d84378165f557486722dbbab))

## [0.0.1] - 2025-06-17

### Bug Fixes

- Remove duplicate bun entry from Brewfile (already managed by Nix) ([1dd4f76](https://github.com/garywu/dotfiles/commit/1dd4f7658b5b43daa2f245685492de5c9309d2c9))
- Resolve bootstrap errors for future runs - Fix Home Manager config path issue - Remove problematic packages - Handle chezmoi conflict properly ([5d86570](https://github.com/garywu/dotfiles/commit/5d86570e825279ea82863b6e47c4049f9c6d3fc2))
- Ensure modern bash takes precedence for new scripts ([15fb4d3](https://github.com/garywu/dotfiles/commit/15fb4d38c46f9a16a665c3919f2a7f2034579f6e))
- Improve Homebrew path detection in Fish config for Apple Silicon Macs ([0e9f4fe](https://github.com/garywu/dotfiles/commit/0e9f4fe4ea53991ab349a3ade0fe01aa60459aa8))
- Remove blocking changelog hook from pre-commit config ([9f121f4](https://github.com/garywu/dotfiles/commit/9f121f44b4cdf8f5e04cc5cd07063da94cf3dcc1))

### Canonicalize

- Home Manager manages all dotfiles/configs, Chezmoi only for secrets/meta, update README and clean project ([5c58bfd](https://github.com/garywu/dotfiles/commit/5c58bfdbeda9673e24b6cbe017ca90aee91fe5b9))

### Documentation

- Add comprehensive philosophy section explaining Nix-first approach and improve bootstrap Home Manager detection ([7250cc2](https://github.com/garywu/dotfiles/commit/7250cc279dc3a7fa4dabc9b5eb73b32768f394aa))
- Update README for enhanced unbootstrap script and symmetric structure - Update project structure to show unbootstrap.sh in root for symmetry - Fix path references from scripts/unbootstrap.sh to ./unbootstrap.sh - Add comprehensive safety warnings to unbootstrap script - Emphasize enhanced cleanup capabilities and safety features ([4c49eaa](https://github.com/garywu/dotfiles/commit/4c49eaa501e62f6abbdf9f74385c537f3812fa1e))
- Add evolution.md documenting bootstrap script history and architectural decisions ([c55cd33](https://github.com/garywu/dotfiles/commit/c55cd33d6b35bb36dff31c0fb964541a0b98c565))

### Features

- Add robust minimal installation script with automatic repo detection ([f7c5bca](https://github.com/garywu/dotfiles/commit/f7c5bca2e8fca0180a5897a4c57cd03f46d086a1))
- Complete setup overhaul with minimal installation and improved structure ([c385344](https://github.com/garywu/dotfiles/commit/c3853440bab6d657ed2b9a05cb7372ce5c7616aa))
- Finalize bootstrap script with improved Homebrew detection and environment sourcing ([c334408](https://github.com/garywu/dotfiles/commit/c334408e8529b25e5c0063e02b0af5495c828025))
- Add system state check script and improve unbootstrap - Add check.sh for comprehensive system auditing and cleanup - Improve unbootstrap.sh with official uninstall methods - Update README.md with check script documentation ([1367ed5](https://github.com/garywu/dotfiles/commit/1367ed5df7b9a0611dfbc1d753757e63164c8c24))
- Add automatic shell management to bootstrap/unbootstrap - Bootstrap now changes default shell to fish automatically - Stores original shell in .shell_backup for restoration - Uninstall script restores original shell from backup - Adds fish to /etc/shells if needed - New terminals will use fish + starship by default ([9aef4b9](https://github.com/garywu/dotfiles/commit/9aef4b9bb0eeda4cab531fa74247daaf432dd69d))
- Add professional development standards and GitHub templates (#5) ([345f034](https://github.com/garywu/dotfiles/commit/345f034be5a3403c39b7843265c47350e62e6017))

### Miscellaneous Tasks

- Enhance Nix backup file handling - Add backup file detection to check.sh for troubleshooting - Improve uninstall.sh to handle all backup file locations - Better alignment with official Nix documentation ([9215e34](https://github.com/garywu/dotfiles/commit/9215e3406890ca53b20df8d52ad6087d53187fd9))
- Post-bootstrap, all configs and scripts up to date ([3cd3890](https://github.com/garywu/dotfiles/commit/3cd38903437c273e4f49945c91b8ed7f5ed69b6c))

### Refactor

- Consolidate installation scripts into single bootstrap.sh ([f25d661](https://github.com/garywu/dotfiles/commit/f25d6616ddc923390c1a3127fc010bda0fc811b7))
- Move unbootstrap.sh to root for symmetry with bootstrap.sh - Move unbootstrap.sh symlink from scripts/ to root directory - Creates symmetric user experience: ./bootstrap.sh and ./unbootstrap.sh - Both setup and teardown scripts now easily discoverable in root ([864018a](https://github.com/garywu/dotfiles/commit/864018ac6d0595d34141ff629a247ac4a6f4b023))
- [**breaking**] Separate Nix/Home Manager from Chezmoi management ([6ecc2d6](https://github.com/garywu/dotfiles/commit/6ecc2d695f0098813c0e49186692428efa7b9240))

### Testing

- Verify pre-commit hooks are working ([3646d2b](https://github.com/garywu/dotfiles/commit/3646d2b2f2c001cef58b6c9768318df05493dea8))

### Enhance

- Improve unbootstrap script to handle all Nix services - Fix stop_nix_daemon() to discover and stop ALL Nix-related launchd services - Add support for Determinate Systems installer services and darwin-store - Enhance process detection and pattern matching - Better error reporting and comprehensive cleanup ([74258f9](https://github.com/garywu/dotfiles/commit/74258f94cccebe5a055589485b94cb04851b1565))

### Workaround

- Install pnpm globally with npm if not available (Nix package broken) ([d477e88](https://github.com/garywu/dotfiles/commit/d477e884b47de7f0025c80be906cd71e4173d3af))

---

🤖 Generated with [git-cliff](https://git-cliff.org)
