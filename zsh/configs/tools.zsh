# Optional tools: each block only activates if the tool is installed.

# fzf key bindings and completion (brew fzf, or vim-plug's ~/.fzf fallback)
[ -d "$HOME/.fzf/bin" ] && PATH="$PATH:$HOME/.fzf/bin"
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# uv / pipx style installers drop binaries in ~/.local/bin
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi

# pnpm
if [ -d "$HOME/Library/pnpm" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  PATH="$PNPM_HOME:$PATH"
fi

# opencode
[ -d "$HOME/.opencode/bin" ] && PATH="$HOME/.opencode/bin:$PATH"

# turso
[ -d "$HOME/.turso" ] && PATH="$PATH:$HOME/.turso"
