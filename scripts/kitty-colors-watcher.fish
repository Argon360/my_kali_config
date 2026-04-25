#!/usr/bin/env fish

set SCHEME_FILE "$HOME/.local/state/caelestia/scheme.json"

log "Starting Kitty dynamic theme watcher..."

# Initial sync
python3 ~/.local/bin/caelestia-to-kitty.py
if test -S /tmp/mykitty-shared
    kitty @ --to unix:/tmp/mykitty-shared set-colors -a "~/.config/kitty/current-theme.conf"
end

# Watch for changes using inotifywait
while inotifywait -e close_write $SCHEME_FILE
    log "Scheme changed, updating kitty..."
    python3 ~/.local/bin/caelestia-to-kitty.py
    if test -S /tmp/mykitty-shared
        kitty @ --to unix:/tmp/mykitty-shared set-colors -a "~/.config/kitty/current-theme.conf"
    end
end
