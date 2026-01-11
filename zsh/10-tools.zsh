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

# FZF defaults
export FZF_DEFAULT_OPTS="
--height=40%
--layout=reverse
--border
--inline-info
--preview 'bat --style=numbers --color=always --line-range :500 {}'
--preview-window=right:60%
"
