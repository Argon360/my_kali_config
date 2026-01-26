# Enable FZF Key bindings (Ctrl+T, Ctrl+R, Alt+C)
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# --- FZF-TAB (Replaces standard completion) ---
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# Custom colors for fzf-tab to match your system ls colors
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Force fzf-tab to use fzf settings
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# NOTE: Standard fzf completion is disabled in favor of fzf-tab
# [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh