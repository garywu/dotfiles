---
title: Password Management CLI Tools
description: Comprehensive guide to command-line password management with KeePass integration
---

# Password Management CLI Tools 🔐

Comprehensive guide to command-line password management tools that integrate with KeePass databases and modern password workflows.

## 🎯 **Tool Overview**

### **KeePassXC-CLI** (Primary Recommendation)
Full-featured CLI for managing KeePass (.kdbx) databases with complete CRUD operations.

### **git-credential-keepassxc**
Git credential helper that integrates directly with KeePassXC for seamless Git authentication.

### **pass** (UNIX Password Manager)
Traditional Unix password manager with GPG encryption and git integration.

## 🔓 **KeePassXC-CLI: Complete KeePass Management**

### **Quick Start**
```bash
# Check if installed
keepassxc-cli --version

# Create a new database
keepassxc-cli db-create MyPasswords.kdbx

# List entries
keepassxc-cli ls MyPasswords.kdbx

# Add an entry with generated password
keepassxc-cli add --generate MyPasswords.kdbx github.com

# Show an entry (with password visible)
keepassxc-cli show -s MyPasswords.kdbx github.com

# Copy password to clipboard
keepassxc-cli clip MyPasswords.kdbx github.com
```

### **Database Operations**

#### **Create and Manage Databases**
```bash
# Create new database with password
keepassxc-cli db-create -p MyPasswords.kdbx

# Create database with key file (passwordless)
openssl rand -out my.key 256
keepassxc-cli db-create --set-key-file my.key MyPasswords.kdbx

# Database information
keepassxc-cli db-info MyPasswords.kdbx

# Interactive mode
keepassxc-cli open MyPasswords.kdbx
```

#### **Entry Management**
```bash
# Add entry with username and generated password
keepassxc-cli add MyPasswords.kdbx -u admin -g example.com

# Add entry with custom password
keepassxc-cli add MyPasswords.kdbx -u user -p "MyPassword123" example.com

# Add entry with URL and notes
keepassxc-cli add MyPasswords.kdbx -u admin -g --url "https://example.com" --notes "Work account" example.com

# Edit existing entry
keepassxc-cli edit MyPasswords.kdbx example.com

# Remove entry (moves to recycle bin)
keepassxc-cli rm MyPasswords.kdbx example.com

# Search entries
keepassxc-cli search MyPasswords.kdbx "github"
```

#### **Password Retrieval**
```bash
# Copy password to clipboard (auto-clears after 10s)
keepassxc-cli clip MyPasswords.kdbx github.com

# Copy username to clipboard
keepassxc-cli clip --attribute username MyPasswords.kdbx github.com

# Show all entry details
keepassxc-cli show MyPasswords.kdbx github.com

# Show password (visible in terminal)
keepassxc-cli show -s MyPasswords.kdbx github.com

# Get specific attribute
keepassxc-cli show --attributes url MyPasswords.kdbx github.com
```

#### **TOTP Support**
```bash
# Copy TOTP code to clipboard
keepassxc-cli clip --totp MyPasswords.kdbx github.com

# Show TOTP code
keepassxc-cli show --totp MyPasswords.kdbx github.com

# Set up TOTP for an entry (manual)
keepassxc-cli edit MyPasswords.kdbx github.com
# Add TOTP secret in the GUI or via additional attributes
```

### **Advanced Features**

#### **Group Management**
```bash
# List entries in specific group
keepassxc-cli ls MyPasswords.kdbx /Work

# Create new group
keepassxc-cli mkdir MyPasswords.kdbx /Personal

# Move entry to group
keepassxc-cli mv MyPasswords.kdbx github.com /Work

# Remove group
keepassxc-cli rmdir MyPasswords.kdbx /OldGroup
```

#### **Attachments**
```bash
# Import attachment to entry
keepassxc-cli attachment-import MyPasswords.kdbx github.com document.pdf

# Export attachment from entry
keepassxc-cli attachment-export MyPasswords.kdbx github.com document.pdf

# Remove attachment
keepassxc-cli attachment-rm MyPasswords.kdbx github.com document.pdf
```

#### **Database Maintenance**
```bash
# Analyze password security
keepassxc-cli analyze MyPasswords.kdbx

# Export database
keepassxc-cli export MyPasswords.kdbx -f csv > backup.csv

# Import from other formats
keepassxc-cli import MyPasswords.kdbx backup.xml

# Merge databases
keepassxc-cli merge MyPasswords.kdbx OtherPasswords.kdbx
```

## 🔗 **Git Integration with KeePassXC**

### **git-credential-keepassxc Setup**

