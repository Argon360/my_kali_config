# Keybindings Reference

This document serves as the **Single Source of Truth** for all keybindings in this environment.
Ambiguity is considered a bug.

---

## 🧭 Navigation & UI (Kitty)

These are handled by the terminal emulator.

| Key | Action |
|-----|--------|
| `Ctrl + Shift + →/←` | Next / Prev Tab |
| `Ctrl + Shift + T` | New Tab |
| `Ctrl + Shift + W` | Close Tab |
| `Ctrl + Alt + N` | New Window |
| `Ctrl + Alt + Q` | Close Window |
| `Ctrl + Alt + H/V` | Split Horizontal / Vertical |
| `Ctrl + Alt + Enter` | Toggle Fullscreen |

---

## 🔍 Search & Selection (FZF)

Routed by Kitty -> Executed by Fish -> FZF.

| Key | Action | Underlying Command |
|-----|--------|-------------------|
| `Ctrl + Alt + P` | Find File | `\cf` |
| `Ctrl + Alt + H` | Find History | `\cr` |
| `Ctrl + Alt + J` | Jump Directory | `\cd` (zoxide) |
| `Ctrl + Alt + X` | Kill Process | `\ck` |

---

## 🐚 Shell Editing (Fish)

Standard readline-style bindings (emacs mode).

| Key | Action |
|-----|--------|
| `Ctrl + A` | Start of line |
| `Ctrl + E` | End of line |
| `Ctrl + U` | Clear line |
| `Ctrl + L` | Clear screen |
| `Ctrl + W` | Delete word |

---

## 📋 Clipboard

| Key | Action |
|-----|--------|
| `Ctrl + Shift + C` | Copy |
| `Ctrl + Shift + V` | Paste |

*Note: `Ctrl+V` is intentionally not used to avoid terminal conflicts.*

---

## ⌨️ Neovim

Leader Key: `<Space>`

Refer to the in-editor `which-key` menu for a complete map.
Common patterns:
- `<Space> f f`: Find File
- `<Space> /`: Grep / Search
- `<Space> g g`: LazyGit