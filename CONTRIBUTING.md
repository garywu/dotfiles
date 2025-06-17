# Contributing to dotfiles

First off, thank you for considering contributing to this dotfiles repository!

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, use the bug report template and include as many details as possible.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Use the feature request template and provide clear use cases.

### Code Contributions

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Make your changes
4. Commit using conventional commits
5. Push to your fork
6. Open a Pull Request

## Development Setup

### Prerequisites
- Nix package manager
- Git
- GitHub CLI (`gh`) for issue management

### Setup Steps
```bash
# Clone the repository
git clone https://github.com/garywu/dotfiles.git
cd dotfiles

# Run bootstrap
./bootstrap.sh

# Apply Home Manager configuration
home-manager switch
```

### Directory Structure
```
.dotfiles/
├── nix/              # Nix and Home Manager configurations
├── chezmoi/          # Secrets and machine-specific templates
├── brew/             # macOS GUI applications
├── .github/          # GitHub templates and workflows
└── docs/             # Additional documentation
```

## Style Guidelines

### Shell Scripts
- Use `shellcheck` for linting (`make lint-shell`)
- Use `shfmt` for formatting (`make format-shell`)
- Follow POSIX standards where possible
- Add error handling and set appropriate flags (`set -euo pipefail`)
- Configuration: `.shellcheckrc`

### Nix Files
- Use `nixpkgs-fmt` for formatting (`make format-nix`)
- Use `statix` for linting when available (`make lint-nix`)
- Keep expressions simple and readable
- Add comments for complex logic

### Fish Scripts
- Use `fish_indent` for formatting (`make format-fish`)
- Check syntax with `fish -n` (`make lint-fish`)
- Follow Fish scripting best practices
- Use descriptive function names

### YAML Files
- Use `yamllint` for linting (`make lint-yaml`)
- Configuration: `.yamllint.yml`
- 2-space indentation
- No trailing spaces

### Markdown Files
- Use `markdownlint` for linting (`make lint-markdown`)
- Configuration: `.markdownlint.json`
- Line length: 120 characters
- ATX-style headers

### TOML Files
- Use `taplo` for formatting (`make format-toml`)
- Use `taplo` for linting (`make lint-toml`)

### General Guidelines
- Run `make lint` before committing
- Run `make format` to auto-fix formatting issues
- Keep files focused and modular
- Document complex logic
- Use meaningful variable names
- Avoid hardcoding values
- Follow `.editorconfig` settings

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/). Each commit message should have the format:

```
type(scope): description

[optional body]

[optional footer(s)]
```

### Types
- `fix`: Bug fixes
- `feat`: New features
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code changes that neither fix bugs nor add features
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks

### Examples
```
feat(nix): add ripgrep to home.nix
fix(fish): correct homebrew path detection on Apple Silicon
docs: update installation instructions in README
refactor(bootstrap): simplify error handling logic
```

## Pull Request Process

1. **Create an issue first**: All PRs should reference an issue
2. **Branch naming**: Use `type/description` format (e.g., `feat/add-tmux-config`)
3. **Keep PRs focused**: One feature/fix per PR
4. **Update documentation**: Include any necessary documentation changes
5. **Test your changes**: Ensure all changes work as expected
6. **Run linting**: Check your code with appropriate linters
7. **Request review**: Once ready, request review from maintainers

### PR Checklist
- [ ] Referenced issue number in PR description
- [ ] Followed code style guidelines
- [ ] Added/updated tests if applicable
- [ ] Updated documentation if needed
- [ ] Commits follow conventional format
- [ ] Branch is up to date with main

## Issue Reporting

### Before Submitting an Issue
- Check if the issue already exists
- Check if it's covered in documentation
- Collect relevant information (OS, versions, error messages)

### Issue Templates
Use the appropriate template:
- **Bug Report**: For reporting bugs
- **Feature Request**: For suggesting new features
- **Documentation**: For documentation improvements
- **Refactoring**: For code improvement suggestions

### Good Issue Practices
- Use clear, descriptive titles
- Provide context and examples
- Include steps to reproduce (for bugs)
- Suggest solutions if you have ideas
- Be respectful and constructive

## Questions?

Feel free to open an issue with the question label or start a discussion in the GitHub Discussions tab.
