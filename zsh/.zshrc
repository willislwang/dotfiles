# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export GOPATH=$HOME/go

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  export PATH="$PATH:$GOPATH/bin:$HOME/bin"
  eval "$(pyenv init -)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$PATH:$GOPATH/bin:$HOME/bin"
fi

ZSH_THEME="robbyrussell"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

alias n=nvim
alias python=python3

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
