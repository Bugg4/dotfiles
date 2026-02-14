#!/bin/sh
# install.sh - Link save-installed.hook into /etc/pacman.d/hooks/
# Generated on 2026-02-14

HOOK_SRC="$(pwd)/save-installed.hook"
HOOK_DEST="/etc/pacman.d/hooks/save-installed.hook"

if [ ! -d "/etc/pacman.d/hooks" ]; then
    echo "Creating /etc/pacman.d/hooks directory..."
    sudo mkdir -p /etc/pacman.d/hooks
fi

echo "Linking $HOOK_SRC to $HOOK_DEST..."
sudo ln -sf "$HOOK_SRC" "$HOOK_DEST"
echo "Hook installed successfully."
