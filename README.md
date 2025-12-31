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
│   ├── kitty.md
│   ├── fish.md
│   ├── fzf.md
│   ├── keybindings.md
│   └── plugins.md
├── .config/
│   ├── kitty/
│   └── fish/
````

---

## 📚 Documentation

Start here if you want to understand *why* things are configured this way:

- 📐 [Architecture & Design Principles](docs/architecture.md)
- 🖥️ [Kitty Terminal Configuration](docs/kitty.md)
- 🐟 [Fish Shell Configuration](docs/fish.md)
- 🔍 [fzf Integration](docs/fzf.md)
- ⌨️ [Keybindings Reference](docs/keybindings.md)
- 🔌 [Plugins & Fisher](docs/plugins.md)

- ⌨️ [Keybinding Cheat Sheet](docs/keybinding-cheat-sheet.md)

---

## 🚀 Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/Argon360/my_kali_config.git
   ```

2. Install dependencies (example):

   ```bash
   sudo apt install kitty fish fzf bat eza ripgrep fd-find
   ```

3. Copy configs into place:

   ```bash
   cp -r .config/* ~/.config/
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
