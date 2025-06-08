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
    bun
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
    fish
    starship
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

    # Advanced CLI tools (moved from Homebrew)
    chezmoi     # Dotfiles management
    mosh        # Robust remote shell
    thefuck     # Correct previous command typos
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

  # Configure programs
  programs = {
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
        # NVM configuration
        set -x NVM_DIR "$HOME/.nvm"
        if test -s "(brew --prefix)/opt/nvm/nvm.sh"
          source "(brew --prefix)/opt/nvm/nvm.sh"
        end

        # Pyenv configuration
        set -x PYENV_ROOT "$HOME/.pyenv"
        if not type -q pyenv
          set -x PATH "$PYENV_ROOT/bin" $PATH
        end
        status --is-interactive; and source (pyenv init -|psub)
        status --is-interactive; and source (pyenv virtualenv-init -|psub)

        # Initialize zoxide
        zoxide init fish | source

        # Initialize fzf
        if test -f ~/.fzf.fish
          source ~/.fzf.fish
        end

        # Initialize direnv
        direnv hook fish | source
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
      enableFishIntegration = true;
    };

    # Configure zoxide
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    # Configure direnv
    direnv = {
      enable = true;
      enableFishIntegration = true;
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