#!/bin/bash

# Dotfiles Installation Script
# Supports: Debian/Ubuntu and macOS
# Author: Generated for dotfiles configuration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "Detected macOS"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
        log_info "Detected Debian/Ubuntu"
    else
        log_error "Unsupported operating system"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package manager dependencies
install_package_managers() {
    log_info "Setting up package managers..."
    
    if [[ "$OS" == "macos" ]]; then
        # Install Homebrew
        if ! command_exists brew; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for Apple Silicon Macs
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        else
            log_success "Homebrew already installed"
        fi
    elif [[ "$OS" == "debian" ]]; then
        # Update package list
        log_info "Updating package list..."
        sudo apt update
        
        # Install essential build tools
        log_info "Installing build essentials..."
        sudo apt install -y build-essential curl git wget software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    fi
}

# Install Node.js
install_nodejs() {
    log_info "Installing Node.js..."
    
    if [[ "$OS" == "macos" ]]; then
        if ! command_exists node; then
            brew install node
        else
            log_success "Node.js already installed"
        fi
    elif [[ "$OS" == "debian" ]]; then
        if ! command_exists node; then
            # Install Node.js LTS
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install -y nodejs
        else
            log_success "Node.js already installed"
        fi
    fi
}

# Install Python
install_python() {
    log_info "Installing Python..."
    
    if [[ "$OS" == "macos" ]]; then
        if ! command_exists python3; then
            brew install python
        else
            log_success "Python already installed"
        fi
    elif [[ "$OS" == "debian" ]]; then
        if ! command_exists python3; then
            sudo apt install -y python3 python3-pip python3-venv
        else
            log_success "Python already installed"
        fi
    fi
}

# Install shell and terminal tools
install_shell_tools() {
    log_info "Installing shell and terminal tools..."
    
    local tools=("zsh" "git" "fzf" "ripgrep" "fd-find" "tmux" "neovim")
    
    if [[ "$OS" == "macos" ]]; then
        # macOS specific tools
        local macos_tools=("eza" "zoxide")
        tools+=("${macos_tools[@]}")
        
        for tool in "${tools[@]}"; do
            if ! command_exists "$tool"; then
                log_info "Installing $tool..."
                case "$tool" in
                    "fd-find") brew install fd ;;
                    "ripgrep") brew install rg ;;
                    *) brew install "$tool" ;;
                esac
            else
                log_success "$tool already installed"
            fi
        done
        
    elif [[ "$OS" == "debian" ]]; then
        # Install basic tools
        for tool in zsh git tmux neovim; do
            if ! dpkg -l | grep -q "^ii  $tool "; then
                log_info "Installing $tool..."
                sudo apt install -y "$tool"
            else
                log_success "$tool already installed"
            fi
        done
        
        # Install fzf
        if ! command_exists fzf; then
            log_info "Installing fzf..."
            sudo apt install -y fzf
        fi
        
        # Install ripgrep
        if ! command_exists rg; then
            log_info "Installing ripgrep..."
            sudo apt install -y ripgrep
        fi
        
        # Install fd-find
        if ! command_exists fd; then
            log_info "Installing fd-find..."
            sudo apt install -y fd-find
            # Create symlink for fd
            if [[ ! -L ~/.local/bin/fd ]]; then
                mkdir -p ~/.local/bin
                ln -sf /usr/bin/fdfind ~/.local/bin/fd
            fi
        fi
        
        # Install eza (modern ls replacement)
        if ! command_exists eza; then
            log_info "Installing eza..."
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt update
            sudo apt install -y eza
        fi
        
        # Install zoxide (smart cd)
        if ! command_exists zoxide; then
            log_info "Installing zoxide..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi
    fi
}

# Install fonts
install_fonts() {
    log_info "Installing fonts..."
    
    if [[ "$OS" == "macos" ]]; then
        # Install Nerd Fonts via Homebrew
        if ! brew list --cask | grep -q font-meslo-lg-nerd-font; then
            log_info "Installing Nerd Fonts..."
            brew tap homebrew/cask-fonts
            brew install --cask font-meslo-lg-nerd-font
            brew install --cask font-jetbrains-mono-nerd-font
            brew install --cask font-fira-code-nerd-font
        else
            log_success "Nerd Fonts already installed"
        fi
        
    elif [[ "$OS" == "debian" ]]; then
        # Install Nerd Fonts manually
        local font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"
        
        if [[ ! -f "$font_dir/MesloLGS NF Regular.ttf" ]]; then
            log_info "Installing MesloLGS Nerd Font..."
            cd /tmp
            wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip
            unzip -o Meslo.zip -d "$font_dir"
            rm Meslo.zip
            fc-cache -fv
        else
            log_success "Nerd Fonts already installed"
        fi
    fi
}

