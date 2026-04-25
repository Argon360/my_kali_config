import json
import os

scheme_path = os.path.expanduser("~/.local/state/caelestia/scheme.json")
kitty_theme_path = os.path.expanduser("~/.config/kitty/current-theme.conf")

def format_color(c):
    if not c:
        return None
    if not c.startswith("#"):
        return f"#{c}"
    return c

with open(scheme_path, 'r') as f:
    data = json.load(f)

colours = data.get('colours', {})

with open(kitty_theme_path, 'w') as f:
    # Basic colors
    f.write(f"background {format_color(colours.get('background', '#000000'))}\n")
    f.write(f"foreground {format_color(colours.get('text', '#ffffff'))}\n")
    f.write(f"cursor {format_color(colours.get('text', '#ffffff'))}\n")
    f.write(f"selection_background {format_color(colours.get('primary', '#666666'))}\n")
    f.write(f"selection_foreground {format_color(colours.get('onSurface', '#000000'))}\n")

    # ANSI colors
    for i in range(16):
        key = f"term{i}"
        if key in colours:
            f.write(f"color{i} {format_color(colours[key])}\n")

print(f"Updated {kitty_theme_path}")
