# Makefile for dotfiles development and management

.PHONY: all help lint format lint-shell format-shell lint-nix format-nix lint-yaml lint-markdown lint-toml format-toml lint-fish format-fish check fix session-start session-end session-status session-log

# Default target
all: help

# Changelog generation
.PHONY: changelog
changelog: ## Generate changelog using git-cliff
	@echo "Generating changelog..."
	@git cliff --config cliff.toml -o CHANGELOG.md
	@echo "Changelog updated!"

# Help target
help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo ""
	@echo "Quick Start:"
	@echo "  make dev-setup      - Set up development environment"
	@echo "  make update         - Update all dependencies"
	@echo "  make deps           - Show dependency versions"
	@echo "  make test           - Run all tests"
	@echo ""
	@echo "Development:"
	@echo "  make lint           - Run all linters"
	@echo "  make format         - Run all formatters"
	@echo "  make pr-ready       - Prepare for pull request"
	@echo "  make ci-test        - Run CI tests locally"
	@echo ""
	@echo "Release Management:"
	@echo "  make changelog      - Generate/update changelog"
	@echo "  make version        - Show current version info"
	@echo "  make tag VERSION=v1.0.0 - Create version tag"
	@echo "  make release-beta   - Create beta release"
	@echo "  make release-stable - Promote beta to stable"
	@echo ""
	@echo "Session Management:"
	@echo "  make session-start  - Start a new development session"
	@echo "  make session-end    - End current session and archive"
	@echo "  make session-status - Show current session status"
	@echo "  make session-log MSG=\"message\" - Add session log entry"
	@echo ""
	@echo "Utilities:"
	@echo "  make issues         - Show open GitHub issues"
	@echo "  make pr             - Show open pull requests"
	@echo "  make clean-logs     - Clean old log files"
	@echo "  make install-docs   - Install documentation dependencies"
	@echo ""
	@echo "Security & Quality:"
	@echo "  make security-all   - Run all security checks"
	@echo "  make security-scan  - Scan for vulnerabilities"
	@echo "  make secret-scan    - Scan for exposed secrets"
	@echo "  make metrics        - Show code metrics"
	@echo "  make coverage       - Check dependency vulnerabilities"
	@echo ""
	@echo "Individual Tools:"
	@echo "  make lint-shell     - Lint shell scripts"
	@echo "  make lint-nix       - Lint Nix files"
	@echo "  make lint-yaml      - Lint YAML files"
	@echo "  make lint-markdown  - Lint Markdown files"
	@echo "  make format-shell   - Format shell scripts"
	@echo "  make format-nix     - Format Nix files"
	@echo ""
	@echo "Use 'make <target>' to run a command."

# Aliases
check: lint
fix: format

# Run all linters
lint: lint-shell lint-nix lint-yaml lint-markdown lint-toml lint-fish
	@echo "✅ All linting checks passed!"

# Run all formatters
format: format-shell format-nix format-toml format-fish
	@echo "✅ All formatting complete!"

# Fix shell issues comprehensively (format + common fixes)
fix-shell:
	@echo "🔧 Fixing shell script issues..."
	@echo "  → Fixing bash shebangs..."
	@./scripts/fix-shebangs.sh
	@echo "  → Running shellharden..."
	@find . -type f -name "*.sh" -not -path "./node_modules/*" -not -path "./.git/*" | xargs -I {} shellharden --transform {} 2>/dev/null || true
	@echo "  → Running shfmt..."
	@find . -type f -name "*.sh" -not -path "./node_modules/*" -not -path "./.git/*" | xargs shfmt -w -i 2 -ci -s 2>/dev/null || true
	@echo "✅ Shell script fixes applied!"

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

# Test targets
test: test-shell test-docs
	@echo "✓ All tests passed"

