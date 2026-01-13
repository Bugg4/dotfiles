#!/usr/bin/env bash

sudo pacman -Sy --noconfirm stow git fastfetch
stow --no-folding --verbose --dir="${HOME}/dotfiles/" --target="${HOME}/" --adopt ./*
git restore .
source "${HOME}/.bashrc"