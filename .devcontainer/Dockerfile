FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    build-essential \
    curl \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    wget \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz \
    && rm go1.21.0.linux-amd64.tar.gz

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Python packages
RUN pip3 install --no-cache-dir \
    black \
    flake8 \
    isort \
    mypy \
    pre-commit \
    pytest \
    pytest-cov \
    pytest-mock \
    pytest-xdist \
    sphinx \
    sphinx-rtd-theme \
    jupyter \
    notebook \
    ipywidgets

# Install Node.js packages
RUN npm install -g \
    typescript \
    ts-node \
    nodemon \
    prettier \
    eslint \
    jest \
    @types/jest \
    ts-jest

# Install Go tools
RUN go install \
    golang.org/x/tools/cmd/godoc@latest \
    github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
    github.com/cosmtrek/air@latest

# Install Rust tools
RUN cargo install \
    cargo-watch \
    cargo-expand \
    cargo-udeps \
    cargo-audit \
    mdbook

# Set up environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV PATH="/root/.cargo/bin:${PATH}"
ENV PATH="/root/go/bin:${PATH}"

# Set up workspace
WORKDIR /workspace

# Set up user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up shell
RUN chsh -s /bin/zsh $USERNAME

# Switch to non-root user
USER $USERNAME 