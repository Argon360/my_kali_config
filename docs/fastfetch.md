# Fastfetch Configuration

## Purpose

**Fastfetch** is the system information tool executed on interactive shell startups and via `ff`. It provides a sleek, modern snapshot of hardware, software, and system health.

---

## 1. Compact Default Layout (`ff` / `fastfetch`)

The default configuration is tailored to be **compact (11 lines)**, matching the exact height of the small CachyOS ASCII logo without wasting terminal vertical space:

```
      ...........           ╭───────────╮  
     /,,,,...../            │  user    │  argon@Growler
    /,,,..,,../   ()        │  distro  │  CachyOS x86_64
   /,,,,../                 │  kernel  │  Linux 7.2.3-1-cachyos
  /,,,.../     /'\          │ 󰅐 uptime  │  1 hour, 13 mins
 /,...../      \,/          │  desktop │  KDE Plasma 6.7.5
 \,,,,,,\\             _    │  shell   │  zsh 5.9
  \,,....\\           / \   │  cpu     │  12th Gen Intel(R) Core(TM) i5-12450H
   \...,..\\          \_/   │  memory  │   4.42 GiB / 15.32 GiB (29%)
    \..,,,,,,,,,,,,/        │ 󰋊 disk    │   14.52 GiB / 120.00 GiB (12%) - btrfs
     \,,........,,/         │  colors  │  ● ● ● ● ● ● ● ●
                            ╰───────────╯  
```

### Key Highlights
- **1:1 Alignment**: The 11-line pill badge matches the 11-line small CachyOS logo line-for-line.
- **Powerline Progress Bars**: Curved Powerline glyphs (``) with multi-color dynamic threshold colors.
- **Instant Speed**: Omits heavy sampling modules for sub-30ms shell startup times.

---

## 2. Full Extended Dashboard (`fffull` & `ffwatch`)

When you want a complete hardware & software breakdown or a live real-time dashboard:

- **`fffull`**: Full static snapshot including dual GPUs, display details, real-time CPU load, swap, and battery.
- **`ffwatch`**: Real-time live updating watch mode (`--watch`). Continuously updates CPU load, memory, swap, and battery in place.

```
                            ╭───────────╮  
                            │  user    │  argon@Growler
                            ├───────────┤  
                            │  distro  │  CachyOS x86_64
      ...........           │  kernel  │  Linux 7.2.3-1-cachyos
     /,,,,...../            │ 󰅐 uptime  │  1 hour, 11 mins
    /,,,..,,../   ()        │  desktop │  KDE Plasma 6.7.5
   /,,,,../                 │ 󱂬 wm      │  KWin (Wayland)
  /,,,.../     /'\          │  term    │  kitty 0.48.2
 /,...../      \,/          │  shell   │  zsh 5.9
 \,,,,,,\\             _    │ 󰏖 pkgs    │  1498 (pacman)
  \,,....\\           / \   ├───────────┤  
   \...,..\\          \_/   │  host    │  Cyborg 15 A12UCX (REV:1.0)
    \..,,,,,,,,,,,,/        │  cpu     │  12th Gen Intel(R) Core(TM) i5-12450H (8+4) @ 4.40 GHz
     \,,........,,/         │ 󰓅 load    │   (15%)
                            │ 󰢮 gpu     │  GeForce RTX 2050 [Discrete]
                            │ 󰢮 gpu     │  UHD Graphics [Integrated]
                            │ 󰍹 display │  1920x1080 @ 144Hz (16")
                            │  memory  │   4.45 GiB / 15.32 GiB (29%)
                            │ 󰓡 swap    │   216.00 KiB / 23.32 GiB (0%)
                            │ 󰋊 disk    │   14.52 GiB / 120.00 GiB (12%) - btrfs
                            │  battery │   (95%) [AC Connected, Charging]
                            ├───────────┤  
                            │  colors  │  ● ● ● ● ● ● ● ●
                            ╰───────────╯  
```

---

## 3. Shell Shortcuts

| Command | Description |
|---|---|
| `ff` / `fastfetch` | Fast, compact 11-line fetch |
| `ffpreview` | Preview primary `~/.config/fastfetch/config.jsonc` |
| `fffull` | Comprehensive hardware & software breakdown |
| `ffwatch` | Real-time live animated dashboard (`Ctrl+C` to stop) |

---

## Configuration Files

- Primary Compact: `~/.config/fastfetch/config.jsonc` (Repo: `fastfetch/config.jsonc`)
- Full Extended: `~/.config/fastfetch/config-full.jsonc` (Repo: `fastfetch/config-full.jsonc`)
