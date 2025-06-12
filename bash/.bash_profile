# this file is sourced *first* by bash when it is invoked as a login shell.
# https://www.pallier.org/understanding-bash-startup-scripts.html#:~:text=Login%20shells%20first%20execute%20/etc/profile%2C%20then%20look%20for%20~/.bash_profile%2C%20~/.bash_login%20and%20~/.profile%2C%20in%20that%20order%2C%20and%20reads%20and%20executes%20commands%20from%20the%20first%20one%20that%20exists.


# source .profile if it exists
[[ -f ~/.profile ]] && . ~/.profile

# source .bashrc if it exists
[[ -f ~/.bashrc ]] && . ~/.bashrc
