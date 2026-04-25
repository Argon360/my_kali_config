function wall() {
    if [ $# -eq 0 ]; then
        caelestia wallpaper -r
    else
        caelestia wallpaper "$@"
    fi
    python3 ~/.local/bin/caelestia-to-kitty.py
    if [ -S /tmp/mykitty-shared ]; then
        kitty @ --to unix:/tmp/mykitty-shared set-colors -a "~/.config/kitty/current-theme.conf"
    fi
}
