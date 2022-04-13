#!/bin/bash

# qutebrowser
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config/ ] && mkdir -p /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config/
cp -r ~/.dotfiles/config/.config/qutebrowser/* /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config/

# gvim (files made read-only to avoid me accidentally editing them in Windows)
[ ! -d /mnt/c/Users/"$USER"/vimfiles/vimrc.d/ ] && mkdir -p /mnt/c/Users/"$USER"/vimfiles/vimrc.d/
cd /mnt/c/Users/"$USER"/vimfiles/ || { echo "ERROR: /mnt/c/Users/$USER/vimfiles/ not found." >&2; exit 1; }
attrib.exe -R vimrc
attrib.exe -R gvimrc
attrib.exe -R vimrc.d\\*
cp -r ~/.dotfiles/config/.config/vim/* .
attrib.exe +R vimrc
attrib.exe +R gvimrc
attrib.exe +R vimrc.d\\*

# mpv
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/mpv/ ] && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/mpv/
cp ~/.dotfiles/config/.config/mpv/* /mnt/c/Users/"$USER"/AppData/Roaming/mpv/

# alacritty
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/ ] && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/
cp ~/.dotfiles/config/.config/alacritty/alacritty.yml.windows /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/alacritty.yml
cp ~/.dotfiles/config/.config/alacritty/alacritty.main.yml /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/alacritty.main.yml

# ranger/rifle
if [ ! -L ~/.dotfiles/config/.config/ranger/rifle.conf ]; then
  rm ~/.dotfiles/config/.config/ranger/rifle.conf
  ln -s ~/.dotfiles/config/.config/ranger/rifle.conf.windows ~/.dotfiles/config/.config/ranger/rifle.conf
  git update-index --skip-worktree ~/.dotfiles/config/.config/ranger/rifle.conf
fi
