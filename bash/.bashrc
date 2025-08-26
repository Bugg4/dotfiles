# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# flex
fastfetch

# git branch in prompt
source ~/scripts/git-prompt.sh

PROMPT_COMMAND='PS1_CMD1=$(pwd)'; PS1='\n\[\e[2m\]${PS1_CMD1}\n\[\e[0;1m\]\u\[\e[0;2m\]@\[\e[0m\]\h\[\e[2m\]$(__git_ps1)> \[\e[0m\]'

HISTSIZE=
HISTFILESIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_eternal_history

# source aliases file
if [ -f "$HOME/.bash_aliases" ]; then
   source "$HOME/.bash_aliases"
fi

# bash functions file
if [ -f "$HOME/.bash_functions" ]; then
   source "$HOME/.bash_functions"
fi

# init zoxide
eval "$(zoxide init bash)"

# pnpm
export PNPM_HOME="/home/marco/.local/share/pnpm"
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

