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
#  File System & Navigation (eza, dust)
# -----------------------------------------------------------------------------
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --color=always --icons=always'
    alias ll='eza -l --group-directories-first --color=always --icons'
    alias la='eza -la --group-directories-first --color=always --icons'
    alias lt='eza --tree --level=3 --color=always --icons'
fi

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

# Maintenance
alias sysup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias fixdpkg='sudo dpkg --configure -a'
alias please='sudo'

# Package Management
alias install='sudo apt install'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias remove='sudo apt remove'
alias search='apt search'

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
alias gp='git push'
alias gpl='git pull'
alias gsw='git switch'
alias gundo='git restore'

# -----------------------------------------------------------------------------
#  Todoist CLI - Core Integrations
# -----------------------------------------------------------------------------
alias todo='todoist-cli'
alias td='todoist-cli'
alias tdm='tdm'
alias tds='todoist-cli sync'
alias tdq='todoist-cli quick'

# Formatted Lists (using custom todoist-pretty-list script)
alias tdl='todoist-pretty-list'
alias tdt='todoist-pretty-list --filter "today"'
alias tdn='todoist-pretty-list --filter "due before: $(date -d \"+8 days\" +%m/%d/%Y)"'

# Interactive Add Task
unalias tda 2>/dev/null
tda() {
    echo -n "Task: "; read content
    [[ -z "$content" ]] && { echo "Cancelled."; return; }

    local project_name=""
    if command -v fzf >/dev/null; then
        local proj_line=$(todoist-cli projects | fzf --height 40% --layout reverse --header "Select Project (Esc to skip)")
        [[ -n "$proj_line" ]] && project_name=$(echo "$proj_line" | cut -d' ' -f2-)
    fi

    echo -n "Due (today, tom, etc): "; read due
    echo -n "Priority (1-4): "; read prio

    local cmd=("todoist-cli" "add")
    [[ -n "$project_name" ]] && cmd+=("--project-name" "${project_name#\#}")
    [[ -n "$due" ]] && cmd+=("-d" "$due")
    [[ -n "$prio" ]] && cmd+=("-p" "$prio")
    cmd+=("$content")

    echo "Adding task..."
    "${cmd[@]}" && todoist-cli sync
}

# Interactive Close Task (FZF)
unalias tdc 2>/dev/null
tdc() {
    local task_line=$(todoist-cli --csv list | sed 's/,,/,No Date,/g' | column -t -s ',' | fzf --header "Select task to CLOSE" --height 40% --layout reverse)
    if [[ -n "$task_line" ]]; then
        local task_id=$(echo "$task_line" | awk '{print $1}')
        echo "Closing task: $(echo "$task_line" | awk '{$1=""; print $0}')"
        todoist-cli close "$task_id" && todoist-cli sync
    else
        echo "Cancelled."
    fi
}

# Interactive Delete Task (FZF)
unalias tdd 2>/dev/null
tdd() {
    local task_line=$(todoist-cli --csv list | sed 's/,,/,No Date,/g' | column -t -s ',' | fzf --header "Select task to DELETE" --height 40% --layout reverse)
    if [[ -n "$task_line" ]]; then
        local task_id=$(echo "$task_line" | awk '{print $1}')
        echo "Deleting: $(echo "$task_line" | awk '{$1=""; print $0}')"
        echo -n "Are you sure? [y/N] "; read confirm
        [[ "$confirm" == "y" ]] && todoist-cli delete "$task_id" && todoist-cli sync
    else
        echo "Cancelled."
    fi
}

# Interactive Modify Task (FZF)
unalias tdm 2>/dev/null
tdm() {
    local task_line=$(todoist-cli --csv list | sed 's/,,/,No Date,/g' | column -t -s ',' | fzf --header "Select task to MODIFY" --height 40% --layout reverse)
    if [[ -n "$task_line" ]]; then
        local task_id=$(echo "$task_line" | awk '{print $1}')
        echo "Selected: $(echo "$task_line" | awk '{$1=""; print $0}')"
        
        echo -n "New Content (leave blank to keep): "; read new_content
        echo -n "New Date (today, tom, etc. - leave blank to keep): "; read new_date
        echo -n "New Priority (1-4 - leave blank to keep): "; read new_prio

        local cmd=("todoist-cli" "modify")
        [[ -n "$new_content" ]] && cmd+=("--content" "$new_content")
        [[ -n "$new_date" ]] && cmd+=("--date" "$new_date")
        [[ -n "$new_prio" ]] && cmd+=("--priority" "$new_prio")
        cmd+=("$task_id")

        if [[ ${#cmd[@]} -gt 3 ]]; then
            echo "Executing: ${cmd[*]}"
            echo -n "Confirm modification? [y/N] "; read confirm
            if [[ "$confirm" == "y" ]]; then
                "${cmd[@]}" && todoist-cli sync
            else
                echo "Cancelled."
            fi
        else
            echo "No changes specified."
        fi
    else
        echo "Cancelled."
    fi
}

# -----------------------------------------------------------------------------
#  AI & Ollama Helpers
# -----------------------------------------------------------------------------
function run_ollama_model() {
    local model_name=$1
    if ! command -v ollama &> /dev/null; then
        echo "Ollama not found. Installing..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi
    ollama list | grep -q "^${model_name%:*}" || ollama pull "$model_name"
    ollama run "$model_name"
}

alias chat-whiterabbit='run_ollama_model "jimscard/whiterabbit-neo"'
alias chat-deepseek='run_ollama_model "deepseek-coder-v2:16b-lite-instruct-q4_K_M"'
alias chat-hermes3='run_ollama_model "hermes3"'
