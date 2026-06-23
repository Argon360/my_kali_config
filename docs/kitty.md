
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
| Ctrl+Alt+H | Horizontal split |
| Ctrl+Alt+V | Vertical split |

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
