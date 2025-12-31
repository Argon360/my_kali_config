#!/bin/bash

# ==============================================================================
#  My Kali / Linux Terminal Configuration - Automated Installer
# ==============================================================================
#
#  This script installs the environment using the files present in this directory.
#  It does NOT clone from git. It assumes you have downloaded/cloned this
#  repository and are running the script from within it.
#
#  1. Installs System Dependencies
#  2. Copies/Deploys configurations to ~/.config
#  3. Configures Fish shell and Starship
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
    log "Updating package lists..."
    sudo apt update -y

    # Core Utils & Shell
    PACKAGES=(
        git
        curl
        wget
        build-essential
        kitty
        fish
        fzf
        bat
        ripgrep
        fd-find
        zoxide
        neovim
        eza
        fastfetch
        atuin
    )

    log "Installing apt packages..."
    for pkg in "${PACKAGES[@]}"; do
        if sudo apt install -y "$pkg" 2>/dev/null; then
            : # Success
        else
            warn "Could not install $pkg via apt. It might need manual installation."
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

# --- 2. External Tools Installation ---
install_externals() {
    # Starship
    if ! command -v starship &> /dev/null; then
        log "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        success "Starship already installed"
    fi
}

# --- 3. Deploy Configurations ---
deploy_configs() {
    log "Deploying configurations..."

    # Check if we are running FROM ~/.config (i.e. user cloned directly into .config)
    if [ "$SCRIPT_DIR" == "$TARGET_DIR" ]; then
        success "Script is running from ~/.config. Files are already in place."
        return
    fi

    mkdir -p "$TARGET_DIR"

    # Files and Directories to install
    ITEMS=(
        "kitty"
        "fish"
        "fastfetch"
        "nvim"
        "bat"
        "atuin"
        "btop"
        "ghostty"
        "lazygit"
        "starship.toml"
    )

    for item in "${ITEMS[@]}"; do
        SRC="$SCRIPT_DIR/$item"
        DEST="$TARGET_DIR/$item"

        if [ -e "$SRC" ]; then
            # If destination exists, backup
            if [ -e "$DEST" ]; then
                warn "Backing up existing $item..."
                mkdir -p "$BACKUP_DIR"
                mv "$DEST" "$BACKUP_DIR/"
            fi
            
            log "Copying $item to $TARGET_DIR..."
            cp -r "$SRC" "$DEST"
            success "Installed $item"
        else
            # Only warn if it's a directory we expected to exist, silence otherwise for optional files
            # But here we assume the repo structure is consistent.
            :
        fi
    done
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

# --- Main ---
main() {
    log "Starting Setup..."
    log "Source Dir: $SCRIPT_DIR"
    
    install_packages
    install_externals
    deploy_configs
    setup_fish

    success "Setup Complete!"
    if [ -d "$BACKUP_DIR" ]; then
        log "Old configs backed up to: $BACKUP_DIR"
    fi
    log "Please restart your terminal."
}

main