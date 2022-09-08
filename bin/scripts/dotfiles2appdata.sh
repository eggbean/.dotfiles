#!/bin/bash

# qutebrowser
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config/ ] && mkdir -p /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config/
cp -r ~/.dotfiles/config/.config/qutebrowser/* /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config/

# gvim (files made read-only to avoid me accidentally editing them in Windows)
[ ! -d /mnt/c/Users/"$USER"/vimfiles/vimrc.d/ ] && mkdir -p /mnt/c/Users/"$USER"/vimfiles/vimrc.d/
cd /mnt/c/Users/"$USER"/vimfiles/ || { echo "ERROR: /mnt/c/Users/$USER/vimfiles/ not found." >&2; exit 1; }
files=('vimrc' 'gvimrc' 'vimrc.d\\*')
for f in "${files[@]}"; do
  attrib.exe -R "$f" 2>/dev/null
done
cp -r ~/.dotfiles/config/.config/vim/* .
for f in "${files[@]}"; do
  attrib.exe +R "$f"
done

# mpv
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/mpv/ ] && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/mpv/
cp -r ~/.dotfiles/config/.config/mpv/* /mnt/c/Users/"$USER"/AppData/Roaming/mpv/

# alacritty
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/ ] && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/
cp ~/.dotfiles/config/.config/alacritty/alacritty.windows.yml /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/alacritty.yml
cp ~/.dotfiles/config/.config/alacritty/alacritty.main.yml /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/alacritty.main.yml

# ranger
if [ ! -L ~/.dotfiles/config/.config/ranger/rifle.conf ]; then
  rm ~/.dotfiles/config/.config/ranger/rifle.conf
  ln -s ~/.dotfiles/config/.config/ranger/rifle.conf.windows ~/.dotfiles/config/.config/ranger/rifle.conf
  cd ~/.dotfiles
  git update-index --skip-worktree ~/.dotfiles/config/.config/ranger/rifle.conf
fi

# windows terminal
if [ -d /mnt/c/Users/"$USER"/winfiles/Windows_Terminal ]; then
  [ ! -d /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState ] && mkdir -p /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
  cp /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json /mnt/c/Users/"$USER"/winfiles/Windows_Terminal/settings.json.bak
  unix2dos -q /mnt/c/Users/"$USER"/winfiles/Windows_Terminal/settings.json.bak
  cp /mnt/c/Users/"$USER"/winfiles/Windows_Terminal/settings.json /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
fi
