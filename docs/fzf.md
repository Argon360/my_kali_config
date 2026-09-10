# FZF Configuration (Everywhere)

## Purpose

**fzf** (fuzzy finder) is the engine behind all interactive search, tab completions, and navigation in this environment. 
It is integrated into:
- **Unified Command Palette (`menu` / `fmenu`)**: Central fuzzy launcher for files, git, configs, apps, and processes.
- **Tab Completion Everywhere**:
  - **Fish**: Powered by `fifc` (interactive fuzzy completion menu with file/dir/command previews on `Tab`).
  - **Zsh**: Powered by `fzf-tab` (interactive popup menu with bat/eza previews).
- **Shell History Search** (`Ctrl + R` / `Ctrl + Alt + H`)
- **File & Directory Search** (`Ctrl + F` / `Ctrl + Alt + P`)
- **Directory Jumping** (`Ctrl + D` / `Ctrl + Alt + J` via Zoxide)
- **Process Management** (`Ctrl + K` / `Ctrl + Alt + X`)

---

## Integration Strategy

We avoid conflicting default terminal shortcuts by synchronizing terminal emulator shortcuts with shell-owned sequences:
- **Kitty** intercepts combinations and forwards control codes to the active shell.
- **Fish & Zsh** bind those control sequences to the corresponding `fzf` handlers.

---

## Keybindings

| Shortcut (Kitty / Shell) | Action | Underlying Code | Description |
|--------------------------|--------|-----------------|-------------|
| `Ctrl + Alt + M` / `Ctrl + G` / `Alt + M` | **Unified FZF Menu** | `\cg` | Opens `menu` command palette |
| `Ctrl + Alt + P` / `Ctrl + F` | **Find File** | `\cf` | Fuzzy file search with syntax preview |
| `Ctrl + Alt + H` / `Ctrl + R` | **History Search** | `\cr` | Fuzzy shell command history |
| `Ctrl + Alt + J` / `Ctrl + D` | **Jump Directory** | `\cd` | Interactive Zoxide directory jumper |
| `Ctrl + Alt + X` / `Ctrl + K` | **Process Kill** | `\ck` | Interactive process viewer & termination |
| `Tab` | **FZF Tab Completion** | `\t` | Fuzzy argument, file, and option completions |

---

## Commands & Utilities

- `menu` / `fmenu`: Opens the full interactive FZF Command Palette.
- `fe [query]`: Fuzzy search and open files directly in `$EDITOR` (Neovim).
- `fcd [dir]`: Fuzzy cd into any subdirectory.
- `fkill`: Fuzzy interactive process terminator.
- `fshow`: Interactive git commit log & diff browser.

