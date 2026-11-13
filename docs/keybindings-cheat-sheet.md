# ⌨️ Keybinding Cheat Sheet

This document is a rapid cheat sheet for all keybindings used in this configuration.
For the complete guide with Wayland gestures and KWin actions, see [SHORTCUTS.md](../SHORTCUTS.md).

It covers:
- Terminal UI (Kitty 0.50+)
- KWin Window Tiling & Workspaces
- Shell behavior (Fish / Zsh)
- FZF integrations
- Routing rules and ownership

No undocumented shortcuts exist.

---

## 🧠 Keybinding Philosophy

| Modifier | Owner | Purpose |
|--------|------|--------|
| `Meta` | KWin | Desktop & workspace navigation |
| `Meta + Alt` | KWin | Window tiling & moving to desktops |
| `Ctrl` | fish | Shell behavior |
| `Ctrl + Alt` | kitty | Route actions to shell |
| `Ctrl + Shift` | kitty | UI / visual controls / kittens |
| `Alt + 1..9` | kitty | Tab jumping |

> **Paste is sacred**
- Paste is always available via `Ctrl + Shift + V` and `Ctrl + V`
- Never rebound or hijacked by sub-processes

---

## 🪟 KWin Desktop & Window Management

| Key | Action |
|----|------|
| `Meta + Alt + ←` | Quick Tile Left (50%) |
| `Meta + Alt + →` | Quick Tile Right (50%) |
| `Meta + Alt + ↑` | Quick Tile Top (50%) |
| `Meta + Alt + ↓` | Quick Tile Bottom (50%) |
| `Meta + 1..9` | Switch to Desktop 1–9 |
| `Meta + Alt + 1..9` | Move Window to Desktop 1–9 |
| `Meta + W` | Toggle Desktop Overview |
| `Alt + Tab` | Walk Through Windows |

---

## 🖥️ Kitty — UI & Window Management

### Tabs

| Key | Action |
|----|------|
| `Ctrl + Shift + →` / `Ctrl + Tab` | Next tab |
| `Ctrl + Shift + ←` / `Ctrl + Shift + Tab` | Previous tab |
| `Ctrl + Shift + T` / `Ctrl + T` | New tab |
| `Ctrl + Shift + W` / `Ctrl + W` | Close tab |
| `Alt + 1..9` | Jump directly to tab 1–9 |
| `Ctrl + Shift + D` | Detach tab |

---

### Windows & Layouts

| Key | Action |
|----|------|
| `Ctrl + Shift + H` | Horizontal split |
| `Ctrl + Shift + V` | Vertical split |
| `Ctrl + Alt + N` | New window |
| `Ctrl + Alt + Q` | Close window |
| `Ctrl + Shift + L` | Next layout |
| `Ctrl + Shift + Z` | Zoom layout (fullscreen split) |
| `Ctrl + Alt + Enter` | Toggle fullscreen |
| `Ctrl + Shift + M` | Detach window |

---

### Modern Kittens (Kitty 0.42+)

| Key | Action |
|----|------|
| `Ctrl + Shift + K` | Command Palette (Search all actions) |
| `Ctrl + Shift + F` | Interactive File Picker (`choose-files`) |
| `Ctrl + Shift + B` | Broadcast keystrokes to all panes |
| `Ctrl + Shift + R` | Interactive window split resizing |
| `Ctrl + Shift + G` | Drag & Drop terminal files (`dnd`) |
| `Ctrl + Shift + E` | Hint mode (URLs) |
| `Ctrl + Shift + P` | Hint mode (Paths) |
| `Ctrl + Shift + Y` | Hint mode (Git SHA hashes) |

---

### Clipboard

| Key | Action |
|----|------|
| `Ctrl + C` | Copy or Interrupt |
| `Ctrl + V` | Paste from clipboard |
| `Ctrl + Shift + C` | Copy |
| `Ctrl + Shift + V` | Paste |

---

### Font Size

| Key | Action |
|----|------|
| `Ctrl + +` | Increase font |
| `Ctrl + -` | Decrease font |
| `Ctrl + 0` | Reset font size |

---

### Background Opacity

| Key | Opacity |
|----|---------|
| `Ctrl + Shift + 1` | 100% |
| `Ctrl + Shift + 2` | 90% |
| `Ctrl + Shift + 3` | 80% |
| `Ctrl + Shift + 4` | 70% |
| `Ctrl + Shift + 5` | 60% |
| `Ctrl + Shift + 6` | 50% |
| `Ctrl + Shift + 7` | 40% |
| `Ctrl + Shift + 8` | 30% |
| `Ctrl + Shift + 9` | 20% |
| `Ctrl + Shift + 0` | 10% |
| `Ctrl + Shift + O` | Reset to default (75%) |

---

## 🐟 Fish / Zsh — Shell Behavior

| Key | Action |
|----|------|
| `Ctrl + A` | Start of line |
| `Ctrl + E` | End of line |
| `Ctrl + U` | Clear line before cursor |
| `Ctrl + K` | Clear line after cursor |
| `Ctrl + W` | Delete word backward |
| `Ctrl + L` | Clear screen |

---

## 🔍 fzf — End-to-End Flow

These actions are triggered via kitty routing:

| Physical Key | Routed As | Final Action |
|------------|----------|--------------|
| `Ctrl + Alt + M` | `\cg` | Unified FZF Menu |
| `Ctrl + Alt + P` | `\cf` | File search |
| `Ctrl + Alt + H` | `\cr` | History search |
| `Ctrl + Alt + J` | `\cd` | Directory jump (Zoxide) |
| `Ctrl + Alt + X` | `\ck` | Process kill |

---

## 🖐️ Wayland Touchpad Gestures

| Gesture | Action |
|---------|--------|
| **3-Finger Horizontal Swipe** | Window Switcher (<kbd>Alt</kbd>+<kbd>Tab</kbd>) |
| **4-Finger Horizontal Swipe** | Slide Virtual Desktops |
| **4-Finger Vertical Swipe** | Toggle Overview |
| **1-Finger Tap + Drag** | Drag Lock |
| **2-Finger Scroll** | Smooth Kinetic Scrolling |

---

## 📌 Summary

- Every shortcut is intentional
- Every binding is documented
- No conflicting overlays
- See [SHORTCUTS.md](../SHORTCUTS.md) for detailed operational notes.
