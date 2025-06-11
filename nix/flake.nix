{
  description = "Cross-platform development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-darwin"; # Change to "x86_64-linux" for Linux or "aarch64-darwin" for M1 Mac
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Development shell for quick access to tools
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Development tools
          git
          python311
          nodejs_20
          go
          rustc
          cargo

          # Shell tools
          fish
          starship
          eza
          bat
          fd
          ripgrep
          tldr

          # Developer CLI Tools
          gh
          jq
          yq
          htop
          tmux
          neovim
          fzf
          zoxide
          direnv
          httpie
          wget
          curl
          tree

          # Advanced CLI tools
          chezmoi
          mosh
          delta
          lazygit
          btop
          glow
          vifm
        ];

        shellHook = ''
          echo "🚀 Development environment loaded!"
          echo "Available tools: git, node, python, go, rust, fish, starship, and many more..."
        '';
      };

      # Home Manager configuration
      homeConfigurations."admin" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };

      devShells.${system}.python = pkgs.mkShell {
        buildInputs = with pkgs; [
          python311Full
          python311Packages.pip
          python311Packages.black
          python311Packages.flake8
          python311Packages.pytest
          python311Packages.ipython
          pipx
        ];
        shellHook = ''
          echo "🐍 Python development environment loaded!"
          echo "Available: python, pip, black, flake8, pytest, ipython, pipx"
        '';
      };
    };
} 