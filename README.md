# Dotfiles

Cross-platform dotfiles for macOS and Linux.

## Install

```bash
git clone https://github.com/willislwang/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
exec zsh
```

The install script will:
- Install zsh (if missing)
- Install oh-my-zsh and plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- Symlink zsh, tmux, and nvim configs
- Merge git aliases into your existing `.gitconfig` via `[include]`
- Link yabai/skhd configs on macOS only

## Contents

| Directory | Config |
|-----------|--------|
| `zsh/` | `.zshrc` |
| `git/` | `.gitconfig` (aliases) |
| `tmux/` | `.tmux.conf` |
| `nvim/` | `.config/nvim/init.vim` |
| `yabai/` | `.yabairc`, `.skhdrc` (macOS only) |

<sub><sup>Ricardo @aeolyus is my inspiration thanks uwu</sub></sup>
