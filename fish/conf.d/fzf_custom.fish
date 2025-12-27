# =============================================================================
#  FZF Custom Community Shortcuts
#  Automatically loaded by Fish
# =============================================================================

# ----------------------------------------------------------------------------- 
#  Process Management
# ----------------------------------------------------------------------------- 
# fkill - find and kill a process
function fkill
    set -l pid (ps -ef | sed 1d | fzf -m --header='[kill:tab] Select process(es) to kill' | awk '{print $2}')
    if test -n "$pid"
        echo $pid | xargs kill -9
    end
end

# ----------------------------------------------------------------------------- 
#  Git Integration
# ----------------------------------------------------------------------------- 
# fco - checkout git branch/tag
function fco
    set -l tags (git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    set -l heads (git branch --all | grep -v HEAD |             sed "s/.* //"    | sed "s#remotes/[^/]*/##" | sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
    set -l target (echo "$tags\n$heads" |             fzf --no-hscroll --ansi +m -d "\t" -n 2) || return
    set target (echo "$target" | awk '{print $2}')
    git checkout "$target"
end

# fgl - git log browser
function fgl
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv | \
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 | \
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
            FZF-EOF"
end

# ----------------------------------------------------------------------------- 
#  System & Navigation
# ----------------------------------------------------------------------------- 
# fssh - search ssh hosts and connect
function fssh
    set -l hosts (cat ~/.ssh/config ~/.ssh/known_hosts 2> /dev/null | grep -iE '^host ' | awk '{print $2}' | sort -u | fzf)
    if test -n "$hosts"
        ssh "$hosts"
    end
end

# fenv - search environment variables
function fenv
    env | fzf
end

# fman - search man pages
function fman
    man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
end

# fip - get IP address of interface
function fip
    ifconfig | grep "inet " | fzf | awk '{print $2}'
end

# ----------------------------------------------------------------------------- 
#  Default FZF Widget Customizations (Previews & Options)
# ----------------------------------------------------------------------------- 

# Use fd (faster, respects .gitignore) for the default source
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
end

# Options:
# - Reverse layout (top-down)
# - Border
# - Previews
set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --info=inline"

# CTRL-T: Preview files with 'bat' (syntax highlighting)
if type -q bat
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
else
    set -gx FZF_CTRL_T_OPTS "--preview 'head -n 100 {}'"
end

# ALT-C: Preview directory tree with 'eza'
if type -q eza
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"
else
    set -gx FZF_ALT_C_OPTS "--preview 'tree -C {} | head -200'"
end

# CTRL-R: formatting
set -gx FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
