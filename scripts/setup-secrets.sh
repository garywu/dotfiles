#!/bin/bash

# Secrets Management Setup Script
# Sets up SOPS with age encryption for secure secrets management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    local missing_tools=()

    if ! command -v age-keygen &> /dev/null; then
        missing_tools+=("age")
    fi

    if ! command -v sops &> /dev/null; then
        missing_tools+=("sops")
    fi

    if ! command -v yq &> /dev/null; then
        missing_tools+=("yq")
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install via: nix-env -iA nixpkgs.age nixpkgs.sops nixpkgs.yq"
        log_info "Or run: home-manager switch"
        exit 1
    fi
}

# Generate age key if it doesn't exist
setup_age_key() {
    local age_key_dir="$HOME/.config/sops/age"
    local age_key_file="$age_key_dir/keys.txt"

    if [[ -f "$age_key_file" ]]; then
        log_success "Age key already exists at $age_key_file"
        return 0
    fi

    log_info "Creating age key directory..."
    mkdir -p "$age_key_dir"

    log_info "Generating new age key..."
    age-keygen -o "$age_key_file"
    chmod 600 "$age_key_file"

    log_success "Age key generated at $age_key_file"
    log_warning "IMPORTANT: Back up this key file! You won't be able to decrypt secrets without it."

    # Display public key for sharing
    local public_key=$(grep "public key:" "$age_key_file" | cut -d: -f2 | tr -d ' ')
    log_info "Your public key (share with team): $public_key"
}

# Create SOPS configuration
create_sops_config() {
    local project_dir=${1:-$(pwd)}
    local sops_config="$project_dir/.sops.yaml"
    local age_key_file="$HOME/.config/sops/age/keys.txt"

    if [[ -f "$sops_config" ]]; then
        log_warning "SOPS configuration already exists at $sops_config"
        read -p "Overwrite? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi

    if [[ ! -f "$age_key_file" ]]; then
        log_error "Age key not found. Run setup_age_key first."
        return 1
    fi

    local public_key=$(grep "public key:" "$age_key_file" | cut -d: -f2 | tr -d ' ')

    log_info "Creating SOPS configuration..."

    cat > "$sops_config" << EOF
keys:
  - &user_key $public_key
creation_rules:
  - path_regex: \.secrets\.ya?ml$
    age: *user_key
  - path_regex: secrets/.*\.ya?ml$
    age: *user_key
  - path_regex: \.env\.secrets$
    age: *user_key
EOF

    log_success "SOPS configuration created at $sops_config"
}

