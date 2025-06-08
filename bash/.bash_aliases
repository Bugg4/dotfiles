# generic
alias ls='eza --color=auto --icons=auto --long --hyperlink --group-directories-first'
alias stow='stow --verbose --dir=${HOME}/dotfiles/ --target=${HOME}/'
alias yt='yt-dlp'
alias btop='btop -u 100'
alias cat='bat'
alias todo='micro $HOME/todo.md'

# git
alias gs="git status"
alias gl="git log"
alias ga="git add"
alias gall="git add ."
alias gca="git commit -a"
alias gc="git commit -m"

# confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -I --preserve-root'

# Parenting changing perms on /
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
