# ⌨️ Complete System & Environment Shortcuts

> **Single Source of Truth** for all keyboard shortcuts, window tiling, terminal kittens, touchpad gestures, and shell integrations in this environment.

---

## 📑 Table of Contents

- [Modifier Hierarchy & Rules](#-modifier-hierarchy--rules)
- [KWin & Desktop Window Management (Plasma 6.8+)](#-kwin--desktop-window-management)
- [Kitty Terminal Emulator (0.50+)](#-kitty-terminal-emulator)
  - [Modern Features & Kittens](#modern-features--kittens-kitty-042050)
  - [Tabs & Window Splits](#tabs--window-splits)
  - [Font Size & Background Opacity](#font-size--background-opacity)
  - [Clipboard & Text Actions](#clipboard--text-actions)
- [Shell & FZF Navigation (Fish / Zsh)](#-shell--fzf-navigation)
- [Wayland Touchpad Gestures](#-wayland-touchpad-gestures)
- [Neovim (LazyVim)](#-neovim-lazyvim)

---

## 🧠 Modifier Hierarchy & Rules

To eliminate key collision between the desktop environment, terminal emulator, and shell, shortcuts strictly adhere to this ownership matrix:

| Modifier | Owner | Domain | Example |
| :--- | :--- | :--- | :--- |
| <kbd>Meta</kbd> (Super) | **KWin** | Desktop navigation, workspace switching, overview | <kbd>Meta</kbd> + <kbd>1..9</kbd> |
| <kbd>Meta</kbd> + <kbd>Alt</kbd> | **KWin** | Window tiling & workspace transfer | <kbd>Meta</kbd> + <kbd>Alt</kbd> + <kbd>←/→/↑/↓</kbd> |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> | **Kitty** | Visual UI, kittens, tabs, opacity, hints | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd> |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> | **Kitty → Shell** | Terminal-to-shell routed actions (FZF) | <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd> |
| <kbd>Ctrl</kbd> | **Shell (Fish)** | Readline line editing & shell signals | <kbd>Ctrl</kbd> + <kbd>C</kbd>, <kbd>Ctrl</kbd> + <kbd>L</kbd> |
| <kbd>Alt</kbd> + <kbd>1..9</kbd> | **Kitty** | Direct tab switching | <kbd>Alt</kbd> + <kbd>1</kbd> |

> [!NOTE]
> **Paste is Sacred**: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> and <kbd>Ctrl</kbd> + <kbd>V</kbd> are protected across all terminal states.

---

## 🪟 KWin & Desktop Window Management

Tested and configured for KDE Plasma 6.8+ on Wayland.

### Window Quick Tiling

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Meta</kbd> + <kbd>Alt</kbd> + <kbd>←</kbd> | **Tile Left** | Snaps window to left 50% of the display |
| <kbd>Meta</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd> | **Tile Right** | Snaps window to right 50% of the display |
| <kbd>Meta</kbd> + <kbd>Alt</kbd> + <kbd>↑</kbd> | **Tile Top** | Snaps window to top 50% of the display |
| <kbd>Meta</kbd> + <kbd>Alt</kbd> + <kbd>↓</kbd> | **Tile Bottom** | Snaps window to bottom 50% of the display |

### Virtual Desktops & Workspace Navigation

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Meta</kbd> + <kbd>1</kbd> ... <kbd>9</kbd> | **Switch to Desktop 1–9** | Instant switch to the corresponding virtual desktop |
| <kbd>Meta</kbd> + <kbd>Alt</kbd> + <kbd>1</kbd> ... <kbd>9</kbd> | **Move Window to Desktop 1–9** | Transports active window directly to target desktop |

### Overview & Window Cycling

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Meta</kbd> + <kbd>W</kbd> | **Toggle Overview** | Interactive desktop overview & search |
| <kbd>Alt</kbd> + <kbd>Tab</kbd> / <kbd>Meta</kbd> + <kbd>Tab</kbd> | **Task Switcher** | Cycle through open windows |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | **Task Switcher (Reverse)** | Cycle backwards through open windows |
| <kbd>Alt</kbd> + <kbd>`</kbd> | **Cycle App Windows** | Walk through windows of the currently focused application |
| <kbd>Ctrl</kbd> + <kbd>F9</kbd> / <kbd>Meta</kbd> + <kbd>F9</kbd> | **Present Windows (Current)** | Expose all windows on current virtual desktop |
| <kbd>Ctrl</kbd> + <kbd>F10</kbd> / <kbd>Meta</kbd> + <kbd>F10</kbd> | **Present Windows (All)** | Expose windows across all virtual desktops |
| <kbd>Meta</kbd> | **Application Launcher** | Open start menu / runner |

---

## 🖥️ Kitty Terminal Emulator

> [!TIP]
> A dedicated, in-depth breakdown of all 55+ Kitty mappings, dynamic opacity profiles, and kitten features is available in [docs/kitty-keys.md](docs/kitty-keys.md).

### Modern Features & Kittens (Kitty 0.42–0.50+)

| Shortcut | Kitten / Command | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd> | `command_palette` | **Command Palette**: Fuzzy search and execute any Kitty action |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | `kitten choose-files` | **Fuzzy File Picker**: Interactive visual file browser with previews |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> | `kitten broadcast` | **Broadcast Typing**: Mirror keystrokes across all open splits simultaneously |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | `start_resizing_window` | **Interactive Resizing**: Arrow keys resize current pane splits smoothly |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> | `kitten dnd` | **Drag & Drop**: Export terminal files via Wayland DnD to external apps |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | `kitten hints --type url` | **URL Hints**: Highlight and click/open links in browser |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | `kitten hints --type path` | **Path Hints**: Select detected file paths and insert directly into prompt |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Y</kbd> | `kitten hints --type hash` | **Hash Hints**: Select Git SHA hashes and copy/insert |

### Tabs & Window Splits

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd> / <kbd>Ctrl</kbd> + <kbd>T</kbd> | `new_tab` | Create a new tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> / <kbd>Ctrl</kbd> + <kbd>W</kbd> | `close_tab` | Close active tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>→</kbd> / <kbd>Ctrl</kbd> + <kbd>Tab</kbd> | `next_tab` | Go to next tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> / <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | `previous_tab` | Go to previous tab |
| <kbd>Alt</kbd> + <kbd>1</kbd> ... <kbd>9</kbd> | `goto_tab 1..9` | Jump directly to tab 1 through 9 |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>D</kbd> | `detach_tab ask` | Detach active tab into a separate window |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> | `launch --location=hsplit` | Split active window **horizontally** |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | `launch --location=vsplit` | Split active window **vertically** |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>N</kbd> | `new_window` | Open new window in current layout |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Q</kbd> | `close_window` | Close focused split window |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd> | `next_layout` | Cycle layouts (`splits` ➔ `stack` ➔ `tall` ➔ `fat` ➔ `grid`) |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Z</kbd> | `toggle_layout stack` | **Zoom**: Maximize split window to fullscreen pane |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Enter</kbd> | `toggle_fullscreen` | Toggle OS-level fullscreen for Kitty |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> | `detach_window ask` | Detach split window into a separate tab/window |

### Font Size & Background Opacity

| Shortcut | Action | Setting |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>+</kbd> | Increase font size | Dynamic font zoom |
| <kbd>Ctrl</kbd> + <kbd>-</kbd> | Decrease font size | Dynamic font shrink |
| <kbd>Ctrl</kbd> + <kbd>0</kbd> | Reset font size | Restore base font size |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>O</kbd> | Default Opacity | **75%** transparency (default blur profile) |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> | Opacity 100% | Completely opaque |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>2</kbd> ... <kbd>0</kbd> | Opacity 90% – 10% | Step down transparency (<kbd>2</kbd>=90%, ..., <kbd>0</kbd>=10%) |

### Clipboard & Text Actions

| Shortcut | Action | Behavior |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>C</kbd> | `copy_or_interrupt` | Copies text if a selection is active; sends `SIGINT` otherwise |
| <kbd>Ctrl</kbd> + <kbd>V</kbd> | `paste_from_clipboard` | Paste directly from system clipboard |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | `copy_to_clipboard` | Copy active selection to clipboard |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | `paste_from_clipboard` | Safe universal terminal paste |

---

## 🐚 Shell & FZF Navigation

Kitty traps these combinations and sends control sequences to Fish/Zsh.

| Shortcut | Fish/Zsh Route | Tool / Action | Description |
| :--- | :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>M</kbd> | `\cg` | **FZF Unified Menu** | Search and launch commands, scripts, and utilities |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd> | `\cf` | **FZF File Search** | Fuzzy find files recursively with bat previews |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>H</kbd> | `\cr` | **History Search** | Search through Atuin / shell command history |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>J</kbd> | `\cd` | **Directory Jump** | Zoxide fast fuzzy jump to recently visited directories |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>X</kbd> | `\ck` | **Process Kill** | Interactive PID selector with CPU/memory stats |

### Readline Line Editing (Fish / Zsh)

| Shortcut | Action |
| :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> | Move cursor to beginning of line |
| <kbd>Ctrl</kbd> + <kbd>E</kbd> | Move cursor to end of line |
| <kbd>Ctrl</kbd> + <kbd>U</kbd> | Clear line from cursor to beginning |
| <kbd>Ctrl</kbd> + <kbd>K</kbd> | Clear line from cursor to end |
| <kbd>Ctrl</kbd> + <kbd>W</kbd> | Delete backward word |
| <kbd>Ctrl</kbd> + <kbd>L</kbd> | Clear screen (preserves prompt) |

---

## 🖐️ Wayland Touchpad Gestures

Integrated via custom KWin Gestures plugin and InputActions.

| Gesture | Direction | Action | Description |
| :--- | :--- | :--- | :--- |
| **3 Fingers** | ↔ Horizontal Swipe | **Window Switcher** | Continuously cycle forward/backward through open windows (<kbd>Alt</kbd>+<kbd>Tab</kbd>) |
| **4 Fingers** | ↔ Horizontal Swipe | **Virtual Desktops** | Smoothly slide between virtual workspaces |
| **4 Fingers** | ↕ Vertical Swipe | **KWin Overview** | Open / close Plasma desktop overview |
| **1 Finger** | Tap + Drag | **Drag Lock** | Click-and-drag windows or selections with timeout release |
| **2 Fingers** | ↕ Vertical Scroll | **Kinetic Pixel Scroll** | Smooth inertia scrolling in Kitty and GUI browsers |

---

## 📝 Neovim (LazyVim)

Leader key is configured as <kbd>Space</kbd>.

| Shortcut | Action |
| :--- | :--- |
| <kbd>Space</kbd> + <kbd>f</kbd> + <kbd>f</kbd> | Find Files (Telescope / fzf-lua) |
| <kbd>Space</kbd> + <kbd>/</kbd> | Live Grep across workspace |
| <kbd>Space</kbd> + <kbd>g</kbd> + <kbd>g</kbd> | LazyGit Terminal UI |
| <kbd>Space</kbd> + <kbd>e</kbd> | Toggle Neo-tree file explorer |
| <kbd>Space</kbd> + <kbd>b</kbd> + <kbd>d</kbd> | Close active buffer |
| <kbd>Space</kbd> + <kbd>s</kbd> + <kbd>k</kbd> | Search Keymaps (Which-Key) |
