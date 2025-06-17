---
title: ChatBlade - CLI ChatGPT Swiss Army Knife
description: Versatile command-line tool for seamless access to ChatGPT and AI models from your terminal
---

# ChatBlade: CLI ChatGPT Swiss Army Knife 🗡️

ChatBlade is a versatile command-line tool that provides seamless access to ChatGPT and other AI models directly from your terminal. Perfect for quick queries, code generation, and AI-assisted development workflows.

## 🚀 **Quick Start**

```bash
# Check installation
chatblade --version

# Set up API key (one-time setup)
export OPENAI_API_KEY="your-api-key-here"
# Or store in ~/.config/chatblade/config.yaml

# Basic usage
chatblade "Explain what this command does: ls -la"

# Interactive mode
chatblade -i

# Process file content
chatblade -f script.py "Add error handling to this code"
```

## ⚙️ **Configuration**

### **API Key Setup**
```bash
# Method 1: Environment variable
echo 'export OPENAI_API_KEY="sk-your-key-here"' >> ~/.config/fish/config.fish

# Method 2: Configuration file
mkdir -p ~/.config/chatblade
cat > ~/.config/chatblade/config.yaml << EOF
openai_api_key: sk-your-key-here
model: gpt-4o-mini  # Default model
temperature: 0.7
max_tokens: 2048
EOF

# Method 3: Use KeePassXC for secure storage
OPENAI_API_KEY=$(keepassxc-cli show passwords.kdbx openai.com --attributes password --key-file ~/.config/keepass.key --no-password)
export OPENAI_API_KEY
```

### **Configuration Options**
```yaml
# ~/.config/chatblade/config.yaml
openai_api_key: your-key-here
model: gpt-4o-mini           # Default model to use
temperature: 0.7             # Creativity level (0.0-2.0)
max_tokens: 2048            # Maximum response length
top_p: 1.0                  # Nucleus sampling
frequency_penalty: 0.0      # Avoid repetition
presence_penalty: 0.0       # Encourage new topics
timeout: 60                 # Request timeout in seconds
```

## 💻 **Core Features**

### **Basic Queries**
```bash
# Simple question
chatblade "What is the difference between TCP and UDP?"

# Code explanation
chatblade "Explain this Python code: def factorial(n): return 1 if n <= 1 else n * factorial(n-1)"

# Get shell command suggestions
chatblade "How to find files larger than 100MB in Linux?"

# Multi-line queries
chatblade "
Write a Python function that:
1. Takes a list of numbers
2. Filters out even numbers
3. Returns the sum of odd numbers
"
```

### **File Processing**
```bash
# Analyze a file
chatblade -f script.py "Review this code and suggest improvements"

# Multiple files
chatblade -f main.py -f utils.py "Explain how these files work together"

# Process specific file types
fd -e py | head -3 | xargs chatblade -f "Generate unit tests for these Python files"

# Code refactoring
chatblade -f legacy_code.js "Convert this JavaScript to modern ES6+ syntax"
```

### **Interactive Mode**
```bash
# Start interactive session
chatblade -i

# Interactive with context from file
chatblade -i -f config.yaml

# Interactive with custom system prompt
chatblade -i -s "You are a senior DevOps engineer. Help me with infrastructure questions."
```

### **System Prompts & Context**
```bash
# Custom system prompt
chatblade -s "You are a Python expert. Provide concise, production-ready code." "Write a REST API endpoint for user authentication"

# Role-based prompts
chatblade -s "You are a security auditor." -f app.py "Find potential security vulnerabilities"

# Context-aware queries
chatblade -c "We are building a microservices architecture with Docker and Kubernetes" "How should we handle service discovery?"
```

## 🛠️ **Development Workflows**

### **Code Generation**
```bash
# Generate functions
chatblade "Write a Python function to parse JSON with error handling"

# Generate with specifications
chatblade "
Create a TypeScript interface for:
- User with id (number), name (string), email (string)
- Include validation methods
- Add JSDoc comments
"

# Generate test cases
chatblade -f main.py "Generate Jest unit tests for all functions in this file"

# Generate documentation
chatblade -f api.py "Generate comprehensive documentation for this API"
```

### **Code Review & Analysis**
```bash
# Code review
chatblade -f pull_request.diff "Review this code change and suggest improvements"

# Performance analysis
chatblade -f slow_function.py "Analyze performance bottlenecks and suggest optimizations"

# Security audit
chatblade -f login.php "Identify security vulnerabilities in this code"

# Architecture review
chatblade -f *.py "Analyze the overall architecture and suggest improvements"
```

