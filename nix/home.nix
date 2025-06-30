{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # Add npm, pipx, and Go bin directories to PATH
  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  # Set up environment variables for development
  home.sessionVariables = {
    PKG_CONFIG_PATH = "$HOME/.nix-profile/lib/pkgconfig";
    # Go toolchain management (1.21+)
    GOTOOLCHAIN = "auto"; # Enable automatic toolchain switching
    # Rust/Cargo configuration
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
  };

  # Create wrapper scripts for additional Python versions
  home.file = {
    # Python 3.10 wrapper
    ".local/bin/python3.10".source = pkgs.writeShellScript "python3.10" ''
      exec ${pkgs.python310}/bin/python3.10 "$@"
    '';
    ".local/bin/pip3.10".source = pkgs.writeShellScript "pip3.10" ''
      exec ${pkgs.python310}/bin/python3.10 -m pip "$@"
    '';

    # Python 3.12 wrapper
    ".local/bin/python3.12".source = pkgs.writeShellScript "python3.12" ''
      exec ${pkgs.python312}/bin/python3.12 "$@"
    '';
    ".local/bin/pip3.12".source = pkgs.writeShellScript "pip3.12" ''
      exec ${pkgs.python312}/bin/python3.12 -m pip "$@"
    '';

    # Python 3.13 wrapper
    ".local/bin/python3.13".source = pkgs.writeShellScript "python3.13" ''
      exec ${pkgs.python313}/bin/python3.13 "$@"
    '';
    ".local/bin/pip3.13".source = pkgs.writeShellScript "pip3.13" ''
      exec ${pkgs.python313}/bin/python3.13 -m pip "$@"
    '';
  };

  # This value determines the Home Manager release that your configuration is compatible with.
  home.stateVersion = "24.05";

  # Force rebuild
  home.extraOutputsToInstall = [ "info" "man" ];

  # Define packages to be installed
  home.packages = with pkgs; ([
    # Development tools
    git

    # Python versions (default version plus alternatives)
    python311 # Python 3.11 (default - available as 'python3', 'python3.11')
    python311Packages.pip # pip for Python 3.11

    # Additional Python versions with manual symlinking to avoid collisions
    # Use: python3.10, python3.12, python3.13 for specific versions

    # JavaScript/Node.js development
    # nodejs_20    # Commented out - will use fnm for version management
    fnm # Fast Node Manager - for multiple Node.js versions
    bun # Fast all-in-one JavaScript runtime & package manager
    yarn # Classic Yarn package manager
    nodePackages.pnpm # Fast, disk space efficient package manager

    # Go development (with native toolchain management)
    go # Latest stable Go with built-in version management (1.21+)
    gopls # Go language server
    golangci-lint # Go linter aggregator
    delve # Go debugger
    gofumpt # Stricter gofmt
    go-tools # Official Go tools (godoc, goimports, gorename, etc.)
    gomodifytags # Add/remove struct tags
    impl # Generate method stubs for interfaces
    gotests # Generate table-driven tests

    # Rust development
    rustc
    cargo
    rustfmt
    clippy # Rust linter
    rust-analyzer # Rust language server
    cargo-watch # Watch for changes and run commands
    cargo-edit # Add/upgrade/remove dependencies from CLI
    cargo-nextest # Next-generation test runner

    protobuf # Protocol Buffer compiler (protoc) for gRPC

    # Build acceleration tools
    sccache # Shared compilation cache for C/C++/Rust

    # Browser automation and testing
    playwright-test # Playwright test runner and CLI
    # Note: Playwright browsers will be installed separately via npx playwright install

    # Graphics and UI development libraries
    pkg-config # Package metadata toolkit for build systems
    cairo # 2D graphics library with multiple output device support
    cairo.dev # Cairo development headers and pkg-config files
    pango # Text layout and rendering library
    pango.dev # Pango development headers and pkg-config files
    glib # GLib core library (required by Pango)
    glib.dev # GLib development headers

    # Version managers
    # nvm           # Not available in nixpkgs, use installer instead
    # pyenv         # Commenting out for now, needs testing
    # rbenv         # Commenting out for now, needs testing
    # asdf-vm       # Commenting out for now, needs testing

    # Cloud tools
    awscli2
    google-cloud-sdk

    # Python package management
    pipx # Install Python CLI tools in isolated environments

    # Cloudflare tools
    cloudflared # Cloudflare Tunnel daemon and toolkit
    # wrangler        # Cloudflare Workers CLI (temporarily disabled - large download)
    flarectl # Cloudflare CLI for account management

    # System utilities
    coreutils # GNU core utilities (timeout, realpath, etc.)

    # Network monitoring and utilities
    openssh # SSH client and SFTP support
    yt-dlp # Download videos from YouTube and other sites

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
    act # Run GitHub Actions locally
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

    # Container & Kubernetes Tools
    dive # Docker image layer explorer
    k9s # Kubernetes CLI dashboard

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
    git-cliff # Changelog generator
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

    # Interactive CLI tools
    gum # Beautiful CLI prompts and interactions

    # Multimedia processing tools
    imagemagick # Image manipulation and conversion
    ffmpeg # Audio/video processing and conversion
    # calibre # E-book management and conversion CLI tools (marked as broken in nixpkgs across platforms)

    # Archive, PDF, and audio tools
    p7zip # Command-line 7-Zip (7z, 7za, 7zr)
    ghostscript # PostScript/PDF interpreter and tools
    lame # MP3 encoder
    rclone # Cloud storage sync ("rsync for cloud storage")

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
    pandoc # Universal document converter (Markdown, HTML, PDF, DOCX, etc.)
    # Note: Mintlify is not available in nixpkgs, using nodejs for npx access

    # Backup and filesystem monitoring tools
    borgbackup # Deduplicating backup program
    fswatch # File system event monitor

    # Linting and Formatting Tools
    shellcheck # Shell script analysis tool
    shfmt # Shell script formatter
    shellharden # Shell script hardening tool (security-focused auto-fixes)
    nixpkgs-fmt # Nix code formatter
    # statix          # Nix static analysis tool (temporarily disabled due to gpgme dependency issue)
    yamllint # YAML linter
    nodePackages.markdownlint-cli # Markdown linter
    taplo # TOML formatter and linter
    pre-commit # Git hook framework for code quality
    # Note: fish_indent is included with fish package

    # Security and Quality Tools
    trivy # Vulnerability scanner for containers and filesystems
    # grype # Vulnerability scanner for container images (alternative to trivy)
    # syft # SBOM generator for containers and filesystems
    hadolint # Dockerfile linter
    gitleaks # Detect secrets in git repos
    # tfsec # Security scanner for Terraform code
    # semgrep # Static analysis tool for finding bugs
    # safety # Python dependency security checker (use via pip)
    # bundler-audit # Ruby dependency security checker (use via gem)
    # npm-audit # Node.js dependency security checker (built into npm)

    # Code Quality Metrics
    tokei # Count lines of code
    # scc # Fast code counter (alternative to tokei)
    # cloc # Count lines of code (traditional tool)
    hyperfine # Command-line benchmarking tool
    # gocyclo # Go cyclomatic complexity analyzer
    # lizard # Code complexity analyzer (multiple languages)

    # Document processing and conversion tools
    tesseract # OCR (Optical Character Recognition) engine
    # Note: For HTML to PDF conversion, consider browser-based solutions like:
    # - Puppeteer (npm install -g puppeteer)
    # - Playwright (npm install -g playwright)
    # - Or cloud services like DocRaptor, PDFShift

    # LaTeX/TeX distribution
    texlive.combined.scheme-basic
  ] ++ (
    # Platform-specific packages
    if pkgs.stdenv.isLinux then [
      # Office suite (Linux only - macOS users typically use native apps)
      libreoffice
      # Document converter using LibreOffice engine (Linux only)
      unoconv
      # Network monitoring tools (Linux only)
      nethogs # Monitor per-process network usage
      bmon # Real-time network bandwidth monitor
      iftop # Display network usage by hosts
      nload # Console network traffic monitor
      transmission-remote-gtk # BitTorrent remote control
    ] else [
      # macOS alternatives for network monitoring
      # Note: Some tools like nethogs, bmon, iftop, nload are Linux-only
      # macOS users can use: Activity Monitor, nettop, or install via Homebrew
    ]
  ));

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
        smart-commit = "!${config.home.homeDirectory}/.dotfiles/scripts/git-smart-commit.sh";
        sc = "!${config.home.homeDirectory}/.dotfiles/scripts/git-smart-commit.sh";
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
        # Add Homebrew to PATH if available (Apple Silicon first, then Intel)
        if test -e /opt/homebrew/bin/brew
          eval (/opt/homebrew/bin/brew shellenv)
        else if test -e /usr/local/bin/brew
          eval (/usr/local/bin/brew shellenv)
        else if command -v brew >/dev/null 2>&1
          eval (brew shellenv)
        end
        # Ensure Nix paths take precedence over Homebrew for development tools
        set -gx PATH $HOME/.nix-profile/bin $HOME/.npm-global/bin $HOME/.local/bin $PATH

        # fnm (Fast Node Manager) integration
        if command -v fnm >/dev/null 2>&1
          fnm env --use-on-cd | source
        end

        # Go environment
        set -gx GOPATH $HOME/go
        set -gx PATH $GOPATH/bin $PATH
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
