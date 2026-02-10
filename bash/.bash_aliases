# shellcheck disable=SC2148
# generic
alias ls='eza --color=auto --icons=auto --long --hyperlink --group-directories-first'
alias stow='stow --no-folding --verbose --dir=${HOME}/dotfiles/ --target=${HOME}/'
alias stow-force='cd $HOME/dotfiles && git stash -m "before stow-force on $(date -I)" && stow --no-folding --verbose --dir=${HOME}/dotfiles/ --target=${HOME}/ --adopt * && git restore .'
alias yt='yt-dlp'
alias btop='btop -u 100'
alias todo='micro $HOME/todo.md'
alias bloat='sudo du -sh * | sort -h'
alias music='mpv "$(find /mnt/WIN_D/Musica/ | fzf)"'
alias ffmpeg='ffmpeg -hide_banner'
alias reflector-refresh='sudo reflector --verbose --protocol https --latest 16 --sort rate --save /etc/pacman.d/mirrorlist && cat /etc/pacman.d/mirrorlist'
alias kp='kp $HOME/documents/keepass/keepass.kdbx'

# quick sourcing
alias sourcebash='source ${HOME}/.bashrc && printf "${HOME}/.bashrc sourced!\n"'
alias sourceprofile='source ${HOME}/.bash_profile && printf "${HOME}/.bash_profile sourced!\n"'

# Open dotfiles
alias dot='code -a $(find $HOME/dotfiles/ -maxdepth 2 -type d | fzf)'
alias dots='code $HOME/dotfiles'

# directories
alias wine-runners='cd $HOME/.local/share/wine/runners'
alias wine-prefixes='cd $HOME/.local/share/wine/prefixes'

# wine
alias wine-ew-affinity='rum ElementalWarriorWine-x86_64 $HOME/.local/share/wine/prefixes/affinity/'
alias wine-affinity-new='WINEPREFIX="$HOME/.local/share/wine/prefixes/affinity-new"'

# git
alias gsb='git checkout $(git branch | fzf)'
alias gor='git-open-remote.sh'

# confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -I --preserve-root'

alias cls='clear'

# Parenting changing perms on /
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