#### **Initial Configuration**
```bash
# Configure git to use KeePassXC credential helper
git config --global credential.helper keepassxc

# For specific repositories only
git config credential.helper keepassxc

# Test the helper
git-credential-keepassxc
```

#### **Create Git Credentials in KeePassXC**
```bash
# Add GitHub credentials
keepassxc-cli add MyPasswords.kdbx -u yourusername -p "your_token" github.com

# Add GitLab credentials
keepassxc-cli add MyPasswords.kdbx -u yourusername -p "your_token" gitlab.com

# Add self-hosted Git
keepassxc-cli add MyPasswords.kdbx -u yourusername -p "password" git.company.com
```

#### **Automatic Git Authentication**
```bash
# Git operations will automatically use KeePassXC
git clone https://github.com/user/repo.git
git push origin main

# No need to enter credentials manually!
```

### **Advanced Git Integration**
```bash
# Configure for specific Git hosting
git config --global credential.https://github.com.helper keepassxc
git config --global credential.https://gitlab.com.helper keepassxc

# Use different KeePassXC databases for different contexts
git config credential.helper "keepassxc --database /path/to/work.kdbx"
```

## 🔐 **Password Generation**

### **Built-in Password Generator**
```bash
# Generate random password (default settings)
keepassxc-cli generate

# Custom length and character sets
keepassxc-cli generate -L 32 --lower --upper --numeric --special

# Exclude ambiguous characters
keepassxc-cli generate -L 16 --exclude-similar

# Generate multiple passwords
for i in {1..5}; do keepassxc-cli generate -L 20; done
```

### **Diceware Passphrases**
```bash
# Generate diceware passphrase (7 words default)
keepassxc-cli diceware

# Custom word count
keepassxc-cli diceware -W 5

# Custom word separator
keepassxc-cli diceware -W 4 --word-separator "_"

# Use custom wordlist
keepassxc-cli diceware -W 6 -w /path/to/wordlist.txt
```

## 🔧 **Automation & Scripting**

### **Passwordless Authentication**
```bash
# Create key file for automation
openssl rand -out ~/.config/keepass.key 256

# Create database with key file only
keepassxc-cli db-create --set-key-file ~/.config/keepass.key ~/.config/passwords.kdbx

# Use in scripts without password prompt
keepassxc-cli ls ~/.config/passwords.kdbx --key-file ~/.config/keepass.key --no-password
```

### **Shell Functions**
Add to your `~/.config/fish/config.fish`:

```fish
# Quick password retrieval
function kpass
    keepassxc-cli clip ~/.config/passwords.kdbx $argv[1] --key-file ~/.config/keepass.key --no-password
end

# Show password temporarily
function kshow
    keepassxc-cli show -s ~/.config/passwords.kdbx $argv[1] --key-file ~/.config/keepass.key --no-password
end

# Add new entry quickly
function kadd
    keepassxc-cli add ~/.config/passwords.kdbx -u $argv[2] -g $argv[1] --key-file ~/.config/keepass.key --no-password
end

# Search entries
function ksearch
    keepassxc-cli search ~/.config/passwords.kdbx $argv[1] --key-file ~/.config/keepass.key --no-password
end
```

### **Tmux Integration**
```bash
# Create tmux session with password access
tmux new-session -d -s passwords
tmux send-keys -t passwords "keepassxc-cli open ~/.config/passwords.kdbx" Enter

# Copy password in tmux pane
tmux send-keys -t passwords "clip github.com" Enter
```

## 🛡️ **Security Best Practices**

### **Database Security**
```bash
# Use strong master passwords
keepassxc-cli generate -L 32 --lower --upper --numeric --special

# Combine password + key file
keepassxc-cli db-create -p --set-key-file ~/.config/keepass.key secure.kdbx

# Regular backups
cp ~/.config/passwords.kdbx ~/.config/passwords.kdbx.backup.$(date +%Y%m%d)

# Test database integrity
keepassxc-cli db-info ~/.config/passwords.kdbx
```

### **Environment Security**
```bash
# Never store passwords in shell history
export HISTCONTROL=ignorespace
 keepassxc-cli add database.kdbx -p "secret" entry  # Note leading space

# Use environment variables for key files
export KEEPASS_KEY_FILE=~/.config/keepass.key
keepassxc-cli ls database.kdbx --key-file "$KEEPASS_KEY_FILE" --no-password

# Secure file permissions
chmod 600 ~/.config/keepass.key
chmod 600 ~/.config/passwords.kdbx
```

