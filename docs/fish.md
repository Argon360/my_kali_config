
# Fish Shell Configuration

## Purpose

fish handles:
- Interactive shell behavior
- Aliases and functions
- Keybindings (Ctrl-only)
- Tool initialization

---

## Startup Tools

Initialized conditionally:
- starship (prompt)
- atuin (history)
- zoxide (directory jumping)
- fzf (selection engine)
- fastfetch (startup info)

Each tool is only loaded if present.

---

## Aliases

Aliases are grouped logically:
- Filesystem
- System / Networking
- Git
- Development
- Quality-of-life

No alias overrides critical shell behavior.

---

## Custom Functions

### `__fzf_cd`
Interactive directory change using fzf.

### `__fzf_kill`
Interactive process selection and termination.

### Workflow Helpers
- `workstart`
- `workend`
- `gpushsafe`
- `weeklyreset`

Each function is defensive and prompts before destructive actions.
