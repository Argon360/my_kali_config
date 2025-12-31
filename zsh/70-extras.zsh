
# -----------------------------------------------------------------------------
# Extras
# -----------------------------------------------------------------------------

if command -v thefuck >/dev/null; then
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias FUCK)"
fi

if command -v fastfetch >/dev/null; then
  fastfetch
fi
