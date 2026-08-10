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
- Install missing `git`, `curl`, zsh, and ripgrep packages.
- Download a reviewed, checksum-verified Neovim release on Linux and install it under `~/.local/opt`.
- Install Oh My Zsh, its plugins, and base16-shell at reviewed, pinned revisions.
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
| `nvim/` | Lua-based `.config/nvim` |
| `yabai/` | `.yabairc`, `.skhdrc` (macOS only) |

## Neovim

On Linux, `bash install.sh --nvim` downloads Neovim v0.12.4 from its official release, verifies its SHA-256 checksum, installs it under `~/.local/opt/nvim-0.12.4`, and links `~/.local/bin/nvim` to it.
`~/.local/bin` is included in the managed Zsh PATH.
The Neovim configuration is linked from `nvim/.config/nvim` to `~/.config/nvim`.
The retired Vimscript configuration is retained at `nvim-archived/init.vim` and is not loaded by Neovim.

### Core Keymaps

Press Space and pause to see the available leader mappings in Which Key.

| Key | Action |
|-----|--------|
| `Space e`, `Ctrl-n` | Open the Oil file explorer |
| `Space f`, `Ctrl-Space` | Find files |
| `Space s`, `Ctrl-g` | Search text with ripgrep |
| `Space b` | List open buffers |
| `Space n`, `Space p`, `Space d` | Next, previous, and close buffer |
| `Space g` | Open Neogit |

Text search requires `ripgrep`.
The complete installer installs it, or install it on Ubuntu with `sudo apt-get install ripgrep`.

<sub><sup>Ricardo @aeolyus is my inspiration thanks uwu</sub></sup>
