export PATH="$HOME/.local/bin:$PATH"
autoload -Uz compinit && compinit

# Rust (Cargo)
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# starship
eval "$(starship init zsh)"

# sheldon
eval "$(sheldon source)"

# uv
eval "$(uv generate-shell-completion zsh)"

# Neovim
export NVIM_APPNAME="nvim"

# Aliases
if [ -f "$HOME/.aliases" ]; then
    source "$HOME/.aliases"
fi

# zoxide
if command -v zoxide > /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Local configurations
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"