### **Network Security**
```bash
# For remote databases (if needed)
scp user@server:~/passwords.kdbx ~/.config/remote_passwords.kdbx
keepassxc-cli ls ~/.config/remote_passwords.kdbx

# Sync with cloud storage
cp ~/.config/passwords.kdbx ~/Dropbox/passwords.kdbx
# KeePass databases are encrypted, safe for cloud storage
```

## 🔄 **Migration & Interoperability**

### **From Other Password Managers**
```bash
# Import from CSV (exported from other managers)
keepassxc-cli import database.kdbx exported_passwords.csv

# Import from 1Password
keepassxc-cli import database.kdbx 1password_export.1pux

# Import from Bitwarden
keepassxc-cli import database.kdbx bitwarden_export.json
```

### **Integration with `pass`**
```bash
# Convert pass entries to KeePassXC
pass ls | while read entry; do
    password=$(pass show "$entry")
    keepassxc-cli add database.kdbx -u "$(whoami)" -p "$password" "$entry"
done

# Parallel usage (gradual migration)
# Use pass for system/server passwords
# Use KeePassXC for web/application passwords
```

## 📊 **Workflow Examples**

### **Daily Development Workflow**
```bash
#!/bin/bash
# Morning development setup

# Get GitHub token for the day
kpass github.com

# Start coding session with database ready
tmux new-session -d -s dev
tmux send-keys -t dev "keepassxc-cli open ~/.config/passwords.kdbx" Enter

# Quick credential lookup during development
alias ghtoken="kshow github.com | grep Password"
alias awskey="kshow aws.com | grep Password"
```

### **Server Administration**
```bash
# Server access script
#!/bin/bash
SERVER=$1

# Get server credentials
USER=$(keepassxc-cli show "$HOME/.config/servers.kdbx" "$SERVER" --attributes username --key-file "$HOME/.config/server.key" --no-password)
PASS=$(keepassxc-cli show "$HOME/.config/servers.kdbx" "$SERVER" --attributes password --key-file "$HOME/.config/server.key" --no-password)

# SSH with credentials
sshpass -p "$PASS" ssh "$USER@$SERVER"
```

### **Backup & Sync Strategy**
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="$HOME/.config/keepass_backups"

mkdir -p "$BACKUP_DIR"

# Backup main database
cp "$HOME/.config/passwords.kdbx" "$BACKUP_DIR/passwords_$DATE.kdbx"

# Sync to cloud storage
rsync -av "$BACKUP_DIR/" "$HOME/Dropbox/keepass_backups/"

# Keep only last 30 days
find "$BACKUP_DIR" -name "*.kdbx" -mtime +30 -delete
```

## 🔍 **Troubleshooting**

### **Common Issues**
```bash
# Database locked/corrupted
keepassxc-cli db-info database.kdbx  # Check integrity

# Permission issues
chmod 600 ~/.config/passwords.kdbx
chmod 600 ~/.config/keepass.key

# Clipboard not working
# On Linux: install xclip or xsel
sudo apt install xclip

# On macOS: should work out of the box
pbpaste  # Test clipboard

# Git credential helper not working
git config --list | grep credential
git-credential-keepassxc  # Test directly
```

### **Performance Optimization**
```bash
# For large databases, use specific group queries
keepassxc-cli ls database.kdbx /Work  # Instead of full database

# Cache open database in tmux session
tmux has-session -t keepass 2>/dev/null || tmux new-session -d -s keepass "keepassxc-cli open database.kdbx"

# Use key files for automation to avoid password prompts
keepassxc-cli ls database.kdbx --key-file ~/.config/keepass.key --no-password
```

## 🔗 **Integration with Other Tools**

### **With Ollama/AI Tools**
```bash
# Use AI credentials securely
OPENAI_API_KEY=$(keepassxc-cli show passwords.kdbx openai.com --attributes password --key-file ~/.config/keepass.key --no-password)
export OPENAI_API_KEY

# AI model access
ollama run llama3.2:8b "Using credentials from KeePassXC..."
```

### **With Development Tools**
```bash
# Docker registry authentication
DOCKER_PASSWORD=$(keepassxc-cli show passwords.kdbx docker.com --attributes password --key-file ~/.config/keepass.key --no-password)
echo "$DOCKER_PASSWORD" | docker login -u myusername --password-stdin

# API testing with HTTPie
API_TOKEN=$(keepassxc-cli show passwords.kdbx api-service.com --attributes password --key-file ~/.config/keepass.key --no-password)
http GET api.example.com/data Authorization:"Bearer $API_TOKEN"
```

---

**💡 Pro Tip**: Start with `keepassxc-cli` for full KeePass compatibility, then add `git-credential-keepassxc` for seamless Git integration. The combination provides a complete CLI password management solution!