---
title: CLI Tools
description: Modern command-line tools that replace traditional Unix utilities
---

import { LearningPath, ToolSelector } from '../../../components';

# CLI Tools

<LearningPath
  level="intermediate"
  time="2 hours"
  prerequisites={[
    "Basic command-line knowledge",
    "Completed Getting Started guide"
  ]}
  nextSteps={[
    "CLI Code Golf for efficiency",
    "Session patterns and workflows",
    "Advanced tool combinations"
  ]}
/>

Modern command-line tools that replace traditional Unix utilities with enhanced performance and features.

## File Navigation & Listing

- **eza** - Modern `ls` with colors and git integration
- **fd** - Simple, fast `find` alternative
- **zoxide** - Smart `cd` with frecency algorithm

## Text Search & Processing

- **ripgrep** - Ultra-fast `grep` replacement
- **bat** - `cat` with syntax highlighting
- **sd** - Intuitive find & replace (better than sed)

## System Monitoring

- **procs** - Modern `ps` replacement
- **dust** - More intuitive `du`
- **htop** - Interactive process viewer

## Git Tools

- **lazygit** - Terminal UI for git
- **delta** - Enhanced git diff viewer

## Data Processing

- **jq** - JSON processor and formatter
- **fx** - Interactive JSON viewer

## Getting Started

See the [Modern CLI Replacements](./modern-replacements/) page for detailed usage examples and comparisons with
traditional tools.

All tools are installed via Home Manager and configured with fish shell aliases for optimal productivity.

## Interactive Tool Finder

<ToolSelector
  title="Find the Right Tool for Your Task"
  tools={[
    {
      name: "eza",
      description: "Modern replacement for ls with git integration",
      command: "eza -la --git --icons",
      useCase: "File listing with visual enhancements",
      tags: ["files", "listing", "navigation"]
    },
    {
      name: "ripgrep",
      description: "Ultra-fast text search across files",
      command: "rg 'pattern' --type python",
      useCase: "Searching code repositories",
      tags: ["search", "text", "performance"]
    },
    {
      name: "fd",
      description: "Simple and fast alternative to find",
      command: "fd -e py -x pytest {}",
      useCase: "Finding files and executing commands",
      tags: ["files", "search", "automation"]
    },
    {
      name: "bat",
      description: "Cat with syntax highlighting and git integration",
      command: "bat README.md --style=numbers,changes",
      useCase: "Viewing code files with highlighting",
      tags: ["files", "viewing", "syntax"]
    },
    {
      name: "zoxide",
      description: "Smarter cd that learns your habits",
      command: "z projects",
      useCase: "Quick navigation to frequently used directories",
      tags: ["navigation", "productivity"]
    },
    {
      name: "sd",
      description: "Intuitive find and replace",
      command: "sd 'before' 'after' file.txt",
      useCase: "String substitution without regex complexity",
      tags: ["text", "editing", "automation"]
    },
    {
      name: "jq",
      description: "Command-line JSON processor",
      command: "curl api.example.com | jq '.data[]'",
      useCase: "Parsing and transforming JSON data",
      tags: ["data", "json", "api"]
    },
    {
      name: "hyperfine",
      description: "Command-line benchmarking tool",
      command: "hyperfine 'grep pattern file' 'rg pattern file'",
      useCase: "Comparing performance of commands",
      tags: ["performance", "benchmarking", "optimization"]
    }
  ]}
/>
