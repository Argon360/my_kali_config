# -----------------------------------------------------------------------------
# Fish-like Options
# -----------------------------------------------------------------------------

# Navigation
setopt AUTO_CD              # Type folder name to cd into it (like Fish)
setopt AUTO_PUSHD           # Push visited dirs to stack
setopt PUSHD_IGNORE_DUPS    # Don't push dupes
setopt PUSHD_SILENT         # Don't print stack after cd

# Correction
setopt CORRECT              # Suggest corrections for commands (e.g., 'sl' -> 'ls')
# setopt CORRECT_ALL        # Suggest corrections for arguments (can be annoying)

# History
setopt HIST_IGNORE_SPACE    # Don't save commands starting with space
setopt APPEND_HISTORY       # Append to history file immediately
setopt SHARE_HISTORY        # Share history between terminals
setopt EXTENDED_HISTORY     # Save timestamps

# UI
setopt NO_BEEP              # Silence the beep!
setopt INTERACTIVE_COMMENTS # Allow comments (#) in interactive shell
