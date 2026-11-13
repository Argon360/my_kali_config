# 🐱 Complete Kitty Terminal Keybindings Reference

> **Official Keybindings & Shortcuts Reference** for the Kitty terminal emulator (`v0.50.0+`).  
> Configuration source: [`kitty/kitty.conf`](../kitty/kitty.conf) (deployed to `~/.config/kitty/kitty.conf`).

---

## 📑 Table of Contents

- [🧠 Modifier & Ownership Architecture](#-modifier--ownership-architecture)
- [✨ Modern Feature Kittens (0.42–0.50+)](#-modern-feature-kittens-kitty-042050)
- [🪟 Window Splits & Layout Management](#-window-splits--layout-management)
- [📑 Tab Management & Direct Navigation](#-tab-management--direct-navigation)
- [🎨 Dynamic Background Opacity Controls](#-dynamic-background-opacity-controls)
- [🔍 Font Sizing & Display Scaling](#-font-sizing--display-scaling)
- [📋 Clipboard & Selection Operations](#-clipboard--selection-operations)
- [🐚 Shell & FZF Key Forwarding](#-shell--fzf-key-forwarding)
- [📜 Scrolling, Buffer & System Actions](#-scrolling-buffer--system-actions)
- [⚡ Complete Quick-Reference Table](#-complete-quick-reference-table)

---

## 🧠 Modifier & Ownership Architecture

To eliminate shortcut collisions between the desktop environment (KWin), the terminal emulator (Kitty), and the shell (Fish/Zsh), bindings strictly follow this hierarchy:

| Modifier | Target Domain | Purpose | Example |
| :--- | :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> | **Kitty UI & Kittens** | Visual overlays, tabs, layouts, hints, opacity | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>K</kbd> |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> | **Kitty → Shell** | Intercepted by Kitty and sent to shell (FZF) | <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>P</kbd> |
| <kbd>Alt</kbd> + <kbd>1..9</kbd> | **Kitty Tabs** | Direct instant tab indexing | <kbd>Alt</kbd>+<kbd>3</kbd> |
| <kbd>Ctrl</kbd> | **Shell (Fish/Zsh)** | Readline line editing and terminal signals | <kbd>Ctrl</kbd>+<kbd>C</kbd>, <kbd>Ctrl</kbd>+<kbd>L</kbd> |
| <kbd>Meta</kbd> (Super) | **KWin (Plasma)** | Desktop windows, workspaces, quick tiling | <kbd>Meta</kbd>+<kbd>Alt</kbd>+<kbd>←</kbd> |

> [!IMPORTANT]
> **Paste Protection**: Clipboard paste is guaranteed via <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> and <kbd>Ctrl</kbd> + <kbd>V</kbd>. It is never overridden or captured by nested CLI tools.

---

## ✨ Modern Feature Kittens (Kitty 0.42–0.50+)

Kitty includes powerful built-in extensions ("kittens") that provide IDE-like overlays, fuzzy finders, and multi-pane orchestration:

| Shortcut | Action / Kitten | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd> | `command_palette` | **Searchable Command Palette**: Fuzzy search and trigger *any* Kitty action, shortcut, or feature from a floating menu. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | `kitten choose-files` | **Visual File Picker**: Interactive fuzzy browser with rich file previews. Selecting a file inserts its absolute path into the active prompt. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> | `kitten broadcast` | **Broadcast Keystrokes**: Mirrors whatever you type to **all open split panes** in the tab simultaneously. Ideal for multi-server SSH administration. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | `start_resizing_window` | **Interactive Window Resizing**: Enters interactive pane resizing mode. Use arrow keys to adjust split borders; press <kbd>Esc</kbd> when finished. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> | `kitten dnd` | **Terminal Drag & Drop**: Initiates file drag-and-drop between the terminal pane and desktop file managers. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | `kitten hints --type url` | **URL Hints Mode**: Scans visible terminal output for web links, assigns hotkey letters, and opens the chosen URL in your browser. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | `kitten hints --type path --program -` | **Path Hints Mode**: Detects file and folder paths on screen, attaches hotkey tags, and pastes the selected path directly into your shell. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Y</kbd> | `kitten hints --type hash --program -` | **Git Hash Hints**: Identifies Git commit SHAs and cryptographic hashes on screen and pastes the selected hash into the shell. |

---

## 🪟 Window Splits & Layout Management

Kitty provides manual tiling without requiring an external multiplexer like tmux:

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> | `launch --location=hsplit` | Split active window **horizontally** (splits pane top/bottom). |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | `launch --location=vsplit` | Split active window **vertically** (splits pane left/right). |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>N</kbd> | `new_window` | Open a new window pane within the current layout. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Q</kbd> | `close_window` | Close the currently focused split pane. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd> | `next_layout` | Cycle layout engine: `splits` ➔ `stack` ➔ `tall` ➔ `fat` ➔ `grid`. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Z</kbd> | `toggle_layout stack` | **Zoom Toggle**: Maximizes focused split to 100% of the window without closing neighboring panes. Press again to un-zoom. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Enter</kbd> | `toggle_fullscreen` | Toggle borderless OS fullscreen for the entire Kitty window. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> | `detach_window ask` | Detach the active split pane and move it to an independent window or tab. |

---

## 📑 Tab Management & Direct Navigation

Tabs allow running isolated workflows side-by-side with automatic powerline indicators:

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> | `new_tab` | Open a new tab (inherits current directory). |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd> | `new_tab` | Alternative standard shortcut to open a new tab. |
| <kbd>Ctrl</kbd> + <kbd>W</kbd> | `close_tab` | Close the active tab and all of its splits. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | `close_tab` | Alternative standard shortcut to close current tab. |
| <kbd>Ctrl</kbd> + <kbd>Tab</kbd> | `next_tab` | Cycle to the next tab on the right. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>→</kbd> | `next_tab` | Move to the next tab (arrow key navigation). |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | `previous_tab` | Cycle to the previous tab on the left. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> | `previous_tab` | Move to previous tab (arrow key navigation). |
| <kbd>Alt</kbd> + <kbd>1</kbd> | `goto_tab 1` | Instantly jump to Tab 1. |
| <kbd>Alt</kbd> + <kbd>2</kbd> | `goto_tab 2` | Instantly jump to Tab 2. |
| <kbd>Alt</kbd> + <kbd>3</kbd> | `goto_tab 3` | Instantly jump to Tab 3. |
| <kbd>Alt</kbd> + <kbd>4</kbd> | `goto_tab 4` | Instantly jump to Tab 4. |
| <kbd>Alt</kbd> + <kbd>5</kbd> | `goto_tab 5` | Instantly jump to Tab 5. |
| <kbd>Alt</kbd> + <kbd>6</kbd> | `goto_tab 6` | Instantly jump to Tab 6. |
| <kbd>Alt</kbd> + <kbd>7</kbd> | `goto_tab 7` | Instantly jump to Tab 7. |
| <kbd>Alt</kbd> + <kbd>8</kbd> | `goto_tab 8` | Instantly jump to Tab 8. |
| <kbd>Alt</kbd> + <kbd>9</kbd> | `goto_tab 9` | Instantly jump to Tab 9. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>D</kbd> | `detach_tab ask` | Detach active tab into its own independent OS window. |

---

## 🎨 Dynamic Background Opacity Controls

Live adjustment of window translucency without restarting or editing config files:

| Shortcut | Target Opacity | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>O</kbd> | **0.75** (75%) | **Default Profile**: Balanced translucency with background blur. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> | **1.00** (100%) | **Fully Solid**: Completely opaque, maximum contrast. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>2</kbd> | **0.90** (90%) | High opacity, subtle background visibility. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>3</kbd> | **0.80** (80%) | Moderate opacity. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>4</kbd> | **0.70** (70%) | Medium translucency. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>5</kbd> | **0.60** (60%) | Balanced translucency. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>6</kbd> | **0.50** (50%) | Semi-transparent. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>7</kbd> | **0.40** (40%) | High translucency. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>8</kbd> | **0.30** (30%) | See-through window background. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>9</kbd> | **0.20** (20%) | Ultra transparent. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd> | **0.10** (10%) | Minimalist ghost profile (10% tint). |

---

## 🔍 Font Sizing & Display Scaling

Dynamically adjust terminal font scale on high-DPI displays or during presentations:

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>+</kbd> (or <kbd>=</kbd>) | `increase_font_size` | Zoom in: increase font size by 1.0pt. |
| <kbd>Ctrl</kbd> + <kbd>-</kbd> | `decrease_font_size` | Zoom out: decrease font size by 1.0pt. |
| <kbd>Ctrl</kbd> + <kbd>0</kbd> | `reset_font_size` | Reset text back to default base size (`11.0pt`). |

---

## 📋 Clipboard & Selection Operations

| Shortcut | Action | Behavior |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>C</kbd> | `copy_or_interrupt` | **Smart Copy**: If text is selected, copies to clipboard; if nothing is selected, sends `SIGINT` (Ctrl+C interrupt). |
| <kbd>Ctrl</kbd> + <kbd>V</kbd> | `paste_from_clipboard` | Direct clipboard paste into active terminal. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | `copy_to_clipboard` | Explicit copy to system clipboard. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | `paste_from_clipboard` | Standard universal terminal paste. |

---

## 🐚 Shell & FZF Key Forwarding

Kitty intercepts these combinations and translates them into control codes delivered to the active shell (Fish/Zsh):

| Shortcut | ANSI Sequence | Mapped Tool | Purpose |
| :--- | :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>M</kbd> | `\cg` (<kbd>Ctrl</kbd>+<kbd>G</kbd>) | **Unified FZF Menu (`fmenu`)** | Universal launcher for commands, scripts, configs, and system utilities. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd> | `\cf` (<kbd>Ctrl</kbd>+<kbd>F</kbd>) | **FZF File Search** | Recursive file search with syntax-highlighted `bat` previews. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>H</kbd> | `\cr` (<kbd>Ctrl</kbd>+<kbd>R</kbd>) | **Command History Search** | Atuin / Fish interactive command history fuzzy search. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>J</kbd> | `\cd` (<kbd>Ctrl</kbd>+<kbd>D</kbd>) | **Directory Jump (`zoxide`)** | Fast fuzzy jump across visited folders and projects. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>X</kbd> | `\ck` (<kbd>Ctrl</kbd>+<kbd>K</kbd>) | **Interactive Process Killer** | Process manager with CPU/RAM metrics and `kill -9` dispatch. |

---

## 📜 Scrolling, Buffer & System Actions

| Shortcut / Control | Action | Description |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F5</kbd> | `load_config_file` | **Hot Reload Config**: Instantly reloads `kitty.conf` without closing terminal sessions. |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F6</kbd> | `debug_config` | Dumps current effective options and loaded keymaps to scrollback and clipboard. |
| <kbd>Shift</kbd> + <kbd>Page_Up</kbd> | `scroll_page_up` | Scroll up by one full screen page. |
| <kbd>Shift</kbd> + <kbd>Page_Down</kbd> | `scroll_page_down` | Scroll down by one full screen page. |
| <kbd>Shift</kbd> + <kbd>↑</kbd> / <kbd>↓</kbd> | `scroll_line_up` / `down` | Scroll up or down by one line. |
| **Touchpad Scroll** | `pixel_scroll yes` | Kinetic inertia pixel-precise scrolling (`momentum_scroll 0.96`). |
| **Interactive Scrollbar** | `scrollbar scrolled` | Click and drag the interactive side scrollbar with mouse or trackpad. |
| **Session Restore** | `restore_session_after_logout` | (Kitty 0.50+) Automatically saves and restores tabs, splits, and layout on login. |

---

## ⚡ Complete Quick-Reference Table

| Keybinding | Action / Command | Primary Function |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>C</kbd> | `copy_or_interrupt` | Copy selected text OR send interrupt signal |
| <kbd>Ctrl</kbd> + <kbd>V</kbd> | `paste_from_clipboard` | Paste from system clipboard |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> | `new_tab` | Open new tab |
| <kbd>Ctrl</kbd> + <kbd>W</kbd> | `close_tab` | Close active tab |
| <kbd>Ctrl</kbd> + <kbd>Tab</kbd> | `next_tab` | Switch to next tab |
| <kbd>Ctrl</kbd> + <kbd>+</kbd> | `increase_font_size` | Increase text size |
| <kbd>Ctrl</kbd> + <kbd>-</kbd> | `decrease_font_size` | Decrease text size |
| <kbd>Ctrl</kbd> + <kbd>0</kbd> | `reset_font_size` | Reset text size to 11.0pt |
| <kbd>Alt</kbd> + <kbd>1</kbd> | `goto_tab 1` | Switch to Tab 1 |
| <kbd>Alt</kbd> + <kbd>2</kbd> | `goto_tab 2` | Switch to Tab 2 |
| <kbd>Alt</kbd> + <kbd>3</kbd> | `goto_tab 3` | Switch to Tab 3 |
| <kbd>Alt</kbd> + <kbd>4</kbd> | `goto_tab 4` | Switch to Tab 4 |
| <kbd>Alt</kbd> + <kbd>5</kbd> | `goto_tab 5` | Switch to Tab 5 |
| <kbd>Alt</kbd> + <kbd>6</kbd> | `goto_tab 6` | Switch to Tab 6 |
| <kbd>Alt</kbd> + <kbd>7</kbd> | `goto_tab 7` | Switch to Tab 7 |
| <kbd>Alt</kbd> + <kbd>8</kbd> | `goto_tab 8` | Switch to Tab 8 |
| <kbd>Alt</kbd> + <kbd>9</kbd> | `goto_tab 9` | Switch to Tab 9 |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Enter</kbd> | `toggle_fullscreen` | Toggle fullscreen |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>N</kbd> | `new_window` | New window in layout |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Q</kbd> | `close_window` | Close active window split |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>M</kbd> | `send_text all \cg` | FZF unified menu (`fmenu`) |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd> | `send_text all \cf` | FZF file search with preview |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>H</kbd> | `send_text all \cr` | Atuin / command history search |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>J</kbd> | `send_text all \cd` | Zoxide fast directory jump |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>X</kbd> | `send_text all \ck` | Interactive process killer |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd> | `new_tab` | Open new tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | `close_tab` | Close active tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | `previous_tab` | Switch to previous tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>→</kbd> | `next_tab` | Switch to next tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> | `previous_tab` | Switch to previous tab |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>D</kbd> | `detach_tab ask` | Detach tab into separate window |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> | `launch --location=hsplit` | Horizontal window split |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | `launch --location=vsplit` | Vertical window split |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd> | `next_layout` | Cycle window layout |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Z</kbd> | `toggle_layout stack` | Toggle zoom (stack layout) |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> | `detach_window ask` | Detach split window |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | `start_resizing_window` | Interactive split resize mode |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd> | `command_palette` | Fuzzy command palette |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | `kitten choose-files` | Visual fuzzy file picker |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> | `kitten broadcast` | Broadcast typing across all panes |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> | `kitten dnd` | Drag & drop files |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | `kitten hints --type url` | URL hints mode |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | `kitten hints --type path` | Path hints mode |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Y</kbd> | `kitten hints --type hash` | Git hash hints mode |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>O</kbd> | `set_background_opacity 0.75` | Default opacity (75%) |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> | `set_background_opacity 1.0` | 100% Opaque |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>2</kbd> | `set_background_opacity 0.9` | 90% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>3</kbd> | `set_background_opacity 0.8` | 80% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>4</kbd> | `set_background_opacity 0.7` | 70% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>5</kbd> | `set_background_opacity 0.6` | 60% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>6</kbd> | `set_background_opacity 0.5` | 50% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>7</kbd> | `set_background_opacity 0.4` | 40% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>8</kbd> | `set_background_opacity 0.3` | 30% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>9</kbd> | `set_background_opacity 0.2` | 20% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd> | `set_background_opacity 0.1` | 10% Opacity |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F5</kbd> | `load_config_file` | Live reload config |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F6</kbd> | `debug_config` | Show debug configuration |
