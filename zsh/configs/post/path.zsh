# ensure dotfiles bin directory is loaded first
PATH="$HOME/.bin:/usr/local/sbin:$PATH"

# asdf: >= 0.16 is a single binary that uses shims; older versions ship asdf.sh
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
elif command -v asdf >/dev/null 2>&1; then
  PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
fi

# mkdir .git/safe in the root of repositories you trust
PATH=".git/safe/../../bin:$PATH"

export -U PATH