# Install macOS-specific applications
install_macos_apps() {
    if [[ "$OS" != "macos" ]]; then
        return
    fi
    
    log_info "Installing macOS-specific applications..."
    
    # Install Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warning "Please complete Xcode Command Line Tools installation and re-run this script"
        exit 0
    fi
    
    # Install GUI applications
    local apps=("alacritty" "raycast" "cursor")
    for app in "${apps[@]}"; do
        if ! brew list --cask | grep -q "$app"; then
            log_info "Installing $app..."
            brew install --cask "$app"
        else
            log_success "$app already installed"
        fi
    done
    
    # Install SketchyBar
    if ! command_exists sketchybar; then
        log_info "Installing SketchyBar..."
        brew tap FelixKratz/formulae
        brew install sketchybar
    fi
    
    # Install AeroSpace
    if ! command_exists aerospace; then
        log_info "Installing AeroSpace..."
        brew install --cask nikitabobko/tap/aerospace
    fi
}

# Setup shell environment
setup_shell() {
    log_info "Setting up shell environment..."
    
    # Set zsh as default shell
    if [[ "$SHELL" != */zsh ]]; then
        log_info "Setting zsh as default shell..."
        if [[ "$OS" == "macos" ]]; then
            sudo chsh -s /bin/zsh "$USER"
        elif [[ "$OS" == "debian" ]]; then
            sudo chsh -s /usr/bin/zsh "$USER"
        fi
    fi
}

# Install LSP servers and development tools
install_dev_tools() {
    log_info "Installing development tools and LSP servers..."
    
    # Install Mason dependencies for Neovim
    if command_exists npm; then
        log_info "Installing language servers..."
        npm install -g pyright typescript-language-server vscode-langservers-extracted
    fi
    
    # Install Python tools
    if command_exists pip3; then
        log_info "Installing Python development tools..."
        pip3 install --user black flake8 pylsp-server
    fi
    
    # Install Lua formatter
    if [[ "$OS" == "macos" ]]; then
        if ! command_exists stylua; then
            brew install stylua
        fi
    elif [[ "$OS" == "debian" ]]; then
        if ! command_exists stylua; then
            cargo install stylua 2>/dev/null || log_warning "Stylua installation failed - install Rust first"
        fi
    fi
}

# Link dotfiles
link_dotfiles() {
    log_info "Linking dotfiles..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Backup existing files
    local files_to_link=(".zshrc" ".p10k.zsh")
    for file in "${files_to_link[@]}"; do
        if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            log_warning "Backing up existing $file to $file.backup"
            mv "$HOME/$file" "$HOME/$file.backup"
        fi
        
        log_info "Linking $file..."
        ln -sf "$script_dir/$file" "$HOME/$file"
    done
    
    # Link .config directory
    if [[ -d "$HOME/.config" && ! -L "$HOME/.config" ]]; then
        log_warning "Backing up existing .config to .config.backup"
        mv "$HOME/.config" "$HOME/.config.backup"
    fi
    
    log_info "Linking .config directory..."
    ln -sf "$script_dir/.config" "$HOME/.config"
}

# Compile SketchyBar helpers (macOS only)
compile_sketchybar_helpers() {
    if [[ "$OS" != "macos" ]]; then
        return
    fi
    
    log_info "Compiling SketchyBar helpers..."
    
    local helpers_dir="$HOME/.config/sketchybar/helpers"
    if [[ -d "$helpers_dir" ]]; then
        cd "$helpers_dir"
        if [[ -f "Makefile" ]]; then
            make 2>/dev/null || log_warning "Failed to compile SketchyBar helpers"
        fi
    fi
}

# Main installation function
main() {
    log_info "Starting dotfiles installation..."
    
    detect_os
    install_package_managers
    install_nodejs
    install_python
    install_shell_tools
    install_fonts
    install_macos_apps
    install_dev_tools
    setup_shell
    link_dotfiles
    compile_sketchybar_helpers
    
    log_success "Installation completed!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    
    if [[ "$OS" == "macos" ]]; then
        log_info "macOS: You may need to grant permissions to Raycast, SketchyBar, and AeroSpace"
        log_info "macOS: Configure AeroSpace by creating ~/.aerospace.toml"
    fi
    
    log_info "Run 'p10k configure' to customize your shell prompt"
}

# Run main function
main "$@"