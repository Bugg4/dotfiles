# shellcheck disable=SC2148
# generic
alias ls='eza --color=auto --icons=auto --long --hyperlink --group-directories-first'
# alias ls='ls -lah --color=auto --group-directories-first'
alias stow='stow --no-folding --verbose --dir=${HOME}/dotfiles --target=${HOME}'
alias yt='yt-dlp'
alias btop='btop -u 100'
alias todo='micro $HOME/todo.md'
alias bloat='sudo du -sh * .[^.]* | sort -h'
alias ffmpeg='ffmpeg -hide_banner'
alias reflector-refresh='sudo reflector --verbose --protocol https --latest 16 --sort rate --save /etc/pacman.d/mirrorlist && cat /etc/pacman.d/mirrorlist'
alias kp='keepass-cli-wrapper $HOME/documents/keepass/keepass.kdbx'
alias ag='antigravity'
alias drag='ripdrag --no-click --resizable --icon-size 64 --and-exit'

# Open dotfiles
alias dots='code $HOME/dotfiles'

# directories
alias wine-runners='cd $HOME/.local/share/wine/runners'
alias wine-prefixes='cd $HOME/.local/share/wine/prefixes'
alias blog='cd $HOME/code/bulga-dev/blog'
alias torrc-local='code $HOME/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/TorBrowser/Data/Tor/torrc'

# wine
alias wine-ew-affinity='rum ElementalWarriorWine-x86_64 $HOME/.local/share/wine/prefixes/affinity/'
alias wine-affinity-new='WINEPREFIX="$HOME/.local/share/wine/prefixes/affinity-new"'

# git
alias gor='git-open-remote'

# confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -I --preserve-root'

# cp progress
alias cp-prog='rsync -ahP'

alias cls='clear'

# Parenting changing perms on /
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
