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
    set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
end
set -gx PATH $PATH ~/go/bin

# -----------------------------------------------------------------------------
# fzf Defaults (UX & Performance)
# -----------------------------------------------------------------------------
set -gx FZF_DEFAULT_OPTS "
--height=40%
--layout=reverse
--border
--inline-info
--preview-window=right:60%
"

# -----------------------------------------------------------------------------
#  Interactive Session Configuration
# -----------------------------------------------------------------------------
if status is-interactive

    # --- Tool Initialization ---

    # Starship Prompt
    if type -q starship
        starship init fish | source
    end

    # Atuin (History Manager)
    if type -q atuin
        atuin init fish | source
    end

    # FZF (Fuzzy Finder)
    if type -q fzf
        fzf --fish | source
    end

    # --- Startup Commands ---

    # Fastfetch (System Info)
    if type -q fastfetch
        fastfetch
    end

    # --- Aliases ---

    # File System (Modern replacements)
    alias ls='eza --group-directories-first --color=always --icons'
    alias ll='eza -l --group-directories-first --color=always --icons'
    alias la='eza -la --group-directories-first --color=always --icons'
    alias lt='eza --tree --level=3 --color=always --icons'

    alias du='dust'
    alias duh='dust -H'

    # System Monitoring
    alias top='btop --utf-force'

    # System Maintenance
    alias sysup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean'
    alias fixdpkg='sudo dpkg --configure -a'
    alias please='sudo'

    # Navigation
    alias ..='cd ..'
    alias ...='cd ../..'

    # Git
    alias g='git'
    alias gs='git status'
    alias gl='git log --oneline --graph --decorate'

    # Utilities
    alias cls='clear'
    alias c='clear'

    # Shell Management
    alias reload='source ~/.config/fish/config.fish'
    alias restart='exec $SHELL'
    alias fontreload='fc-cache -fv'

    # App Specific
    alias ffpreview='fastfetch --config ~/.config/fastfetch/config.jsonc'
    alias kreload='killall kitty; kitty &; disown'
    alias reloadall='reload; ffpreview; echo "✔ All configs reloaded"'

    # -----------------------------------------------------------------------------
    #  fzf Key Bindings (Explicit & Predictable)
    # -----------------------------------------------------------------------------

    # Ensure default Fish bindings are loaded
    fish_default_key_bindings

    # Ctrl+F → File search
    bind \cf fzf-file-widget

    # Ctrl+R → History search
    bind \cr fzf-history-widget

    # Ctrl+D → Directory jump
    function __fzf_cd
        set dir (find . -type d 2>/dev/null | fzf)
        test -n "$dir"; and cd "$dir"
    end
    bind \cd __fzf_cd

    # Ctrl+K → Process selector → kill
    function __fzf_kill
        ps -ef | sed 1d | fzf | awk '{print $2}' | xargs -r kill -9
    end
    bind \ck __fzf_kill
end
