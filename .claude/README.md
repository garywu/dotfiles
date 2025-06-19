# Claude Session Management

This directory contains session tracking and context management for dotfiles development.

## Directory Structure

```
.claude/
├── history/          # Daily session logs with timestamps
├── context/          # Project-specific context files
├── snippets/         # Reusable code snippets and configurations
├── session.json      # Current session state
└── README.md         # This file
```

## Usage

### Starting a Session

```bash
make session-start
```

This will:
- Create a new session entry in `session.json`
- Initialize a daily log in `history/YYYY-MM-DD.md`
- Show current dotfiles status

### Ending a Session

```bash
make session-end
```

This will:
- Update the session summary
- Commit any pending changes
- Archive the session state

### Session Status

```bash
make session-status
```

Shows:
- Current session info
- Recent changes
- Pending tasks

## Session History

Session logs are stored in `history/` with the format:
- Filename: `YYYY-MM-DD.md`
- Content: Timestamped entries of all session activities

## Context Files

Store project-specific context in `context/`:
- `setup.md` - Setup procedures and notes
- `issues.md` - Known issues and solutions
- `improvements.md` - Future enhancement ideas

## Snippets

Reusable configurations and code snippets are stored in `snippets/`:
- `nix/` - Nix configurations
- `shell/` - Shell scripts and functions
- `configs/` - Configuration templates
