#!/usr/bin/env bash

# Ask for sudo upfront (needed for pacman)
sudo pacman -Sy --noconfirm stow fastfetch

# Navigate to the dotfiles directory
cd "${HOME}/dotfiles" || { echo "Dotfiles directory not found!"; exit 1; }

# Stow and Restore
stow --no-folding --verbose --target="${HOME}" --adopt */ && \
git restore .

# Final
source "${HOME}/.bashrc"