
# -----------------------------------------------------------------------------
# FZF Key Bindings
# -----------------------------------------------------------------------------

if command -v fzf >/dev/null; then
  source /usr/share/fzf/key-bindings.zsh 2>/dev/null
  source /usr/share/fzf/completion.zsh 2>/dev/null

  fzf-file-widget() {
    local file
    file=$(fzf)
    [[ -n $file ]] && LBUFFER+="$file"
  }
  zle -N fzf-file-widget
  bindkey '^F' fzf-file-widget

  bindkey '^R' fzf-history-widget

  fzf-cd-widget() {
    local dir
    dir=$(find . -type d 2>/dev/null | fzf)
    [[ -n $dir ]] && cd "$dir"
  }
  zle -N fzf-cd-widget
  bindkey '^D' fzf-cd-widget

  fzf-kill-widget() {
    ps -ef | sed 1d | fzf | awk '{print $2}' | xargs -r kill -9
  }
  zle -N fzf-kill-widget
  bindkey '^K' fzf-kill-widget
fi
