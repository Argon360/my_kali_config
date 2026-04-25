# =============================================================================
# ZSH Main Entry Point
# =============================================================================

# Safety: only interactive shells
[[ -o interactive ]] || return

# Base directory for modular config
ZSH_CONFIG=$HOME/.config/zsh

# -----------------------------------------------------------------------------
# 1. Load Modular Configs
# -----------------------------------------------------------------------------

# Define modules to load in order
zsh_modules=(
    00-env.zsh
    10-tools.zsh
    15-options.zsh
    20-prompt.zsh
    30-history.zsh
    40-navigation.zsh
    50-bindings.zsh
    60-aliases.zsh
    70-extras.zsh
    80-completion.zsh
    85-fzf.zsh
    90-plugins.zsh
)

for module in $zsh_modules; do
    [[ -f $ZSH_CONFIG/$module ]] && source $ZSH_CONFIG/$module
done

# -----------------------------------------------------------------------------
# 4. Startup
# -----------------------------------------------------------------------------
# Caelestia Startup
if command -v fastfetch >/dev/null; then
  echo -ne '\x1b[38;5;16m'
  echo '     ______           __          __  _       '
  echo '    / ____/___ ____  / /__  _____/ /_(_)___ _ '
  echo '   / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/ '
  echo '  / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /  '
  echo '  \____/\__,_/\___/_/\___/____/\__/_/\__,_/   '
  echo -ne '\x1b[0m'
  fastfetch --key-padding-left 5
fi

