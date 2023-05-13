dependencies: oh-my-zsh, ripgrep, JetBrains Mono Nerd Font

clone to ~/.dotfiles, pull in git submodules, and use stow to symlink dotfiles

Fixing backspace in tmux in macOS - https://stackoverflow.com/a/72596670

```
brew install ncurses
$(brew --prefix)/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
tic -xe tmux-256color ~/tmux-256color.info
```
