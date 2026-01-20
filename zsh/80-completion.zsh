# -----------------------------------------------------------------------------
# Completion Tuning
# -----------------------------------------------------------------------------
autoload -U compinit; compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colored completion (uses LS_COLORS)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Menu selection (like Fish)
# zstyle ':completion:*' menu select
