# 🗂️ dotfiles

Portable dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
# On a fresh machine:
git clone git@github.com:jjeb/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh

# Then fill in your secrets:
cp ~/dotfiles/zsh/.zshrc.local.example ~/.zshrc.local
# Edit ~/.zshrc.local with your API keys
```

## Packages

Each directory is a Stow package that symlinks into `$HOME`:

| Package | What it configures |
|---------|-------------------|
| `zsh/` | Shell config (Oh My Zsh + Starship + asdf + fzf) |
| `git/` | Git identity, editor, credential helper |
| `tmux/` | Tmux prefix, vi keys, mouse, Nord theme, Pi status |
| `kitty/` | Kitty terminal (Catppuccin Mocha + Firefox-style tabs) |
| `starship/` | Starship prompt (emoji git symbols, battery) |
| `pi/` | Pi coding agent (models, keybindings, custom agents, extensions) |
| `asdf/` | Runtime versions (Node, Ruby, Python, Go) |
| `gh/` | GitHub CLI aliases |
| `htop/` | Htop layout |

## Adding a new package

```bash
# 1. Create the package directory mirroring $HOME:
mkdir -p ~/dotfiles/newpkg/.config/newapp

# 2. Copy config files into it:
cp ~/.config/newapp/config.toml ~/dotfiles/newpkg/.config/newapp/

# 3. Stow it:
cd ~/dotfiles && stow newpkg

# 4. Commit:
git add newpkg/ && git commit -m "feat: add newpkg config"
```

## Secrets

Machine-specific secrets live in `~/.zshrc.local` (gitignored). See `zsh/.zshrc.local.example` for the template.

## Dependencies

Run `brew bundle --file=Brewfile` or use `install.sh` which does it automatically.
