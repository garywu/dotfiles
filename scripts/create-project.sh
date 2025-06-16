#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if project name is provided
if [ -z "$1" ]; then
    print_error "Please provide a project name"
    echo "Usage: $0 <project-name> [project-type]"
    echo "Project types: python, node, ai, rust, go"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_TYPE=${2:-python}  # Default to python if not specified

# Function to create Python project
create_python_project() {
    print_status "Creating Python project: $PROJECT_NAME"

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Create virtual environment using uv (faster than venv)
    print_status "Creating virtual environment with uv..."
    uv venv

    # Create project structure
    mkdir -p src tests docs

    # Create requirements files
    cat > requirements.txt << 'EOL'
# Core dependencies
pytest==7.4.0
black==23.7.0
isort==5.12.0
flake8==6.1.0
mypy==1.5.1
pre-commit==3.3.3

# Development dependencies
ipython==8.14.0
jupyter==1.0.0
notebook==7.0.3
EOL

    cat > requirements-dev.txt << 'EOL'
-r requirements.txt
pytest-cov==4.1.0
pytest-mock==3.11.1
pytest-xdist==3.3.1
sphinx==7.1.2
sphinx-rtd-theme==1.3.0
EOL

    # Create .gitignore
    cat > .gitignore << 'EOL'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
.venv/
venv/
ENV/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Testing
.coverage
htmlcov/
.pytest_cache/

# Documentation
docs/_build/

# Jupyter
.ipynb_checkpoints
*.ipynb

# Environment variables
.env
.env.local
EOL

    # Create README
    cat > README.md << 'EOL'
# Project Name

Brief description of your project.

## Setup

1. Create virtual environment:
   ```bash
   uv venv
   source .venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   uv pip install -r requirements.txt
   ```

3. Install development dependencies:
   ```bash
   uv pip install -r requirements-dev.txt
   ```

## Development

- Run tests: `pytest`
- Format code: `black .`
- Sort imports: `isort .`
- Type checking: `mypy .`
- Lint code: `flake8`

## Documentation

Build documentation:
```bash
cd docs
make html
```
EOL

    # Create pre-commit config
    cat > .pre-commit-config.yaml << 'EOL'
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files

-   repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
    -   id: black

-   repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
    -   id: isort

-   repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
    -   id: flake8

-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.5.1
    hooks:
    -   id: mypy
        additional_dependencies: [types-all]
EOL

    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"

    print_status "Python project created successfully!"
}

# Function to create Node.js project
create_node_project() {
    print_status "Creating Node.js project: $PROJECT_NAME"

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Initialize npm project
    npm init -y

    # Create project structure
    mkdir -p src tests docs

    # Create package.json
    cat > package.json << 'EOL'
{
  "name": "project-name",
  "version": "1.0.0",
  "description": "",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "lint": "eslint .",
    "format": "prettier --write ."
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "@types/jest": "^29.5.3",
    "@types/node": "^20.4.5",
    "@typescript-eslint/eslint-plugin": "^6.2.0",
    "@typescript-eslint/parser": "^6.2.0",
    "eslint": "^8.45.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-prettier": "^5.0.0",
    "jest": "^29.6.2",
    "nodemon": "^3.0.1",
    "prettier": "^3.0.0",
    "ts-jest": "^29.1.1",
    "typescript": "^5.1.6"
  }
}
EOL

    # Create tsconfig.json
    cat > tsconfig.json << 'EOL'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
EOL

    # Create .gitignore
    cat > .gitignore << 'EOL'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build
dist/
build/

# Testing
coverage/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Environment
.env
.env.local

# OS
.DS_Store
Thumbs.db
EOL

    # Create README
    cat > README.md << 'EOL'
# Project Name

Brief description of your project.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Install development dependencies:
   ```bash
   npm install --save-dev
   ```

## Development

- Start development server: `npm run dev`
- Run tests: `npm test`
- Lint code: `npm run lint`
- Format code: `npm run format`

## Building

Build the project:
```bash
npm run build
```
EOL

    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"

    print_status "Node.js project created successfully!"
}

