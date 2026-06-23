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
    
    # Basic Config
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu no
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':fzf-tab:*' switch-group '<' '>'
    
    # Bind TAB to next option and Shift-TAB to previous
    zstyle ':fzf-tab:*' fzf-flags --bind 'tab:down,btab:up'

    # Disable continuous trigger so TAB only moves the selection
    zstyle ':fzf-tab:*' continuous-trigger ''
    
    # Previews
    # Default: Bat for files, fallback to cat
    if command -v bat >/dev/null; then
        zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [ -d $realpath ]; then eza -1 --color=always $realpath; else bat --color=always --style=numbers --line-range=:500 $realpath; fi'
    else
        zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [ -d $realpath ]; then ls -1 --color=always $realpath; else cat $realpath; fi'
    fi

    # Command options and aliases
    zstyle ':fzf-tab:complete:-command-:*' fzf-preview '(out=$(whence -p $word); [ -n "$out" ] && $out --help) | head -n 50'
    
    # CD/Navigation: Eza (Tree view for directories)
    if command -v eza >/dev/null; then
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    else
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    fi
    
    # Kill: Show detailed process info
    zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
fi

# 4. Syntax Highlighting (MUST BE LAST)
if [[ -f ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
