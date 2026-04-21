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

# Set zsh as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "==> Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# Symlink zsh config (oh-my-zsh install may have written a new .zshrc, overwrite it)
echo "==> Linking zsh config..."
ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

# Symlink tmux config
echo "==> Linking tmux config..."
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Install vim-plug
PLUG_PATH="$HOME/.local/share/nvim/site/autoload/plug.vim"
if [[ ! -f "$PLUG_PATH" ]]; then
  echo "==> Installing vim-plug..."
  curl -fLo "$PLUG_PATH" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Symlink nvim config
echo "==> Linking nvim config..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"

# Install nvim plugins
echo "==> Installing nvim plugins..."
nvim --headless +PlugInstall +qall 2>/dev/null

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

# WSL2: apply Tomorrow Night to Windows Terminal
if grep -qi microsoft /proc/version 2>/dev/null; then
  WT_SETTINGS=$(find /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json 2>/dev/null | head -1)
  if [[ -n "$WT_SETTINGS" ]]; then
    echo "==> Configuring Windows Terminal..."
    if ! command -v jq &>/dev/null; then
      sudo apt-get install -y jq
    fi
    TOMORROW_NIGHT='{
      "name": "Tomorrow Night",
      "background": "#1D1F21", "foreground": "#C5C8C6",
      "cursorColor": "#C5C8C6", "selectionBackground": "#373B41",
      "black": "#1D1F21", "red": "#CC6666", "green": "#B5BD68",
      "yellow": "#F0C674", "blue": "#81A2BE", "purple": "#B294BB",
      "cyan": "#8ABEB7", "white": "#C5C8C6",
      "brightBlack": "#969896", "brightRed": "#CC6666", "brightGreen": "#B5BD68",
      "brightYellow": "#F0C674", "brightBlue": "#81A2BE", "brightPurple": "#B294BB",
      "brightCyan": "#8ABEB7", "brightWhite": "#FFFFFF"
    }'
    jq --argjson scheme "$TOMORROW_NIGHT" '
      .schemes = ((.schemes // []) | map(select(.name != "Tomorrow Night")) + [$scheme]) |
      .profiles.defaults.colorScheme = "Tomorrow Night"
    ' "$WT_SETTINGS" > "$WT_SETTINGS.tmp" && mv "$WT_SETTINGS.tmp" "$WT_SETTINGS"
  fi
fi

echo ""
echo "Done! Run: exec zsh"
