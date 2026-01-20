# Fish Shell Configuration

## Purpose

fish handles:
- Interactive shell behavior
- Aliases and functions
- Keybindings (Ctrl-only)
- Tool initialization

---

## Startup Tools

Initialized conditionally (only if installed):
- **starship**: Prompt (Source: `starship.toml`)
- **atuin**: Shell history sync & search
- **zoxide**: Smarter `cd`
- **fastfetch**: System info on login (Source: `fastfetch/config.jsonc`)
- **thefuck**: Command correction

---

## Aliases

Aliases are strictly categorized to avoid clutter.

### 📂 Filesystem
- `ls`, `ll`, `la`: mapped to **eza** (modern ls replacement) with icons and git integration.
- `lt`, `tree1`, `tree2`: Tree views.
- `x`: Universal extract (unp).
- `du`, `duh`: mapped to **dust**.

### 🛠️ System / Infra
- `top`: mapped to **btop**.
- `ipinfo`, `routes`, `ports`, `myip`: Networking shortcuts.
- `sysup`: Full system update (apt update/upgrade/autoremove).

### 🧭 Navigation
- `..`, `...`: Directory traversal.
- `home`: Go to `~`.

### 🐙 Git (The "g" Suite)
A comprehensive set of git abbreviations is provided, favoring explicit naming over cryptic 2-letter combos.
- `gs`, `gl`, `gd`: Status, Log, Diff.
- `ga`, `gc`, `gp`: Add, Commit, Push.
- `gsw`, `grb`: Switch, Rebase.
- `gunstage`, `gundo`: Safety undo commands.

### 💻 Neovim
- `nv`: Main editor.
- `cf`: Edit fish config.
- `cn`: Edit nvim config.

---

## Custom Functions

These functions encapsulate complex workflows to prevent mistakes.

### `workstart`
- Shows git status and recent log.
- Used when starting a coding session to gain context.

### `workend`
- Checks for uncommitted changes.
- Prompts for confirmation before you walk away.

### `gpushsafe`
- Shows destination branch and status.
- **Requires interactive confirmation (y/N)** before pushing.
- Prevents accidental pushes to `main` or wrong branches.

### `weeklyreset`
- Runs system updates (`sysup`).
- Prunes remote git branches.
- Deletes merged local branches.

---

## Shell Management

- `reload`: Sources `config.fish`.
- `reloadall`: Reloads fish, kitty, and fastfetch.