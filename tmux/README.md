# Terminal Cheat Sheet

This configuration setup uses **Alacritty** as the terminal emulator and **Tmux** as the terminal multiplexer.

## 🚀 Alacritty Keybindings
*Terminal Emulator Actions*

| Keybinding | Action |
| :--- | :--- |
| `F11` | Toggle Fullscreen |
| `Ctrl` + `Shift` + `N` | New Alacritty Instance |
| `Ctrl` + `Shift` + `C` | Copy |
| `Ctrl` + `Shift` + `V` | Paste |
| `Shift` + `Insert` | Paste Selection |
| `Ctrl` + `+` / `=` | Increase Font Size |
| `Ctrl` + `-` | Decrease Font Size |
| `Ctrl` + `0` | Reset Font Size |
| `Ctrl` + `Shift` + `F` | Search Forward |
| `Ctrl` + `Shift` + `B` | Search Backward |
| `Shift` + `Home` | Scroll to Top |
| `Shift` + `End` | Scroll to Bottom |

---

## 🟢 Tmux Keybindings
*Window & Pane Management*

**Prefix Key:** `Ctrl` + `a`  
*(Press the Prefix key first, release it, then press the action key)*

### Pane Management
| Keybinding | Action |
| :--- | :--- |
| `Prefix` + `|` | Split Pane **Vertically** (Side-by-Side) |
| `Prefix` + `-` | Split Pane **Horizontally** (Top-Bottom) |
| `Alt` + `↑` `↓` `←` `→` | **Switch Focus** between Panes (No Prefix needed) |
| `Mouse Click` | Select Pane |
| `Mouse Drag` | Resize Pane Borders |
| `Ctrl` + `d` / `exit` | Close current Pane |

### Window (Tab) Management
| Keybinding | Action |
| :--- | :--- |
| `Prefix` + `c` | Create **New Window** |
| `Prefix` + `n` | Go to **Next** Window |
| `Prefix` + `p` | Go to **Previous** Window |
| `Prefix` + `1`...`9` | Go to Window Number |
| `Prefix` + `w` | List / Select Windows interactively |
| `Prefix` + `,` | Rename current Window |

### Session Management
| Keybinding | Action |
| :--- | :--- |
| `Prefix` + `d` | **Detach** from session (leaves it running in background) |
| `tmux a` | **Attach** to the last session (run in terminal) |
| `Prefix` + `s` | Switch between available sessions |

### General
| Keybinding | Action |
| :--- | :--- |
| `Prefix` + `?` | Show all Tmux keybindings |
| `Prefix` + `:` | Enter Command Prompt |
