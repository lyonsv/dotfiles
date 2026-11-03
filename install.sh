#!/usr/bin/env bash
#
# Bootstrap a new machine with these dotfiles.
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/lyonsv/dotfiles/main/install.sh)"
#
# Safe to re-run: it pulls the latest dotfiles and re-links everything.
# Options (env vars):
#   DOTFILES_DIR=~/git/dotfiles   where to clone (must match rcrc DOTFILES_DIRS)
#   DOTFILES_REPO=<url>           repo to clone
#   INSTALL_LANGUAGES=1           also install the asdf languages in ~/.tool-versions
#   SKIP_BREW=1                   skip Homebrew + Brewfile

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/lyonsv/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/git/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

load_brew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

# --- 1. Homebrew --------------------------------------------------------------
if [ -z "${SKIP_BREW:-}" ]; then
  load_brew
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew (installs Xcode Command Line Tools too; may ask for your password)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew
  fi
fi

# --- 2. Clone / update the repo ----------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  warn "git is not available. On macOS run: xcode-select --install, then re-run this script."
  exit 1
fi

if [ -d "$DOTFILES_DIR/.git" ]; then
  info "Updating $DOTFILES_DIR"
  git -C "$DOTFILES_DIR" pull --ff-only || warn "Could not fast-forward; using local copy as-is"
else
  info "Cloning $DOTFILES_REPO -> $DOTFILES_DIR"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# --- 3. Packages --------------------------------------------------------------
if [ -z "${SKIP_BREW:-}" ] && command -v brew >/dev/null 2>&1; then
  info "Installing packages from Brewfile"
  brew bundle --file="$DOTFILES_DIR/Brewfile" || warn "Some Brewfile entries failed"
  if [ -f "$HOME/Brewfile.local" ]; then
    info "Installing packages from ~/Brewfile.local"
    brew bundle --file="$HOME/Brewfile.local" || warn "Some Brewfile.local entries failed"
  fi
fi

if ! command -v rcup >/dev/null 2>&1; then
  warn "rcm (rcup) is not installed. Install it (brew install rcm) and re-run."
  exit 1
fi

# --- 4. Back up any real files that would be replaced by symlinks ------------
export RCRC="$DOTFILES_DIR/rcrc"
info "Checking for existing dotfiles to back up"
while IFS=: read -r dest _src; do
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$HOME"/}")"
    mv "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
    warn "Backed up $dest -> $BACKUP_DIR/${dest#"$HOME"/}"
  fi
done < <(lsrc)

# --- 5. Link everything (runs hooks/post-up: installs vim plugins) -----------
info "Linking dotfiles with rcup"
rcup -f

# --- 6. Create untracked *.local files from templates (never overwrites) -----
for tpl in "$DOTFILES_DIR"/templates/*; do
  target="$HOME/.$(basename "$tpl")"
  if [ ! -e "$target" ]; then
    cp "$tpl" "$target"
    info "Created $target"
  fi
done

# --- 7. Optional: languages via asdf ------------------------------------------
if [ -n "${INSTALL_LANGUAGES:-}" ] && command -v asdf >/dev/null 2>&1 && [ -f "$HOME/.tool-versions" ]; then
  info "Installing languages from ~/.tool-versions (this can take a while)"
  while read -r plugin _version; do
    [ -z "$plugin" ] && continue
    case "$plugin" in \#*) continue ;; esac
    asdf plugin add "$plugin" 2>/dev/null || true
  done < "$HOME/.tool-versions"
  (cd "$HOME" && asdf install) || warn "Some asdf installs failed"
fi

# --- 8. Default shell ----------------------------------------------------------
case "${SHELL:-}" in
  */zsh) ;;
  *)
    info "Changing default shell to zsh"
    chsh -s "$(command -v zsh)" || warn "Could not change shell; run: chsh -s \$(which zsh)"
    ;;
esac

cat <<MSG

Done. Open a new terminal (or run: exec zsh -l).

  Secrets / work settings  -> ~/.zshrc.local, ~/.gitconfig.local, ~/.aliases.local
  Extra brew packages      -> ~/Brewfile.local, then re-run this script
  Languages (asdf)         -> INSTALL_LANGUAGES=1 bash $DOTFILES_DIR/install.sh
  GitHub auth              -> gh auth login
MSG
[ -d "$BACKUP_DIR" ] && echo "  Replaced files were backed up to $BACKUP_DIR"
exit 0
