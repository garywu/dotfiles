---
title: EditorConfig Hierarchical Strategy
description: Comprehensive guide to EditorConfig setup across global dotfiles and project-specific configurations
---

# EditorConfig Hierarchical Strategy

This document explains the multi-layered EditorConfig approach used across the dotfiles ecosystem and claude-init project templates.

## Overview

The EditorConfig system operates on a **hierarchical configuration model** that balances global consistency with project-specific needs:

1. **Global dotfiles**: Optimized for web development (2-space default)
2. **claude-init templates**: Project-specific overrides for different technologies
3. **Project inheritance**: Local `.editorconfig` files override global settings

## Global Configuration (Dotfiles)

The dotfiles `.editorconfig` provides web-development-optimized defaults:

```ini
# ~/.dotfiles/.editorconfig - Global defaults
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2  # Web development optimized

# Shell scripts (optimized for web tooling)
[*.{sh,bash,fish}]
indent_size = 2

# Language-specific overrides
[*.py]
indent_size = 4  # Python PEP 8

[*.go]
indent_style = tab  # Go convention

[Makefile]
indent_style = tab  # Required by Make
```

### Rationale for 2-Space Global Default

- **Primary workflow**: Web development (JavaScript, TypeScript, CSS, HTML)
- **Consistency**: Matches modern web framework conventions (React, Vue, Angular)
- **Readability**: Better for complex nested structures in web technologies
- **Tool compatibility**: Aligns with Prettier, ESLint, and other web dev tools

## Project-Specific Overrides (claude-init)

The `claude-init` repository provides templates for different project types that override global settings as needed.

### Infrastructure/DevOps Projects

For infrastructure projects requiring 4-space shell scripts:

```ini
# claude-init/templates/infrastructure/.editorconfig
root = true

# Inherit global defaults for most files
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

# Infrastructure-specific: 4-space shell scripts
[*.{sh,bash}]
indent_style = space
indent_size = 4  # Infrastructure convention

# YAML for Kubernetes, Docker Compose, etc.
[*.{yml,yaml}]
indent_size = 2

# Terraform
[*.{tf,tfvars}]
indent_size = 2

# Dockerfile
[Dockerfile*]
indent_size = 2
```

### Backend API Projects

For backend projects with different language requirements:

```ini
# claude-init/templates/api/.editorconfig
root = true

# Go API project
[*.go]
indent_style = tab
indent_size = 4

# Python API project
[*.py]
indent_size = 4
max_line_length = 88  # Black formatter

# Java/Kotlin API project
[*.{java,kt,kts}]
indent_size = 4
continuation_indent_size = 8

# Shell scripts for API tooling
[*.{sh,bash}]
indent_size = 2  # Keep web dev standard for tooling
```

### Data Science Projects

For data science with specific R/Python requirements:

```ini
# claude-init/templates/data-science/.editorconfig
root = true

# Python - Black formatter compatible
[*.py]
indent_size = 4
max_line_length = 88

# R files
[*.{r,R,Rmd}]
indent_size = 2

# Jupyter Notebooks
[*.ipynb]
indent_size = 1

# Data files - preserve exact format
[*.{csv,tsv,json,jsonl}]
trim_trailing_whitespace = false
insert_final_newline = false
```

## How the Hierarchy Works

### 1. Inheritance Chain

```
Project .editorconfig (highest priority)
    ↓
claude-init template .editorconfig
    ↓
Global dotfiles .editorconfig (lowest priority)
```

### 2. EditorConfig Resolution

EditorConfig searches from the current file's directory upward until it finds a file with `root = true`:

```
/project-root/
├── .editorconfig (root = true) ← Stops here
├── src/
│   ├── components/
│   │   └── Button.tsx ← Uses project .editorconfig
│   └── utils/
└── scripts/
    └── deploy.sh ← Uses project .editorconfig
```

### 3. Example Resolution

For a file `/project/scripts/deploy.sh`:

1. **Check**: `/project/scripts/.editorconfig` (not found)
2. **Check**: `/project/.editorconfig` (found, has `root = true`)
3. **Apply**: Rules from project `.editorconfig`
4. **Result**: Uses project-specific shell script indentation

## Implementation Strategy

### For New Projects

When initializing a new project with `claude-init`:

1. **Detect project type** (web, infrastructure, API, data science)
2. **Copy appropriate template** `.editorconfig` from claude-init
3. **Customize if needed** for specific project requirements
4. **Document decisions** in project README or CONTRIBUTING.md

### For Existing Projects

When working on existing projects:

