# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------

# 1. Autosuggestions
if [[ -f ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_USE_ASYNC=1
fi

# 2. History Substring Search (Fish Up/Down)
if [[ -f ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    # Color for the matched part
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
fi

# 3. FZF-Tab (Interactive Completion)
if [[ -f ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]]; then
    source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
    # Use LS_COLORS for file list
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    # Use FZF for selection
    zstyle ':completion:*' menu no
    # Preview files with Bat
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
fi

# 4. Syntax Highlighting (MUST BE LAST)
if [[ -f ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi