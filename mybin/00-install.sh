#!/bin/bash

# Target directory
TARGET="/usr/local/bin"

# Current directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Explicit list of scripts to link
# Can be relative to this directory or absolute paths
SCRIPTS=(
    "accel"
    "convert-hugo-callouts"
    "fix-foto-banchetti"
    "git-open-remote"
    "git-prompt"
    "grimshot"
    "homebackup"
    "imv-preview"
    "keepass-cli-wrapper"
    "nettraffic"
    "pkgshow"
    "sourcebash"
    "trackers"
    "update-theme"
    "vidshot"
    "waydroid-full-reset"
    "winswitch"
)

echo "Installing selected scripts to $TARGET..."

# Prompt for sudo early
sudo -v

for script in "${SCRIPTS[@]}"; do
    # Resolve path: if not absolute, make it relative to this script's dir
    if [[ "$script" = /* ]]; then
        full_path="$script"
    else
        full_path="$DIR/$script"
    fi

    if [ ! -f "$full_path" ]; then
        echo "Warning: $script not found at $full_path, skipping."
        continue
    fi

    filename=$(basename "$full_path")
    echo "Linking $filename..."
    sudo ln -sf "$full_path" "$TARGET/$filename"
done

echo "Done! Selected scripts have been linked to $TARGET."
