# Secrets and Environment Variables Management

Complete guide for securely managing environment variables and secrets in development.

## 🔧 Environment Variables Management

### 1. direnv (Project-Specific Variables)

**Best for**: Project-specific, non-sensitive environment variables

```bash
# Install (already in your Nix config)
# direnv is automatically available

# Setup in project directory
cd my-project
echo "export NODE_ENV=development" > .envrc
echo "export API_URL=http://localhost:3000" >> .envrc
echo "export DEBUG=true" >> .envrc

# Allow direnv to load the file
direnv allow

# Variables are automatically loaded when entering the directory
cd my-project  # Variables loaded
cd ..          # Variables unloaded
```

### 2. dotenv Files

**Best for**: Application configuration, development settings

```bash
# .env file structure
NODE_ENV=development
API_URL=http://localhost:3000
DATABASE_URL=postgresql://localhost/myapp
PORT=3000

# Load with dotenv-cli
dotenv -e .env.development -- npm start

# Or in application code (Node.js example)
require('dotenv').config()
```

### 3. Shell-Specific Methods

```bash
# Fish shell functions
function setenv
    set -gx $argv[1] $argv[2]
end

function unsetenv
    set -e $argv[1]
end

# Temporary environment variables
env API_KEY=secret npm start
```

## 🔐 Secrets Management

### 1. SOPS (Secrets OPerationS) - Recommended

**Best for**: Team collaboration, GitOps, encrypted secrets in repositories

```bash
# Initialize SOPS with age (modern encryption)
age-keygen -o ~/.config/sops/age/keys.txt

# Create .sops.yaml configuration
cat > .sops.yaml << EOF
keys:
  - &user_key age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
creation_rules:
  - path_regex: \.secrets\.ya?ml$
    age: *user_key
  - path_regex: secrets/.*\.ya?ml$
    age: *user_key
EOF

# Create encrypted secrets file
sops secrets.yaml

# Example secrets.yaml content (encrypted after saving):
api:
  key: sk-1234567890abcdef
  secret: abc123def456
database:
  password: supersecretpassword
```

**Usage with direnv**:
```bash
# .envrc
# Load encrypted secrets
eval "$(sops -d secrets.yaml | yq -r 'to_entries[] | "export \(.key | upcase)=\(.value)"')"

# Or specific values
export API_KEY="$(sops -d --extract '["api"]["key"]' secrets.yaml)"
```

### 2. pass (UNIX Password Manager)

**Best for**: Personal secrets, command-line workflows

```bash
# Initialize password store
pass init your-gpg-key-id

# Store secrets
pass insert api/github-token
pass insert database/postgres-password

# Retrieve secrets
export GITHUB_TOKEN=$(pass api/github-token)
export DB_PASSWORD=$(pass database/postgres-password)

# Use in scripts
#!/bin/bash
GITHUB_TOKEN=$(pass api/github-token)
curl -H "Authorization: token $GITHUB_TOKEN" ...
```

### 3. System Keychain Integration

**macOS Keychain**:
```bash
# Store secret
security add-generic-password -a "$USER" -s "github-token" -w "your-token-here"

# Retrieve secret
security find-generic-password -a "$USER" -s "github-token" -w
```

**Linux Secret Service**:
```bash
# Using secret-tool (GNOME Keyring)
secret-tool store --label="GitHub Token" service github username "$USER"
secret-tool lookup service github username "$USER"
```

## 🏗️ Project Structure Best Practices

### Directory Layout
```
project/
├── .env.example          # Template with dummy values
├── .env.local           # Local development (gitignored)
├── .envrc              # direnv configuration
├── secrets/
│   ├── .sops.yaml      # SOPS configuration
│   ├── dev.yaml        # Development secrets (encrypted)
│   └── prod.yaml       # Production secrets (encrypted)
├── scripts/
│   ├── load-secrets.sh # Script to load secrets
│   └── deploy.sh       # Deployment script
└── .gitignore          # Exclude sensitive files
```

### .gitignore Configuration
```gitignore
# Environment files
.env
.env.local
.env.*.local

# Secrets (unencrypted)
secrets/*.key
secrets/unencrypted/
*.pem
*.p12

# Don't ignore encrypted secrets
!secrets/*.yaml
!secrets/*.yml

# But ignore SOPS key files
.sops/
```

## 🔄 Workflow Examples

### Development Workflow
```bash
# 1. Clone repository
git clone repo-url && cd repo

# 2. Copy environment template
cp .env.example .env.local

# 3. Load secrets (if team member)
sops -d secrets/dev.yaml > /tmp/secrets.env
source /tmp/secrets.env && rm /tmp/secrets.env

# 4. Start development
direnv allow
npm start
```

