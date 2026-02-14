# -----------------------------------------------------------------------------
# Tool Integrations
# -----------------------------------------------------------------------------

# Bat
if command -v bat >/dev/null; then
  export BAT_THEME="Dracula"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  alias cat='bat'
fi

# Delta
if command -v delta >/dev/null; then
  export GIT_PAGER=delta
fi
