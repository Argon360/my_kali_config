
# -----------------------------------------------------------------------------
# Environment Variables & PATH
# -----------------------------------------------------------------------------

# Linuxbrew
if [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Go
export PATH="$PATH:$HOME/go/bin"
