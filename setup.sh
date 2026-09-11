#!/bin/bash

# ==============================================================================
#  My Kali / Linux Terminal Configuration - Automated Installer (CLI Only)
# ==============================================================================
#
#  This script installs the CLI/terminal environment.
#  It excludes Hyprland and Caelestia shell configurations.
#
#  1. Installs System Dependencies (Apt, Dnf, or Pacman)
#  2. Copies/Deploys configurations to ~/.config
#  3. Deploys custom desktop applications to ~/.local/share/applications
#  4. Configures Fish & Zsh shells
#  5. Fixes hardcoded home paths dynamically
#
# ==============================================================================

set -e  # Exit on error

# --- Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config/config_backup_$(date +%s)"

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Prerequisites Check ---
if [ "$EUID" -eq 0 ]; then
    error "Please run this script as a normal user (not root). Sudo will be requested when needed."
fi

# --- 1. System Updates & Package Installation ---
install_packages() {
    # Detect Package Manager
    if command -v pacman >/dev/null; then
        PM="pacman"
        UPDATE_CMD="sudo pacman -Sy"
        INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    elif command -v dnf >/dev/null; then
        PM="dnf"
        UPDATE_CMD="sudo dnf check-update"
        INSTALL_CMD="sudo dnf install -y"
    elif command -v apt >/dev/null; then
        PM="apt"
        UPDATE_CMD="sudo apt update -y"
        INSTALL_CMD="sudo apt install -y"
    else
        error "No supported package manager found (dnf, apt or pacman)."
    fi

    log "Using $PM package manager..."
    log "Updating package lists..."
    $UPDATE_CMD || true # dnf check-update returns 100 if updates are available

    # Core Utils & Shell (Hyprland / Caelestia packages removed)
    PACKAGES=(
        git
        curl
        wget
        kitty
        fish
        zsh
        fzf
        bat
        ripgrep
        fd-find
        zoxide
        neovim
        eza
        fastfetch
        atuin
        btop
        lazygit
        github-cli
        dust
        flatpak
        nodejs
        npm
        wl-clipboard
        xclip
        trash-cli
        gnome-keyring
        inotify-tools
        jq
        putty
        openconnect
        vivaldi
        inetutils
    )

    # Distro-specific package name adjustments & Extras
    if [ "$PM" == "pacman" ]; then
        PACKAGES=("${PACKAGES[@]/fd-find/fd}")
        PACKAGES+=(base-devel git-delta unp unzip ttf-jetbrains-mono-nerd)
    elif [ "$PM" == "dnf" ]; then
        log "Configuring Fedora specific repositories..."
        sudo dnf install -y dnf-plugins-core util-linux-user
        
        # Enable COPR for lazygit, git-delta, eza (F42+) and fonts
        sudo dnf copr enable -y dejan/lazygit
        sudo dnf copr enable -y elxreno/jetbrains-mono-fonts
        sudo dnf copr enable -y alternateved/eza
        
        PACKAGES+=(jetbrains-mono-fonts git-delta file-unpack)
        PACKAGES=("${PACKAGES[@]/fd-find/fd-find}") # Fedora uses fd-find
    else
        # Debian/Kali
        PACKAGES+=(build-essential git-delta unp unzip)
        # Adjust vivaldi package name for Debian
        PACKAGES=("${PACKAGES[@]/vivaldi/vivaldi-stable}")
    fi

    log "Installing packages..."
    for pkg in "${PACKAGES[@]}"; do
        if $INSTALL_CMD "$pkg" 2>/dev/null; then
            : # Success
        else
            warn "Could not install $pkg via $PM. It might need manual installation."
        fi
    done

    # Fix bat -> batcat symlink
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        log "Linking batcat to bat..."
        mkdir -p ~/.local/bin
        ln -sf "$(command -v batcat)" ~/.local/bin/bat
    fi

    # Fix fdfind -> fd symlink
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        log "Linking fdfind to fd..."
        mkdir -p ~/.local/bin
        ln -sf "$(command -v fdfind)" ~/.local/bin/fd
    fi
}

