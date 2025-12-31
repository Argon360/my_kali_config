
# fzf Integration

fzf is used as a **pure selection engine**.

All bindings and policy decisions are defined in fish or kitty.

---

## Default Options

- Reverse layout
- Preview via bat
- 40% height
- Right-side preview window

These defaults apply globally via environment variables.

---

## Keybindings (fish-owned)

| Key | Action |
|----|------|
| Ctrl+F | File search |
| Ctrl+R | History search |
| Ctrl+D | Directory jump |
| Ctrl+K | Process kill |

No Alt bindings.
No Ctrl+V usage.

---

## Why Default fzf.fish Bindings Are Disabled

- They reintroduce Alt/Meta keys
- They conflict with terminal conventions
- They override user intent

Only explicit bindings are used.
