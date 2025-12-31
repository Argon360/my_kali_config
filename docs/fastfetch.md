# Fastfetch Configuration

## Purpose

**Fastfetch** is the system information tool that runs when a new interactive shell session starts. 
It provides a quick snapshot of the hardware and software environment.

---

## Layout

The output is structured into three distinct boxes:

### 1. 🖥️ Hardware
- **Host**: Model/Type
- **CPU**: Model & Core count
- **GPU**: Model
- **Display**: Resolution
- **Disk**: Usage
- **Memory**: RAM & Swap usage

### 2. 💿 Software
- **OS**: Kali Linux version
- **Packages**: Count
- **Kernel**: Version
- **WM/DE**: Window Manager / Desktop Environment
- **Terminal**: Terminal Emulator info
- **Theme**: GTK Theme active

### 3. ⏱️ Uptime / Age
- **OS Age**: Days since installation (calculated from root filesystem creation)
- **Uptime**: Current session duration

---

## Customization

- **Logo**: Loads a custom text file from `~/.config/kali/branding/about.txt`.
- **Colors**: Uses Green for Hardware, Blue for Software, Magenta for Time.
- **Borders**: Custom ASCII borders wrap each section.

---

## Configuration File

Located at: `~/.config/fastfetch/config.jsonc`
