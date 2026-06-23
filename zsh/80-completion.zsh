# -----------------------------------------------------------------------------
# Completion Tuning
# -----------------------------------------------------------------------------
autoload -U compinit; compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colored completion (uses LS_COLORS)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Disable menu selection (fzf-tab will handle it)
zstyle ':completion:*' menu no
