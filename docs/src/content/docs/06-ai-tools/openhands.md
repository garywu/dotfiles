---
title: OpenHands - AI Coding Assistant
description: Full AI development environment with file browsing, terminal access, and multi-step task execution
---

# OpenHands: AI Coding Assistant 🖥️

OpenHands provides a complete AI development environment that can browse files, run commands, and execute complex multi-step coding tasks.

## 🚀 **Quick Start**

OpenHands is available through our automated setup script:

```bash
# Install OpenHands
./scripts/setup-openhands.sh install

# Start the service
./scripts/setup-openhands.sh start

# Access the web interface
open http://localhost:3030
```

## 🎯 **What OpenHands Can Do**

### **File Operations**
- Browse and read project files
- Create and modify files
- Understand project structure
- Navigate complex codebases

### **Terminal Integration**
- Execute command-line tools
- Run scripts and tests
- Install dependencies
- Perform system operations

### **Development Tasks**
- Write complete features
- Debug complex issues
- Refactor existing code
- Generate documentation

### **Multi-Step Workflows**
- Plan and execute complex tasks
- Coordinate multiple files changes
- Run tests and validate changes
- Iterate based on feedback

## 💻 **Setup & Configuration**

### **Initial Setup**
```bash
# Complete installation with all dependencies
./scripts/setup-openhands.sh install

# The script will:
# 1. Pull required Docker images
# 2. Create configuration directories
# 3. Set up environment files
# 4. Start the service
```

### **Configuration**
```bash
# Edit configuration
./scripts/setup-openhands.sh config

# Configuration is stored in:
~/.config/openhands/config.env
```

Example configuration:
```bash
# OpenHands Configuration
OPENHANDS_VERSION=0.43
SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.43-nikolaik
LOG_ALL_EVENTS=true

# Add your API keys here
ANTHROPIC_API_KEY=your_claude_key_here
OPENAI_API_KEY=your_openai_key_here
```

### **Service Management**
```bash
# Start OpenHands
./scripts/setup-openhands.sh start

# Stop OpenHands
./scripts/setup-openhands.sh stop

# Restart service
./scripts/setup-openhands.sh restart

# Check status
./scripts/setup-openhands.sh status

# View logs
./scripts/setup-openhands.sh logs
```

## 🔧 **Available Commands**

The setup script provides comprehensive management:

```bash
./scripts/setup-openhands.sh <command>

Commands:
    install     - Install OpenHands
    start       - Start OpenHands
    stop        - Stop OpenHands
    restart     - Restart OpenHands
    status      - Show OpenHands status
    update      - Update to latest version
    logs        - Show OpenHands logs
    config      - Edit configuration
    service     - Create system service (auto-start)
    uninstall   - Remove OpenHands completely
    help        - Show help
```

## 🎨 **Web Interface Features**

### **Chat Interface**
- Natural language task descriptions
- Real-time conversation with AI
- File and code context awareness
- Multi-turn conversations

### **File Browser**
- Visual project navigation
- File editing capabilities
- Syntax highlighting
- Diff viewing for changes

### **Terminal Emulator**
- Full terminal access within the interface
- Command execution and output
- Integration with AI suggestions
- Real-time command feedback

### **Task Planning**
- Multi-step task breakdown
- Progress tracking
- Rollback capabilities
- Validation and testing

## 🚀 **Example Workflows**

### **Feature Development**
1. **Describe the feature**: "Add user authentication to this Flask app"
2. **OpenHands will**:
   - Analyze existing code structure
   - Plan the implementation
   - Create necessary files
   - Implement authentication logic
   - Add tests
   - Update documentation

### **Bug Fixing**
1. **Describe the issue**: "Users can't log in, getting 500 error"
2. **OpenHands will**:
   - Examine error logs
   - Trace the issue through code
   - Identify the root cause
   - Implement the fix
   - Test the solution

### **Code Refactoring**
1. **Request refactoring**: "Refactor this code to use async/await"
2. **OpenHands will**:
   - Analyze current implementation
   - Plan the async conversion
   - Update function signatures
   - Handle error cases
   - Update tests and documentation

### **Documentation Generation**
1. **Ask for docs**: "Generate API documentation for this project"
2. **OpenHands will**:
   - Scan all API endpoints
   - Generate comprehensive docs
   - Include examples and schemas
   - Create navigation structure

## ⚙️ **Integration with Your Environment**

### **Docker Integration**
OpenHands runs in a sandboxed Docker environment with access to:
- Your project files (mounted as volumes)
- Docker daemon (for container operations)
- Network access (for package installation)
- All your installed CLI tools

### **Tool Access**
OpenHands can use all the modern CLI tools from your environment:
```bash
# File operations with modern tools
eza -la --git          # Enhanced file listing
rg "pattern" --type py # Fast code search
fd -e js              # Quick file finding
bat config.py         # Syntax highlighted viewing
```

### **Git Integration**
```bash
# Git operations
git status
git add .
git commit -m "feat: add user authentication"
git push origin feature-branch
```

## 🔒 **Security & Privacy**

### **Sandboxed Environment**
- Runs in isolated Docker containers
- Limited access to host system
- Network restrictions configurable
- No direct host file system access

### **API Key Management**
```bash
# Store API keys securely
./scripts/setup-openhands.sh config

# Keys are stored in:
~/.config/openhands/config.env

# Not committed to git
echo "~/.config/openhands/" >> .gitignore
```

### **Data Privacy**
- Code is sent to AI providers (Claude, OpenAI)
- Use local models via Ollama for sensitive code
- Review generated code before committing
- Consider using on private/internal projects only

## 🛠 **Troubleshooting**

### **Common Issues**

#### **Service Won't Start**
```bash
# Check Docker status
docker info

# Check OpenHands logs
./scripts/setup-openhands.sh logs

# Restart the service
./scripts/setup-openhands.sh restart
```

#### **Can't Access Web Interface**
```bash
# Check if service is running
./scripts/setup-openhands.sh status

# Verify port is available
lsof -i :3030

# Try different port (edit config)
./scripts/setup-openhands.sh config
```

#### **API Key Issues**
```bash
# Verify API keys are set
./scripts/setup-openhands.sh config

# Test API connectivity
curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages
```

### **Performance Optimization**
```bash
# Monitor resource usage
docker stats openhands-app

# Check available disk space
df -h

# Clean up old containers
docker system prune
```

## 🔄 **Updates & Maintenance**

### **Updating OpenHands**
```bash
# Update to latest version
./scripts/setup-openhands.sh update

# The script will:
# 1. Stop current service
# 2. Pull latest images
# 3. Restart with new version
```

### **Backup & Restore**
```bash
# Configuration is in
~/.config/openhands/

# State is in
~/.openhands-state/

# Backup both directories before updates
```

## 🌟 **Best Practices**

### **Effective Prompting**
1. **Be specific about requirements**
2. **Provide context about existing code**
3. **Specify testing requirements**
4. **Mention any constraints or preferences**

### **Project Organization**
1. **Keep projects well-structured**
2. **Use clear file and folder names**
3. **Include README files with context**
4. **Maintain good git history**

### **Review Generated Code**
1. **Always review before committing**
2. **Test thoroughly**
3. **Understand the implementation**
4. **Check for security issues**

## 🔗 **Related Tools**

- [Ollama](../ollama/) - Local AI models for privacy
- [ChatBlade](../chatblade/) - Terminal AI chat

---

**💡 Pro Tip**: Start with simple tasks to get familiar with OpenHands, then gradually move to more complex multi-file features. Always review and understand the generated code!
