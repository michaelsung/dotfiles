# Dependencies

- oh-my-zsh https://ohmyz.sh/#install
- zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
- ripgrep https://github.com/BurntSushi/ripgrep
- JetBrains Mono Nerd Font https://www.nerdfonts.com/font-downloads

# Setup
clone to ~/.dotfiles, pull in git submodules, and use stow to symlink dotfiles

# Troubleshooting
Fixing backspace in tmux in macOS - https://stackoverflow.com/a/72596670

```
brew install ncurses
$(brew --prefix)/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
tic -xe tmux-256color ~/tmux-256color.info
```
