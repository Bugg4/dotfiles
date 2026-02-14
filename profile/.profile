# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# set user dictories
export SCREENSHOTS_DIR=$HOME/images/screenshots
export DOCUMENTS_DIR=$HOME/documents
export DOWNLOADS_DIR=$HOME/downloads

# default terminal emulator
export TERM=alacritty

# default editor
export VISUAL=code
export EDITOR="${VISUAL}"

# hint electron apps to use Wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# make flags for parallel builds
# export MAKEFLAGS=-j$(nproc) #disabled for conflict with the building process of nvidia-580xx-utils AUR package

# Automatically launch Hyprland if not running in a graphical environment
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec start-hyprland
fi
