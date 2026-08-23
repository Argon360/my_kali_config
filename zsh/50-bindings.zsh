# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
bindkey -e

# Ctrl + Left/Right
bindkey '^[[1;5D' backward-word
bindkey '^[[5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5C' forward-word

# Ctrl + Backspace / Delete
bindkey '^H' backward-kill-word
bindkey '^?' backward-delete-char
bindkey '^[[3;5~' kill-word
bindkey '^W' backward-kill-word

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# -----------------------------------------------------------------------------
# Up Arrow: Atuin (Magic History)
# -----------------------------------------------------------------------------
# If Atuin is installed, use it for the Up arrow.
# Otherwise, fall back to history-substring-search.

if command -v atuin >/dev/null; then
  # Atuin widget name depends on version, usually _atuin_search_widget
  bindkey '^[[A' _atuin_search_widget
  [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" _atuin_search_widget
else
  # Fallback: History Substring Search
  bindkey '^[[A' history-substring-search-up
  [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
fi

# -----------------------------------------------------------------------------
# History Substring Search (Down Arrow)
# -----------------------------------------------------------------------------
# We keep Down arrow for quick line-by-line history navigation
bindkey '^[[B' history-substring-search-down
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
