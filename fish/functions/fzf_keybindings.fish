# -------------------------------
# fzf – Single Source of Truth
# -------------------------------

# File / project search
bind \cf fzf-file-widget
bind -M insert \cf fzf-file-widget

# Command history
bind \cr fzf-history-widget
bind -M insert \cr fzf-history-widget

# Directory jump (custom, deterministic)
bind \cd __fzf_cd
bind -M insert \cd __fzf_cd

# Process kill (custom, deterministic)
bind \ck __fzf_kill
bind -M insert \ck __fzf_kill
