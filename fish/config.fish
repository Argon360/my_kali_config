# =============================================================================
#  Fish Shell Configuration
#  Environment: Linux (Pop!_OS / Debian / Ubuntu / Kali)
# =============================================================================

# -----------------------------------------------------------------------------
#  Environment Variables & Path
# -----------------------------------------------------------------------------

# Disable default greeting
set -g fish_greeting

# Path Configuration
if test -d /home/linuxbrew/.linuxbrew/bin
    fish_add_path /home/linuxbrew/.linuxbrew/bin
end

# Append Go bin to path
fish_add_path --path --append ~/go/bin

# Default editors
set -Ux EDITOR nvim
set -Ux VISUAL nvim

# -----------------------------------------------------------------------------
#  Integration Configuration (Bat, Delta, FZF)
# -----------------------------------------------------------------------------

# Bat (Better Cat)
if type -q bat
    set -gx BAT_THEME Dracula
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    alias cat='bat'
end

# Delta (Better Diff)
if type -q delta
    set -gx GIT_PAGER delta
end

# FZF Defaults
set -gx FZF_DEFAULT_OPTS "
--height=40%
--layout=reverse
--border
--inline-info
--preview 'bat --style=numbers --color=always --line-range :500 {}'
--preview-window=right:60%
"

# -----------------------------------------------------------------------------
#  Interactive Session Configuration
# -----------------------------------------------------------------------------
if status is-interactive

    # -------------------------------------------------------------------------
    #  Tool Initialization
    # -------------------------------------------------------------------------

    if type -q starship
        starship init fish | source
    end

    if type -q atuin
        atuin init fish | source
    end

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source
        fish_default_key_bindings

        bind \cf fzf-file-widget
        bind \cr fzf-history-widget

        function __fzf_cd
            set dir (find . -type d 2>/dev/null | fzf)
            test -n "$dir"; and cd "$dir"
        end
        bind \cd __fzf_cd

        function __fzf_kill
            ps -ef | sed 1d | fzf | awk '{print $2}' | xargs -r kill -9
        end
        bind \ck __fzf_kill
    end

    # -------------------------------------------------------------------------
    #  Startup Commands
    # -------------------------------------------------------------------------

    if type -q fastfetch
        fastfetch
    end

    # -------------------------------------------------------------------------
    #  Aliases
    # -------------------------------------------------------------------------

    # -----------------------------
    # File System
    # -----------------------------
    alias ls='eza --group-directories-first --color=always --icons'
    alias ll='eza -l --group-directories-first --color=always --icons'
    alias la='eza -la --group-directories-first --color=always --icons'
    alias lt='eza --tree --level=3 --color=always --icons'
    alias tree1='eza --tree --level=1 --icons'
    alias tree2='eza --tree --level=2 --icons'

    alias x='unp'
    alias du='dust'
    alias duh='dust -H'
    alias duh1='du -h --max-depth=1 | sort -hr'
    alias dfh='df -hT'
    alias fcount='find . -type f | wc -l'
    alias dcount='find . -type d | wc -l'

    # -----------------------------
    # System / Infra
    # -----------------------------
    alias top='btop --utf-force'
    alias mem='free -h'
    alias cpu='lscpu | less'
    alias ipinfo='ip -c a'
    alias routes='ip route'
    alias ports='ss -tulnp'
    alias myip='curl -s ifconfig.me'
    alias dnscheck='resolvectl status || systemd-resolve --status'

    # -----------------------------
    # System Maintenance
    # -----------------------------
    alias sysup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean'
    alias fixdpkg='sudo dpkg --configure -a'
    alias please='sudo'

    # -----------------------------
    # Navigation
    # -----------------------------
    alias ..='cd ..'
    alias ...='cd ../..'
    alias home='cd ~'

    # -----------------------------
    # Git (Professional & Explicit)
    # -----------------------------
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
    alias gps='git push --set-upstream origin (git branch --show-current)'

    alias gunstage='git restore --staged'
    alias gundo='git restore'
    alias grs='git reset'
    alias gsoft='git reset --soft HEAD~1'
    alias grsh='git reset --hard'

    alias gclean='git branch --merged | grep -v "\*" | grep -v main | xargs -r git branch -d'

    alias gsm='git submodule'
    alias gsmi='git submodule update --init --recursive'
    alias gsmu='git submodule update --remote'

    # -----------------------------
    # Neovim / Dev
    # -----------------------------
    alias nv='nvim'
    alias nvdiff='nvim -d'
    alias nvlog='nvim +"term git log --oneline --graph --decorate --all"'
    alias scratch='nvim +"enew"'
    alias cf='nvim ~/.config/fish/config.fish'
    alias cn='nvim ~/.config/nvim'

    # -----------------------------
    # Utilities / QoL
    # -----------------------------
    alias cls='clear'
    alias c='clear'
    alias now='date +"%Y-%m-%d %H:%M:%S"'
    alias week='date +"Week %V, %Y"'
    alias weather='curl wttr.in'
    alias genpass='openssl rand -base64 24'
    alias json='python -m json.tool'

    alias clip='wl-copy 2>/dev/null || xclip -selection clipboard'
    alias paste='wl-paste 2>/dev/null || xclip -o -selection clipboard'

    # -----------------------------
    # Shell Management
    # -----------------------------
    alias reload='source ~/.config/fish/config.fish'
    alias restart='exec $SHELL'
    alias fontreload='fc-cache -fv'
    alias ffpreview='fastfetch --config ~/.config/fastfetch/config.jsonc'
    alias kreload='killall kitty; kitty &; disown'
    alias reloadall='reload; ffpreview; echo "✔ All configs reloaded"'

    # -------------------------------------------------------------------------
    #  Functions (High-Leverage Productivity)
    # -------------------------------------------------------------------------

    function workstart
        echo "🔍 Repository overview"
        git status -sb
        echo
        git log --oneline --decorate -5
    end

    function workend
        echo "📦 Final status check"
        git status
        echo
        read -P "Everything committed? (y/N) " confirm
        test "$confirm" = y; or echo "⚠️  You still have work pending"
    end

    function gpushsafe
        echo "📌 Branch: "(git branch --show-current)
        git status -sb
        read -P "Push current branch? (y/N) " confirm
        test "$confirm" = y; or begin
            echo "❌ Push cancelled"
            return
        end
        git push
    end

    function gcommit
        git status --short
        if not git diff --cached --quiet
            git commit
        else
            echo "❌ Nothing staged. Use ga / gaa first."
        end
    end

    function greset-hard-safe
        echo "⚠️  This will DISCARD all local changes"
        git status
        read -P "Type RESET to continue: " confirm
        test "$confirm" = RESET; or begin
            echo "❌ Reset cancelled"
            return
        end
        git reset --hard
    end

    function weeklyreset
        echo "🧹 Weekly hygiene"
        sysup
        git fetch --prune
        git branch --merged | grep -v "\*" | grep -v main | xargs -r git branch -d
        echo "✅ Done"
    end

    # -------------------------------------------------------------------------
    #  TheFuck
    # -------------------------------------------------------------------------
    if type -q thefuck
        thefuck --alias | source
        thefuck --alias FUCK | source
    end

end
