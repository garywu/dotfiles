---
title: Tmux Mastery - Terminal Multiplexing
description: Manage multiple terminal sessions, split windows, and maintain persistent development environments
---

# Tmux Mastery: Terminal Multiplexing 🖥️

Tmux allows you to manage multiple terminal sessions, split windows, and maintain persistent development environments. Perfect for development workflows and remote work.

## 🚀 **Quick Start**

```bash
# Install tmux (already included in your setup)
tmux --version

# Basic session management
tmux                        # Start new session
tmux new -s myproject       # Start named session
tmux attach -t myproject    # Attach to session
tmux list-sessions          # List all sessions
tmux kill-session -t myproject  # Kill session
```

## 🎯 **Essential Key Bindings**

**Prefix Key**: `Ctrl-b` (default) - Press this before any tmux command

### **Session Management**
```bash
Ctrl-b d        # Detach from session (session keeps running)
Ctrl-b s        # Choose session from list
Ctrl-b $        # Rename current session
Ctrl-b (        # Switch to previous session
Ctrl-b )        # Switch to next session
```

### **Window Management**
```bash
Ctrl-b c        # Create new window
Ctrl-b n        # Next window
Ctrl-b p        # Previous window
Ctrl-b 0-9      # Switch to window by number
Ctrl-b w        # Choose window from list
Ctrl-b ,        # Rename current window
Ctrl-b &        # Kill current window
```

### **Pane Management**
```bash
Ctrl-b %        # Split window vertically
Ctrl-b "        # Split window horizontally
Ctrl-b arrow    # Navigate between panes
Ctrl-b o        # Go to next pane
Ctrl-b x        # Kill current pane
Ctrl-b z        # Toggle pane zoom (fullscreen)
Ctrl-b {        # Move pane left
Ctrl-b }        # Move pane right
```

### **Pane Resizing**
```bash
Ctrl-b Ctrl-arrow   # Resize pane (hold Ctrl)
Ctrl-b Alt-arrow    # Resize pane in larger steps
```

## 💻 **Development Workflows**

### **1. Full-Stack Development Setup**
```bash
# Start project session
tmux new -s webapp

# Window 1: Frontend (default)
cd ~/projects/my-app/frontend
npm run dev

# Create backend window
Ctrl-b c
cd ~/projects/my-app/backend
python manage.py runserver

# Create database window
Ctrl-b c
cd ~/projects/my-app
docker-compose up postgres

# Create logs window
Ctrl-b c
tail -f ~/projects/my-app/logs/app.log

# Name the windows
Ctrl-b , # Rename to "frontend"
# Navigate and rename others: "backend", "database", "logs"
```

### **2. Git Workflow Setup**
```bash
# Start git session
tmux new -s git-workflow

# Main terminal
lazygit

# Split for commands
Ctrl-b %
# Terminal for git commands, testing, etc.

# Bottom pane for file viewing
Ctrl-b "
bat README.md
```

### **3. AI Development Setup**
```bash
# Start AI session
tmux new -s ai-dev

# Window 1: Ollama service
ollama serve

# Window 2: Model interaction
Ctrl-b c
ollama run qwen2.5-coder:7b-instruct

# Window 3: Development
Ctrl-b c
cd ~/projects/ai-project
nvim main.py

# Window 4: Testing
Ctrl-b c
# Run tests, execute scripts
```

### **4. Remote Development Session**
```bash
# Connect to remote server
ssh user@server

# Start tmux on remote
tmux new -s remote-dev

# Setup development environment on remote
# Window 1: Code editor
nvim project.py

# Window 2: Application
Ctrl-b c
python app.py

# Window 3: Logs
Ctrl-b c
tail -f /var/log/app.log

# Detach and work locally
Ctrl-b d

# Reconnect later
ssh user@server
tmux attach -t remote-dev
```

## 🔧 **Configuration & Customization**

### **Basic tmux.conf**
Create `~/.tmux.conf`:

```bash
# Improve colors
set -g default-terminal "screen-256color"

# Change prefix key to Ctrl-a (optional)
# unbind C-b
# set -g prefix C-a
# bind C-a send-prefix

# Enable mouse support
set -g mouse on

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer
set -g history-limit 10000

# Faster key repetition
set -s escape-time 0

# Activity monitoring
setw -g monitor-activity on
set -g visual-activity on

# Easier pane splitting
bind | split-window -h
bind - split-window -v

# Vim-like pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Reload config file
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Status bar customization
set -g status-bg colour234
set -g status-fg colour137
set -g status-left '#[fg=colour233,bg=colour241,bold] #S '
set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
```

### **Advanced Configuration**
```bash
# Synchronize panes (type in all panes simultaneously)
bind y setw synchronize-panes

# Copy mode improvements (vi keys)
setw -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection

# Better session management
bind C-s choose-session
bind C-k kill-session

# Window navigation
bind -n M-h previous-window
bind -n M-l next-window

# Pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

## 🎨 **Status Bar & Themes**

### **Custom Status Bar**
```bash
# Add to ~/.tmux.conf

