#!/bin/bash

# ==============================================================================
#  Argon360 Universal System Setup
# ==============================================================================
#
#  This script is the master key to replicating the Argon360 environment.
#  It combines system provisioning (installing packages, languages, tools)
#  with dotfiles management (safely deploying configs).
#
#  Features:
#  1. Installs Core Dependencies, Security Tools, and Dev Libraries.
#  2. Sets up Rust (Cargo) and Go.
#  3. Installs modern CLI tools (Walker, Atuin, Lazygit, etc.).
#  4. Safely deploys configurations to ~/.config (with backups).
#  5. Configures Zsh (plugins + auto-generated .zshrc) and Fish.
#
#  Usage:
#    Run this script from the root of your dotfiles directory.
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

# ==============================================================================
# 1. System Updates & Core Packages
# ==============================================================================
install_packages() {
    log "Updating package lists and upgrading system..."
    sudo apt update -y && sudo apt upgrade -y

    # Combined list from all setups
    PACKAGES=(
        # Core Utilities
        git
        curl
        wget
        build-essential
        cmake
        pkg-config
        unzip
        
        # Shells & Terminal
        zsh
        fish
        kitty
        tmux
        
        # Modern CLI Tools
        fzf
        bat
        ripgrep
        fd-find
        zoxide
        eza
        fastfetch
        btop
        neovim
        
        # Security & Networking (Kali profile)
        wireshark
        nmap
        
        # Apps
        vlc
        
        # Development Libraries (Required for compiling tools like Walker)
        libgtk-4-dev
        libgtk-layer-shell-dev
        libpoppler-glib-dev
        protobuf-compiler
    )

    log "Installing APT packages..."
    # Install in a loop to catch individual failures but keep going
    for pkg in "${PACKAGES[@]}"; do
        if sudo apt install -y "$pkg" 2>/dev/null; then
            : # Success
        else
            warn "Could not install $pkg via apt. It might need manual installation or is already installed."
        fi
    done

    # Fix symlinks for Debian/Ubuntu naming quirks
    fix_symlinks
}

fix_symlinks() {
    log "Fixing 'bat' and 'fd' naming quirks..."
    mkdir -p ~/.local/bin
    
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        ln -sf "$(command -v batcat)" ~/.local/bin/bat
        success "Linked batcat -> bat"
    fi

    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        ln -sf "$(command -v fdfind)" ~/.local/bin/fd
        success "Linked fdfind -> fd"
    fi
}

# ==============================================================================
# 2. Language Environments (Rust & Go)
# ==============================================================================
install_languages() {
    # Rust / Cargo
    if ! command -v cargo &> /dev/null; then
        log "Installing Rust (Cargo)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        success "Rust/Cargo is already installed."
    fi

    # Go
    if ! command -v go &> /dev/null; then
        log "Go not found. Attempting to install via apt..."
        if sudo apt install -y golang-go; then
             success "Go installed via apt."
        else
             warn "Failed to install Go. Please install manually."
        fi
    else
        success "Go is already installed."
    fi
}

# ==============================================================================
# 3. External Tools (Compiled/Scripted)
# ==============================================================================
install_externals() {
    log "Installing external tools..."

    # Starship
    if ! command -v starship &> /dev/null; then
        log "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        success "Starship already installed."
    fi

    # Atuin (Shell History)
    if ! command -v atuin &> /dev/null; then
        log "Installing Atuin..."
        if command -v cargo &> /dev/null; then
            cargo install atuin
        else
            bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
        fi
    fi

    # Lazygit
    if ! command -v lazygit &> /dev/null; then
        log "Installing Lazygit..."
        if command -v go &> /dev/null; then
            go install github.com/jesseduffield/lazygit@latest
        else
            warn "Go not found. Skipping Lazygit."
        fi
    fi

    # Walker (App Launcher)
    if ! command -v walker &> /dev/null; then
        log "Installing Walker (this may take a while)..."
        if command -v cargo &> /dev/null; then
            cargo install walker
        else
            warn "Cargo not found. Skipping Walker."
        fi
    fi
}

# ==============================================================================
# 4. Deploy Configurations (Dotfiles)
# ==============================================================================
deploy_configs() {
    log "Deploying configurations..."
    mkdir -p "$TARGET_DIR"

    # List of config folders to look for in the script's directory
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
        "hypr"
        "waybar"
    )

    for item in "${ITEMS[@]}"; do
        SRC="$SCRIPT_DIR/$item"
        DEST="$TARGET_DIR/$item"

        if [ -e "$SRC" ]; then
            # Safety: Don't copy if we are running inside ~/.config (avoid self-overwrite loop)
            if [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
                if [ -e "$DEST" ]; then
                    warn "Backing up existing $item..."
                    mkdir -p "$BACKUP_DIR"
                    mv "$DEST" "$BACKUP_DIR/"
                fi
                log "Copying $item..."
                cp -r "$SRC" "$DEST"
            fi
            success "Deployed $item"
        else
            # Only warn if we really expected it (optional)
            # warn "Source $item not found in $SCRIPT_DIR"
            true
        fi
    done
}

