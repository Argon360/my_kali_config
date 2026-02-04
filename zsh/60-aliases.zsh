# -----------------------------------------------------------------------------
# FZF Key Bindings (Preserved)
# -----------------------------------------------------------------------------
if command -v fzf >/dev/null; then
  # Debian/Kali specific paths
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
  
  # Also check standard paths (fallback)
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  
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
#  Ported Fish Aliases
# -----------------------------------------------------------------------------

# File System (eza)
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --color=always --icons=always'
  alias ll='eza -l --group-directories-first --color=always --icons'
  alias la='eza -la --group-directories-first --color=always --icons'
  alias lt='eza --tree --level=3 --color=always --icons'
  alias tree1='eza --tree --level=1 --icons'
  alias tree2='eza --tree --level=2 --icons'
fi

# Modern Utils
alias x='unp'
command -v dust >/dev/null && alias du='dust' && alias duh='dust -H'
alias duh1='du -h --max-depth=1 | sort -hr'
alias dfh='df -hT'
alias fcount='find . -type f | wc -l'
alias dcount='find . -type d | wc -l'

# System / Infra
alias top='btop --force-utf'
alias mem='free -h'
alias cpu='lscpu | less'
alias ipinfo='ip -c a'
alias routes='ip route'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'
alias dnscheck='resolvectl status || systemd-resolve --status'

# Maintenance
alias sysup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias fixdpkg='sudo dpkg --configure -a'
alias please='sudo'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'

# -----------------------------------------------------------------------------
#  Editors
# -----------------------------------------------------------------------------
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias lvim='NVIM_APPNAME=lazyvim nvim'

# -----------------------------------------------------------------------------
#  Git Aliases
# -----------------------------------------------------------------------------
alias gs='git status'
alias gss='git status -sb'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gwip='git add . && git commit -m "wip: checkpoint"'

alias gl='git log --oneline --decorate'
alias glg='git log --oneline --graph --decorate --all'
alias glast='git log -1 --stat'

alias gd='git diff'
alias gds='git diff --staged'
alias gshow='git show'
alias gblame='git blame -w -M -C'

alias gb='git branch'
alias gba='git branch -a'
alias gbranch='git branch --show-current'
alias gsw='git switch'
alias gswc='git switch -c'

alias gm='git merge'
alias grb='git rebase'
alias grbi='git rebase -i'

alias gf='git fetch'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gp='git push'
alias gps='git push --set-upstream origin $(git branch --show-current)'

alias gunstage='git restore --staged'
alias gundo='git restore'
alias grs='git reset'
alias gsoft='git reset --soft HEAD~1'
alias grsh='git reset --hard'
alias gclean='git branch --merged | grep -v "\*" | grep -v main | xargs -r git branch -d'

alias gsm='git submodule'
alias gsmi='git submodule update --init --recursive'
alias gsmu='git submodule update --remote'

# -----------------------------------------------------------------------------
#  Tool Integrations
# -----------------------------------------------------------------------------
if command -v batcat >/dev/null; then
    alias bat='batcat'; alias cat='batcat'
    export BAT_THEME="Dracula"
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
elif command -v bat >/dev/null; then
    export BAT_THEME="Dracula"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    alias cat='bat'
fi

if command -v delta >/dev/null; then export GIT_PAGER='delta'; fi

# -----------------------------------------------------------------------------
#  Utilities / QoL
# -----------------------------------------------------------------------------
alias cls='clear'; alias c='clear'
alias now='date +"%Y-%m-%d %H:%M:%S"'; alias week='date +"Week %V, %Y"'
alias weather='curl wttr.in'; alias genpass='openssl rand -base64 24'
alias json='python3 -m json.tool'

if command -v wl-copy >/dev/null; then
    alias clip='wl-copy'; alias paste='wl-paste'
else
    alias clip='xclip -selection clipboard'; alias paste='xclip -o -selection clipboard'
fi

alias reload='source ~/.zshrc'; alias restart='exec zsh'
alias kreload='killall kitty; kitty &; disown'

