
# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

if command -v atuin >/dev/null; then
  eval "$(atuin init zsh)"
fi
