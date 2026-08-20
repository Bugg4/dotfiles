#!/usr/bin/env bash

remotes=$(git remote -v | awk -F' ' '{print $2}' | uniq)
count=$(echo "$remotes" | wc -l)

if [ "$count" -eq 0 ]; then
   echo "No git remotes found." >&2
   exit 1
elif [ "$count" -eq 1 ]; then
   remote=$remotes
else
   # Multiple remotes --> let user pick one
   remote=$(echo "$remotes" | fzf --prompt="Select remote: ")
   [ -z "$remote" ] && exit 0
fi

xdg-open "$remote" >/dev/null 2>&1 &