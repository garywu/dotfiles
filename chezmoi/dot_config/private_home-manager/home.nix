{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "admin";
  home.homeDirectory = "/Users/admin";

  # This value determines the Home Manager release that your configuration is compatible with.
  home.stateVersion = "24.05";

  # Define packages to be installed
  home.packages = with pkgs; [
    # Development tools
    git
    python311
    nodejs_20
    bun
    go
    rustc
    cargo

    # Version managers
    # nvm           # Not available in nixpkgs, use installer instead
    # pyenv         # Commenting out for now, needs testing
    # rbenv         # Commenting out for now, needs testing  
    # asdf-vm       # Commenting out for now, needs testing

    # Cloud tools
    awscli2
    google-cloud-sdk

    # Shell tools
    fish
    starship
    bash         # Modern Bash (macOS ships with 3.2 from 2007)
    eza          # Modern ls replacement (was exa)
    bat
    fd
    ripgrep
    tldr

    # Developer CLI Tools
    gh          # GitHub CLI
    hub         # GitHub command-line tool
    glab        # GitLab CLI
    jq          # JSON processor
    yq          # YAML processor
    htop        # Process viewer
    ncdu        # Disk usage analyzer
    tmux        # Terminal multiplexer
    neovim      # Modern vim
    fzf         # Fuzzy finder
    zoxide      # Smarter cd
    direnv      # Directory-specific environment variables
    mkcert      # Local HTTPS development
    httpie      # User-friendly HTTP client
    wget        # Network downloader
    curl        # Network transfer
    tree        # Directory tree

    # AI/ML Tools
    ollama          # Local LLM inference server (CLI)
    chatblade       # CLI Swiss Army Knife for ChatGPT
    chatgpt-cli     # Interactive CLI for ChatGPT
    # claude-code     # Agentic coding tool for terminal (unfree license)
    # python312Packages.huggingface-hub # Hugging Face model hub CLI (python package)
    litellm         # Use any LLM as drop-in replacement for GPT-3.5-turbo

    # Advanced CLI tools
    chezmoi     # Dotfiles management
    mosh        # Robust remote shell
    # thefuck   # Removed due to Python 3.12+ incompatibility
    delta       # Syntax-highlighting pager for git/diff
    lazygit     # TUI for git
    btop        # Resource monitor (modern htop alternative)
    glow        # Markdown previewer in terminal
    vifm        # Terminal file manager with preview support

    # Environment Variables & Secrets Management
    sops        # Secrets management with encryption
    age         # Simple, modern encryption tool
    pass        # UNIX password manager
    gnupg       # GNU Privacy Guard for encryption
    envsubst    # Environment variable substitution
    dotenv-cli  # Load .env files from command line
  ];

  # Configure basic programs
  programs = {
    # Configure git
    git = {
      enable = true;
      userName = "Your Name";
      userEmail = "your.email@example.com";
      aliases = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    # Configure fish shell
    fish = {
      enable = true;
      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        cat = "bat";
        find = "fd";
        grep = "rg";
      };
    };

    # Configure starship prompt
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[➜](green)";
          error_symbol = "[✗](red)";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "blue bold";
        };
      };
    };
  };
} 