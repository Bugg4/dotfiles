fzf-aliases-functions() {
  local CMD
  CMD=$(
    (
      # List all aliases
      alias
      # List all function names, filtering out internal ones (starting with _)
      declare -F | awk '{print $3}' | grep -v "^_"
    ) | fzf | cut -d'=' -f1
  )

  # If a command was selected (CMD is not empty), execute it
  if [[ -n "$CMD" ]]; then
    eval "$CMD"
  fi
}

function fzf-env-vars() {
  local out
  out=$(env | fzf)
  echo $(echo $out | cut -d= -f2)
}

# fuzzy cd
function fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
  ls
}