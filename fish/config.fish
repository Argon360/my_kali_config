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

# -----------------------------------------------------------------------------
#  Integration Configuration (Bat, Delta, FZF)
# -----------------------------------------------------------------------------

# Bat (Better Cat)
if type -q bat
    set -gx BAT_THEME Dracula # Optional: Adjust to preference
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    alias cat='bat'
end

# Delta (Better Diff)
if type -q delta
    set -gx GIT_PAGER delta
end

# FZF Defaults (UX & Performance)
# Integrated with bat for previewing files
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

    # --- Tool Initialization (Optimized) ---

    # Starship Prompt
    if type -q starship
        starship init fish | source
    end

    # Atuin (History Manager)
    if type -q atuin
        atuin init fish | source
    end

    # Zoxide (Smarter cd)
    if type -q zoxide
        zoxide init fish | source
    end

    # FZF (Fuzzy Finder)
    if type -q fzf
        fzf --fish | source

        # -----------------------------------------------------------------------------
        #  fzf Key Bindings
        # -----------------------------------------------------------------------------

        fish_default_key_bindings

        # Ctrl+F → File search (uses fd if available, falls back to find)
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
    #alias rm='shred -u'
    #alias rmd='/bin/rm -r' # Recursive delete (shred fails on dirs)

    alias x='unp' # Extract archive

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
    alias home='cd ~'

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

    # TheFuck
    if type -q thefuck
        thefuck --alias | source
        thefuck --alias FUCK | source
    end

end
