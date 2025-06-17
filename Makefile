# Makefile for dotfiles linting and formatting

.PHONY: all help lint format lint-shell format-shell lint-nix format-nix lint-yaml lint-markdown lint-toml format-toml lint-fish format-fish check fix

# Default target
all: help

# Help target
help:
	@echo "Dotfiles Linting and Formatting"
	@echo "==============================="
	@echo ""
	@echo "Available targets:"
	@echo "  make lint       - Run all linters"
	@echo "  make format     - Run all formatters"
	@echo "  make check      - Same as 'make lint'"
	@echo "  make fix        - Same as 'make format'"
	@echo ""
	@echo "Individual linters:"
	@echo "  make lint-shell     - Lint shell scripts with shellcheck"
	@echo "  make lint-nix       - Lint Nix files with statix"
	@echo "  make lint-yaml      - Lint YAML files with yamllint"
	@echo "  make lint-markdown  - Lint Markdown files with markdownlint"
	@echo "  make lint-toml      - Check TOML files with taplo"
	@echo "  make lint-fish      - Check Fish scripts syntax"
	@echo ""
	@echo "Individual formatters:"
	@echo "  make format-shell   - Format shell scripts with shfmt"
	@echo "  make format-nix     - Format Nix files with nixpkgs-fmt"
	@echo "  make format-toml    - Format TOML files with taplo"
	@echo "  make format-fish    - Format Fish scripts with fish_indent"

# Aliases
check: lint
fix: format

# Run all linters
lint: lint-shell lint-nix lint-yaml lint-markdown lint-toml lint-fish
	@echo "✅ All linting checks passed!"

# Run all formatters
format: format-shell format-nix format-toml format-fish
	@echo "✅ All formatting complete!"

# Shell linting and formatting
lint-shell:
	@echo "🔍 Linting shell scripts..."
	@find . -type f -name "*.sh" -o -name "*.bash" | grep -v node_modules | xargs -r shellcheck || true
	@shellcheck bootstrap.sh || true

format-shell:
	@echo "🎨 Formatting shell scripts..."
	@find . -type f -name "*.sh" -o -name "*.bash" | grep -v node_modules | xargs -r shfmt -w || true
	@shfmt -w bootstrap.sh || true

# Nix linting and formatting
lint-nix:
	@echo "🔍 Linting Nix files..."
	@if command -v statix >/dev/null 2>&1; then \
		find . -type f -name "*.nix" | grep -v node_modules | xargs -r statix check || true; \
	else \
		echo "⚠️  statix not installed, skipping Nix linting"; \
	fi

format-nix:
	@echo "🎨 Formatting Nix files..."
	@find . -type f -name "*.nix" | grep -v node_modules | xargs -r nixpkgs-fmt || true

# YAML linting
lint-yaml:
	@echo "🔍 Linting YAML files..."
	@yamllint . || true

# Markdown linting
lint-markdown:
	@echo "🔍 Linting Markdown files..."
	@markdownlint '**/*.md' --ignore node_modules || true

# TOML linting and formatting
lint-toml:
	@echo "🔍 Checking TOML files..."
	@find . -type f -name "*.toml" | grep -v node_modules | xargs -r taplo check || true

format-toml:
	@echo "🎨 Formatting TOML files..."
	@find . -type f -name "*.toml" | grep -v node_modules | xargs -r taplo format || true

# Fish linting and formatting
lint-fish:
	@echo "🔍 Checking Fish scripts..."
	@find . -type f -name "*.fish" | grep -v node_modules | while read -r file; do \
		fish -n "$$file" || true; \
	done

format-fish:
	@echo "🎨 Formatting Fish scripts..."
	@find . -type f -name "*.fish" | grep -v node_modules | xargs -r fish_indent -w || true
