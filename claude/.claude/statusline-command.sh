#!/bin/bash
# Status line derived from the bash PS1 in ~/.bashrc (trailing ">" removed),
# plus subscription quota usage when Claude Code provides it.
input=$(cat)
# Debug: keep the last payload so the available fields can be inspected.
{ printf '%s' "$input" > /tmp/claude-1000/-home-marco/6f4869d5-5383-4521-8b74-0a6c545eddd9/scratchpad/statusline-input.json; } 2>/dev/null

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
git_part=""
[ -n "$branch" ] && git_part=" ($branch)"

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | 100 - . | round')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | 100 - . | round')
quota=""
[ -n "$five" ] && quota=" | 5h left: $five%"
[ -n "$week" ] && quota="$quota | 7d left: $week%"

printf '\033[2m%s\033[0m\n\033[0;1m%s\033[0;2m@\033[0m%s\033[2m%s\033[0m%s' \
  "$cwd" "$(whoami)" "${HOSTNAME%%.*}" "$git_part" "$quota"