# ==============================================================================
# 5. Shell Setup (Fish & Zsh)
# ==============================================================================
setup_fish() {
    log "Configuring Fish Shell..."
    if command -v fish &> /dev/null; then
        # Install Fisher plugin manager
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" || warn "Fisher install failed/skipped"
        
        # Update plugins if config exists
        if [ -f "$TARGET_DIR/fish/fish_plugins" ]; then
            fish -c "fisher update"
        fi
    fi
}

setup_zsh() {
    log "Configuring Zsh..."
    ZSH_PLUGIN_DIR="$HOME/.config/zsh/plugins"
    mkdir -p "$ZSH_PLUGIN_DIR"

    # Helper to clone plugins
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

    # Install Core Zsh Plugins
    clone_plugin "https://github.com/romkatv/powerlevel10k.git" "$ZSH_PLUGIN_DIR/powerlevel10k"
    clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    clone_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
    clone_plugin "https://github.com/zsh-users/zsh-history-substring-search.git" "$ZSH_PLUGIN_DIR/zsh-history-substring-search"
    clone_plugin "https://github.com/Aloxaf/fzf-tab" "$ZSH_PLUGIN_DIR/fzf-tab"

    # Auto-Generate .zshrc
    # This ensures the user's .zshrc always points to our modular config
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
export PATH=\"
$HOME/.local/bin:$HOME/go/bin:$PATH\"

# Base directory for modular config
ZSH_CONFIG=\"
$HOME/.config/zsh\"

# -----------------------------------------------------------------------------
# 2. Load Modular Configs
# -----------------------------------------------------------------------------
# Core
[[ -f "\"
$ZSH_CONFIG/00-env.zsh\"" ]] && source "\"
$ZSH_CONFIG/00-env.zsh\""
[[ -f "\"
$ZSH_CONFIG/10-tools.zsh\"" ]] && source "\"
$ZSH_CONFIG/10-tools.zsh\""
[[ -f "\"
$ZSH_CONFIG/15-options.zsh\"" ]] && source "\"
$ZSH_CONFIG/15-options.zsh\""

# Behavior
[[ -f "\"
$ZSH_CONFIG/30-history.zsh\"" ]] && source "\"
$ZSH_CONFIG/30-history.zsh\""
[[ -f "\"
$ZSH_CONFIG/40-navigation.zsh\"" ]] && source "\"
$ZSH_CONFIG/40-navigation.zsh\""
[[ -f "\"
$ZSH_CONFIG/50-bindings.zsh\"" ]] && source "\"
$ZSH_CONFIG/50-bindings.zsh\""
[[ -f "\"
$ZSH_CONFIG/60-aliases.zsh\"" ]] && source "\"
$ZSH_CONFIG/60-aliases.zsh\""
[[ -f "\"
$ZSH_CONFIG/70-extras.zsh\"" ]] && source "\"
$ZSH_CONFIG/70-extras.zsh\""
[[ -f "\"
$ZSH_CONFIG/80-completion.zsh\"" ]] && source "\"
$ZSH_CONFIG/80-completion.zsh\""

# Plugins
[[ -f "\"
$ZSH_CONFIG/90-plugins.zsh\"" ]] && source "\"
$ZSH_CONFIG/90-plugins.zsh\""

# -----------------------------------------------------------------------------
# 3. Prompt
# -----------------------------------------------------------------------------
if command -v starship >/dev/null; then
  eval "\"
$(starship init zsh)\n"
fi

# -----------------------------------------------------------------------------
# 4. Startup
# -----------------------------------------------------------------------------
if command -v fastfetch >/dev/null; then
  fastfetch
fi
"
    # Write .zshrc if it doesn't exist or if it's our own auto-generated one
    if [ ! -f "$HOME/.zshrc" ] || grep -q "Auto-Generated" "$HOME/.zshrc"; then
        echo "$ZSHRC_CONTENT" > "$HOME/.zshrc"
        success "Updated ~/.zshrc"
    else
        warn "~/.zshrc exists and is not auto-generated. Skipping overwrite."
        warn "Please manually verify it sources ~/.config/zsh files."
    fi
}

set_default_shell() {
    if command -v zsh &> /dev/null; then
        if [ "$SHELL" != "$(which zsh)" ]; then
            log "Changing default shell to Zsh..."
            chsh -s "$(which zsh)"
        fi
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================
main() {
    log "Starting Argon360 System Setup..."
    log "Source Dir: $SCRIPT_DIR"
    
    install_packages
    install_languages
    install_externals
    deploy_configs
    setup_fish
    setup_zsh
    set_default_shell

    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}  Setup Complete!  ${NC}"
    echo -e "${GREEN}==========================================${NC}"
    if [ -d "$BACKUP_DIR" ]; then
        log "Old configs backed up to: $BACKUP_DIR"
    fi
    log "Please restart your terminal or log out/in."
}

main