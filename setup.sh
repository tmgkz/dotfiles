#!/bin/bash

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "==> Start Setup..."

if exists brew; then
    echo "Detected: Homebrew"
    INSTALL_CMD="brew install"
elif exists pacman; then
    echo "Detected: Pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
elif exists apt; then
    echo "Detected: Apt"
    INSTALL_CMD="sudo apt install -y"
    sudo apt update
elif exists dnf; then
    echo "Detected: Dnf"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "Error: Supported package manager not found."
    exit 1
fi

# --- 0. curl, unzip ---
if ! exists curl; then
    echo "Installing curl..."
    $INSTALL_CMD curl
fi

if ! exists unzip; then
    echo "Installing unzip..."
    $INSTALL_CMD unzip
fi

# --- 0. Build tools ---
if ! exists cc; then
    echo "Linker 'cc' not found. Installing build tools..."
    if exists brew; then
        echo "Checking Xcode Command Line Tools..."
        if ! xcode-select -p >/dev/null 2>&1; then
            echo "Installing Xcode Command Line Tools..."
            xcode-select --install
            echo "Please complete the Xcode installation dialog and run this script again."
            exit 1
        fi
    elif exists pacman; then
        sudo pacman -S --noconfirm base-devel
    elif exists apt; then
        $INSTALL_CMD build-essential
    elif exists dnf; then
        sudo dnf groupinstall -y "Development Tools"
    fi
fi

# --- 1. fzf ---
if ! exists fzf; then
    echo "Installing fzf..."
    $INSTALL_CMD fzf
else
    echo "fzf is already installed."
fi

# --- 2. Rust toolchain ---
if ! exists cargo; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
fi

# --- 3. uv ---
if ! exists uv; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
fi

# --- 4. Neovim ---
if ! exists nvim; then
    echo "Installing Neovim..."
    $INSTALL_CMD neovim
fi

# --- 5. Zsh ---
if ! exists zsh; then
    echo "Installing zsh..."
    $INSTALL_CMD zsh
fi

# --- 6. Sheldon ---
if ! exists sheldon; then
    echo "Installing sheldon..."
    if exists brew || exists pacman; then
        $INSTALL_CMD sheldon
    else
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    fi
fi

# --- 7. Rust made tools ---
if ! exists lsd; then
    # lsd
    echo "Installing lsd..."
    if exists brew; then
        brew install lsd
    elif exists pacman; then
        sudo pacman -S --noconfirm lsd
    elif exists dnf; then
        sudo dnf install -y lsd
    else
        echo "Installing lsd via Cargo..."
        cargo install lsd
    fi

    # starship
    if ! exists starship; then
        echo "Installing starship..."
        curl -sS https://starship.rs/inst/all.sh | sh -s -- -y
    fi
fi

# --- 8. Nerd Fonts ---
FONT_NAME="JetBrainsMono"
echo "Checking Nerd Fonts ($FONT_NAME)..."

if [ "$(uname)" == "Darwin" ]; then
    if ! brew list --cask | grep -q "font-jetbrains-mono-nerd-font"; then
        echo "Installing Nerd Font via Homebrew..."
        brew install --cask font-jetbrains-mono-nerd-font
    else
        echo "Nerd Font is already installed."
    fi
else
    FONT_DIR="$HOME/.local/share/fonts"
    if [ ! -d "$FONT_DIR" ]; then
        mkdir -p "$FONT_DIR"
    fi

    if ! ls "$FONT_DIR" | grep -q "$FONT_NAME"; then
        echo "Installing Nerd Font manually..."
        VERSION="v3.4.0"
        ZIP_FILE="${FONT_NAME}.zip"
        URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${ZIP_FILE}"
        
        curl -L -o "/tmp/$ZIP_FILE" "$URL"
        unzip -o -q "/tmp/$ZIP_FILE" -d "$FONT_DIR"
        rm "/tmp/$ZIP_FILE"
        
        if exists fc-cache; then
            echo "Updating font cache..."
            fc-cache -fv
        fi
    else
        echo "Nerd Font is already installed in $FONT_DIR."
    fi
fi

# --- 9. Link Configs ---
echo "==> Linking Configs..."
mkdir -p "$HOME/.config"

# Link files
[ -f "$DOTFILES_DIR/.zshrc" ] && ln -snf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.aliases" ] && ln -snf "$DOTFILES_DIR/.aliases" "$HOME/.aliases"

# Link .config
if [ -d "$DOTFILES_DIR/.config" ]; then
    for config_dir in "$DOTFILES_DIR/.config"/*; do
        if [ -d "$config_dir" ] || [ -f "$config_dir" ]; then
            target="$HOME/.config/$(basename "$config_dir")"
            ln -snf "$config_dir" "$target"
            echo "Linked $(basename "$config_dir") to $target"
        fi
    done
fi

echo "Links created."

# --- 10. Default shell change ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

echo "✅ All Setup Completed!"
