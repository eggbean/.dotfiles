#!/bin/bash

[[ "$(id -u)" = "0" ]] && { echo "This script is not supposed to be run as root" >&2; exit 1; }

cp -r ~/.dotfiles/config/.config/qutebrowser/ /mnt/c/Users/$USER/AppData/Roaming/qutebrowser/
cp ~/.dotfiles/config/.vimrc /mnt/c/Users/$USER/vimfiles/vimrc
cp ~/.dotfiles/config/.vim/colors/summerfruit256.vim /mnt/c/Users/jason/vimfiles/colors/
cp ~/.dotfiles/config/.gvimrc /mnt/c/Users/$USER/vimfiles/gvimrc
cp ~/.dotfiles/config/.config/mpv/input.conf /mnt/c/Users/$USER/AppData/Roaming/mpv/
cp ~/.dotfiles/config/.config/alacritty/alacritty.yml.windows /mnt/c/Users/$USER/AppData/Roaming/alacritty/alacritty.yml