# Function to create AI project
create_ai_project() {
    print_status "Creating AI project: $PROJECT_NAME"

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Create virtual environment using uv
    print_status "Creating virtual environment with uv..."
    uv venv

    # Create project structure
    mkdir -p src tests docs data models notebooks

    # Create requirements files
    cat > requirements.txt << 'EOL'
# Core ML dependencies
torch==2.0.1
transformers==4.30.0
datasets==2.13.1
evaluate==0.4.0
accelerate==0.21.0
peft==0.4.0

# Development
pytest==7.4.0
black==23.7.0
isort==5.12.0
flake8==6.1.0
mypy==1.5.1
pre-commit==3.3.3

# Jupyter
jupyter==1.0.0
notebook==7.0.3
ipywidgets==8.1.0

# Monitoring
wandb==0.15.8
mlflow==2.7.1
EOL

    cat > requirements-dev.txt << 'EOL'
-r requirements.txt
pytest-cov==4.1.0
pytest-mock==3.11.1
pytest-xdist==3.3.1
sphinx==7.1.2
sphinx-rtd-theme==1.3.0
EOL

    # Create .gitignore
    cat > .gitignore << 'EOL'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
.venv/
venv/
ENV/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Testing
.coverage
htmlcov/
.pytest_cache/

# Documentation
docs/_build/

# Jupyter
.ipynb_checkpoints
*.ipynb

# Data
data/raw/
data/processed/
data/external/

# Models
models/*.pt
models/*.pth
models/*.h5
models/*.onnx
models/*.pb

# Logs
logs/
wandb/
mlruns/

# Environment variables
.env
.env.local
EOL

    # Create README
    cat > README.md << 'EOL'
# AI Project Name

Brief description of your AI project.

## Setup

1. Create virtual environment:
   ```bash
   uv venv
   source .venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   uv pip install -r requirements.txt
   ```

3. Install development dependencies:
   ```bash
   uv pip install -r requirements-dev.txt
   ```

## Development

- Run tests: `pytest`
- Format code: `black .`
- Sort imports: `isort .`
- Type checking: `mypy .`
- Lint code: `flake8`

## Training

1. Prepare your data in the `data/raw` directory
2. Run preprocessing: `python src/data/preprocess.py`
3. Train model: `python src/models/train.py`

## Evaluation

Run evaluation:
```bash
python src/models/evaluate.py
```

## Documentation

Build documentation:
```bash
cd docs
make html
```
EOL

    # Create pre-commit config
    cat > .pre-commit-config.yaml << 'EOL'
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files

-   repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
    -   id: black

-   repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
    -   id: isort

-   repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
    -   id: flake8

-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.5.1
    hooks:
    -   id: mypy
        additional_dependencies: [types-all]
EOL

    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"

    print_status "AI project created successfully!"
}

# Function to create Rust project
create_rust_project() {
    print_status "Creating Rust project: $PROJECT_NAME"

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Initialize cargo project
    cargo init --name "$PROJECT_NAME" --bin

    # Create project structure
    mkdir -p src tests docs examples benches

    # Create Cargo.toml with common dependencies
    cat > Cargo.toml << 'EOL'
[package]
name = "project-name"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A Rust project"
license = "MIT"

[dependencies]
# Core dependencies
tokio = { version = "1.28", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
clap = { version = "4.3", features = ["derive"] }
config = "0.13"
dotenv = "0.15"
env_logger = "0.10"

[dev-dependencies]
# Testing
mockall = "0.11"
proptest = "1.3"
criterion = "0.5"
pretty_assertions = "1.4"

[profile.release]
lto = true
codegen-units = 1
panic = "abort"
strip = true

[profile.dev]
opt-level = 0
debug = true

[profile.test]
opt-level = 0
debug = true
EOL

    # Create .gitignore
    cat > .gitignore << 'EOL'
# Generated by Cargo
/target/
**/*.rs.bk
Cargo.lock

# IDE
.idea/
.vscode/
*.swp
*.swo

# Environment
.env
.env.local

# OS
.DS_Store
Thumbs.db

# Documentation
docs/_build/
EOL

    # Create README
    cat > README.md << 'EOL'
# Project Name

Brief description of your Rust project.

## Setup

1. Install Rust:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. Install development tools:
   ```bash
   rustup component add rustfmt clippy
   cargo install cargo-watch cargo-expand cargo-udeps cargo-audit
   ```

## Development

- Build: `cargo build`
- Run: `cargo run`
- Test: `cargo test`
- Format: `cargo fmt`
- Lint: `cargo clippy`
- Watch: `cargo watch -x run`

## Documentation

Generate documentation:
```bash
# Generate and open docs
cargo doc --open

# Generate and serve docs with mdbook
cargo install mdbook
mdbook serve docs
```

## Benchmarks

Run benchmarks:
```bash
cargo bench
```

## Security

Check for vulnerabilities:
```bash
cargo audit
```
EOL

    # Create mdbook configuration
    mkdir -p docs/src
    cat > docs/book.toml << 'EOL'
[book]
title = "Project Documentation"
authors = ["Your Name"]
description = "Documentation for the project"
language = "en"
multilingual = false

[build]
build-dir = "../_build"
create-missing = false

[output.html]
site-url = "/"
default-theme = "light"
preferred-dark-theme = "navy"
git-repository-url = ""
git-repository-icon = "fa-github"
edit-url-template = ""
EOL

    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"

    print_status "Rust project created successfully!"
}

