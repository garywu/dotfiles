---
title: AI Tools Integration
description: Integrate AI-powered tools into your development workflow for enhanced productivity
---

# AI Tools Integration 🤖

Transform your development workflow with AI-powered tools that provide code generation, analysis, and assistance directly in your terminal.

## Available AI Tools

### 🦙 **Ollama - Local LLM Management**
Run powerful language models locally on your Apple Silicon Mac for privacy and speed.

- **Best for**: Code generation, review, explanation
- **Privacy**: 100% local, no data leaves your machine
- **Performance**: Optimized for M1/M2/M3/M4 Macs
- **Models**: Coding-specific models like Qwen2.5-Coder, CodeLlama

[→ Learn Ollama](/06-ai-tools/ollama/)

### 💬 **ChatBlade - Terminal Chat Interface**
Command-line interface for various AI providers with streaming responses.

- **Best for**: Quick queries, scripting, automation
- **Providers**: OpenAI, Claude, local models via Ollama
- **Features**: Streaming, conversation history, scripting support

[→ Learn ChatBlade](/06-ai-tools/chatblade/)

### 🖥️ **OpenHands - AI Coding Assistant**
Full AI development environment that can browse files, run commands, and write code.

- **Best for**: Complex coding tasks, project understanding
- **Features**: File browsing, terminal access, multi-step tasks
- **Models**: Works with Claude, GPT-4, local models

[→ Learn OpenHands](/06-ai-tools/openhands/)

## Quick Start Guide

### 1. **Set up Local AI (Ollama)**
```bash
# Already installed via bootstrap
ollama pull qwen2.5-coder:7b-instruct  # Best coding model
ollama run qwen2.5-coder:7b-instruct "Write a Python function to validate email addresses"
```

### 2. **Install Terminal Chat (ChatBlade)**
```bash
# Install via pip
pip install chatblade

# Set up API key (optional, can use Ollama)
export OPENAI_API_KEY="your-key-here"

# Quick test
chatblade "Explain the difference between ls and eza"
```

### 3. **Set up AI Coding Environment (OpenHands)**
```bash
# Use the setup script
./scripts/setup-openhands.sh install

# Access at http://localhost:3030
# Configure with your preferred AI provider
```

## AI-Enhanced Workflows

### **Code Generation & Review**
```bash
# Generate code with Ollama
ollama run qwen2.5-coder:7b "Write a REST API endpoint for user authentication in Python FastAPI"

# Review code with ChatBlade
cat my_code.py | chatblade "Review this code and suggest improvements"

# Interactive coding with OpenHands
# Open http://localhost:3030 and describe your project
```

### **Documentation & Explanation**
```bash
# Explain complex code
rg "class.*:" --type py | head -5 | chatblade "Explain these Python class definitions"

# Generate documentation
ollama run qwen2.5-coder:7b "Generate docstrings for this Python module: $(cat utils.py)"

# README generation
find . -name "*.py" | head -10 | xargs cat | chatblade "Create a README.md for this Python project"
```

### **Debugging & Analysis**
```bash
# Analyze error logs
tail -50 error.log | chatblade "Analyze these error logs and suggest fixes"

# Code review automation
git diff HEAD~1 | ollama run qwen2.5-coder:7b "Review this git diff and suggest improvements"

# Performance analysis
tokei . | chatblade "Analyze this codebase statistics and suggest optimization areas"
```

## Integration with Development Tools

### **Git Workflow Enhancement**
```bash
# AI-powered commit messages
git diff --cached | chatblade "Generate a conventional commit message for these changes"

# Branch name suggestions
git status | chatblade "Suggest a good git branch name for these changes"

# Code review preparation
git diff main..HEAD | ollama run qwen2.5-coder:7b "Summarize changes in this PR"
```

### **Project Analysis**
```bash
# Architecture analysis
fd -e py | head -20 | xargs cat | chatblade "Analyze the architecture of this Python project"

# Dependency analysis
cat package.json | chatblade "Analyze these dependencies and suggest updates"

# Security review
rg -i "password|key|secret|token" --type py | chatblade "Review these lines for security issues"
```

## Best Practices

### **Model Selection Guide**
- **Quick queries**: Use ChatBlade with fast models
- **Code generation**: Use Ollama with coding-specific models
- **Complex tasks**: Use OpenHands with GPT-4 or Claude
- **Privacy-sensitive**: Always use local models via Ollama

### **Prompt Engineering Tips**
1. **Be specific**: "Write a Python function that validates email with regex" vs "write email function"
2. **Provide context**: Include relevant code, error messages, or requirements
3. **Specify format**: "Return only the code" or "explain step by step"
4. **Use examples**: Show input/output examples for better results

### **Security Considerations**
```bash
# Use local models for sensitive code
ollama run qwen2.5-coder:7b "Review this authentication code"

# Avoid sending secrets to external APIs
grep -v "password\|key\|secret" code.py | chatblade "Review this code"

# Use environment variables for API keys
export OPENAI_API_KEY="$(security find-generic-password -w -s openai-key)"
```

## Performance Optimization

### **Resource Management**
```bash
# Monitor AI tool resource usage
btop  # Check CPU/RAM usage during AI tasks

# Optimize Ollama models
ollama ps  # Check running models
ollama stop unused-model  # Free up memory
```

### **Response Speed Tips**
1. **Use smaller models** for simple tasks (llama3.2:3b)
2. **Keep models loaded** for frequent use
3. **Use streaming** with ChatBlade for immediate feedback
4. **Batch similar queries** to same model

## Troubleshooting

### **Common Issues**
```bash
# Ollama service not running
ollama serve

# ChatBlade API issues
chatblade --test

# OpenHands connection problems
./scripts/setup-openhands.sh status
./scripts/setup-openhands.sh logs
```

### **Performance Issues**
```bash
# Check available memory
htop

# Restart AI services
pkill ollama && ollama serve
./scripts/setup-openhands.sh restart
```

## What's Next?

1. **Start with Ollama** - Set up local AI for privacy and speed
2. **Add ChatBlade** - Get terminal-based AI assistance
3. **Try OpenHands** - Experience full AI development environment
4. **Integrate with workflows** - Add AI to your daily development tasks
5. **Customize prompts** - Develop effective prompting strategies

Ready to supercharge your development workflow with AI? [Get started with Ollama!](/06-ai-tools/ollama/)
