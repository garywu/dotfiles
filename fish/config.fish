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
