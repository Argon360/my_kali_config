#!/bin/bash

# ==============================================================================
#  Automated Installer for My Kali / Linux Terminal Configuration
# ==============================================================================
#
#  This script sets up the environment described in the README.
#  It handles:
#  1. Package installation (Debian/Kali prioritized)
#  2. Configuration linking (if not already in place)
#  3. Shell setup (Fish, Starship, Fisher)
#
# ==============================================================================

set -e  # Exit on error

# --- Colors & Formatting ---
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

# --- 1. Distro Detection & Package Installation ---
install_dependencies() {
    log "Detecting distribution..."
    
    if [ -f /etc/debian_version ]; then
        log "Debian-based system detected. Updating apt cache..."
        sudo apt update -y

        PACKAGES=(
            kitty
            fish
            fzf
            bat
            ripgrep
            fd-find
            zoxide
            curl
            wget
            git
            neovim
            gh
        )

        # Optional/Newer packages that might fail on older distros
        OPTIONAL_PACKAGES=(
            eza
            fastfetch
            atuin
        )

        log "Installing core packages: ${PACKAGES[*]}"
        sudo apt install -y "${PACKAGES[@]}"

        log "Attempting to install optional packages..."
        for pkg in "${OPTIONAL_PACKAGES[@]}"; do
            if sudo apt install -y "$pkg" 2>/dev/null; then
                success "Installed $pkg"
            else
                warn "Could not install $pkg via apt. You may need to install it manually or via Cargo."
                # Fallback for common tools if missing?
            fi
        done

        # Fix bat -> batcat
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            log "Linking batcat to bat..."
            mkdir -p ~/.local/bin
            ln -s "$(command -v batcat)" ~/.local/bin/bat
            success "Created ~/.local/bin/bat symlink"
        fi

        # Fix fdfind -> fd
        if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
             log "Linking fdfind to fd..."
             mkdir -p ~/.local/bin
             ln -s "$(command -v fdfind)" ~/.local/bin/fd
             success "Created ~/.local/bin/fd symlink"
        fi

    else
        warn "Non-Debian distro detected. Skipping automated package installation."
        warn "Please ensure the following are installed: kitty, fish, fzf, bat, eza, ripgrep, fd, zoxide, atuin, fastfetch, starship, neovim."
    fi
}

# --- 2. External Tools Installation (If missing) ---

install_externals() {
    # Starship
    if ! command -v starship &> /dev/null; then
        log "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        success "Starship already installed"
    fi
    
    # Atuin (if not installed by apt)
    if ! command -v atuin &> /dev/null; then
        log "Installing Atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    fi
}

# --- 3. Configuration Linking ---

setup_configs() {
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_DIR="$HOME/.config"
    
    log "Setting up configurations from $REPO_ROOT..."

    # Check if we are already inside ~/.config
    if [ "$REPO_ROOT" == "$CONFIG_DIR" ]; then
        success "Script running from ~/.config. Configs are already in place."
        return
    fi

    # List of directories to symlink
    DIRS_TO_LINK=("kitty" "fish" "fastfetch" "nvim" "bat" "atuin" "btop" "ghostty" "lazygit")
    
    # Ensure target dir exists
    mkdir -p "$CONFIG_DIR"

    for dir in "${DIRS_TO_LINK[@]}"; do
        SOURCE="$REPO_ROOT/$dir"
        TARGET="$CONFIG_DIR/$dir"

        if [ -d "$SOURCE" ]; then
            if [ -L "$TARGET" ]; then
                log "Symlink exists for $dir, skipping."
            elif [ -d "$TARGET" ]; then
                warn "Directory $TARGET already exists (not a symlink). Backing up..."
                mv "$TARGET" "${TARGET}.backup.$(date +%s)"
                ln -s "$SOURCE" "$TARGET"
                success "Linked $dir"
            else
                ln -s "$SOURCE" "$TARGET"
                success "Linked $dir"
            fi
        fi
    done

    # Handle starship.toml specifically
    if [ -f "$REPO_ROOT/starship.toml" ]; then
        if [ ! -L "$CONFIG_DIR/starship.toml" ]; then
            if [ -f "$CONFIG_DIR/starship.toml" ]; then
                 mv "$CONFIG_DIR/starship.toml" "$CONFIG_DIR/starship.toml.backup.$(date +%s)"
            fi
            ln -s "$REPO_ROOT/starship.toml" "$CONFIG_DIR/starship.toml"
            success "Linked starship.toml"
        fi
    fi
}

# --- 4. Fish Shell Setup ---

setup_fish() {
    log "Configuring Fish Shell..."
    
    # Check if fish is valid
    if ! command -v fish &> /dev/null; then
        error "Fish shell not found. Please install it first."
    fi

    # Install Fisher (Plugin Manager)
    log "Installing/Updating Fisher and plugins..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    
    # Install plugins defined in fish_plugins file if it exists
    if [ -f "$HOME/.config/fish/fish_plugins" ]; then
        fish -c "fisher update"
        success "Fisher plugins updated"
    fi
}

# --- 5. Post-Install Verification ---

verify_installation() {
    log "Verifying installation..."
    
    TOOLS=(kitty fish fzf bat ripgrep zoxide atuin fastfetch starship nvim git)
    MISSING=0
    
    for tool in "${TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "  $tool: ${GREEN}INSTALLED${NC}"
        else
            echo -e "  $tool: ${RED}MISSING${NC}"
            MISSING=1
        fi
    done
    
    if [ $MISSING -eq 0 ]; then
        success "All core tools found."
    else
        warn "Some tools are missing. Please check the logs."
    fi
}

# --- Main Execution ---

main() {
    log "Starting setup..."
    
    install_dependencies
    install_externals
    setup_configs
    setup_fish
    verify_installation
    
    log "Setup complete! Please restart your shell or terminal."
    log "If you haven't, set fish as default: chsh -s \$(which fish)"
}

main