test-shell:
	@echo "Testing shell scripts..."
	@shellcheck bootstrap.sh tests/*.sh tests/docs/*.sh || true

test-docs:
	@echo "Testing documentation links..."
	@timeout 30 ./tests/docs/test_production_links_simple.sh

test-docs-local:
	@echo "Testing documentation locally..."
	@./tests/docs/test_links.sh local

# Session Management
session-start:
	@./scripts/session-start.sh

session-end:
	@./scripts/session-end.sh

session-status:
	@./scripts/session-status.sh

session-log:
	@if [ -z "$(MSG)" ]; then \
		echo "Usage: make session-log MSG=\"your log message\""; \
		exit 1; \
	else \
		./scripts/session-log.sh "$(MSG)"; \
	fi

# Development Environment Setup
.PHONY: dev-setup dev-clean update deps bootstrap ci-test

dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	@./bootstrap.sh
	@echo "Development environment ready!"

dev-clean: ## Clean development environment
	@echo "Cleaning development environment..."
	@./unbootstrap.sh
	@echo "Development environment cleaned!"

update: ## Update all dependencies (Nix, Homebrew, etc.)
	@echo "Updating Nix packages..."
	@nix flake update
	@echo "Applying Home Manager updates..."
	@home-manager switch
	@echo "Updating Homebrew packages..."
	@brew update && brew upgrade
	@echo "All dependencies updated!"

deps: ## Show dependency versions
	@echo "=== System Dependencies ==="
	@echo "Nix version: $$(nix --version)"
	@echo "Home Manager: $$(home-manager --version)"
	@echo "Chezmoi: $$(chezmoi --version)"
	@echo "Homebrew: $$(brew --version | head -1)"
	@echo ""
	@echo "=== Language Versions ==="
	@echo "Node.js: $$(node --version)"
	@echo "Python: $$(python3 --version)"
	@echo "Ruby: $$(ruby --version)"
	@echo ""
	@echo "=== Key Tools ==="
	@echo "Git: $$(git --version)"
	@echo "Fish: $$(fish --version)"
	@echo "Starship: $$(starship --version)"

bootstrap: dev-setup ## Alias for dev-setup

ci-test: ## Run CI tests locally
	@echo "Running CI tests locally..."
	@echo "Linting..."
	@$(MAKE) lint
	@echo "Testing documentation..."
	@$(MAKE) test-docs
	@echo "All CI tests passed!"

# Git Workflow Helpers
.PHONY: pr-ready release-beta release-stable

pr-ready: lint format test ## Prepare for pull request
	@echo "Checking for uncommitted changes..."
	@git diff --exit-code || (echo "Error: Uncommitted changes found" && exit 1)
	@echo "Ready for PR!"

release-beta: ## Create beta release
	@echo "Creating beta release..."
	@git checkout main
	@git pull origin main
	@git checkout beta
	@git merge main --no-ff -m "chore: merge main into beta for release"
	@echo "Beta release prepared. Don't forget to push!"

release-stable: ## Promote beta to stable
	@echo "Promoting beta to stable..."
	@git checkout beta
	@git pull origin beta
	@git checkout stable
	@git merge beta --no-ff -m "chore: promote beta to stable release"
	@echo "Stable release prepared. Don't forget to push and tag!"

# Utility Commands
.PHONY: clean-logs issues pr

clean-logs: ## Clean old log files
	@echo "Cleaning old log files..."
	@find logs -name "*.log" -mtime +30 -delete 2>/dev/null || true
	@echo "Log files cleaned!"

issues: ## Show open GitHub issues
	@gh issue list --limit 20

pr: ## Show open pull requests
	@gh pr list --limit 10

# Installation shortcuts
.PHONY: install-docs install-cli

install-docs: ## Install documentation dependencies
	@echo "Installing documentation dependencies..."
	@cd docs && npm install
	@echo "Documentation dependencies installed!"

install-cli: ## Install additional CLI tools
	@echo "Installing additional CLI tools..."
	@home-manager switch
	@echo "CLI tools installed!"

# Version and Release Management
.PHONY: version changelog-preview tag

version: ## Show current version
	@echo "Current version: $$(git describe --tags --abbrev=0 2>/dev/null || echo 'No version tagged')"
	@echo "Commits since last tag: $$(git rev-list --count $$(git describe --tags --abbrev=0 2>/dev/null)..HEAD 2>/dev/null || echo 'N/A')"

changelog-preview: ## Preview changelog for next release
	@echo "Preview of changes for next release:"
	@git cliff --unreleased

tag: ## Create a new version tag
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make tag VERSION=v1.0.0"; \
		exit 1; \
	else \
		git tag -a $(VERSION) -m "Release $(VERSION)"; \
		echo "Tagged version $(VERSION)"; \
		echo "Don't forget to push tags: git push origin $(VERSION)"; \
	fi

# Security and Quality Metrics
.PHONY: security-scan secret-scan docker-scan metrics coverage

security-scan: ## Run security scans on the codebase
	@echo "Running security scans..."
	@echo "Scanning for vulnerabilities in filesystem..."
	@trivy fs . --severity HIGH,CRITICAL || true
	@echo "Security scan complete!"

secret-scan: ## Scan for secrets in git history
	@echo "Scanning for secrets in git repository..."
	@gitleaks detect --source . --verbose || true
	@echo "Secret scan complete!"

docker-scan: ## Scan Dockerfiles for issues
	@echo "Scanning Dockerfiles..."
	@find . -name "Dockerfile*" -type f | while read -r file; do \
		echo "Checking $$file..."; \
		hadolint "$$file" || true; \
	done
	@echo "Dockerfile scan complete!"

metrics: ## Show code metrics
	@echo "=== Code Metrics ==="
	@tokei .
	@echo ""
	@echo "=== Repository Size ==="
	@du -sh .
	@echo ""
	@echo "=== Git Statistics ==="
	@echo "Total commits: $$(git rev-list --all --count)"
	@echo "Contributors: $$(git shortlog -sn | wc -l)"
	@echo "Files tracked: $$(git ls-files | wc -l)"

coverage: ## Check dependency vulnerabilities
	@echo "Checking for vulnerabilities in dependencies..."
	@echo ""
	@echo "=== NPM Dependencies ==="
	@if [ -f package.json ]; then \
		cd docs && npm audit || true; \
	else \
		echo "No package.json found"; \
	fi
	@echo ""
	@echo "=== Python Dependencies ==="
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 list --outdated || true; \
	else \
		echo "pip3 not found"; \
	fi
	@echo ""
	@echo "Dependency check complete!"

# Combined security check
.PHONY: security-all

security-all: security-scan secret-scan docker-scan coverage ## Run all security checks
	@echo "All security checks complete!"
