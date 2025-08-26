# generic
alias ls='eza --color=auto --icons=auto --long --hyperlink --group-directories-first'
alias stow='stow --verbose --dir=${HOME}/dotfiles/ --target=${HOME}/'
alias yt='yt-dlp'
alias btop='btop -u 100'
alias todo='micro $HOME/todo.md'

# quich sourcing
alias sourcebash='source ${HOME}/.bashrc && printf "${HOME}/.bashrc sourced!\n"'
alias sourceprofile='source ${HOME}/.bash_profile && printf "${HOME}/.bash_profile sourced!\n"'

# git
alias gs='git status'
alias gl='git log'
alias ga='git add'
alias gall='git add .'
alias gca='git commit -a'
alias gc='git commit -m'
alias gb='git branch'
alias gsb='git checkout $(git branch | fzf)'


# confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -I --preserve-root'

# Parenting changing perms on /
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
