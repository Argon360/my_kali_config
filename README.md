# My Kali / Linux Terminal Configuration

A curated, conflict-free terminal environment built around **kitty**, **fish**, and **fzf**.

This repository is not a collection of random dotfiles.  
It is a **documented, opinionated environment specification** designed for long-term use, portability, and zero shortcut ambiguity.

---

## ✨ Goals & Philosophy

- Deterministic keybindings (no surprises)
- Clear separation of responsibilities
- Minimal reliance on plugin defaults
- Terminal conventions respected
- Portable across Linux distributions

Designed and tested on:

- Kali Linux
- Debian / Ubuntu / Pop!_OS
- X11 and Wayland environments

---

## 🧱 Core Components

| Component | Role |
|--------|------|
| **kitty** | Terminal emulator, UI & key routing |
| **fish** | Interactive shell & behavior |
| **fzf** | Fuzzy selection engine |
| **fisher** | Fish plugin manager |
| **starship** | Cross-shell prompt |
| **fastfetch** | System information fetcher |
| **neovim** | LazyVim-based IDE |

---

## ⌨️ Keybinding Model (At a Glance)

| Modifier | Owner | Purpose |
|--------|------|--------|
| `Ctrl` | fish | Shell behavior |
| `Ctrl + Alt` | kitty | UI → shell routing |
| `Ctrl + Shift` | kitty | Visual / UI actions |
| `Alt` | ❌ unused | Avoided (DE conflicts) |

Paste remains **sacred**:

- `Ctrl + Shift + V` → Paste

---

## 📂 Repository Structure

```text
.
├── README.md          # You are here
├── docs/              # All documentation
│   ├── README.md
│   ├── architecture.md
│   ├── fish.md
│   ├── kitty.md
│   ├── fzf.md
│   ├── keybindings.md
│   ├── plugins.md
│   ├── starship.md
│   ├── fastfetch.md
│   └── nvim.md
├── .config/
│   ├── kitty/
│   ├── fish/
│   ├── fastfetch/
│   ├── nvim/
│   └── starship.toml
````

---

## 📚 Documentation

Start here if you want to understand *why* things are configured this way:

- 📐 [Architecture & Design Principles](docs/architecture.md)
- 🖥️ [Kitty Terminal Configuration](docs/kitty.md)
- 🐟 [Fish Shell Configuration](docs/fish.md)
- 🔍 [FZF Integration](docs/fzf.md)
- 🚀 [Starship Prompt](docs/starship.md)
- ℹ️ [Fastfetch System Info](docs/fastfetch.md)
- 📝 [Neovim / LazyVim](docs/nvim.md)
- ⌨️ [Keybindings Reference](docs/keybindings.md)
- 🔌 [Plugins & Fisher](docs/plugins.md)

- ⌨️ [Keybinding Cheat Sheet](docs/keybinding-cheat-sheet.md)

---

## 🚀 Getting Started

### ⚡ Automated Setup (Recommended)

1. Clone the repository:

   ```bash
   git clone https://github.com/Argon360/my_kali_config.git ~/.config/my-dotfiles
   cd ~/.config/my-dotfiles
   ```
   *(Note: You can clone this anywhere, but `~/.config/my-dotfiles` is a good spot)*

2. Run the installer:

   ```bash
   ./setup.sh
   ```
   This script will:
   - Detect your distro (Debian/Kali preferred)
   - Install required packages (`kitty`, `fish`, `fzf`, `bat`, `eza`, `zoxide`, `atuin`, etc.)
   - Link configuration files to `~/.config/`
   - Set up `fisher` plugins

3. Restart your terminal.

---

### 🛠️ Manual Setup

If you prefer to do things yourself:

1. Clone the repository:

   ```bash
   git clone https://github.com/Argon360/my_kali_config.git
   ```

2. Install dependencies (example):

   ```bash
   # For Arch / CachyOS:
   sudo pacman -S kitty fish fzf bat ripgrep fd zoxide neovim eza fastfetch atuin paru

   # For Fedora:
   sudo dnf install kitty fish fzf bat ripgrep fd-find zoxide neovim eza fastfetch atuin

   # For Debian/Ubuntu/Kali:
   sudo apt install kitty fish fzf bat ripgrep fd-find zoxide neovim eza fastfetch atuin
   # Install starship, atuin, eza, fastfetch as needed
   ```

3. Copy configs into place:

   ```bash
   # Copy specific configurations
   cp -r kitty fish nvim fastfetch ~/.config/
   cp starship.toml ~/.config/
   ```

4. Set fish as default shell (optional):

   ```bash
   chsh -s /usr/bin/fish
   ```

---

## ⚠️ Notes

- Plugin defaults are intentionally overridden
- No Alt-based shortcuts are used
- `Ctrl+V` is never rebound
- All bindings are explicit and documented

If something feels “missing”, it is probably intentional.

---

## 📌 Status

This configuration is **actively used**, **documented**, and **maintained**.

Feel free to fork or adapt — but understand the design rules first.