### Team Onboarding Script
```bash
#!/bin/bash
# scripts/setup-secrets.sh

echo "🔐 Setting up secrets for development..."

# Check if user has SOPS key
if [[ ! -f ~/.config/sops/age/keys.txt ]]; then
    echo "❌ SOPS key not found. Please add your age key to ~/.config/sops/age/keys.txt"
    echo "Ask a team member for the team's public key and generate your key with:"
    echo "age-keygen -o ~/.config/sops/age/keys.txt"
    exit 1
fi

# Decrypt and load development secrets
if [[ -f secrets/dev.yaml ]]; then
    echo "✅ Loading development secrets..."
    sops -d secrets/dev.yaml | while IFS='=' read -r key value; do
        echo "export $key='$value'" >> .env.local
    done
    echo "✅ Secrets loaded to .env.local"
else
    echo "❌ Development secrets file not found"
fi

echo "🚀 Ready for development!"
```

## 🛡️ Security Best Practices

### 1. Principle of Least Privilege
```bash
# Different secrets for different environments
secrets/
├── dev.yaml      # Development secrets (limited scope)
├── staging.yaml  # Staging secrets (production-like data)
└── prod.yaml     # Production secrets (full access)
```

### 2. Rotation Strategy
```bash
# Regular rotation script
#!/bin/bash
# scripts/rotate-secrets.sh

echo "🔄 Rotating API keys..."

# Generate new API key
NEW_KEY=$(generate-new-api-key)

# Update in SOPS
sops --set '["api"]["key"] "'$NEW_KEY'"' secrets/prod.yaml

# Deploy to production
kubectl apply -f k8s/secrets.yaml

echo "✅ Secrets rotated successfully"
```

### 3. Audit and Monitoring
```bash
# Log secret access
function load_secret() {
    local secret_name=$1
    echo "$(date): Loading secret $secret_name by $USER" >> ~/.secret_access.log
    sops -d --extract ".$secret_name" secrets.yaml
}

# Monitor for plain-text secrets in commits
git config --global core.hooksPath ~/.git-hooks
```

## 🔌 Integration Examples

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    environment:
      - NODE_ENV=${NODE_ENV}
      - API_KEY=${API_KEY}
    env_file:
      - .env.local
```

### Kubernetes
```yaml
# Using SOPS with kubectl
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  api-key: ENC[AES256_GCM,data:xxxxx,type:str]
  db-password: ENC[AES256_GCM,data:yyyyy,type:str]
```

### CI/CD Integration
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Install SOPS
      - name: Install SOPS
        run: |
          wget https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux
          chmod +x sops-v3.7.3.linux
          sudo mv sops-v3.7.3.linux /usr/local/bin/sops

      # Decrypt secrets
      - name: Decrypt secrets
        run: |
          echo "${{ secrets.SOPS_AGE_KEY }}" > /tmp/age.key
          export SOPS_AGE_KEY_FILE=/tmp/age.key
          sops -d secrets/prod.yaml > /tmp/secrets.env
          source /tmp/secrets.env
```

## 🔧 Useful Commands

### SOPS Commands
```bash
# Edit encrypted file
sops secrets.yaml

# Decrypt to stdout
sops -d secrets.yaml

# Extract specific value
sops -d --extract '["api"]["key"]' secrets.yaml

# Encrypt existing file
sops -e -i secrets.yaml

# Re-encrypt with new keys
sops updatekeys secrets.yaml
```

### Environment Variable Debugging
```bash
# List all environment variables
printenv | sort

# Find specific variables
printenv | grep -i api

# Check if variable is set
[[ -n "$API_KEY" ]] && echo "API_KEY is set" || echo "API_KEY is not set"

# Show variable with fallback
echo "API URL: ${API_URL:-http://localhost:3000}"
```

## 🚨 Common Mistakes to Avoid

1. **Committing .env files** - Always add to .gitignore
2. **Using production secrets in development** - Use separate secret sets
3. **Storing secrets in shell history** - Use `read -s` for input
4. **Plain-text secrets in scripts** - Always encrypt or reference
5. **Sharing secrets via chat/email** - Use secure secret sharing tools
6. **Not rotating secrets** - Implement regular rotation
7. **Overly broad secret access** - Use principle of least privilege

## 📚 Additional Resources

- [SOPS Documentation](https://github.com/mozilla/sops)
- [direnv Documentation](https://direnv.net/)
- [12-Factor App Config](https://12factor.net/config)
- [OWASP Secrets Management](https://owasp.org/www-community/vulnerabilities/Password_Plaintext_Storage)
