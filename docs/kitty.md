
# Kitty Terminal Configuration

## Purpose

kitty is responsible for:
- Tabs and windows
- Layouts and splits
- Font rendering
- Clipboard integration
- Routing high-level keybindings to the shell

kitty does **not** implement shell logic.

---

## Fonts & Rendering

- Font: JetBrainsMono Nerd Font
- Size: 11.0
- Ligatures: enabled
- Cursor trail enabled for visibility

---

## Clipboard

| Key | Action |
|----|------|
| Ctrl+Shift+C | Copy |
| Ctrl+Shift+V | Paste |

Paste is intentionally *not* rebound elsewhere.

---

## Keybindings (kitty-owned)

> [!TIP]
> For the complete, unabridged catalog of all 55+ shortcuts, kittens, dynamic opacity profiles, and font controls, see the **[Complete Kitty Keybindings Reference](kitty-keys.md)**.

### Tabs
| Key | Action |
|----|------|
| Ctrl+Shift+→ | Next tab |
| Ctrl+Shift+← | Previous tab |
| Ctrl+Shift+T | New tab |
| Ctrl+Shift+W | Close tab |

### Windows & Layouts
| Key | Action |
|----|------|
| Ctrl+Alt+N | New window |
| Ctrl+Alt+Q | Close window |
| Ctrl+Alt+Enter | Fullscreen |
| Ctrl+Shift+H | Horizontal split |
| Ctrl+Shift+V | Vertical split |
| Ctrl+Shift+L | Next layout |
| Ctrl+Shift+Z | Toggle zoom (stack layout) |

### Modern Kittens & Features (Kitty 0.42–0.50+)
| Key | Action |
|----|------|
| Ctrl+Shift+K | Command Palette |
| Ctrl+Shift+F | Fast Visual File Chooser (`choose-files`) |
| Ctrl+Shift+B | Broadcast Keystrokes to all panes |
| Ctrl+Shift+R | Interactive Window Resizing |
| Ctrl+Shift+G | Terminal Drag & Drop (`dnd`) |
| Ctrl+Shift+E | URL Hints mode |
| Ctrl+Shift+P | Path Hints mode |
| Ctrl+Shift+Y | Hash Hints mode |

---

## Shell Routing

kitty forwards these to fish:

| Key | Sent |
|----|------|
| Ctrl+Alt+P | Ctrl+F |
| Ctrl+Alt+H | Ctrl+R |
| Ctrl+Alt+J | Ctrl+D |
| Ctrl+Alt+X | Ctrl+K |

See `fzf.md`.
