#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update these intentionally after reviewing upstream changes.
OH_MY_ZSH_REVISION="0912e05c0589d26ea20d79555487900880aad4d5"
ZSH_AUTOSUGGESTIONS_REVISION="85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5"
ZSH_SYNTAX_HIGHLIGHTING_REVISION="1d85c692615a25fe2293bdd44b34c217d5d2bf04"
BASE16_SHELL_REVISION="5c54546e8d349819bdc2854143b815842dee042d"
NEOVIM_VERSION="0.12.4"
NEOVIM_LINUX_X86_64_SHA256="012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628"
NEOVIM_LINUX_ARM64_SHA256="ceb7e88c6b681f0515d135dcdfad54f5eb4373b25ce6172197cd9a69c758063f"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

on_error() {
  printf 'Error: installation failed on line %s.\n' "$1" >&2
}
trap 'on_error "$LINENO"' ERR

case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux) OS="linux" ;;
  *) fail "unsupported OS: $(uname -s)" ;;
esac

run_as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    command -v sudo &>/dev/null || fail "sudo is required to install packages"
    sudo "$@"
  fi
}

install_packages() {
  if [[ "$OS" == "macos" ]]; then
    command -v brew &>/dev/null || fail "Homebrew is required to install: $*"
    brew install "$@"
    return
  fi

  if command -v apt-get &>/dev/null; then
    run_as_root apt-get install -y "$@"
  elif command -v dnf &>/dev/null; then
    run_as_root dnf install -y "$@"
  elif command -v pacman &>/dev/null; then
    run_as_root pacman -S --needed --noconfirm "$@"
  elif command -v apk &>/dev/null; then
    run_as_root apk add "$@"
  elif command -v zypper &>/dev/null; then
    run_as_root zypper --non-interactive install "$@"
  else
    fail "no supported package manager found; install manually: $*"
  fi
}

ensure_command() {
  local command_name="$1"
  local package_name="$2"

  command -v "$command_name" &>/dev/null || install_packages "$package_name"
  command -v "$command_name" &>/dev/null || fail "$command_name was not installed"
}

backup_existing_target() {
  local target="$1"
  local backup
  local suffix=1

  [[ -e "$target" || -L "$target" ]] || return 0

  backup="${target}.backup-$(date +%Y%m%d%H%M%S)"
  while [[ -e "$backup" || -L "$backup" ]]; do
    backup="${target}.backup-$(date +%Y%m%d%H%M%S)-${suffix}"
    ((++suffix))
  done

  printf '==> Backing up %s to %s\n' "$target" "$backup"
  mv "$target" "$backup"
}

link_file() {
  local source="$1"
  local target="$2"

  [[ -e "$source" ]] || fail "source does not exist: $source"
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    return
  fi

  backup_existing_target "$target"
  ln -s "$source" "$target"
}

install_pinned_repo() {
  local repository="$1"
  local revision="$2"
  local destination="$3"

  if [[ -e "$destination" && ! -d "$destination" ]]; then
    fail "repository destination is not a directory: $destination"
  fi

  if [[ ! -d "$destination" ]]; then
    mkdir -p "$(dirname "$destination")"
    git init --quiet "$destination"
    git -C "$destination" remote add origin "$repository"
  elif ! git -C "$destination" rev-parse --is-inside-work-tree &>/dev/null; then
    fail "repository destination is not a Git repository: $destination"
  fi

  git -C "$destination" fetch --depth=1 origin "$revision"
  git -C "$destination" checkout --quiet --detach FETCH_HEAD
  [[ "$(git -C "$destination" rev-parse HEAD)" == "$revision" ]] || fail "could not verify $repository revision"
}

