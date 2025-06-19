---
title: Security Policy
description: Security policies and vulnerability reporting procedures
---

# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of this project seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Create a Public Issue

Security vulnerabilities should not be reported through public GitHub issues.

### 2. Contact Methods

Please report vulnerabilities by:
- Creating a private security advisory on GitHub
- Sending an email to the repository owner (check GitHub profile)

### 3. Information to Include

When reporting a vulnerability, please include:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Suggested fix (if any)

### 4. Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 1 week
- **Resolution Target**: Within 2 weeks for critical issues

### 5. Disclosure Process

1. Security report received and acknowledged
2. Investigate and validate the issue
3. Develop and test fixes
4. Release patches
5. Public disclosure (coordinated with reporter)

## Security Best Practices for Users

When using these dotfiles:

1. **Review Scripts**: Always review scripts before executing
2. **Secrets Management**:
   - Never commit secrets to the repository
   - Use Chezmoi templates for sensitive data
   - Keep `.chezmoi.toml` private
3. **Dependencies**: Regularly update Nix packages
4. **Permissions**: Be cautious with file permissions
5. **Sources**: Only install from trusted sources

## Security Updates

Security updates will be released as patch versions and announced through:
- GitHub Releases
- Security Advisories
- Commit messages with `security:` prefix

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who help improve this project's security.
