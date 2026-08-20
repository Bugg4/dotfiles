# shellcheck disable=SC2148
fzf-aliases-functions() {
  local command_name
  command_name=$(
    (
      # List all aliases
      alias
      # List all function names, filtering out internal ones (starting with _)
      declare -F | awk '{print $3}' | grep -v "^_"
    ) | fzf | cut -d'=' -f1
  )

  if [[ -n $command_name ]]; then
    eval "$command_name"
  fi
}

fzf-env-vars() {
  local out
  out=$(env | fzf) || return
  printf '%s\n' "${out#*=}"
}

sourcebash() {
  source "$HOME/.bashrc"
  printf '%s sourced\n' "$HOME/.bashrc"
}

sourceprofile() {
  source "$HOME/.bash_profile"
  printf '%s sourced\n' "$HOME/.bash_profile"
}

# fuzzy cd (no hidden dirs)
fcd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune \
    -o -type d -print 2>/dev/null | fzf +m) || return
  cd "$dir" || return
  command ls
}

# fuzzy cd, include hidden dirs
fcda() {
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) || return
  cd "$dir" || return
  command ls
}

# fuzzy find file and cd to it
fcdf() {
  local file dir
  file=$(fzf +m -q "${1:-}") || return
  dir=$(dirname -- "$file")
  cd "$dir" || return
  command ls
}

qr() {
  local input
  if (( $# > 0 )); then
    # If an argument is provided, use it
    input="$*"
  else
    # Otherwise read from stdin
    input="$(cat)"
  fi

  qrencode -t UTF8 -o - "$input"
}

extract() {
  if (( $# != 1 )) || [[ ! -f $1 ]]; then
    printf 'Usage: extract <archive>\n' >&2
    return 2
  fi

  case $1 in
    *.tar.bz2) tar xvjf "$1" ;;
    *.tar.gz) tar xvzf "$1" ;;
    *.bz2) bunzip2 -- "$1" ;;
    *.rar) unrar x -- "$1" ;;
    *.gz) gunzip -- "$1" ;;
    *.tar) tar xvf "$1" ;;
    *.tbz2) tar xvjf "$1" ;;
    *.tgz) tar xvzf "$1" ;;
    *.zip) unzip -- "$1" ;;
    *.Z) uncompress -- "$1" ;;
    *.7z) 7z x -- "$1" ;;
    *)
      printf 'Unsupported archive: %s\n' "$1" >&2
      return 2
      ;;
    esac
}

b64decode() {
  local input decoded

  if (( $# > 0 )); then
    input="$1"
  else
    input="$(cat)"
  fi

  if ! decoded=$(printf '%s' "$input" | base64 --decode 2>/dev/null); then
    printf 'Error: invalid base64 input\n' >&2
    return 1
  fi

  printf '%s' "$decoded"
  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$decoded" | wl-copy
  fi
}

lanip() {
  ip route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([^ ]*\).*/\1/p' | head -n 1
}

music() {
  local track
  track=$(find /mnt/WIN_D/Musica -type f 2>/dev/null | fzf) || return
  mpv -- "$track"
}

dot() {
  local directory
  directory=$(find "$HOME/dotfiles" -maxdepth 2 -type d | fzf) || return
  code -a -- "$directory"
}

gsb() {
  local branch
  branch=$(git branch --all --format='%(refname:short)' | fzf) || return
  git switch -- "$branch"
}

stow-force() {
  local package
  if (( $# == 0 )); then
    printf 'Usage: stow-force <package> [...]\n' >&2
    return 2
  fi

  for package in "$@"; do
    if ! git -C "$HOME/dotfiles" diff --quiet -- "$package" ||
       ! git -C "$HOME/dotfiles" diff --cached --quiet -- "$package"; then
      printf 'Refusing to adopt over local changes in package: %s\n' "$package" >&2
      return 1
    fi
    command stow --no-folding --verbose \
      --dir="$HOME/dotfiles" --target="$HOME" --adopt "$package" || return
  done
  git -C "$HOME/dotfiles" restore --worktree -- "$@"
}
