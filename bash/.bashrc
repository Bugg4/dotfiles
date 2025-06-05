# Obligatory flex
fastfetch

# environment variable exports
export EDITOR=micro
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export MAKEFLAGS="--jobs=$(nproc)"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PROMPT_COMMAND='PS1_CMD1=$(pwd)'; PS1='\n\[\e[2m\]${PS1_CMD1}\n\[\e[0;1m\]\u\[\e[0;2m\]@\[\e[0m\]\h\[\e[2m\]> \[\e[0m\]'

HISTSIZE=
HISTFILESIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_eternal_history

# Aliases file
if [ -f "$HOME/.bash_aliases" ]; then
   source "$HOME/.bash_aliases"
fi

# Set PATH
PATH=$HOME/Scripts:$PATH

# init zoxide
eval "$(zoxide init bash)"
