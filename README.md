# dotfiles

My zsh, vim, tmux and git setup. Based on [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)
and managed with [rcm](https://github.com/thoughtbot/rcm).

## New machine

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/lyonsv/dotfiles/main/install.sh)"
```

This will:

1. Install Homebrew (and with it the Xcode Command Line Tools) if missing
2. Clone this repo to `~/git/dotfiles` (or `git pull` if it's already there)
3. `brew bundle` the [Brewfile](Brewfile), plus `~/Brewfile.local` if present
4. Move any existing real dotfiles that would be replaced to `~/.dotfiles-backup/<timestamp>/`
5. Symlink everything into `$HOME` with `rcup`, then install vim plugins (`hooks/post-up`)
6. Create the untracked `~/.*.local` files from [templates/](templates) if they don't exist

Re-running it is safe. Options:

```sh
INSTALL_LANGUAGES=1 ~/git/dotfiles/install.sh   # also asdf-install ~/.tool-versions
SKIP_BREW=1 ~/git/dotfiles/install.sh           # just re-link
```

Afterwards, run `gh auth login` so `git push` to GitHub works over HTTPS.

## Local overrides (not committed)

Anything machine-specific (secrets, API tokens, work email, work aliases) goes in a
`.local` file. These are sourced last, so they win:

| File | Loaded by |
| --- | --- |
| `~/.zshrc.local` | `zshrc`: env vars, tokens, `PATH` tweaks |
| `~/.zshenv.local` | `zshenv` |
| `~/.aliases.local` | `aliases` |
| `~/.gitconfig.local` | `gitconfig`, e.g. `[user] email = you@work.example` |
| `~/.vimrc.local` / `~/.vimrc.bundles.local` | `vimrc` / `vimrc.bundles` |
| `~/.tmux.conf.local` | `tmux.conf` |
| `~/.psqlrc.local` | `psqlrc` |
| `~/.git_template.local/hooks/*` | git hooks in `git_template` |
| `~/Brewfile.local` | `install.sh` |
| `~/dotfiles-local/` | rcm: files here override files in this repo |

**Never put secrets in this repo.** They go in `~/.zshrc.local`.

## Day to day

- Edit files in `~/git/dotfiles`. They are symlinked, so changes apply immediately.
- Add a new dotfile: create it here without the leading dot (e.g. `foo` -> `~/.foo`), then run `rcup`.
- Add zsh config: drop a file into `zsh/configs/` (or `pre/` / `post/` for ordering).
- `lsrc` shows what is linked where.

## What's in here

- **zsh**: vi keybindings, git-branch prompt, history, completion, functions (`g`, `mcd`, `envup`),
  fzf, asdf shims, zsh-syntax-highlighting, and optional bun/pnpm/opencode/turso paths
- **vim** (vim-plug): fzf, ALE (eslint + prettier fix on save), fugitive, vim-test, rails, TypeScript, gruvbox
- **tmux**: `C-s` prefix, vim-style pane movement, windows numbered from 1
- **git**: aliases, commit template, `~/.git_template` hooks (ctags), `gh` credential helper
- **bin/**: `tat`, `git-up`, `git-ca`, `clear-port`, `whats-in-port`, `replace`, and others
