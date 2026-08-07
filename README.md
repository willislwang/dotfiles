# Dotfiles

Cross-platform dotfiles for macOS and Linux.

## Install

```bash
git clone https://github.com/willislwang/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
exec zsh
```

The install script supports macOS with Homebrew and Linux with `apt-get`, `dnf`, `pacman`, `apk`, or `zypper`.
It requires `sudo` when package installation is needed.

The install script will:
- Install missing `git`, `curl`, zsh, and Neovim packages.
- Install Oh My Zsh, its plugins, base16-shell, Vim-plug, and Neovim plugins at reviewed, pinned revisions.
- Symlink zsh, tmux, Neovim, and agent-instruction configs.
- Back up an existing managed target as `<target>.backup-<timestamp>` before replacing it.
- Add the repository's Git aliases as a global `[include]` without overwriting existing Git configuration.
- Link yabai/skhd configs on macOS only.
- Apply the Tomorrow Night scheme to Windows Terminal when running under WSL2.

## Contents

| Directory | Config |
|-----------|--------|
| `zsh/` | `.zshrc` |
| `git/` | `.gitconfig` (aliases) |
| `tmux/` | `.tmux.conf` |
| `nvim/` | `.config/nvim/init.vim` |
| `yabai/` | `.yabairc`, `.skhdrc` (macOS only) |

<sub><sup>Ricardo @aeolyus is my inspiration thanks uwu</sub></sup>
