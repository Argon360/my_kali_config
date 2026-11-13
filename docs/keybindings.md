# Keybindings Reference

This document serves as the **Single Source of Truth** for core keybindings in this environment.
For the complete cheat sheet across KWin, Kitty kittens, Touchpad Gestures, and Shell routing, see [SHORTCUTS.md](../SHORTCUTS.md).

---

## 🧭 Navigation & UI (Kitty)

Handled by the terminal emulator (Kitty 0.50+).

| Key | Action |
|-----|--------|
| `Ctrl + Shift + →` / `Ctrl + Tab` | Next Tab |
| `Ctrl + Shift + ←` / `Ctrl + Shift + Tab` | Previous Tab |
| `Ctrl + Shift + T` / `Ctrl + T` | New Tab |
| `Ctrl + Shift + W` / `Ctrl + W` | Close Tab |
| `Alt + 1..9` | Go to Tab 1–9 |
| `Ctrl + Shift + D` | Detach Tab |
| `Ctrl + Shift + H` | Split Horizontal |
| `Ctrl + Shift + V` | Split Vertical |
| `Ctrl + Alt + N` | New Window |
| `Ctrl + Alt + Q` | Close Window |
| `Ctrl + Shift + L` | Next Layout (Splits, Stack, Tall, Fat, Grid) |
| `Ctrl + Shift + Z` | Toggle Zoom (Stack Layout) |
| `Ctrl + Alt + Enter` | Toggle Fullscreen |
| `Ctrl + Shift + M` | Detach Window |

---

## 🧰 Modern Kittens & Tools (Kitty 0.42+)

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl + Shift + K` | Command Palette | Fuzzy search and execute Kitty actions |
| `Ctrl + Shift + F` | Choose Files | Visual interactive file picker with preview |
| `Ctrl + Shift + B` | Broadcast | Mirror typing to all panes simultaneously |
| `Ctrl + Shift + R` | Resize Window | Interactive split and window edge resizing |
| `Ctrl + Shift + G` | Drag & Drop | Drag terminal files to external GUI apps |
| `Ctrl + Shift + E` | Hints (URLs) | Highlight and open hyperlinks |
| `Ctrl + Shift + P` | Hints (Paths) | Select detected paths and insert |
| `Ctrl + Shift + Y` | Hints (Hashes) | Select Git SHA hashes and insert |

---

## 🪟 KWin Desktop & Window Management

| Key | Action |
|-----|--------|
| `Meta + Alt + ←` | Quick Tile Window Left |
| `Meta + Alt + →` | Quick Tile Window Right |
| `Meta + Alt + ↑` | Quick Tile Window Top |
| `Meta + Alt + ↓` | Quick Tile Window Bottom |
| `Meta + 1..9` | Switch to Desktop 1–9 |
| `Meta + Alt + 1..9` | Move Window to Desktop 1–9 |
| `Meta + W` | Toggle Desktop Overview |
| `Alt + Tab` | Cycle Open Windows |

---

## 🔍 Search & Selection (FZF)

Routed by Kitty -> Executed by Fish -> FZF.

| Key | Action | Underlying Command |
|-----|--------|-------------------|
| `Ctrl + Alt + M` | Unified FZF Menu | `\cg` / `menu` |
| `Ctrl + Alt + P` | Find File | `\cf` |
| `Ctrl + Alt + H` | Find History | `\cr` |
| `Ctrl + Alt + J` | Jump Directory | `\cd` (zoxide) |
| `Ctrl + Alt + X` | Kill Process | `\ck` |

---

## 🐚 Shell Editing (Fish / Zsh)

Standard readline-style bindings (emacs mode).

| Key | Action |
|-----|--------|
| `Ctrl + A` | Start of line |
| `Ctrl + E` | End of line |
| `Ctrl + U` | Clear before cursor |
| `Ctrl + K` | Clear after cursor |
| `Ctrl + L` | Clear screen |
| `Ctrl + W` | Delete word backward |

---

## 📋 Clipboard

| Key | Action |
|-----|--------|
| `Ctrl + C` | Copy (if selected) or Interrupt |
| `Ctrl + V` | Paste from clipboard |
| `Ctrl + Shift + C` | Copy |
| `Ctrl + Shift + V` | Paste |

*Note: `Ctrl+V` and `Ctrl+Shift+V` are both preserved and conflict-free.*

---

## ⌨️ Neovim

Leader Key: `<Space>`

Refer to the in-editor `which-key` menu for a complete map.
Common patterns:
- `<Space> f f`: Find File
- `<Space> /`: Grep / Search
- `<Space> g g`: LazyGit
- `<Space> e`: Neo-tree File Explorer
