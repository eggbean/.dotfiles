#!/bin/bash

# qutebrowser
[ ! -d /mnt/c/Users/$USER/AppData/Roaming/qutebrowser/config/ ] && mkdir -p /mnt/c/Users/$USER/AppData/Roaming/qutebrowser/config/
cp -r ~/.dotfiles/config/.config/qutebrowser/* /mnt/c/Users/$USER/AppData/Roaming/qutebrowser/config/

# gvim
[ ! -d /mnt/c/Users/$USER/vimfiles/ ] && mkdir /mnt/c/Users/$USER/vimfiles/
cd /mnt/c/Users/$USER/vimfiles/
attrib.exe -R vimrc
attrib.exe -R gvimrc
attrib.exe -R vimrc.d\\*
cp -r ~/.dotfiles/config/.config/vim/* /mnt/c/Users/$USER/vimfiles/
attrib.exe +R vimrc
attrib.exe +R gvimrc
attrib.exe +R vimrc.d\\*

# mpv
[ ! -d /mnt/c/Users/$USER/AppData/Roaming/mpv/ ] && mkdir /mnt/c/Users/$USER/AppData/Roaming/mpv/
cp ~/.dotfiles/config/.config/mpv/* /mnt/c/Users/$USER/AppData/Roaming/mpv/

# alacritty
[ ! -d /mnt/c/Users/$USER/AppData/Roaming/alacritty/ ] && mkdir /mnt/c/Users/$USER/AppData/Roaming/alacritty/
cp ~/.dotfiles/config/.config/alacritty/alacritty.yml.windows /mnt/c/Users/$USER/AppData/Roaming/alacritty/alacritty.yml
cp ~/.dotfiles/config/.config/alacritty/alacritty.main.yml /mnt/c/Users/$USER/AppData/Roaming/alacritty/alacritty.main.yml
