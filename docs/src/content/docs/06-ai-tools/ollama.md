---
title: Ollama - Local LLM Management
description: Run powerful language models locally with Ollama for privacy and speed
---

# Ollama: Local LLM Management 🤖

Ollama provides easy local LLM hosting optimized for Apple Silicon. With your **M4 24GB RAM**, you can run powerful models locally for privacy and speed.

## 🚀 **Quick Start**

```bash
# Check Ollama status
ollama --version

# List available models
ollama list

# Start Ollama service (if not running)
ollama serve

# Pull and run a model
ollama run llama3.2:3b
```

## 🎯 **Recommended Models for M4 24GB**

### **Best Models for Your Setup:**

#### **🏆 Primary Coding Models (7B-8B)**
```bash
# Qwen2.5-Coder (BEST for coding)
ollama pull qwen2.5-coder:7b-instruct    # 4.7GB - Excellent code generation

# DeepSeek Coder V2 (Great for debugging)
ollama pull deepseek-coder-v2:16b        # 9.4GB - Advanced code understanding

# Code Llama (Meta's coding model)
ollama pull codellama:7b-instruct        # 3.8GB - Solid general coding
```

#### **🧠 General Purpose Models (3B-13B)**
```bash
# Llama 3.2 (Latest Meta model)
ollama pull llama3.2:3b                  # 2.0GB - Fast, efficient
ollama pull llama3.2:8b                  # 4.7GB - Better reasoning

# Qwen2.5 (Alibaba's latest)
ollama pull qwen2.5:7b                   # 4.7GB - Excellent instruction following
ollama pull qwen2.5:14b                  # 8.2GB - Advanced reasoning

# Mistral (European model)
ollama pull mistral:7b                   # 4.1GB - Good balance
ollama pull mistral-nemo:12b             # 7.1GB - Recent improvements
```

#### **⚡ Lightweight Models (1B-3B)**
```bash
# For quick queries and low memory usage
ollama pull llama3.2:1b                  # 1.3GB - Ultra fast
ollama pull qwen2.5:3b                   # 1.9GB - Good performance/size ratio
ollama pull phi3:3.8b                    # 2.3GB - Microsoft's efficient model
```

## 💻 **Development Workflows**

### **1. Code Generation & Review**
```bash
# Generate a function
ollama run qwen2.5-coder:7b-instruct "Write a Python function to parse JSON with error handling"

# Code review
ollama run qwen2.5-coder:7b-instruct "Review this code and suggest improvements: [paste code]"

# Explain complex code
ollama run qwen2.5-coder:7b-instruct "Explain what this TypeScript code does: [paste code]"
```

### **2. API Integration with curl**
```bash
# Using Ollama's REST API
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b-instruct",
  "prompt": "Write a Python REST API endpoint for user authentication",
  "stream": false
}'
```

### **3. Model Management**
```bash
# Pull multiple models efficiently
ollama pull qwen2.5-coder:7b-instruct &
ollama pull llama3.2:8b &
wait

# Check model info
ollama show qwen2.5-coder:7b-instruct

# Remove unused models
ollama rm old-model-name

# Update models
ollama pull qwen2.5-coder:7b-instruct  # Re-pull for updates
```

## ⚙️ **Performance Optimization**

### **Memory Management for 24GB**
```bash
# Set concurrent model limit (recommended: 2-3 models max)
export OLLAMA_MAX_LOADED_MODELS=2

# Set memory per model (adjust based on usage)
export OLLAMA_MAX_VRAM=8GB
```

### **Model Selection Strategy**
- **Quick queries**: Use 3B models (llama3.2:3b, qwen2.5:3b)
- **Coding tasks**: Use 7B coding models (qwen2.5-coder:7b)
- **Complex reasoning**: Use 8B-14B models (qwen2.5:14b)
- **Multiple tasks**: Keep 1 small + 1 large model loaded

### **Storage Management (500GB)**
```bash
# Check model storage usage
du -sh ~/.ollama/models

# Remove unused models regularly
ollama list | grep -v "NAME\|qwen2.5-coder\|llama3.2" | awk '{print $1}' | xargs -I {} ollama rm {}
```

## 🔧 **Configuration & Customization**

### **Modelfile Creation**
```bash
# Create custom model with system prompt
cat > Modelfile << EOF
FROM qwen2.5-coder:7b-instruct

TEMPLATE """{{ if .System }}<|im_start|>system
{{ .System }}<|im_end|>
{{ end }}{{ if .Prompt }}<|im_start|>user
{{ .Prompt }}<|im_end|>
{{ end }}<|im_start|>assistant
"""

PARAMETER temperature 0.1
PARAMETER top_p 0.9
PARAMETER stop "<|im_end|>"

SYSTEM """You are a senior software engineer who writes clean, efficient code with comprehensive documentation. Always explain your reasoning and provide usage examples."""
EOF

# Create the custom model
ollama create my-coding-assistant -f Modelfile
```

### **Environment Configuration**
```bash
# Add to ~/.config/fish/config.fish
echo 'export OLLAMA_HOST=127.0.0.1:11434' >> ~/.config/fish/config.fish
echo 'export OLLAMA_MODELS=~/.ollama/models' >> ~/.config/fish/config.fish
```

## 🚀 **Advanced Workflows**

### **Integration with Development Tools**
```bash
# Use with git hooks for commit message generation
git log --oneline -5 | ollama run qwen2.5:7b "Generate a conventional commit message for these changes:"

# Code documentation generation
find . -name "*.py" -exec cat {} \; | ollama run qwen2.5-coder:7b "Generate documentation for this Python module:"
```

### **Multi-Model Setup**
```bash
# Terminal 1: Coding assistant
ollama run qwen2.5-coder:7b-instruct

# Terminal 2: General purpose
ollama run llama3.2:8b

# Terminal 3: Quick queries
ollama run llama3.2:3b
```

## 📊 **Model Comparison**

| Model | Size | RAM Usage | Speed | Best For |
|-------|------|-----------|-------|----------|
| llama3.2:1b | 1.3GB | ~2GB | ⚡⚡⚡⚡ | Quick questions |
| llama3.2:3b | 2.0GB | ~3GB | ⚡⚡⚡ | General chat |
| qwen2.5-coder:7b | 4.7GB | ~6GB | ⚡⚡ | Coding tasks |
| llama3.2:8b | 4.7GB | ~6GB | ⚡⚡ | Reasoning |
| qwen2.5:14b | 8.2GB | ~10GB | ⚡ | Complex tasks |

## 🛠 **Troubleshooting**

### **Common Issues**
```bash
# Service not running
ollama serve

# Model not found
ollama pull model-name

# Out of memory
ollama ps  # Check running models
ollama stop model-name  # Stop unused models

# Check logs
tail -f ~/.ollama/logs/server.log
```

### **Performance Issues**
```bash
# Check system resources
btop  # Monitor CPU/RAM usage

# Restart Ollama service
pkill ollama
ollama serve
```

## 🔗 **Integration Examples**

See also:
- [ChatBlade Integration](/06-ai-tools/chatblade/) - Use Ollama with ChatBlade
- [OpenHands Setup](/06-ai-tools/openhands/) - AI coding assistant
- [Development Workflow](/07-development-workflow/) - Complete AI coding setup

---

**💡 Pro Tip**: Start with `qwen2.5-coder:7b-instruct` and `llama3.2:8b` - they provide the best balance of performance and capability for your 24GB setup.