1. **Check existing** `.editorconfig` in project root
2. **If none exists**, create one using claude-init template
3. **If conflicts arise**, create project-specific override
4. **Document override rationale** for team understanding

### Example Workflow

```bash
# 1. Initialize new infrastructure project
claude-init infrastructure my-k8s-project

# 2. This creates .editorconfig with:
# - 4-space shell scripts (infrastructure standard)
# - 2-space YAML (Kubernetes standard)
# - Other infrastructure-appropriate settings

# 3. Global dotfiles .editorconfig is ignored due to root = true
```

## Common Scenarios

### Scenario 1: Web Developer Working on Infrastructure

**Problem**: Global 2-space shell scripts don't match infrastructure team's 4-space standard.

**Solution**:
```bash
# Use claude-init template for infrastructure project
cd infrastructure-project
cp ~/external/claude-init/templates/infrastructure/.editorconfig .
```

### Scenario 2: Infrastructure Engineer Working on Web App

**Problem**: Need to contribute to web application with different conventions.

**Solution**:
- Global dotfiles already optimized for web development
- No project `.editorconfig` means global rules apply
- 2-space indentation automatically used

### Scenario 3: Mixed-Technology Monorepo

**Problem**: Single repository contains multiple project types.

**Solution**:
```ini
# .editorconfig - Monorepo with multiple technologies
root = true

# Global defaults (web-optimized)
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

# Infrastructure subdirectory
[infrastructure/**.{sh,bash}]
indent_size = 4

# Backend API subdirectory
[api/**.go]
indent_style = tab

# Frontend apps maintain global 2-space default
[apps/**.*]
indent_size = 2
```

## Benefits of This Approach

### 1. **Zero Friction for Primary Work**
- Global dotfiles optimized for main workflow (web development)
- No constant fighting with editor settings

### 2. **Automatic Project Adaptation**
- claude-init templates provide appropriate settings for project type
- Team members get consistent formatting automatically

### 3. **Override When Needed**
- Easy to create project-specific rules when requirements differ
- Hierarchical system provides predictable behavior

### 4. **Documentation and Discoverability**
- Templates in claude-init serve as documentation
- Clear examples for common project types
- Easy for teams to understand and adopt

## Documentation Integration

### In Project README

```markdown
## Development Setup

This project uses EditorConfig for consistent formatting. Your editor should:

1. **Install EditorConfig plugin** for your editor
2. **Check project root** for `.editorconfig` file
3. **Follow project conventions** automatically

### Formatting Rules
- **Shell scripts**: 4 spaces (infrastructure standard)
- **YAML files**: 2 spaces (Kubernetes standard)
- **Most other files**: 2 spaces (inherited from global)

See `.editorconfig` file for complete settings.
```

### In CONTRIBUTING.md

```markdown
## Code Style

This project uses EditorConfig to maintain consistent formatting across editors and team members.

### Setup
1. Install EditorConfig plugin for your editor
2. Settings are automatically applied from `.editorconfig`

### Overriding Global Settings
This project overrides some global dotfiles settings:
- Shell scripts use 4 spaces (vs global 2 spaces)
- Rationale: Infrastructure team convention for improved readability

### Adding New File Types
When adding support for new languages:
1. Add appropriate rules to `.editorconfig`
2. Consider team conventions and language standards
3. Document decisions in this file
```

## Troubleshooting

### Common Issues

1. **Editor not respecting settings**
   - Install EditorConfig plugin for your editor
   - Check that `.editorconfig` has `root = true`

2. **Conflicting with other formatters**
   - EditorConfig sets basic rules (indentation, line endings)
   - Language-specific formatters (Prettier, Black) handle advanced formatting
   - EditorConfig runs first, formatters can override

3. **Pre-commit hooks failing**
   - Ensure local editor settings match project `.editorconfig`
   - Run `editorconfig-checker` to validate files

### Debugging Configuration

```bash
# Check which .editorconfig file is being used
find . -name ".editorconfig" -type f

# Validate .editorconfig syntax
editorconfig-checker .editorconfig

# Test specific file resolution
editorconfig-checker path/to/specific/file.sh
```

## External Resources

- **dotfiles**: Global configuration in `~/.dotfiles/.editorconfig`
- **claude-init**: Project templates in `external/claude-init/templates/`
- **EditorConfig docs**: [editorconfig.org](https://editorconfig.org/)
- **claude-init patterns**: [editorconfig-patterns.md](../../../external/claude-init/docs/editorconfig-patterns.md)

---

This hierarchical strategy provides the best of both worlds: optimized global defaults for primary work, with easy project-specific overrides when needed. The claude-init integration ensures teams can quickly adopt appropriate conventions for their project type.