# Function to create Go project
create_go_project() {
    print_status "Creating Go project: $PROJECT_NAME"

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Initialize go module
    go mod init "$PROJECT_NAME"

    # Create project structure
    mkdir -p cmd/$PROJECT_NAME internal pkg api docs examples test

    # Create main.go
    cat > cmd/$PROJECT_NAME/main.go << 'EOL'
package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigChan
		cancel()
	}()

	// Your application logic here
	log.Println("Starting application...")

	<-ctx.Done()
	log.Println("Shutting down...")
}
EOL

    # Create go.mod with common dependencies
    cat > go.mod << 'EOL'
module project-name

go 1.21

require (
	github.com/spf13/cobra v1.7.0
	github.com/spf13/viper v1.16.0
	go.uber.org/zap v1.24.0
	google.golang.org/grpc v1.57.0
)
EOL

    # Create .gitignore
    cat > .gitignore << 'EOL'
# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out

# Output
bin/
dist/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Environment
.env
.env.local

# OS
.DS_Store
Thumbs.db

# Go specific
/vendor/
/go.sum

# Documentation
docs/_build/
EOL

    # Create README
    cat > README.md << 'EOL'
# Project Name

Brief description of your Go project.

## Setup

1. Install Go:
   ```bash
   # macOS
   brew install go
   ```

2. Install development tools:
   ```bash
   go install golang.org/x/tools/cmd/godoc@latest
   go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
   go install github.com/cosmtrek/air@latest
   ```

## Development

- Build: `go build ./...`
- Run: `go run cmd/project-name/main.go`
- Test: `go test ./...`
- Format: `go fmt ./...`
- Lint: `golangci-lint run`
- Watch: `air`

## Documentation

Generate documentation:
```bash
# Generate and serve docs
godoc -http=:6060

# Generate and serve docs with mkdocs
pip install mkdocs mkdocs-material
mkdocs serve
```

## Testing

Run tests with coverage:
```bash
go test -cover ./...
go test -bench=. ./...
```

## Security

Check for vulnerabilities:
```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```
EOL

    # Create mkdocs configuration
    cat > mkdocs.yml << 'EOL'
site_name: Project Documentation
site_description: Documentation for the project
site_author: Your Name
repo_url: https://github.com/yourusername/project-name
repo_name: project-name

theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - search.highlight
    - search.share
    - search.suggest

markdown_extensions:
  - pymdownx.highlight
  - pymdownx.superfences
  - pymdownx.inlinehilite
  - pymdownx.tabbed
  - pymdownx.emoji
  - pymdownx.tasklist
  - pymdownx.snippets
  - admonition
  - footnotes
  - toc:
      permalink: true

plugins:
  - search
  - mkdocstrings:
      default_handler: go
      handlers:
        go:
          selection:
            docstring_style: godoc
          rendering:
            show_source: true
            show_root_heading: true
EOL

    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"

    print_status "Go project created successfully!"
}

# Main function
main() {
    case $PROJECT_TYPE in
        "python")
            create_python_project
            ;;
        "node")
            create_node_project
            ;;
        "ai")
            create_ai_project
            ;;
        "rust")
            create_rust_project
            ;;
        "go")
            create_go_project
            ;;
        *)
            print_error "Unknown project type: $PROJECT_TYPE"
            echo "Available types: python, node, ai, rust, go"
            exit 1
            ;;
    esac
}

# Run the main function
main
