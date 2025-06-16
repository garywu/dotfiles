# Node.js version management
function setup_node() {
    local version=$1
    if [ -z "$version" ]; then
        version="lts/*"  # Default to latest LTS
    fi

    # Install the specified version if not already installed
    if ! nvm ls "$version" >/dev/null 2>&1; then
        nvm install "$version"
    fi

    # Use the specified version
    nvm use "$version"

    # Install global packages
    npm install -g npm@latest
    npm install -g yarn
    npm install -g pnpm
}

# Python version management
function setup_python() {
    local version=$1
    if [ -z "$version" ]; then
        version="3.11"  # Default to Python 3.11
    fi

    # Install the specified version if not already installed
    if ! pyenv versions | grep -q "$version"; then
        pyenv install "$version"
    fi

    # Set global Python version
    pyenv global "$version"

    # Upgrade pip
    pip install --upgrade pip

    # Install common Python packages
    pip install virtualenv
    pip install pipenv
    pip install poetry
}

# Create virtual environment
function create_venv() {
    local name=$1
    local python_version=$2

    if [ -z "$name" ]; then
        echo "Usage: create_venv <name> [python_version]"
        return 1
    fi

    if [ -z "$python_version" ]; then
        python_version=$(pyenv global)
    fi

    # Create virtual environment
    pyenv virtualenv "$python_version" "$name"

    # Activate virtual environment
    pyenv activate "$name"
}

# Node.js project setup
function setup_node_project() {
    local node_version=$1

    if [ -z "$node_version" ]; then
        node_version="lts/*"
    fi

    # Setup Node.js version
    setup_node "$node_version"

    # Initialize project if package.json doesn't exist
    if [ ! -f "package.json" ]; then
        npm init -y
    fi
}

# Python project setup
function setup_python_project() {
    local python_version=$1
    local venv_name=$2

    if [ -z "$python_version" ]; then
        python_version="3.11"
    fi

    if [ -z "$venv_name" ]; then
        venv_name="venv"
    fi

    # Setup Python version
    setup_python "$python_version"

    # Create virtual environment
    create_venv "$venv_name" "$python_version"

    # Initialize project if requirements.txt doesn't exist
    if [ ! -f "requirements.txt" ]; then
        touch requirements.txt
    fi
}

# Load versions from chezmoi configuration
if [ -f "${HOME}/.config/chezmoi/chezmoi.toml" ]; then
    NODE_VERSION=$(grep "node_version" "${HOME}/.config/chezmoi/chezmoi.toml" | cut -d'"' -f2)
    PYTHON_VERSION=$(grep "python_version" "${HOME}/.config/chezmoi/chezmoi.toml" | cut -d'"' -f2)

    # Setup default versions
    setup_node "$NODE_VERSION"
    setup_python "$PYTHON_VERSION"
fi
