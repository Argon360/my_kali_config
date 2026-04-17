# =============================================================================
#  ZSH ALIASES & FUNCTIONS CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
#  FZF Integrations & Key Bindings
# -----------------------------------------------------------------------------
if command -v fzf >/dev/null; then
    # Source system FZF scripts if available
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
    
    # Custom FZF Widgets
    fzf-file-widget() { local file; file=$(fzf); [[ -n $file ]] && LBUFFER+="$file"; }
    zle -N fzf-file-widget; bindkey '^F' fzf-file-widget
    bindkey '^R' fzf-history-widget
    
    fzf-cd-widget() { local dir; dir=$(find . -type d 2>/dev/null | fzf); [[ -n $dir ]] && cd "$dir"; }
    zle -N fzf-cd-widget; bindkey '^D' fzf-cd-widget

    fzf-kill-widget() {
        local pid
        if [[ "$UID" != "0" ]]; then
            pid=$(ps -f -u $UID | sed 1d | fzf -m --header 'Select process to kill' | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf -m --header 'Select process to kill' | awk '{print $2}')
        fi
        if [[ -n "$pid" ]]; then
            echo "$pid" | xargs kill -9
            zle reset-prompt
        fi
    }
    zle -N fzf-kill-widget; bindkey '^K' fzf-kill-widget
fi

# -----------------------------------------------------------------------------
#  File System & Navigation (Recursive by default)
# -----------------------------------------------------------------------------
alias cp='cp -ivR'
alias scp='scp -r'
alias grep='grep --recursive --color=auto --exclude-dir={.git,node_modules,vendor}'

if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --color=always --icons=always'
    alias ll='eza -l --group-directories-first --color=always --icons'
    alias la='eza -la --group-directories-first --color=always --icons'
    alias lt='eza --tree --color=always --icons' # Removed --level=3 to be fully recursive
fi

# Secure RM (shred for files, auto-recursive, handles locked files)
unalias rm 2>/dev/null
rm() {
    local -a targets
    local force=0
    local verbose=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force) force=1; shift ;;
            -v|--verbose) verbose="-v"; shift ;;
            -fv|-vf) force=1; verbose="-v"; shift ;;
            -r|-R|--recursive) shift ;; # Ignore -r as we are now auto-recursive
            --) shift; targets+=("$@"); break ;;
            -*) shift ;; # Ignore other flags
            *) targets+=("$1"); shift ;;
        esac
    done

    for item in "${targets[@]}"; do
        [[ ! -e "$item" && ! -L "$item" ]] && continue

        if [[ -d "$item" ]]; then
            echo "Securely removing directory: $item"
            # Remove immutable flag if present (requires sudo if not owner)
            [[ -f /usr/bin/chattr ]] && sudo chattr -R -i "$item" 2>/dev/null
            
            # Shred all files inside
            find "$item" -type f -print0 | xargs -0 -I {} shred -uvzf -n 3 {}
            
            # Remove the directory structure
            sudo rm -rf "$item"
        else
            # It's a file or symlink
            # Try to unlock if it's a regular file
            if [[ -f "$item" ]]; then
                [[ -f /usr/bin/chattr ]] && sudo chattr -i "$item" 2>/dev/null
            fi
            
            # Shred with force flag (handles read-only)
            # Use sudo to ensure we can shred root-owned files the user wants gone
            sudo shred -uvzf -n 3 "$item" || sudo rm -f "$item"
        fi
    done
}

alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias x='unp'

command -v dust >/dev/null && alias du='dust' && alias duh='dust -H'
alias fcount='find . -type f | wc -l'
alias dcount='find . -type d | wc -l'

# -----------------------------------------------------------------------------
#  System Information & Maintenance
# -----------------------------------------------------------------------------
alias top='btop --force-utf'
alias mem='free -h'
alias cpu='lscpu | less'
alias ipinfo='ip -c a'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'

# Package Management
if command -v pacman >/dev/null; then
    alias sysup='sudo pacman -Syu'
    alias install='sudo pacman -S'
    alias update='sudo pacman -Sy'
    alias upgrade='sudo pacman -Syu'
    alias remove='sudo pacman -Rs'
    alias search='pacman -Ss'
    alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'
elif command -v dnf >/dev/null; then
elif command -v apt >/dev/null; then
    alias sysup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean'
    alias install='sudo apt install'
    alias update='sudo apt update'
    alias upgrade='sudo apt upgrade'
    alias remove='sudo apt remove'
    alias search='apt search'
fi
alias fixdpkg='sudo dpkg --configure -a'
alias please='sudo'

# -----------------------------------------------------------------------------
#  Editors & Utilities
# -----------------------------------------------------------------------------
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias lvim='NVIM_APPNAME=lazyvim nvim'

alias cls='clear'
alias c='clear'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias weather='curl wttr.in'
alias json='python3 -m json.tool'

if command -v wl-copy >/dev/null; then
    alias clip='wl-copy'; alias paste='wl-paste'
else
    alias clip='xclip -selection clipboard'; alias paste='xclip -o -selection clipboard'
fi

alias reload='source ~/.zshrc'
alias restart='exec zsh'

# -----------------------------------------------------------------------------
#  Git Shortcuts
# -----------------------------------------------------------------------------
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --decorate'
alias gcl='git clone'
alias gp='git push'
alias gpl='git pull'
alias gsw='git switch'
alias gundo='git restore'

# -----------------------------------------------------------------------------
#  Gemini CLI Enhancements
# -----------------------------------------------------------------------------
alias gem='cd ~/Documents/gemini && gemini'
alias gemy='cd ~/Documents/gemini && gemini --approval-mode yolo'
alias gemp='cd ~/Documents/gemini && gemini --approval-mode plan'
alias gems='cd ~/Documents/gemini && gemini --sandbox'

