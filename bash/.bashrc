# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# flex
fastfetch

# git branch in prompt
source ~/scripts/git-prompt.sh

PROMPT_COMMAND='PS1_CMD1=$(pwd)'; PS1='\n\[\e[2m\]${PS1_CMD1}\n\[\e[0;1m\]\u\[\e[0;2m\]@\[\e[0m\]\h\[\e[2m\]$(__git_ps1)> \[\e[0m\]'

# source aliases file
if [ -f "$HOME/.bash_aliases" ]; then
   source "$HOME/.bash_aliases"
fi

# bash functions file
if [ -f "$HOME/.bash_functions" ]; then
   source "$HOME/.bash_functions"
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Node version manager (nvm)
source /usr/share/nvm/init-nvm.sh

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Append this line to ~/.bashrc to enable fzf keybindings for Bash:
source /usr/share/fzf/key-bindings.bash
# Append this line to ~/.bashrc to enable fuzzy auto-completion for Bash:
source /usr/share/fzf/completion.bash

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTCONTROL=erasedups
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
