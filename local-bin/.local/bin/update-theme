#!/usr/bin/env bash 

wp=$(realpath $1)

hyprctl hyprpaper wallpaper 'DP-4, '$wp', cover'
wallust run $wp
killall waybar
waybar &
notify-send -t 2000 -i $wp "Theme updated" "The theme has been successfully updated to $wp."