# --- 2. External Tools & Manual Installation ---
install_externals() {
    # Starship
    if ! command -v starship &> /dev/null; then
        log "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        success "Starship already installed"
    fi

    # Todoist Desktop App (Flatpak)
    if ! flatpak list 2>/dev/null | grep -qi "com.todoist.Todoist"; then
        log "Installing native Todoist desktop app via Flatpak..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
        flatpak install -y flathub com.todoist.Todoist || warn "Failed to install Todoist via Flatpak"
    else
        success "Todoist native app already installed"
    fi

    # Clean up obsolete Bitwarden if present
    if command -v bitwarden &>/dev/null || flatpak list 2>/dev/null | grep -qi "com.bitwarden.desktop"; then
        log "Removing obsolete Bitwarden installation..."
        if [ "$PM" == "pacman" ] && pacman -Qi bitwarden &>/dev/null; then
            sudo pacman -Rns --noconfirm bitwarden 2>/dev/null || true
        elif [ "$PM" == "apt" ] && dpkg -s bitwarden &>/dev/null; then
            sudo apt remove -y bitwarden 2>/dev/null || true
        elif [ "$PM" == "dnf" ] && rpm -q bitwarden &>/dev/null; then
            sudo dnf remove -y bitwarden 2>/dev/null || true
        fi
        flatpak uninstall -y com.bitwarden.desktop 2>/dev/null || true
    fi

    # Proton Pass Desktop App
    if ! command -v proton-pass &> /dev/null && ! flatpak list 2>/dev/null | grep -qi "me.proton.Pass"; then
        log "Installing Proton Pass desktop app..."
        if [ "$PM" == "pacman" ] && pacman -Si proton-pass &>/dev/null; then
            sudo pacman -S --noconfirm proton-pass || warn "Failed to install proton-pass via pacman"
        else
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
            flatpak install -y flathub me.proton.Pass || warn "Failed to install Proton Pass via Flatpak"
        fi
    else
        success "Proton Pass already installed"
    fi

    # Nerd Font (Manual for Debian/Kali if not Fedora/Arch)
    if [ "$PM" == "apt" ]; then
        if ! fc-list | grep -qi "JetBrainsMono"; then
            log "Installing JetBrainsMono Nerd Font..."
            FONT_DIR="$HOME/.local/share/fonts"
            mkdir -p "$FONT_DIR"
            ZIP_PATH="/tmp/JetBrainsMono.zip"
            wget -O "$ZIP_PATH" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
            unzip -o "$ZIP_PATH" -d "$FONT_DIR"
            rm "$ZIP_PATH"
            fc-cache -fv > /dev/null
            success "JetBrainsMono Nerd Font installed"
        fi
    fi
}

