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
#  3. Configures Fish & Zsh shells
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
    if command -v dnf >/dev/null; then
        PM="dnf"
        UPDATE_CMD="sudo dnf check-update"
        INSTALL_CMD="sudo dnf install -y"
    elif command -v apt >/dev/null; then
        PM="apt"
        UPDATE_CMD="sudo apt update -y"
        INSTALL_CMD="sudo apt install -y"
    else
        error "No supported package manager found (dnf or apt)."
    fi

    log "Using $PM package manager..."
    log "Updating package lists..."
    $UPDATE_CMD || true # dnf check-update returns 100 if updates are available

    # Core Utils & Shell
    PACKAGES=(
        git
        curl
        wget
        build-essential
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
    )

    # Distro-specific package name adjustments
    if [ "$PM" == "dnf" ]; then
        # On Fedora, some packages have different names
        # build-essential -> @development-tools
        # fd-find -> fd-find (same name)
        PACKAGES=("${PACKAGES[@]/build-essential/@development-tools}")
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
        "ghostty"
        "lazygit"
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
    ZSHRC_CONTENT="# =============================================================================
# ZSH Main Entry Point (Auto-Generated)
# =============================================================================

# Safety: only interactive shells
[[ -o interactive ]] || return

# -----------------------------------------------------------------------------
# 1. Environment Variables
# -----------------------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim
export PATH=\"$HOME/.local/bin:$HOME/go/bin:$PATH"

# Base directory for modular config
ZSH_CONFIG="$HOME/.config/zsh"

# -----------------------------------------------------------------------------
# 2. Load Modular Configs
# -----------------------------------------------------------------------------
# Load modules in explicit order to handle dependencies

# Core
[[ -f "$ZSH_CONFIG/00-env.zsh" ]] && source "$ZSH_CONFIG/00-env.zsh"
[[ -f "$ZSH_CONFIG/10-tools.zsh" ]] && source "$ZSH_CONFIG/10-tools.zsh"
[[ -f "$ZSH_CONFIG/15-options.zsh" ]] && source "$ZSH_CONFIG/15-options.zsh"

# Behavior
[[ -f "$ZSH_CONFIG/30-history.zsh" ]] && source "$ZSH_CONFIG/30-history.zsh"
[[ -f "$ZSH_CONFIG/40-navigation.zsh" ]] && source "$ZSH_CONFIG/40-navigation.zsh"
[[ -f "$ZSH_CONFIG/50-bindings.zsh" ]] && source "$ZSH_CONFIG/50-bindings.zsh"
[[ -f "$ZSH_CONFIG/60-aliases.zsh" ]] && source "$ZSH_CONFIG/60-aliases.zsh"
[[ -f "$ZSH_CONFIG/70-extras.zsh" ]] && source "$ZSH_CONFIG/70-extras.zsh"
[[ -f "$ZSH_CONFIG/80-completion.zsh" ]] && source "$ZSH_CONFIG/80-completion.zsh"

# Plugins
[[ -f "$ZSH_CONFIG/90-plugins.zsh" ]] && source "$ZSH_CONFIG/90-plugins.zsh"

# -----------------------------------------------------------------------------
# 3. Prompt
# -----------------------------------------------------------------------------
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

# -----------------------------------------------------------------------------
# 4. Startup
# -----------------------------------------------------------------------------
if command -v fastfetch >/dev/null; then
  fastfetch
fi
"
    
    # Write .zshrc if it doesn't exist or if forced
    if [ ! -f "$HOME/.zshrc" ] || grep -q "Auto-Generated" "$HOME/.zshrc"; then
        echo "$ZSHRC_CONTENT" > "$HOME/.zshrc"
        success "Updated ~/.zshrc"
    else
        warn "~/.zshrc exists and is not auto-generated. Skipping overwrite."
        warn "Please manually verify it sources ~/.config/zsh files."
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
    setup_zsh

    success "Setup Complete!"
    if [ -d "$BACKUP_DIR" ]; then
        log "Old configs backed up to: $BACKUP_DIR"
    fi
    log "Please restart your terminal."
}

main