# Create example secrets structure
create_secrets_structure() {
    local project_dir=${1:-$(pwd)}

    log_info "Creating secrets directory structure..."

    # Create secrets directory
    mkdir -p "$project_dir/secrets"

    # Create example .env.example file
    if [[ ! -f "$project_dir/.env.example" ]]; then
        cat > "$project_dir/.env.example" << EOF
# Environment Variables Template
# Copy to .env.local and fill in actual values

# Application Configuration
NODE_ENV=development
PORT=3000
DEBUG=true

# API Configuration
API_URL=http://localhost:3000
API_TIMEOUT=5000

# Database Configuration
DATABASE_URL=postgresql://localhost/myapp_development

# External Services (use secrets for actual values)
# API_KEY=your-api-key-here
# JWT_SECRET=your-jwt-secret-here
# STRIPE_SECRET_KEY=your-stripe-secret-here
EOF
        log_success "Created .env.example template"
    fi

    # Create example encrypted secrets file
    if [[ ! -f "$project_dir/secrets/dev.yaml" ]]; then
        # Create temporary unencrypted file
        cat > "/tmp/dev_secrets.yaml" << EOF
# Development Secrets
api:
  key: "dev-api-key-placeholder"
  secret: "dev-api-secret-placeholder"

database:
  password: "dev-db-password"

jwt:
  secret: "dev-jwt-secret-super-long-random-string"

external_services:
  stripe_secret_key: "sk_test_placeholder"
  sendgrid_api_key: "SG.placeholder"
EOF

        # Encrypt the file
        sops -e "/tmp/dev_secrets.yaml" > "$project_dir/secrets/dev.yaml"
        rm "/tmp/dev_secrets.yaml"

        log_success "Created encrypted development secrets at secrets/dev.yaml"
        log_info "Edit with: sops secrets/dev.yaml"
    fi

    # Create .envrc for direnv integration
    if [[ ! -f "$project_dir/.envrc" ]]; then
        cat > "$project_dir/.envrc" << 'EOF'
#!/bin/bash

# Load environment variables from .env.local if it exists
if [[ -f .env.local ]]; then
    dotenv .env.local
fi

# Load secrets from SOPS (development environment)
if [[ -f secrets/dev.yaml ]]; then
    # Check if we can decrypt (user has the key)
    if sops -d secrets/dev.yaml > /dev/null 2>&1; then
        # Load each secret as environment variable
        eval "$(sops -d secrets/dev.yaml | yq eval '.api | to_entries | .[] | "export API_" + (.key | upcase) + "=" + .value' -)"
        eval "$(sops -d secrets/dev.yaml | yq eval '.database | to_entries | .[] | "export DB_" + (.key | upcase) + "=" + .value' -)"
        eval "$(sops -d secrets/dev.yaml | yq eval '.jwt | to_entries | .[] | "export JWT_" + (.key | upcase) + "=" + .value' -)"

        echo "✅ Secrets loaded from secrets/dev.yaml"
    else
        echo "❌ Cannot decrypt secrets/dev.yaml - check your age key"
    fi
fi

# Project-specific environment variables
export NODE_ENV=development
export DEBUG=true
export PORT=3000
EOF
        log_success "Created .envrc with secrets integration"
        log_info "Run 'direnv allow' to enable automatic secret loading"
    fi

    # Update .gitignore
    local gitignore="$project_dir/.gitignore"
    if [[ -f "$gitignore" ]]; then
        # Check if secrets patterns are already there
        if ! grep -q "\.env\.local" "$gitignore"; then
            cat >> "$gitignore" << EOF

# Environment files
.env.local
.env.*.local

# Secrets (unencrypted)
secrets/*.key
secrets/unencrypted/
*.pem
*.p12

# SOPS key files
.sops/

# Don't ignore encrypted secrets
!secrets/*.yaml
!secrets/*.yml
EOF
            log_success "Updated .gitignore with secrets patterns"
        fi
    else
        log_warning ".gitignore not found - consider creating one"
    fi
}

# Create helper scripts
create_helper_scripts() {
    local project_dir=${1:-$(pwd)}
    local scripts_dir="$project_dir/scripts"

    mkdir -p "$scripts_dir"

    # Secret loading script
    cat > "$scripts_dir/load-secrets.sh" << 'EOF'
#!/bin/bash

# Load secrets from SOPS files
# Usage: source scripts/load-secrets.sh [environment]

ENVIRONMENT=${1:-dev}
SECRETS_FILE="secrets/${ENVIRONMENT}.yaml"

if [[ ! -f "$SECRETS_FILE" ]]; then
    echo "❌ Secrets file not found: $SECRETS_FILE"
    return 1
fi

if ! sops -d "$SECRETS_FILE" > /dev/null 2>&1; then
    echo "❌ Cannot decrypt $SECRETS_FILE - check your age key"
    return 1
fi

# Load secrets as environment variables
eval "$(sops -d "$SECRETS_FILE" | yq eval '.api | to_entries | .[] | "export API_" + (.key | upcase) + "=" + .value' -)"
eval "$(sops -d "$SECRETS_FILE" | yq eval '.database | to_entries | .[] | "export DB_" + (.key | upcase) + "=" + .value' -)"
eval "$(sops -d "$SECRETS_FILE" | yq eval '.jwt | to_entries | .[] | "export JWT_" + (.key | upcase) + "=" + .value' -)"

echo "✅ Secrets loaded from $SECRETS_FILE"
EOF

    chmod +x "$scripts_dir/load-secrets.sh"
    log_success "Created secrets loading script at scripts/load-secrets.sh"

    # Secret rotation script
    cat > "$scripts_dir/rotate-secrets.sh" << 'EOF'
#!/bin/bash

# Rotate secrets in SOPS files
# Usage: scripts/rotate-secrets.sh [environment] [secret-type]

ENVIRONMENT=${1:-dev}
SECRET_TYPE=${2:-api}
SECRETS_FILE="secrets/${ENVIRONMENT}.yaml"

if [[ ! -f "$SECRETS_FILE" ]]; then
    echo "❌ Secrets file not found: $SECRETS_FILE"
    exit 1
fi

echo "🔄 Rotating $SECRET_TYPE secrets in $ENVIRONMENT environment..."

case $SECRET_TYPE in
    "api")
        # Generate new API key (example)
        NEW_KEY="$(openssl rand -hex 32)"
        sops --set "[\"api\"][\"key\"] \"$NEW_KEY\"" "$SECRETS_FILE"
        echo "✅ API key rotated"
        ;;
    "jwt")
        # Generate new JWT secret
        NEW_SECRET="$(openssl rand -base64 64)"
        sops --set "[\"jwt\"][\"secret\"] \"$NEW_SECRET\"" "$SECRETS_FILE"
        echo "✅ JWT secret rotated"
        ;;
    *)
        echo "❌ Unknown secret type: $SECRET_TYPE"
        echo "Available types: api, jwt"
        exit 1
        ;;
esac

echo "🚀 Don't forget to restart your application!"
EOF

    chmod +x "$scripts_dir/rotate-secrets.sh"
    log_success "Created secrets rotation script at scripts/rotate-secrets.sh"
}

# Show usage examples
show_usage_examples() {
    echo ""
    log_success "=== Secrets Management Setup Complete! ==="
    echo ""
    log_info "📚 Quick Reference:"
    echo ""
    echo "🔧 Edit secrets:"
    echo "   sops secrets/dev.yaml"
    echo ""
    echo "👀 View secrets:"
    echo "   sops -d secrets/dev.yaml"
    echo ""
    echo "🔑 Extract specific secret:"
    echo "   sops -d --extract '[\"api\"][\"key\"]' secrets/dev.yaml"
    echo ""
    echo "📁 Load secrets in shell:"
    echo "   source scripts/load-secrets.sh dev"
    echo ""
    echo "🔄 Enable automatic loading:"
    echo "   direnv allow"
    echo ""
    echo "🔄 Rotate secrets:"
    echo "   scripts/rotate-secrets.sh dev api"
    echo ""
    log_info "📖 For detailed documentation, see: templates/secrets-management.md"
    echo ""
    log_warning "🔐 Remember to:"
    echo "  • Back up your age key (~/.config/sops/age/keys.txt)"
    echo "  • Share your public key with team members"
    echo "  • Never commit .env.local or unencrypted secrets"
    echo "  • Rotate secrets regularly"
}

# Main execution
main() {
    local project_dir=${1:-$(pwd)}

    echo "🔐 Secrets Management Setup"
    echo "==========================="
    echo ""
    log_info "Setting up secrets management for: $project_dir"
    echo ""

    # Check dependencies
    check_dependencies

    # Setup age key
    setup_age_key

    # Create SOPS configuration
    create_sops_config "$project_dir"

    # Create secrets structure
    create_secrets_structure "$project_dir"

    # Create helper scripts
    create_helper_scripts "$project_dir"

    # Show usage examples
    show_usage_examples
}

# Run main function
main "$@"
