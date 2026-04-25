function wall
    if test (count $argv) -eq 0
        caelestia wallpaper -r
    else
        caelestia wallpaper $argv
    end
    
    # Sync kitty theme
    python3 ~/.local/bin/caelestia-to-kitty.py
    
    # Live reload all kitty instances
    # We use kitty @ set-colors to push the new theme
    if test -S /tmp/mykitty-shared
        kitty @ --to unix:/tmp/mykitty-shared set-colors -a "~/.config/kitty/current-theme.conf"
    end
end
