# Source Nix environment
if test -e ~/.nix-profile/etc/profile.d/nix.sh
    bass source ~/.nix-profile/etc/profile.d/nix.sh
end

# Add Nix paths to PATH
set -gx PATH ~/.nix-profile/bin $PATH

# Add Homebrew to PATH
eval (/opt/homebrew/bin/brew shellenv)

# Initialize Starship prompt
starship init fish | source

# Set some useful aliases
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias cat="bat"
alias find="fd"
alias work='cd /Volumes/data/work'
alias grep="rg"
