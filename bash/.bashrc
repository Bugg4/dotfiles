# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# flex
fastfetch

PROMPT_COMMAND='PS1_CMD1=$(pwd)'; PS1='\n\[\e[2m\]${PS1_CMD1}\n\[\e[0;1m\]\u\[\e[0;2m\]@\[\e[0m\]\h\[\e[2m\]> \[\e[0m\]'

HISTSIZE=
HISTFILESIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_eternal_history

# source aliases file
if [ -f "$HOME/.bash_aliases" ]; then
   source "$HOME/.bash_aliases"
fi

# init zoxide
eval "$(zoxide init bash)"
