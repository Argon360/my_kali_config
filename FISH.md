# 🐟 Fish Shell Configuration – Operations Manual

> Environment: Linux (Pop!_OS / Debian / Ubuntu / Kali)  
> Shell: fish  
> Editor: Neovim (LazyVim)  
> Philosophy: Safety, clarity, repeatability, low cognitive load

---

## 1. Core Principles

- Prefer **explicit commands** over clever shortcuts
- Use **functions** for destructive or irreversible actions
- Reduce decision fatigue with **repeatable workflows**
- Optimize for **recovery**, not raw speed
- Terminal is the **primary control plane**

---

## 2. Environment Defaults

- Default editor:
  - `EDITOR=nvim`
  - `VISUAL=nvim`
- Git pager:
  - `delta`
- Search:
  - `fzf` + `bat`
- Prompt:
  - `starship`
- History:
  - `atuin`
- Navigation:
  - `zoxide`

---

## 3. File System & Navigation

### Listing & Trees
| Command | Description |
|------|------------|
| `ls` | Enhanced list (icons, dirs first) |
| `ll` | Long list |
| `la` | Long list (all files) |
| `lt` | Tree (level 3) |
| `tree1` | Tree (level 1) |
| `tree2` | Tree (level 2) |

### Disk Usage
| Command | Description |
|------|------------|
| `du` | Disk usage (dust) |
| `duh` | Disk usage (human-readable) |
| `duh1` | Disk usage (top-level only) |
| `dfh` | Disk free (filesystem + type) |

### Counts
| Command | Description |
|------|------------|
| `fcount` | Count files recursively |
| `dcount` | Count directories recursively |

### Navigation
| Command | Description |
|------|------------|
| `..` | Up one directory |
| `...` | Up two directories |
| `home` | Go to `$HOME` |

---

## 4. System / Infrastructure

### Monitoring
| Command | Description |
|------|------------|
| `top` | btop |
| `mem` | Memory usage |
| `cpu` | CPU info |
| `ports` | Listening ports |
| `routes` | Routing table |

### Networking
| Command | Description |
|------|------------|
| `ipinfo` | Local IP addresses (colored) |
| `myip` | Public IP |
| `dnscheck` | DNS resolver status |

---

## 5. System Maintenance

| Command | Description |
|------|------------|
| `sysup` | Full system update + cleanup |
| `fixdpkg` | Fix broken dpkg state |
| `please` | Alias for `sudo` |

---

## 6. Git – Professional Workflow

### Status & Context
| Command | Description |
|------|------------|
| `gs` | Git status |
| `gss` | Git status (short + branch) |

### Add
| Command | Description |
|------|------------|
| `ga` | Stage files |
| `gaa` | Stage everything |

### Commit
| Command | Description |
|------|------------|
| `gc` | Commit (opens Neovim) |
| `gcm "msg"` | Commit with message |
| `gca` | Amend last commit |
| `gwip` | WIP checkpoint commit |

### Logs
| Command | Description |
|------|------------|
| `gl` | One-line log |
| `glg` | Graph log (all branches) |
| `glast` | Last commit with stats |

### Diff & Inspection
| Command | Description |
|------|------------|
| `gd` | Working tree diff |
| `gds` | Staged diff |
| `gshow` | Show commit |
| `gblame` | Blame with rename detection |

### Branching
| Command | Description |
|------|------------|
| `gb` | List branches |
| `gba` | List all branches |
| `gbranch` | Current branch |
| `gsw` | Switch branch |
| `gswc` | Create & switch branch |

### Merge / Rebase
| Command | Description |
|------|------------|
| `gm` | Merge |
| `grb` | Rebase |
| `grbi` | Interactive rebase |

### Remote
| Command | Description |
|------|------------|
| `gf` | Fetch |
| `gpl` | Pull |
| `gplr` | Pull with rebase |
| `gp` | Push |
| `gps` | Push & set upstream |

### Undo / Recovery
| Command | Description |
|------|------------|
| `gunstage` | Unstage files |
| `gundo` | Restore working tree |
| `grs` | Reset |
| `gsoft` | Soft reset HEAD~1 |
| `grsh` | Hard reset |
| `gclean` | Delete merged local branches |

### Submodules
| Command | Description |
|------|------------|
| `gsm` | Submodule command |
| `gsmi` | Init & update recursively |
| `gsmu` | Update submodules from remote |

---

## 7. Neovim / Development

| Command | Description |
|------|------------|
| `nv` | Open Neovim |
| `nvdiff` | Neovim diff mode |
| `nvlog` | Git log inside Neovim |
| `scratch` | Empty scratch buffer |
| `cf` | Edit fish config |
| `cn` | Edit Neovim config |

---

## 8. Utilities / Quality of Life

| Command | Description |
|------|------------|
| `cls`, `c` | Clear screen |
| `now` | Current timestamp |
| `week` | Current week number |
| `weather` | Terminal weather |
| `genpass` | Random password |
| `json` | Pretty-print JSON |

### Clipboard
| Command | Description |
|------|------------|
| `clip` | Copy to clipboard |
| `paste` | Paste from clipboard |

---

## 9. Shell Management

| Command | Description |
|------|------------|
| `reload` | Reload fish config |
| `restart` | Restart shell |
| `fontreload` | Reload font cache |
| `ffpreview` | Fastfetch preview |
| `kreload` | Restart kitty |
| `reloadall` | Reload everything |

---

## 10. High-Leverage Fish Functions (CRITICAL)

### `workstart`
Establish context at the start of a session.
```sh
workstart
````

### `workend`

End session with a safety check.

```sh
workend
```

### `gcommit`

Smart commit (prevents empty commits).

```sh
gcommit
```

### `gpushsafe`

Guarded push with branch visibility and confirmation.

```sh
gpushsafe
```

### `greset-hard-safe`

Protected hard reset.

```sh
greset-hard-safe
```

### `weeklyreset`

Weekly hygiene (system + Git).

```sh
weeklyreset
```

---

## 11. Recommended Daily Workflow

```text
workstart
→ edit (Neovim)
→ gd / gds
→ gcommit
→ gpushsafe
→ workend
```

---

## 12. Final Notes

* This shell is **opinionated by design**
* If something feels “slow”, it is probably **saving you from a mistake**
* Stability beats novelty
* Discipline beats configuration

> Tools are finished.
> Now execution matters.

