#!/usr/bin/env bash
file="$1"

if file --mime-type -b "$file" | grep -q '^image/'; then
   # If imv is already running, tell it to open new file
   if imv-msg open "$file" 2>/dev/null; then
      exit 0
   fi
   # Otherwise, start a new one
   imv -n "$file" &
fi
