{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "admin";
  home.homeDirectory = "/Users/admin";

  # Add npm and pipx bin directories to PATH
  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
  ];

  # This value determines the Home Manager release that your configuration is compatible with.
  home.stateVersion = "24.05";

  # Force rebuild
  home.extraOutputsToInstall = [ "info" "man" ];

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

    # Cloudflare tools
    cloudflared # Cloudflare Tunnel daemon and toolkit
    # wrangler        # Cloudflare Workers CLI (temporarily disabled - large download)
    flarectl # Cloudflare CLI for account management

    # Shell tools
    fish
    starship
    bash # Modern Bash (macOS ships with 3.2 from 2007)
    eza # Modern ls replacement (was exa)
    bat
    fd
    ripgrep
    tldr

    # Enhanced search and navigation
    silver-searcher # ag - fast code searching
    broot # New way to navigate directory trees
    lsd # Next gen ls command with icons
    procs # Modern ps replacement
    dust # More intuitive du
    duf # Better df alternative
    tokei # Count code statistics
    hyperfine # Command-line benchmarking tool
    watchexec # Execute commands on file changes
    sd # Intuitive find & replace (better than sed)

    # Developer CLI Tools
    gh # GitHub CLI
    hub # GitHub command-line tool
    glab # GitLab CLI
    jq # JSON processor
    yq # YAML processor
    htop # Process viewer
    ncdu # Disk usage analyzer
    tmux # Terminal multiplexer
    neovim # Modern vim
    fzf # Fuzzy finder
    zoxide # Smarter cd
    direnv # Directory-specific environment variables
    mkcert # Local HTTPS development
    httpie # User-friendly HTTP client
    wget # Network downloader
    curl # Network transfer
    tree # Directory tree

    # AI/ML Tools
    # ollama is installed via Homebrew on macOS (see bootstrap.sh)
    # Note: chatblade, chatgpt-cli, litellm not available in nixpkgs
    # Install manually with: pip install chatblade litellm chatgpt-cli
    # Or use pipx: pipx install chatblade && pipx install litellm

    # Advanced CLI tools
    chezmoi # Dotfiles management
    mosh # Robust remote shell
    # thefuck   # Removed due to Python 3.12+ incompatibility
    delta # Syntax-highlighting pager for git/diff
    lazygit # TUI for git
    btop # Resource monitor (modern htop alternative)
    glow # Markdown previewer in terminal
    vifm # Terminal file manager with preview support

    # Git enhancement tools
    tig # Text-mode interface for git
    gitui # Blazing fast terminal-ui for git

    # File content tools
    gron # Make JSON greppable
    jless # Command-line JSON viewer
    hexyl # Command-line hex viewer
    choose # Human-friendly alternative to cut/awk
    # xsv # Fast CSV command line toolkit (removed - use xan instead)

    # Environment Variables & Secrets Management
    sops # Secrets management with encryption
    age # Simple, modern encryption tool
    # pass        # UNIX password manager (commented out: broken dependency)
    # gnupg       # GNU Privacy Guard for encryption (commented out: broken dependency)
    envsubst # Environment variable substitution
    dotenv-cli # Load .env files from command line

    # KeePass-compatible tools
    # keepassxc   # KeePassXC GUI and CLI (keepassxc-cli) (temporarily disabled due to gpgme dependency issue)
    # git-credential-keepassxc  # Git credential helper for KeePassXC (temporarily disabled due to gpgme dependency issue)

    # Documentation tools
    # Note: Mintlify is not available in nixpkgs, using nodejs for npx access

    # Linting and Formatting Tools
    shellcheck # Shell script analysis tool
    shfmt # Shell script formatter
    nixpkgs-fmt # Nix code formatter
    # statix          # Nix static analysis tool (temporarily disabled due to gpgme dependency issue)
    yamllint # YAML linter
    nodePackages.markdownlint-cli # Markdown linter
    taplo # TOML formatter and linter
    # Note: fish_indent is included with fish package
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
      shellInit = ''
        # Load Nix environment if available
        if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
        end
        # Ensure all user-level bins are in PATH
        set -gx PATH $HOME/.nix-profile/bin $HOME/.npm-global/bin $HOME/.local/bin $PATH
        # Add Homebrew to PATH if available (Apple Silicon first, then Intel)
        if test -e /opt/homebrew/bin/brew
          eval (/opt/homebrew/bin/brew shellenv)
        else if test -e /usr/local/bin/brew
          eval (/usr/local/bin/brew shellenv)
        else if command -v brew >/dev/null 2>&1
          eval (brew shellenv)
        end
      '';
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
