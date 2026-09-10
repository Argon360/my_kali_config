# Fastfetch Configuration

## Purpose

**Fastfetch** is the system information tool that runs when a new interactive shell session starts. 
It provides a quick snapshot of the hardware and software environment.

---

# Fastfetch Configuration

## Purpose

**Fastfetch** is the system information tool executed on interactive shell startups and via `ffpreview`. It provides a sleek, modern snapshot of hardware, software, and system health.

---

## Layout & Aesthetic

The configuration uses a modern **Pill-Badge Card** layout with JetBrainsMono Nerd Font icons and Powerline-style progress bars:

```
                            ╭───────────╮  
                            │  user    │  argon@Growler
                            ├───────────┤  
                            │  distro  │  CachyOS x86_64
      ...........           │  kernel  │  Linux 7.2.3-1-cachyos
     /,,,,...../            │ 󰅐 uptime  │  1 hour, 3 mins
    /,,,..,,../   ()        │  desktop │  KDE Plasma 6.7.5
   /,,,,../                 │ 󱂬 wm      │  KWin (Wayland)
  /,,,.../     /'\          │  term    │  kitty 0.48.2
 /,...../      \,/          │  shell   │  zsh 5.9
 \,,,,,,\\             _    │ 󰏖 pkgs    │  1498 (pacman)
  \,,....\\           / \   ├───────────┤  
   \...,..\\          \_/   │  host    │  Cyborg 15 A12UCX (REV:1.0)
    \..,,,,,,,,,,,,/        │  cpu     │  12th Gen Intel Core i5-12450H (8+4) @ 4.40 GHz
     \,,........,,/         │ 󰢮 gpu     │  GeForce RTX 2050 [Discrete]
                            │ 󰢮 gpu     │  UHD Graphics [Integrated]
                            │ 󰍹 display │  1920x1080 @ 144Hz (16")
                            │  memory  │   4.47 GiB / 15.32 GiB (29%)
                            │ 󰓡 swap    │   216.00 KiB / 23.32 GiB (0%)
                            │ 󰋊 disk    │   14.52 GiB / 120.00 GiB (12%) - btrfs
                            │  battery │   (93%) [AC Connected, Charging]
                            ├───────────┤  
                            │  colors  │  ● ● ● ● ● ● ● ●
                            ╰───────────╯  
```

### 1.  User & Host
- Stylized dynamic title: `{user}@{host}`

### 2. 💿 System & Desktop
- **Distro**: OS name and architecture (`CachyOS x86_64`)
- **Kernel**: Linux kernel release
- **Uptime**: Session uptime
- **Desktop**: Desktop environment (`KDE Plasma 6.7.5`)
- **WM**: Window manager with display protocol (`KWin (Wayland)`)
- **Terminal & Shell**: Active terminal and shell version
- **Packages**: Installed pacman package count

### 3. 🖥️ Hardware & Metrics
- **Host**: Machine model / motherboard
- **CPU**: Model with performance/efficiency core breakdown
- **Load**: Real-time CPU usage percentage with smooth progress bar
- **GPU**: Discrete and Integrated GPU detection
- **Display**: Resolution, refresh rate, and physical display size
- **Memory**: RAM usage with smooth Powerline progress bar & percentage
- **Swap**: Swap usage with smooth progress bar
- **Disk**: Primary root (`/`) filesystem usage with progress bar & filesystem type
- **Battery**: Charge level with bar and charging status
- **Palette**: Terminal 16-color circular swatches

---

## Dynamic Progress Bars & Live Watch Mode

Fastfetch supports both static startup snapshots and live-updating dynamic monitoring:

- **`ff`**: Standard instant snapshot.
- **`ffpreview`**: Preview explicit `~/.config/fastfetch/config.jsonc`.
- **`ffwatch`** (`fastfetch --watch`): **Live Dynamic Mode**. Continuously refreshes the progress bars (CPU Load, Memory, Swap, Battery) in real-time right inside the terminal.

### Dynamic Thresholds
The progress bars dynamically shift color states based on capacity:
- 🟢 **Normal**: < 50%
- 🟡 **Elevated**: 50% - 80%
- 🔴 **High/Critical**: > 80%
*(Battery inverts thresholds to alert when power is depleted).*

---

## Configuration File

- Repository: `fastfetch/config.jsonc`
- Deployed location: `~/.config/fastfetch/config.jsonc`
