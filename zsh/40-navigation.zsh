
# -----------------------------------------------------------------------------
# Navigation
# -----------------------------------------------------------------------------

if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

# -----------------------------------------------------------------------------
# Auto-eza on directory change
# -----------------------------------------------------------------------------
autoload -Uz add-zsh-hook

_auto_eza_on_cd() {
    [[ -o interactive ]] || return 0
    if command -v eza >/dev/null 2>&1; then
        eza -a --group-directories-first --icons=auto
    else
        ls -A
    fi
}

add-zsh-hook chpwd _auto_eza_on_cd

