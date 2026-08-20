# Bash login-shell bootstrap.

# Session-wide environment
[[ -r "$HOME/.profile" ]] && source "$HOME/.profile"

# Interactive Bash configuration
[[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
