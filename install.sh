#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
STOW_PACKAGES=(zsh git tmux kitty starship pi asdf gh htop)

echo "🗂️  Dotfiles installer"
echo "   Repo: $DOTFILES_DIR"
echo ""

# ─── 1. Homebrew ──────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew already installed"
fi

# ─── 2. Brew bundle ──────────────────────────────────────────
echo "📦 Installing Homebrew dependencies..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ─── 3. Oh My Zsh ────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "📦 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh already installed"
fi

# ─── 4. TPM (Tmux Plugin Manager) ────────────────────────────
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "📦 Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "✅ TPM already installed"
fi

# ─── 5. Back up conflicting files ────────────────────────────
echo "🔄 Checking for conflicting files..."
BACKUP_NEEDED=false
for pkg in "${STOW_PACKAGES[@]}"; do
  # Find all files in the stow package (relative to the package dir)
  while IFS= read -r -d '' file; do
    target="$HOME/$file"
    if [[ -f "$target" && ! -L "$target" ]]; then
      backup="${target}.dotfiles-backup"
      echo "   Backing up: $target → $backup"
      mv "$target" "$backup"
      BACKUP_NEEDED=true
    fi
  done < <(cd "$DOTFILES_DIR/$pkg" && find . -type f -print0 | sed 's|^\./||')
done

if [[ "$BACKUP_NEEDED" == false ]]; then
  echo "   No conflicts found"
fi

# ─── 6. Stow all packages ────────────────────────────────────
echo "🔗 Stowing packages..."
cd "$DOTFILES_DIR"
for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ -d "$pkg" ]] && [[ -n "$(ls -A "$pkg")" ]]; then
    stow --restow --target="$HOME" "$pkg"
    echo "   ✅ $pkg"
  else
    echo "   ⏭️  $pkg (empty, skipping)"
  fi
done

# ─── 7. Create ~/.zshrc.local from template ───────────────────
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  if [[ -f "$DOTFILES_DIR/zsh/.zshrc.local.example" ]]; then
    cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
    echo ""
    echo "⚠️  Created ~/.zshrc.local from template"
    echo "   Edit it now to add your API keys and machine-specific paths:"
    echo "   \$EDITOR ~/.zshrc.local"
  fi
else
  echo "✅ ~/.zshrc.local already exists"
fi

# ─── 8. asdf runtimes ────────────────────────────────────────
if command -v asdf &>/dev/null && [[ -f "$HOME/.tool-versions" ]]; then
  echo "📦 Installing asdf runtimes from .tool-versions..."
  asdf install || echo "   ⚠️  Some runtimes may need manual plugin installation"
fi

# ─── 9. Pi Extensions ────────────────────────────────────────
if [[ -f "$HOME/.pi/agent/npm/package.json" ]]; then
  echo "📦 Installing Pi extensions..."
  (cd "$HOME/.pi/agent/npm" && npm install --quiet) || echo "   ⚠️  Pi extensions npm install failed"
fi

echo ""
echo "🎉 Done! Restart your shell or run: source ~/.zshrc"
