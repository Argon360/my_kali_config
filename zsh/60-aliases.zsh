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
  zle -N fzf-cd-widget; bindkey '^[c' fzf-cd-widget

  fzf-kill-widget() {
      local pid
      if [ "$UID" != "0" ]; then
          pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
      else
          pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
      fi
      if [ "x$pid" != "x" ]; then
          echo $pid | xargs kill -${1:-9}
      fi
      zle reset-prompt
  }
  zle -N fzf-kill-widget; bindkey '^[k' fzf-kill-widget
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
command -v btop >/dev/null && alias top='btop --utf-force'
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
alias kreload='killall kitty; kitty &; disown'alias lg="lazygit"
