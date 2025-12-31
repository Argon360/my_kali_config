
# Architecture & Design Principles

This environment follows classic Unix separation-of-concerns.

---

## Layered Responsibility Model

| Layer | Responsibility |
|----|----|
| Operating System | Global shortcuts, window manager |
| kitty | UI actions, tab/window management, routing |
| fish | Command behavior, shell logic |
| fzf | Interactive selection engine |

No layer overrides another.

---

## Modifier Key Policy

| Modifier | Owner | Notes |
|------|------|------|
| Ctrl | fish | Shell behavior only |
| Ctrl+Alt | kitty | UI → shell routing |
| Ctrl+Shift | kitty | Visual/UI controls |
| Alt | ❌ unused | Avoided to prevent DE conflicts |

---

## Why This Matters

- Prevents shortcut collisions
- Avoids plugin surprises
- Makes configs portable
- Preserves muscle memory

This model survives OS upgrades and shell/plugin changes.
