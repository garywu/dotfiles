# Python Development Setup

This dotfiles configuration provides a modern Python development environment using `uv`, an ultra-fast Python package and project manager.

## Overview

We use a two-tier approach:
1. **CLI Tools**: Globally installed development tools (black, pytest, etc.)
2. **Project Libraries**: Project-specific dependencies (numpy, pillow, etc.)

## Why uv?

- **Speed**: 10-100x faster than pip/pipx
- **All-in-one**: Replaces pip, pipx, venv, virtualenv, poetry
- **Modern**: Written in Rust, actively developed
- **Compatible**: Works with existing Python ecosystems

## Automatic Setup

The bootstrap process automatically:
1. Installs Python 3.11 via Nix
2. Installs uv to `~/.local/bin/uv`
3. Runs `setup-python-tools-uv.sh` to install common CLI tools

## Manual Python Tools Installation

If you need to run the Python tools setup manually:

```bash
./scripts/setup-python-tools-uv.sh
```

This installs:
- **Code Quality**: black, ruff, mypy
- **Development**: poetry, ipython, pre-commit
- **Testing**: pytest, tox
- **Documentation**: mkdocs
- **Utilities**: httpie, cookiecutter, pip-tools

## Working with Projects

### Creating a New Project

```bash
# Create project directory
mkdir my-project && cd my-project

# Create virtual environment with uv (super fast!)
uv venv

# Activate the environment
source .venv/bin/activate  # On Unix/macOS
# or
.venv\Scripts\activate     # On Windows

# Install project dependencies
uv pip install django fastapi numpy pandas

# Or from requirements.txt
uv pip install -r requirements.txt
```

### Using uv Instead of pip

uv is a drop-in replacement for pip:

```bash
# Instead of: pip install package
uv pip install package

# Instead of: pip install -r requirements.txt
uv pip install -r requirements.txt

# Instead of: pip freeze
uv pip freeze
```

### Installing Additional CLI Tools

To install additional Python CLI tools globally:

```bash
# Install a CLI tool (like pipx)
uv tool install pylint

# List installed tools
uv tool list

# Upgrade a tool
uv tool upgrade black

# Upgrade all tools
uv tool upgrade --all
```

## Tools vs Libraries

**CLI Tools** (install globally with `uv tool install`):
- Executables you run from the command line
- Examples: black, pytest, mypy, flake8
- Installed once, used across all projects

**Libraries** (install per-project with `uv pip install`):
- Python packages you import in code
- Examples: numpy, pandas, requests, pillow
- Different projects may need different versions

## Best Practices

1. **Always use virtual environments** for projects
2. **Keep global tools minimal** - only CLI utilities
3. **Pin versions** in requirements.txt for reproducibility
4. **Use uv** instead of pip for speed

## Troubleshooting

### uv not found

If `uv` is not in your PATH:

```bash
# Add to current session
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Python version conflicts

The system uses Python 3.11 from Nix. If you need a different version:

```bash
# Install specific Python version with uv
uv python install 3.12

# Create venv with specific Python
uv venv --python 3.12
```

### Tool conflicts

If a tool was previously installed with pipx:

```bash
# Remove old pipx version
pipx uninstall black

# Install with uv
uv tool install black
```

## Advanced Usage

### Global Development Environment

For data science or general development:

```bash
# Create a global environment
uv venv ~/.python-dev

# Activate it
source ~/.python-dev/bin/activate

# Install common libraries
uv pip install jupyter numpy pandas matplotlib seaborn scikit-learn
```

### Project Templates

Use cookiecutter for project templates:

```bash
# Create from template
cookiecutter https://github.com/cookiecutter/cookiecutter-django

# Or use a local template
cookiecutter ./my-template/
```

## Resources

- [uv Documentation](https://github.com/astral-sh/uv)
- [Python Packaging Guide](https://packaging.python.org/)
- [Real Python Tutorials](https://realpython.com/)

## Summary

This setup provides:
- Fast, modern Python tooling with uv
- Clean separation between tools and libraries
- Consistent development environment
- Easy project management

The bootstrap process handles everything automatically, so you can focus on writing Python code!
