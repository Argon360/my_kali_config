# FZF Configuration

## Purpose

**fzf** (fuzzy finder) is the engine behind all interactive search and navigation in this environment. 
It is integrated into:
- Shell history search
- File navigation
- Process management
- Directory jumping (via zoxide)

---

## Integration Strategy

We do **not** use default fzf keybindings directly in the terminal emulator to avoid conflicts.
Instead, **kitty** intercepts specific key combinations and sends the corresponding `fzf` sequences to the shell.

This ensures:
1.  Keybindings work over SSH (if the remote shell supports them).
2.  Kitty retains control of the modifier keys.
3.  No "double-binding" issues.

---

## Keybindings

| Key (Kitty) | Action | Context |
|------------|--------|---------|
| `Ctrl + Alt + P` | **Project/File Search** | Finds files recursively |
| `Ctrl + Alt + H` | **History Search** | Search shell command history |
| `Ctrl + Alt + J` | **Jump Directory** | Interactive `z` (zoxide) |
| `Ctrl + Alt + X` | **Process Kill** | Search and kill processes |

---

## Underlying Commands

The shell receives standard sequences which trigger `fzf` functions:

- `\cf` → `file_search`
- `\cr` → `history_search`
- `\cd` → `zoxide_interactive`
- `\ck` → `process_kill`

## Customization

The behavior of these searches is controlled by the `fzf.fish` plugin and environment variables in `config.fish`.
