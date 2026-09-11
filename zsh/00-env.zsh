
# -----------------------------------------------------------------------------
# Environment Variables & PATH
# -----------------------------------------------------------------------------

# Default terminal
export TERMINAL="kitty"

# Linuxbrew
if [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Go
export PATH="$PATH:$HOME/go/bin"

