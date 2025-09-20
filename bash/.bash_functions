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

# fuzzy cd (no hidden dirs)
function fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
    -o -type d -print 2>/dev/null | fzf +m) &&
    cd "$dir"
  ls
}

# fuzzy cd, include hidden dirs
function fcda() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
  ls
}

# fuzzy find file and cd to it
function fcdf() {
  local file
  local dir
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
  ls
}

qr() {
  local input
  if [[ -n "$1" ]]; then
    # If an argument is provided, use it
    input="$*"
  else
    # Otherwise read from stdin
    input="$(cat)"
  fi

  qrencode -t UTF8 -o - "$input"
}

extract() {
  if [ -f $1 ]; then
    case $1 in
    *.tar.bz2) tar xvjf $1 ;;
    *.tar.gz) tar xvzf $1 ;;
    *.bz2) bunzip2 $1 ;;
    *.rar) unrar x $1 ;;
    *.gz) gunzip $1 ;;
    *.tar) tar xvf $1 ;;
    *.tbz2) tar xvjf $1 ;;
    *.tgz) tar xvzf $1 ;;
    *.zip) unzip $1 ;;
    *.Z) uncompress $1 ;;
    *.7z) 7z x $1 ;;
    *) echo "Unable to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
