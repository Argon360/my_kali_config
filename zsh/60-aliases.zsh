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
fi

# -----------------------------------------------------------------------------
#  Ported Fish Aliases
# -----------------------------------------------------------------------------

# File System (eza)
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --color=always --icons'
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
alias top='btop --utf-force'
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
alias tdl='todoist-cli list'
alias tda='todoist-cli add'
alias tdc='todoist-cli close'
alias tdd='todoist-cli delete'
alias tds='todoist-cli sync'
alias tdq='todoist-cli quick'
alias tdt='todoist-cli list --filter "today"'
alias tdn='todoist-cli list --filter "7 days"'


# Interactive Todoist
tdnew() {
  echo "New Task"
  echo -n "Title: "; read title
  if [[ -z "$title" ]]; then echo "Cancelled"; return; fi

  local project_name=""
  local project_id=""
  if command -v fzf >/dev/null; then
    echo "Fetching projects..."
    # Get raw CSV line
    local project_line=$(todoist-cli --csv projects | fzf --header "Select Project" --delimiter=, --with-nth=2)
    
    if [[ -n "$project_line" ]]; then
      # Extract ID (Column 1) and Name (Column 2)
      project_id=$(echo "$project_line" | awk -F, '{print $1}')
      project_name=$(echo "$project_line" | awk -F, '{print $2}' | sed 's/^#//')
      echo "Selected Project: $project_name"
    else
      echo "No project selected. Defaulting to Inbox."
    fi
  fi

  local section_name=""
  # Fetch sections if project is selected and jq is available
  if [[ -n "$project_id" ]] && command -v jq >/dev/null; then
    local cache_file="$HOME/.cache/todoist/cache.json"
    if [[ -f "$cache_file" ]]; then
        # Query sections for the specific project_id
        local sections=$(jq -r --arg pid "$project_id" '.sections[] | select(.project_id == $pid) | .name' "$cache_file")
        if [[ -n "$sections" ]]; then
            section_name=$(echo "$sections" | fzf --header "Select Section")
            [[ -n "$section_name" ]] && echo "Selected Section: $section_name"
        fi
    fi
  fi

  echo -n "Priority (1-4, Default 1): "; read priority
  [[ -z "$priority" ]] && priority=1

  echo -n "Date: "; read due

  if [[ -n "$section_name" ]]; then
      # Use quick add for sections as 'add' command might not support it
      # Format: "Title #Project / Section pPriority Date"
      local quick_str="$title"
      [[ -n "$project_name" ]] && quick_str+=" #$project_name / $section_name"
      [[ -n "$priority" ]] && quick_str+=" p$priority"
      [[ -n "$due" ]] && quick_str+=" $due"
      
      echo "Adding task via Quick Add: $quick_str"
      todoist-cli quick "$quick_str"
  else
      # Use standard add
      local args=()
      [[ -n "$project_name" ]] && args+=(--project-name "$project_name")
      [[ -n "$priority" ]] && args+=(--priority "$priority")
      [[ -n "$due" ]] && args+=(--date "$due")

      echo "Adding task: $title"
      todoist-cli add "${args[@]}" "$title"
  fi
}
