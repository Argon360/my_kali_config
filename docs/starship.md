# Starship Prompt Configuration

## Purpose

**Starship** provides a cross-shell, high-performance command prompt. 
This configuration is tuned for:
- **Clarity**: High-contrast colors.
- **Context**: Showing git status, language versions, and execution time.
- **Aesthetics**: A "Powerline" style with rainbow separators.

---

## Visual Style

The prompt uses a "Rainbow" flow, where each segment flows into the next using powerline separators (``).

**Palette:**
- **User/Host**: Purple (`#9A348E`)
- **Directory**: Pink (`#DA627D`)
- **Git**: Orange (`#FCA17D`)
- **Languages**: Light Blue (`#86BBD8`)
- **Docker**: Teal (`#06969A`)
- **Time**: Dark Blue (`#33658A`)

---

## Modules

### 👤 User & Context
- **Username**: Always shown in white on purple.
- **Hostname**: Hidden (unless over SSH, typically).
- **Directory**: Truncated to 3 levels. Common paths (Documents, Downloads) use icons.

### 🛠️ Git
Shows:
- Current branch
- Status symbols (modified, staged, ahead/behind)
- Detailed divergence info

### 📦 Toolchains
Displays version numbers for the following *only when relevant files are present*:
- C / C++
- Go
- Rust
- Node.js
- Java / Gradle
- Python (via `python` module, if enabled)
- Docker
- and more...

### ⏱️ Performance
- **Time**: Shows current time (24h format) at the end of the prompt.
- **Execution Duration**: (Implicitly handled by Starship if a command takes too long).

---

## Configuration File

Located at: `~/.config/starship.toml`
