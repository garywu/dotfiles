{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "admin";
  home.homeDirectory = "/Users/admin";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";

  # Define packages to be installed
  home.packages = with pkgs; [
    # Development tools
    git
    python311
    nodejs_20
    go
    rustc
    cargo

    # Version managers
    nvm
    pyenv
    rbenv
    asdf-vm

    # Cloud tools
    awscli2
    google-cloud-sdk

    # Shell tools
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    exa
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
  ];

  # Configure programs
  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        ls = "exa";
        ll = "exa -l";
        la = "exa -la";
        cat = "bat";
        find = "fd";
        grep = "rg";
        cd = "zoxide";  # Use zoxide for cd
      };
      initExtra = ''
        # NVM configuration
        export NVM_DIR="$HOME/.nvm"
        [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
        [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

        # Pyenv configuration
        export PYENV_ROOT="$HOME/.pyenv"
        command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"

        # Load version managers
        source ${config.home.homeDirectory}/.config/version-managers.zsh

        # Initialize zoxide
        eval "$(zoxide init zsh)"

        # Initialize fzf
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

        # Initialize direnv
        eval "$(direnv hook zsh)"
      '';
    };

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

    # Configure fzf
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Configure zoxide
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Configure direnv
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Configure neovim
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    # Configure tmux
    tmux = {
      enable = true;
      shortcut = "Space";
      baseIndex = 1;
      escapeTime = 0;
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        vim-tmux-navigator
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
      ];
      extraConfig = ''
        # Enable mouse mode
        set -g mouse on

        # Increase scrollback buffer size
        set -g history-limit 50000

        # Start window numbering at 1
        set -g base-index 1

        # Start pane numbering at 1
        setw -g pane-base-index 1

        # Automatically set window title
        setw -g automatic-rename on
        set -g set-titles on
        set -g set-titles-string "#T"
      '';
    };
  };
} 