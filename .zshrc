# Rust (Cargo)
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH"

eval "$(sheldon source)"

# uv
eval "$(uv generate-shell-completion zsh)"

# Neovim
export NVIM_APPNAME="nvim"

# Aliases
if [ -f "$DOTFILES_DIR/.aliases" ]; then
    source "$DOTFILES_DIR/.aliases"
fi