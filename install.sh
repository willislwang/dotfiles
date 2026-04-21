#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

echo "==> Detected OS: $OS"

# Install zsh
if ! command -v zsh &>/dev/null; then
  echo "==> Installing zsh..."
  if [[ "$OS" == "linux" ]]; then
    sudo apt-get install -y zsh
  elif [[ "$OS" == "macos" ]]; then
    brew install zsh
  fi
fi

# Install oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Install base16-shell
if [[ ! -d "$HOME/.config/base16-shell" ]]; then
  echo "==> Installing base16-shell..."
  git clone https://github.com/tinted-theming/base16-shell.git "$HOME/.config/base16-shell"
fi

# Symlink zsh config (oh-my-zsh install may have written a new .zshrc, overwrite it)
echo "==> Linking zsh config..."
ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

# Symlink tmux config
echo "==> Linking tmux config..."
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Symlink nvim config
echo "==> Linking nvim config..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"

# Merge git aliases via [include] so we don't overwrite credential helpers
echo "==> Merging git config..."
if ! grep -qF "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig" 2>/dev/null; then
  printf '\n[include]\n\tpath = %s/git/.gitconfig\n' "$DOTFILES" >> "$HOME/.gitconfig"
fi

# macOS-only configs
if [[ "$OS" == "macos" ]]; then
  echo "==> Linking yabai/skhd config..."
  ln -sf "$DOTFILES/yabai/.yabairc" "$HOME/.yabairc"
  ln -sf "$DOTFILES/yabai/.skhdrc" "$HOME/.skhdrc"
fi

echo ""
echo "Done! Run: exec zsh"
