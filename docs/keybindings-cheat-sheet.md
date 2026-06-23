
# ⌨️ Keybinding Cheat Sheet

This document is the **single source of truth** for all keybindings used in this configuration.

It covers:
- Terminal UI (kitty)
- Shell behavior (fish)
- fzf integrations
- Routing rules and ownership

No undocumented shortcuts exist.

---

## 🧠 Keybinding Philosophy

| Modifier | Owner | Purpose |
|--------|------|--------|
| `Ctrl` | fish | Shell behavior |
| `Ctrl + Alt` | kitty | Route actions to shell |
| `Ctrl + Shift` | kitty | UI / visual controls |
| `Alt` | ❌ unused | Avoided (DE conflicts) |

> **Paste is sacred**
- Paste is **always** `Ctrl + Shift + V`
- `Ctrl + V` is never rebound

---

## 🖥️ Kitty — UI & Window Management

### Tabs

| Key | Action |
|----|------|
| `Ctrl + Shift + →` | Next tab |
| `Ctrl + Shift + ←` | Previous tab |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + W` | Close tab |

---

### Windows & Layouts

| Key | Action |
|----|------|
| `Ctrl + Alt + N` | New window |
| `Ctrl + Alt + Q` | Close window |
| `Ctrl + Alt + Enter` | Toggle fullscreen |
| `Ctrl + Alt + H` | Horizontal split |
| `Ctrl + Alt + V` | Vertical split |

---

### Clipboard

| Key | Action |
|----|------|
| `Ctrl + Shift + C` | Copy |
| `Ctrl + Shift + V` | Paste |

---

### Visual / Utility

| Key | Action |
|----|------|
| `Ctrl + Shift + E` | Hint mode (select text/URLs) |

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

## 🐟 Fish — Shell Behavior

> These bindings are **Ctrl-only** and work in both `default` and `insert` modes.

### fzf Actions (Shell-Owned)

| Key | Action |
|----|------|
| `Ctrl + F` | File / project search |
| `Ctrl + R` | Command history search |
| `Ctrl + D` | Directory jump |
| `Ctrl + K` | Process kill |

---

## 🔍 fzf — End-to-End Flow

These actions are triggered via kitty routing:

| Physical Key | Routed As | Final Action |
|------------|----------|--------------|
| `Ctrl + Alt + P` | `Ctrl + F` | File search |
| `Ctrl + Alt + H` | `Ctrl + R` | History search |
| `Ctrl + Alt + J` | `Ctrl + D` | Directory jump |
| `Ctrl + Alt + X` | `Ctrl + K` | Process kill |

This separation ensures:
- No Alt usage inside fish
- No shell logic in kitty
- No plugin surprise bindings

---

## 🚫 Explicitly Not Used

These keys are intentionally **not bound**:

| Key | Reason |
|----|--------|
| `Alt + *` | DE / WM conflicts |
| `Ctrl + V` | Breaks paste semantics |
| `Ctrl + T` | Avoids duplicate file search |
| fzf default Alt bindings | Disabled for clarity |

---

## 📌 Summary

- Every shortcut is intentional
- Every binding is documented
- There is exactly **one way** to do each action
- No plugin overrides user intent

If something isn’t bound — it’s on purpose.
