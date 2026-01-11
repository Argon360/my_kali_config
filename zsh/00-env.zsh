
# -----------------------------------------------------------------------------
# Environment Variables & PATH
# -----------------------------------------------------------------------------

# Automatically remove duplicates from these arrays
typeset -U path PATH
typeset -U fpath FPATH

# Linuxbrew
if [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi
