# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# set user dictories
export SCREENSHOTS_DIR=$HOME/images/screenshots
export DOCUMENTS_DIR=$HOME/documents
export SCRIPTS_DIR=$HOME/scripts
export DOWNLOADS_DIR=$HOME/downloads

# default terminal emulator
export TERM=alacritty

# default editor
export VISUAL=code
export EDITOR="${VISUAL}"

# hint electron apps to use Wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# make flags for parallel builds
export MAKEFLAGS=-j$(nproc)


# add other user directories to PATH
if [ -d "$SCRIPTS_DIR" ] ; then
    PATH="$SCRIPTS_DIR:$PATH"
fi

# Automatically launch Hyprland if not running in a graphical environment
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec Hyprland
fi
