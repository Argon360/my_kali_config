
# -----------------------------------------------------------------------------
# Extras
# -----------------------------------------------------------------------------

# EVE-NG Integration: Force Kitty terminal (Tabbed mode)
export OVERRIDE_TERMINAL_CMD="/home/argon/.local/bin/eve-ng-terminal"

if command -v thefuck >/dev/null; then
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias FUCK)"
fi