# Todoist CLI
alias todo='todoist-cli'
alias td='todoist-cli'
alias tdl='todoist-pretty-list'
alias tdc='todoist-cli close'
alias tds='todoist-cli sync'
alias tdq='todoist-cli quick'
alias tdt='todoist-pretty-list --filter "today"'
alias tdn='todoist-pretty-list --filter "due before: $(date -d "+8 days" +%m/%d/%Y)"'

# Interactive Add Task (tda)
unalias tda 2>/dev/null
tda() {
  # 1. Task Content
  echo -n "Task: "
  read content
  if [[ -z "$content" ]]; then echo "Cancelled."; return; fi

  # 2. Select Project (Optional)
  local project_id=""
  local project_name=""
  if command -v fzf >/dev/null; then
    # Parse "ID #Name" format
    local proj_line
    proj_line=$(todoist-cli projects | fzf --height 40% --layout reverse --header "Select Project (Esc to skip)" --preview "echo {}")
    
    if [[ -n "$proj_line" ]]; then
      project_id=$(echo "$proj_line" | awk '{print $1}')
      project_name=$(echo "$project_line" | cut -d' ' -f2-)
      echo "Project: $project_name"
    fi
  fi

  # 3. Due Date (Optional)
  echo -n "Due (today, tom, mon, etc): "
  read due

  # 4. Priority (Optional)
  echo -n "Priority (1-4): "
  read prio

  # Construct Command
  local cmd=("todoist-cli" "add")
  [[ -n "$project_name" ]] && cmd+=("--project-name" "${project_name#\#}")
  [[ -n "$due" ]] && cmd+=("-d" "$due")
  [[ -n "$prio" ]] && cmd+=("-p" "$prio")
  cmd+=("$content")

  # Execute
  echo "Adding task..."
  "${cmd[@]}" && todoist-cli sync
}

# Interactive Delete
unalias tdd 2>/dev/null
tdd() {
  if ! command -v fzf >/dev/null; then
    todoist-cli delete "$@"
    return
  fi

  local task_line
  # We format the CSV output into a pretty-spaced list for fzf
  # Column 1 (ID) is kept at the start but we tell fzf to show other columns
  task_line=$(todoist-cli --csv list | sed 's/,,/,No Date,/g' | column -t -s ',' | fzf --header "Select task to DELETE" --height 40% --layout reverse)
  
  if [[ -n "$task_line" ]]; then
    local task_id
    task_id=$(echo "$task_line" | awk '{print $1}')
    
    if [[ -n "$task_id" ]]; then
        echo "Deleting task: $(echo "$task_line" | awk '{$1=""; print $0}')"
        echo -n "Are you sure? [y/N] "; read confirm
        if [[ "$confirm" == "y" ]]; then
            todoist-cli delete "$task_id" && todoist-cli sync
        else
            echo "Cancelled."
        fi
    fi
  else
    echo "Deletion cancelled."
  fi
}


# Package Management
alias install='sudo apt install'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias remove='sudo apt remove'
alias search='apt search'

# -----------------------------------------------------------------------------
#  Ollama (Auto-install & Model Pull)
# -----------------------------------------------------------------------------
function run_ollama_model() {
    local model_name=$1

    # 1. Check if Ollama is installed
    if ! command -v ollama &> /dev/null; then
        echo "Ollama is not installed. Installing now..."
        curl -fsSL https://ollama.com/install.sh | sh
        if [ $? -ne 0 ]; then
            echo "Failed to install Ollama. Please install it manually."
            return 1
        fi
    fi

    # 2. Check if the model is already pulled
    if ! ollama list | grep -q "^${model_name%:*}"; then
        echo "Model '$model_name' not found. Pulling..."
        ollama pull "$model_name"
    fi

    # 3. Run the model
    ollama run "$model_name"
}

alias chat-whiterabbit='run_ollama_model "jimscard/whiterabbit-neo"'
alias chat-deepseek='run_ollama_model "deepseek-coder-v2:16b-lite-instruct-q4_K_M"'
alias chat-hermes3='run_ollama_model "hermes3"'