### **Debugging Assistant**
```bash
# Explain errors
chatblade "Explain this error: TypeError: 'NoneType' object is not subscriptable"

# Debug with logs
chatblade -f error.log "Analyze this error log and suggest debugging steps"

# Troubleshoot with code
chatblade -f broken_script.py "This script isn't working. What could be wrong?"

# Performance debugging
chatblade -f slow_query.sql "This SQL query is slow. How can I optimize it?"
```

## 🔄 **Advanced Usage**

### **Model Selection**
```bash
# Use different models
chatblade -m gpt-4o "Complex reasoning task requiring latest model"
chatblade -m gpt-4o-mini "Simple query for faster response"
chatblade -m gpt-3.5-turbo "Cost-effective option"

# Model-specific parameters
chatblade -m gpt-4o -t 0.1 "Generate precise, deterministic code"
chatblade -m gpt-4o -t 1.5 "Creative writing task"
```

### **Output Control**
```bash
# Control response length
chatblade --max-tokens 100 "Brief explanation of REST APIs"
chatblade --max-tokens 2000 "Detailed tutorial on Docker containers"

# Raw output (no formatting)
chatblade --raw "Generate a JSON object with user data"

# Save to file
chatblade "Generate a Python web scraper" > scraper.py

# Append to existing file
chatblade "Add error handling to this function" -f main.py >> enhanced_main.py
```

## 🔌 **Integration Examples**

### **Git Workflow Integration**
```bash
# Generate commit messages
git diff --cached | chatblade "Generate a conventional commit message for these changes"

# Code review automation
git diff main..feature-branch | chatblade "Review this code change for potential issues"

# Branch naming suggestions
chatblade "Suggest git branch names for: Adding user authentication system"
```

### **CI/CD Integration**
```bash
# Dockerfile optimization
chatblade -f Dockerfile "Optimize this Dockerfile for size and security"

# Config validation
chatblade -f docker-compose.yml "Validate this Docker Compose configuration"

# Deployment review
chatblade -f deployment.yaml "Review this Kubernetes deployment for best practices"
```

### **Database Operations**
```bash
# SQL generation
chatblade "Generate SQL query to find users who haven't logged in for 30 days"

# Schema design
chatblade "Design database schema for an e-commerce system with products, users, and orders"

# Query optimization
chatblade -f slow_query.sql "Optimize this SQL query for better performance"
```

## 🎯 **Productivity Workflows**

### **Daily Development Tasks**
```bash
# Morning standup preparation
chatblade -f recent_commits.txt "Summarize what I worked on yesterday based on these commits"

# Code cleanup
fd -e py | xargs chatblade -f "Identify code smell and suggest refactoring for these Python files"

# Quick references
alias explain="chatblade 'Explain this command:'"
alias howto="chatblade 'How do I'"
alias debug="chatblade 'Help debug this error:'"
```

### **Learning & Research**
```bash
# Technology comparison
chatblade "Compare React vs Vue.js for a new project, considering team size and requirements"

# Best practices
chatblade "What are the best practices for securing a Node.js application?"

# Architecture decisions
chatblade "Should I use microservices or monolith for a team of 5 developers building a SaaS product?"
```

## 📝 **Custom Functions & Aliases**

### **Fish Shell Functions**
Add to `~/.config/fish/config.fish`:

```fish
# Quick AI assistance
function ai
    chatblade $argv
end

# Explain command
function explain
    chatblade "Explain this command: $argv"
end

# Code review
function review
    chatblade -f $argv[1] "Review this code and suggest improvements"
end

# Generate tests
function gentests
    chatblade -f $argv[1] "Generate unit tests for this file"
end

# Interactive coding session
function aicode
    chatblade -i -s "You are a senior software engineer. Help with coding questions and provide production-ready solutions."
end
```

### **Integration with Ollama**
```bash
# Fallback to local AI when OpenAI is unavailable
function ai_query() {
    if chatblade --test-connection; then
        chatblade "$@"
    else
        echo "Using local Ollama..."
        echo "$@" | ollama run llama3.2:8b
    fi
}
```

## 🔧 **Troubleshooting**

### **Common Issues**
```bash
# API key issues
chatblade --test-connection
echo $OPENAI_API_KEY  # Check if set

# Rate limiting
chatblade --wait-on-rate-limit "Your query here"

# Large file handling
head -100 large_file.py | chatblade "Analyze first 100 lines of this code"

# Network timeouts
chatblade --timeout 120 "Complex query that needs more time"
```

### **Performance Optimization**
```bash
# Use faster model for simple queries
alias quickai='chatblade -m gpt-3.5-turbo'

# Reduce token usage
chatblade --max-tokens 500 "Brief answer to: $query"
```

---

**💡 Pro Tip**: Combine ChatBlade with KeePassXC for secure API key management and use it alongside Ollama for a complete AI development workflow - online for complex tasks, local for privacy-sensitive queries!
