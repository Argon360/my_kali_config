# -----------------------------------------------------------------------------
# FZF Configuration (Everywhere)
# -----------------------------------------------------------------------------

# 1. Load FZF (Modern way)
# This handles key bindings (CTRL-T, CTRL-R, ALT-C) and fuzzy completion (**)
if command -v fzf >/dev/null; then
  eval "$(fzf --zsh)"
fi

# 2. Defaults & Backends
# Use ripgrep (rg) for ultra-fast searching if available
if command -v rg >/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Use fd for ALT-C if available, otherwise find
if command -v fd >/dev/null; then
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null; then
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
else
  export FZF_ALT_C_COMMAND='find . -mindepth 1 -path "*/.*" -prune -o -type d -print 2> /dev/null | cut -b3-'
fi

# 3. Appearance (Nord-inspired)
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --color=bg+:-1,fg:gray,fg+:white,hl:blue,hl+:blue
  --color=prompt:blue,header:blue,pointer:magenta,info:yellow,marker:magenta
  --bind "ctrl-/:change-preview-window(down|hidden|)"
'

# 4. Global Previews
# Note: eza is used for directories.
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -T --color=always {} | head -200; else cat {}; fi'"
export FZF_ALT_C_OPTS="--preview 'eza -T --color=always {} | head -200'"

# 5. FZF-Tab Integration (Loaded in 90-plugins.zsh)
# These zstyles must be set before or after, but they are here for organization.
zstyle ':fzf-tab:*' fzf-flags '--height=60%'
zstyle ':fzf-tab:*' fzf-preview-window 'right:60%'
zstyle ':fzf-tab:complete:(ssh|scp):*' fzf-preview 'dig $word || host $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-variant-):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'systemctl status $word'

# 6. Helper Functions (FZF Everywhere)

# fe [QUERY] - Open fuzzy-selected file in EDITOR
fe() {
  local files
  IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fcd - cd into fuzzy-selected directory
fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fkill - Fuzzy kill process
fkill() {
    local pid 
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $USER | sed 1d | fzf -m | awk "{print \$2}")
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk "{print \$2}")
    fi  
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -${1:-9}
    fi  
}

# fenv - Fuzzy search & export environment variables
fenv() {
  local out
  out=$(env | fzf) && export $(echo "$out" | cut -d= -f1)
}

# fshow - Git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
