# Interactive Bash configuration.
[[ $- != *i* ]] && return

shopt -s histappend checkwinsize

__is_vscode() {
  [[ ${TERM_PROGRAM:-} == vscode ]]
}

__is_tmux() {
  [[ -n ${TMUX:-} || ${TERM:-} == screen* || ${TERM:-} == tmux* ]]
}

if ! __is_vscode && ! __is_tmux && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# Git branch support and prompt.
[[ -r "$HOME/.local/bin/git-prompt" ]] && source "$HOME/.local/bin/git-prompt"

__prompt_update() {
  history -a
  PS1_CWD=$PWD
}
PROMPT_COMMAND=__prompt_update
PS1='\n\[\e[2m\]${PS1_CWD}\n\[\e[0;1m\]\u\[\e[0;2m\]@\[\e[0m\]\h\[\e[2m\]$(__git_ps1)> \[\e[0m\]'

# Aliases and functions
[[ -r "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"
[[ -r "$HOME/.bash_functions" ]] && source "$HOME/.bash_functions"

# Interactive runtime integrations
[[ -r /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

[[ -r /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
[[ -r /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash

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
# History is flushed by __prompt_update after each command.
