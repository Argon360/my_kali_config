# ======================================================
#  Fish Shell Configuration
#  Designed for Pop!_OS / Debian / Ubuntu + Kitty
# ======================================================

# -----------------------------
#  Disable default greeting
# -----------------------------
set -g fish_greeting

# -----------------------------
#  PATH fixes (cargo + brew)
# -----------------------------
if test -d /home/linuxbrew/.linuxbrew/bin
    set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
end

set -gx PATH $PATH ~/go/bin


# -----------------------------
#  Atuin (History Manager)
# -----------------------------
if type -q atuin
    atuin init fish | source
end

# -----------------------------
#  Aliases (Modern replacements)
# -----------------------------

# eza = better ls
alias ls='eza --group-directories-first --color=always --icons'
alias ll='eza -l --group-directories-first --color=always --icons'
alias la='eza -la --group-directories-first --color=always --icons'
alias lt='eza --tree --level=3 --color=always --icons'

# btop = better top
alias top="btop --utf-force"

# Dust = better du
alias du="dust"
alias duh="dust -H"

# -----------------------------
#  System Update Shortcuts
# -----------------------------
alias sysup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean"
alias fixdpkg="sudo dpkg --configure -a"

# -----------------------------
#  Navigation Shortcuts
# -----------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias please='sudo'

# -----------------------------
#  Tools & Utilities
# -----------------------------
alias cls="clear"
alias c="clear"

# -----------------------------
#  Starship Prompt
# -----------------------------
if type -q starship
    starship init fish | source
end

# -----------------------------
#  Fastfetch on startup (optional)
# -----------------------------
fastfetch

# -----------------------------
#  Reload things
# -----------------------------
# Reload Fish shell (reloads config.fish)
alias reload='source ~/.config/fish/config.fish'

# Reload Fastfetch config preview
alias ffpreview='fastfetch --config ~/.config/fastfetch/config.jsonc'

# Restart Kitty completely
alias kreload='killall kitty; kitty &; disown'

# Reload the terminal font cache
alias fontreload='fc-cache -fv'

# Restart the current shell session (clean)
alias restart='exec $SHELL'

# Restart all
alias reloadall='freload; ffpreview; echo "✔ All configs reloaded"'


if status is-interactive
    # Commands to run in interactive sessions can go here
end