# --- 3. Deploy Configurations ---
deploy_configs() {
    log "Deploying configurations..."

    mkdir -p "$TARGET_DIR"

    # Files and Directories to install/copy
    ITEMS=(
        "kitty"
        "fish"
        "zsh"
        "fastfetch"
        "nvim"
        "bat"
        "atuin"
        "btop"
        "environment.d"
        "starship.toml"
    )

    for item in "${ITEMS[@]}"; do
        SRC="$SCRIPT_DIR/$item"
        DEST="$TARGET_DIR/$item"

        # Check if source exists in the repo folder we are running from
        if [ -e "$SRC" ]; then
            # If we are NOT running directly inside ~/.config, copy files
            if [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
                if [ -e "$DEST" ]; then
                    warn "Backing up existing $item..."
                    mkdir -p "$BACKUP_DIR"
                    mv "$DEST" "$BACKUP_DIR/"
                fi
                log "Copying $item to $TARGET_DIR..."
                cp -r "$SRC" "$DEST"
            fi
            success "Deployed $item"
        fi
    done

    # Deploy Desktop Entries
    if [ -d "$SCRIPT_DIR/applications" ]; then
        log "Deploying desktop applications..."
        mkdir -p "$HOME/.local/share/applications"
        cp -r "$SCRIPT_DIR/applications/"* "$HOME/.local/share/applications/"
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$HOME/.local/share/applications"
        fi
        success "Deployed applications"
    fi

    # Deploy Custom Binaries
    if [ -d "$SCRIPT_DIR/bin" ]; then
        log "Deploying custom binaries..."
        mkdir -p "$HOME/.local/bin"
        cp -r "$SCRIPT_DIR/bin/"* "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/"*
        success "Deployed custom binaries"
    fi

    # Deploy Autostart Entries
    if [ -d "$SCRIPT_DIR/autostart" ]; then
        log "Deploying autostart entries..."
        mkdir -p "$HOME/.config/autostart"
        cp -r "$SCRIPT_DIR/autostart/"* "$HOME/.config/autostart/"
        success "Deployed autostart entries"
    fi

    # Apply Touchpad Drag Lock & Gestures
    if [ -x "$HOME/.local/bin/apply-touchpad-drag-lock" ]; then
        log "Applying touchpad drag-lock and gestures configuration..."
        "$HOME/.local/bin/apply-touchpad-drag-lock" 2>/dev/null || true
        success "Touchpad drag-lock and gestures applied"
    fi

    # Deploy KWin Scripts (Kyanite dynamic workspaces)
    if [ -d "$SCRIPT_DIR/kwin/scripts/kyanite" ] && command -v kpackagetool6 &>/dev/null; then
        log "Installing Kyanite dynamic workspaces KWin script..."
        kpackagetool6 --type KWin/Script --upgrade "$SCRIPT_DIR/kwin/scripts/kyanite" 2>/dev/null || \
        kpackagetool6 --type KWin/Script --install "$SCRIPT_DIR/kwin/scripts/kyanite" 2>/dev/null || true
        if command -v kwriteconfig6 &>/dev/null; then
            kwriteconfig6 --file kwinrc --group "Plugins" --key "kyaniteEnabled" "true"
            if command -v qdbus6 &>/dev/null; then
                qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
            fi
        fi
        success "Deployed Kyanite dynamic workspaces"
    fi

    # Deploy Systemd User Services
    if [ -d "$SCRIPT_DIR/systemd/user" ]; then
        log "Deploying systemd user services..."
        mkdir -p "$HOME/.config/systemd/user"
        cp -r "$SCRIPT_DIR/systemd/user/"* "$HOME/.config/systemd/user/"
        if command -v systemctl &> /dev/null; then
            systemctl --user daemon-reload 2>/dev/null || true
            systemctl --user enable --now agy-session-tracker.path 2>/dev/null || true
            systemctl --user enable --now kitty-daemon.service 2>/dev/null || true
        fi
        success "Deployed systemd user services"
    fi
}

# --- 4. Fish Setup ---
setup_fish() {
    log "Configuring Fish Shell..."
    if command -v fish &> /dev/null; then
        # Install Fisher
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" || warn "Fisher install failed/skipped"
        
        # Update plugins
        if [ -f "$TARGET_DIR/fish/fish_plugins" ]; then
            fish -c "fisher update"
        fi
    fi
}

# --- 5. Zsh Setup ---
setup_zsh() {
    log "Configuring Zsh..."
    ZSH_PLUGIN_DIR="$HOME/.config/zsh/plugins"
    mkdir -p "$ZSH_PLUGIN_DIR"

    # Clone Plugins
    clone_plugin() {
        REPO=$1
        DEST=$2
        if [ ! -d "$DEST" ]; then
            log "Cloning $REPO..."
            git clone --depth=1 "$REPO" "$DEST"
        else
            success "$(basename $DEST) already installed"
        fi
    }

    clone_plugin "https://github.com/romkatv/powerlevel10k.git" "$ZSH_PLUGIN_DIR/powerlevel10k"
    clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    clone_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
    clone_plugin "https://github.com/zsh-users/zsh-history-substring-search.git" "$ZSH_PLUGIN_DIR/zsh-history-substring-search"
    clone_plugin "https://github.com/Aloxaf/fzf-tab" "$ZSH_PLUGIN_DIR/fzf-tab"

    # Setup .zshrc in home directory
    ZSHRC_CONTENT='# =============================================================================
# ZSH Main Entry Point (Auto-Generated)
# =============================================================================

# Safety: only interactive shells
[[ -o interactive ]] || return

# -----------------------------------------------------------------------------
# 1. Environment Variables
# -----------------------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

# Base directory for modular config
ZSH_CONFIG="$HOME/.config/zsh"

# -----------------------------------------------------------------------------
# 2. Load Modular Configs
# -----------------------------------------------------------------------------
# Load modules in explicit order to handle dependencies

zsh_modules=(
    00-env.zsh
    10-tools.zsh
    15-options.zsh
    20-prompt.zsh
    30-history.zsh
    40-navigation.zsh
    50-bindings.zsh
    60-aliases.zsh
    70-extras.zsh
    80-completion.zsh
    85-fzf.zsh
    claude.zsh
    90-plugins.zsh
)

for module in $zsh_modules; do
    [[ -f "$ZSH_CONFIG/$module" ]] && source "$ZSH_CONFIG/$module"
done

# -----------------------------------------------------------------------------
# 3. Startup
# -----------------------------------------------------------------------------
if command -v fastfetch >/dev/null; then
  fastfetch
fi
'
    
    # Write .zshrc if it doesn'\''t exist or if forced
    if [ ! -f "$HOME/.zshrc" ] || grep -q "Auto-Generated" "$HOME/.zshrc"; then
        echo "$ZSHRC_CONTENT" > "$HOME/.zshrc"
        success "Updated ~/.zshrc"
    else
        warn "~/.zshrc exists and is not auto-generated. Skipping overwrite."
        warn "Please manually verify it sources ~/.config/zsh files."
    fi
}

# --- 6. User Directories & Bin Setup ---
setup_user_dirs() {
    log "Setting up user directories..."
    mkdir -p "$HOME/.local/bin"
}

# --- 7. Fix Hardcoded Paths ---
fix_hardcoded_paths() {
    log "Fixing hardcoded paths in configurations..."
    
    # Files to process in ~/.config and ~/.local/share/applications
    FILES=(
        "$TARGET_DIR/zsh/claude.zsh"
        "$TARGET_DIR/fish/fish_variables"
        "$TARGET_DIR/atuin/atuin-receipt.json"
        "$HOME/.local/share/applications/eve-ng-integration.desktop"
        "$HOME/.local/share/applications/kitty.desktop"
    )

    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            log "Processing $file..."
            # Replace /home/argon with the actual $HOME path
            sed -i "s|/home/argon|$HOME|g" "$file"
        fi
    done
}

# --- 8. Set Default Login Shell ---
set_default_shell() {
    log "Configuring default login shell..."
    local target_shell
    target_shell=$(command -v zsh || command -v fish)
    if [ -n "$target_shell" ]; then
        local current_shell
        current_shell=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)
        if [ "$current_shell" != "$target_shell" ]; then
            log "Switching default shell from $current_shell to $target_shell..."
            if command -v chsh >/dev/null; then
                chsh -s "$target_shell" "$USER" 2>/dev/null || sudo chsh -s "$target_shell" "$USER" 2>/dev/null || warn "Could not set default shell automatically. Run: chsh -s $target_shell"
            fi
        else
            success "Default shell is already $target_shell"
        fi
    fi
}

# --- Main ---
main() {
    log "Starting Automated Setup..."
    log "Source Dir: $SCRIPT_DIR"
    
    install_packages
    install_externals
    deploy_configs
    setup_user_dirs
    setup_fish
    setup_zsh
    fix_hardcoded_paths
    set_default_shell

    success "Automated Setup Complete!"
    if [ -d "$BACKUP_DIR" ]; then
        log "Old configs backed up to: $BACKUP_DIR"
    fi
    log "Please restart your terminal."
}

main
