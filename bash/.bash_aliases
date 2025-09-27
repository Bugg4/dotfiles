# generic
alias ls='eza --color=auto --icons=auto --long --hyperlink --group-directories-first'
alias stow='stow --verbose --dir=${HOME}/dotfiles/ --target=${HOME}/'
alias yt='yt-dlp'
alias btop='btop -u 100'
alias todo='micro $HOME/todo.md'
alias bloat='sudo du -sh * | sort -h'
alias music='mpv "$(find /mnt/WIN_D/Musica/ | fzf)"'

# quick sourcing
alias sourcebash='source ${HOME}/.bashrc && printf "${HOME}/.bashrc sourced!\n"'
alias sourceprofile='source ${HOME}/.bash_profile && printf "${HOME}/.bash_profile sourced!\n"'

# configs
alias conf-hyprland='code $HOME/.config/hypr/'

# directories
alias cd-wine-runners='cd $HOME/.local/share/wine/runners'
alias cd-wine-prefixes='cd $HOME/.local/share/wine/prefixes'

# wine
alias wine-ew-affinity='rum ElementalWarriorWine-x86_64 $HOME/.local/share/wine/prefixes/affinity/'
alias wine-latest-affinity='rum /usr/ $HOME/.local/share/wine/prefixes/test'

# git
alias gs='git status'
alias gl='git log'
alias gadd='git add'
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
