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

# -----------------------------------------------------------------------------
# FZF Standard Integration
# -----------------------------------------------------------------------------
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