# Status bar position
set -g status-position bottom

# Status bar content
set -g status-left-length 20
set -g status-left '#[fg=green]#S #[fg=blue]#I:#P '

set -g status-right-length 50
set -g status-right '#[fg=yellow]#(whoami)@#h #[fg=white]%H:%M %d-%b-%y'

# Window status format
setw -g window-status-current-format '#[fg=white,bg=red] #I #W '
setw -g window-status-format '#[fg=cyan] #I #W '

# Colors
set -g status-bg black
set -g status-fg white
```

## 🚀 **Productivity Scripts**

### **Project Session Script**
Create `~/scripts/tmux-project.sh`:

```bash
#!/bin/bash
# Quick project session setup

PROJECT_NAME=$1
PROJECT_PATH=$2

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: tmux-project.sh <name> [path]"
    exit 1
fi

# Create session
tmux new-session -d -s "$PROJECT_NAME"

# Setup windows
tmux rename-window -t "$PROJECT_NAME:1" "code"
if [ -n "$PROJECT_PATH" ]; then
    tmux send-keys -t "$PROJECT_NAME:code" "cd $PROJECT_PATH && nvim ." Enter
fi

tmux new-window -t "$PROJECT_NAME" -n "terminal"
if [ -n "$PROJECT_PATH" ]; then
    tmux send-keys -t "$PROJECT_NAME:terminal" "cd $PROJECT_PATH" Enter
fi

tmux new-window -t "$PROJECT_NAME" -n "git"
tmux send-keys -t "$PROJECT_NAME:git" "lazygit" Enter

tmux new-window -t "$PROJECT_NAME" -n "server"

# Attach to session
tmux attach-session -t "$PROJECT_NAME"
```

### **Kill All Sessions Script**
Create `~/scripts/tmux-cleanup.sh`:

```bash
#!/bin/bash
# Kill all tmux sessions

tmux list-sessions | awk '{print $1}' | sed 's/://' | xargs -I {} tmux kill-session -t {}
echo "All tmux sessions killed"
```

## 📱 **Remote Development with Mosh**

### **Persistent Remote Sessions**
```bash
# Install mosh (already included)
mosh user@server

# On remote server, start tmux
tmux new -s dev

# Setup development environment
# ... your work ...

# Detach and disconnect
Ctrl-b d
exit

# Reconnect later (mosh automatically reconnects)
mosh user@server
tmux attach -t dev
```

## 🎯 **Best Practices**

### **Session Organization**
- **One session per project**: Keep projects isolated
- **Descriptive names**: Use meaningful session names
- **Consistent window layout**: Same windows for similar projects
- **Save session state**: Use tmux-resurrect plugin for persistence

### **Window Management**
- **Rename windows**: Give windows descriptive names
- **Logical grouping**: Group related tasks in windows
- **Kill unused windows**: Keep sessions clean

### **Pane Usage**
- **Split by task**: Editor in one pane, terminal in another
- **Monitor logs**: Keep logs visible in a pane
- **Quick reference**: Keep documentation in a pane

### **Workflow Optimization**
- **Use scripts**: Automate session setup
- **Learn key bindings**: Memorize common shortcuts
- **Customize config**: Tailor tmux to your workflow
- **Practice regularly**: Build muscle memory

## 🛠 **Common Use Cases**

### **1. Pair Programming**
```bash
# Create shared session
tmux new -s pair-programming

# Share session with colleague
# (requires shared user account or tmux socket sharing)

# Synchronize input across panes
Ctrl-b y  # (if configured)
```

### **2. Long-Running Tasks**
```bash
# Start session for long task
tmux new -s build

# Run build process
make build-all

# Detach and check later
Ctrl-b d

# Check progress later
tmux attach -t build
```

### **3. Multiple Environment Testing**
```bash
# Session for testing different environments
tmux new -s testing

# Window 1: Development environment
cd ~/project && npm run dev

# Window 2: Staging environment
Ctrl-b c
ssh staging-server
cd /app && npm start

# Window 3: Production monitoring
Ctrl-b c
ssh prod-server
tail -f /var/log/app.log
```

## 🔍 **Troubleshooting**

### **Common Issues**
```bash
# Session not found
tmux list-sessions  # Check existing sessions

# Terminal colors wrong
export TERM=screen-256color

# Config not loading
tmux source-file ~/.tmux.conf

# Kill hanging session
tmux kill-session -t session-name

# Reset tmux completely
pkill tmux
rm -rf ~/.tmux/
```

### **Performance Issues**
```bash
# Reduce history limit
set -g history-limit 2000

# Disable activity monitoring
setw -g monitor-activity off

# Check tmux process
ps aux | grep tmux
```

---

**💡 Pro Tip**: Start with basic session and window management, then gradually add pane splitting and customization. Create project-specific session templates for consistent workflows!