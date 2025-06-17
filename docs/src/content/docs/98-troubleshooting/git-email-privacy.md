---
title: Git Email Privacy Protection
description: How to protect your email privacy in Git commits and public repositories
---

# Git Email Privacy Protection

## Why Email Privacy Matters

When you make Git commits, your email address is included in the commit metadata and becomes part of the permanent Git history. If you push to a public repository, this email becomes publicly visible and can be:
- Harvested by spammers
- Used for social engineering
- Exposed in data breaches

## GitHub's Privacy-Protecting Email

GitHub provides a no-reply email address that:
- ✅ Associates commits with your GitHub account
- ✅ Protects your real email from public exposure
- ✅ Works with all Git operations

### Format
```
username@users.noreply.github.com
```

## Configuration

### 1. Set Git Configuration
```bash
git config --global user.name "your-github-username"
git config --global user.email "username@users.noreply.github.com"
```

### 2. Update Chezmoi Configuration
Edit `chezmoi/chezmoi.toml`:
```toml
[data]
# Use GitHub's privacy-protecting email
name = "your-github-username"
email = "username@users.noreply.github.com"
```

### 3. Enable Email Privacy on GitHub
1. Go to GitHub Settings → Emails
2. Check "Keep my email addresses private"
3. Check "Block command line pushes that expose my email"

## Verification

Check your current Git configuration:
```bash
git config --global user.name
git config --global user.email
```

Test with a new commit:
```bash
git commit --allow-empty -m "Test privacy email"
git log -1 --pretty=format:"%an <%ae>"
```

## Best Practices

### ✅ DO:
- Always use the no-reply email for public repositories
- Enable GitHub's email privacy settings
- Document the privacy email in your setup instructions
- Use environment variables for sensitive data

### ❌ DON'T:
- Use your personal email in public repositories
- Commit `.env` files with real email addresses
- Include email addresses in documentation examples
- Share your personal email in issue comments

## Additional Privacy Tips

### 1. Repository-Specific Configuration
For work repositories, you can set different emails:
```bash
cd /path/to/work/repo
git config user.email "work-email@company.com"
```

### 2. GPG Signing with Privacy Email
You can still sign commits with GPG while using the privacy email:
```bash
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true
```

### 3. Check Existing Commits
To find commits with exposed emails:
```bash
git log --all --format="%ae" | sort | uniq
```

## Fixing Past Commits

If you've already made commits with your personal email, you have options:

### For Unpushed Commits
```bash
git commit --amend --author="username <username@users.noreply.github.com>"
```

### For Pushed Commits
Consider whether rewriting history is worth it, as it can cause issues for collaborators. If necessary, use tools like:
- `git filter-branch` (deprecated)
- `git filter-repo` (recommended)
- BFG Repo-Cleaner

## Automation

Add to your bootstrap script:
```bash
# Set privacy-protecting Git configuration
setup_git_privacy() {
    local github_username="${1:-$USER}"
    git config --global user.name "$github_username"
    git config --global user.email "${github_username}@users.noreply.github.com"
    echo "Git configured with privacy-protecting email"
}
```

---

**💡 Pro Tip**: Using GitHub's no-reply email is a simple way to maintain privacy without sacrificing functionality. It's especially important for dotfiles repositories that often contain personal configurations!
