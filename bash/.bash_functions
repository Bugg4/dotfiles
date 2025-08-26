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