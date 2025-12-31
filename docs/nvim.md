# Neovim Configuration

## Purpose

This Neovim setup is built on top of **LazyVim**, a highly configured, performance-focused framework.
It turns Neovim into a full-featured IDE.

---

## Core Features (LazyVim)

- **Plugin Manager**: `lazy.nvim` (fast, lazy-loading)
- **LSP**: Native LSP support with `mason.nvim` for easy server installation.
- **Completion**: `nvim-cmp` for autocompletion.
- **Treesitter**: Advanced syntax highlighting and code navigation.
- **Formatting**: Auto-formatting via `conform.nvim` / `null-ls`.
- **UI**: `noice.nvim` for slick UI notifications and cmdline.

---

## Custom Aliases (Fish)

To integrate smoothly with the shell workflow:

| Alias | Command | Purpose |
|-------|---------|---------|
| `nv` | `nvim` | Main editor command |
| `nvdiff` | `nvim -d` | Diff mode |
| `nvlog` | `nvim +"term git log..."` | View git log in a terminal buffer |
| `scratch` | `nvim +"enew"` | Open a quick scratchpad |
| `cf` | `nvim ~/.config/fish/config.fish` | Quick edit Fish config |
| `cn` | `nvim ~/.config/nvim` | Quick edit Nvim config |

---

## File Structure

- `init.lua`: Entry point.
- `lazy-lock.json`: Locks plugin versions for stability.
- `lazyvim.json`: LazyVim specific settings.
- `lua/`: Custom configuration and plugins.

---

## Keybindings (Leader)

The **Leader key** is set to `<Space>`.
Refer to the built-in `which-key` menu (press Space and wait) for a dynamic list of bindings.