install_neovim() {
  if [[ "$OS" == "macos" ]]; then
    ensure_command nvim neovim
    return
  fi

  local architecture
  local asset
  local checksum
  local install_dir="$HOME/.local/opt/nvim-$NEOVIM_VERSION"

  case "$(uname -m)" in
    x86_64) architecture="x86_64" ;;
    aarch64|arm64) architecture="arm64" ;;
    *) fail "unsupported Linux architecture for Neovim: $(uname -m)" ;;
  esac

  asset="nvim-linux-$architecture"
  if [[ "$architecture" == "x86_64" ]]; then
    checksum="$NEOVIM_LINUX_X86_64_SHA256"
  else
    checksum="$NEOVIM_LINUX_ARM64_SHA256"
  fi

  if [[ ! -x "$install_dir/bin/nvim" ]]; then
    ensure_command tar tar
    ensure_command sha256sum coreutils

    (
      local archive="$(mktemp)"
      local extraction_dir="$(mktemp -d)"
      trap 'rm -rf "$archive" "$extraction_dir"' EXIT

      printf '==> Downloading Neovim v%s...\n' "$NEOVIM_VERSION"
      curl --fail --location --retry 3 --output "$archive" \
        "https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/$asset.tar.gz"
      printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check --status || fail "Neovim checksum verification failed"
      tar -C "$extraction_dir" -xzf "$archive"
      [[ -x "$extraction_dir/$asset/bin/nvim" ]] || fail "Neovim archive did not contain nvim"

      mkdir -p "$(dirname "$install_dir")"
      backup_existing_target "$install_dir"
      mv "$extraction_dir/$asset" "$install_dir"
    )
  fi

  link_file "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
}

login_shell() {
  local account

  if [[ "$OS" == "linux" ]]; then
    account="$(getent passwd "$(id -u)")" || fail "could not determine the configured login shell"
    printf '%s\n' "${account##*:}"
  else
    account="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null)" || fail "could not determine the configured login shell"
    printf '%s\n' "${account#UserShell: }"
  fi
}

if [[ $# -gt 0 ]]; then
  case "$1" in
    --nvim)
      [[ $# -eq 1 ]] || fail "usage: $0 --nvim"
      echo "==> Detected OS: $OS"
      ensure_command curl curl
      install_neovim
      exit 0
      ;;
    *) fail "usage: $0 [--nvim]" ;;
  esac
fi

echo "==> Detected OS: $OS"

ensure_command git git
ensure_command curl curl
ensure_command zsh zsh

echo "==> Installing oh-my-zsh..."
install_pinned_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_REVISION" "$HOME/.oh-my-zsh"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
echo "==> Installing zsh-autosuggestions..."
install_pinned_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_AUTOSUGGESTIONS_REVISION" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
echo "==> Installing zsh-syntax-highlighting..."
install_pinned_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_SYNTAX_HIGHLIGHTING_REVISION" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "==> Installing base16-shell..."
install_pinned_repo "https://github.com/tinted-theming/base16-shell.git" "$BASE16_SHELL_REVISION" "$HOME/.config/base16-shell"

zsh_path="$(command -v zsh)"
if [[ "$(login_shell)" != "$zsh_path" ]]; then
  if [[ -f /etc/shells ]]; then
    shell_is_allowed=false
    while IFS= read -r shell; do
      [[ "$shell" == "$zsh_path" ]] && shell_is_allowed=true
    done < /etc/shells
    [[ "$shell_is_allowed" == true ]] || fail "$zsh_path is not listed in /etc/shells"
  fi

  echo "==> Setting zsh as default shell..."
  chsh -s "$zsh_path" || printf '    Run manually: chsh -s %s\n' "$zsh_path"
fi

echo "==> Linking zsh config..."
link_file "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
echo "==> Linking tmux config..."
link_file "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

install_neovim
ensure_command rg ripgrep

echo "==> Linking nvim config..."
link_file "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"

echo "==> Merging git config..."
GIT_CONFIG="$DOTFILES/git/.gitconfig"
git_include_exists=false
while IFS= read -r include; do
  [[ "$include" == "$GIT_CONFIG" ]] && git_include_exists=true
done < <(git config --global --get-all include.path 2>/dev/null || true)
if [[ "$git_include_exists" == false ]]; then
  git config --global --add include.path "$GIT_CONFIG"
fi

echo "==> Linking agent instructions..."
link_file "$DOTFILES/AGENTS.md" "$HOME/AGENTS.md"
link_file "$DOTFILES/AGENTS.md" "$HOME/.claude/CLAUDE.md"

if [[ "$OS" == "macos" ]]; then
  echo "==> Linking yabai/skhd config..."
  link_file "$DOTFILES/yabai/.yabairc" "$HOME/.yabairc"
  link_file "$DOTFILES/yabai/.skhdrc" "$HOME/.skhdrc"
fi

if grep -qi microsoft /proc/version 2>/dev/null; then
  shopt -s nullglob
  terminal_settings=(/mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json)
  shopt -u nullglob
  WT_SETTINGS="${terminal_settings[0]:-}"
  if [[ -n "$WT_SETTINGS" ]]; then
    echo "==> Configuring Windows Terminal..."
    ensure_command jq jq
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

printf '\nDone! Run: exec zsh\n'
