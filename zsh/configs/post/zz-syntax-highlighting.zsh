# zsh-syntax-highlighting (brew install zsh-syntax-highlighting).
# Must be sourced after everything else that touches ZLE widgets.
if command -v brew >/dev/null 2>&1; then
  _zsh_hl="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$_zsh_hl" ] && source "$_zsh_hl"
  unset _zsh_hl
fi
