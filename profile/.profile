# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi

# set user dictories
SCREENSHOTS_DIR=$HOME/screenshots
DOCUMENTS_DIR=$HOME/documents
SCRIPTS_DIR=$HOME/scripts
DOWNLOADS_DIR=$HOME/downloads

# set PATH so it includes user's private bin if it exists
if [ -d "$SCRIPTS_DIR" ] ; then
    PATH="$SCRIPTS_DIR:$PATH"
fi

# default terminal emulator
TERM=alacritty

# hint electron apps to use Wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland

# make flags for parallel builds
MAKEFLAGS=-j=$(nproc)

