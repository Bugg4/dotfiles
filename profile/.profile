# Session-wide environment. Bash login shells source this from ~/.bash_profile.

# User directories
export SCREENSHOTS_DIR="$HOME/images/screenshots"
export DOCUMENTS_DIR="$HOME/documents"
export DOWNLOADS_DIR="$HOME/downloads"

# Preferred applications. TERM is deliberately not set here; the active
# terminal emulator is responsible for choosing the correct terminal type.
export TERMINAL=alacritty
export VISUAL=code
export EDITOR="$VISUAL"

# Language and user executable locations
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"

path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

path_append() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac
}

path_prepend "$BUN_INSTALL/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$PNPM_HOME"
path_prepend "$HOME/.local/bin"
path_append "$HOME/.lmstudio/bin"
export PATH
unset -f path_prepend path_append

# Hint Electron applications to use Wayland.
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# make flags for parallel builds
# export MAKEFLAGS=-j$(nproc) #disabled for conflict with the building process of nvidia-580xx-utils AUR package

# Automatically launch Hyprland if not running in a graphical environment
if [ -z "${DISPLAY:-}" ] && [ "${XDG_VTNR:-}" = 1 ]; then
  exec start-hyprland
fi
