#!/bin/bash

# This script essentially copies Linux configuration files from the dotfiles repository to Windows

# qutebrowser
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config ] && mkdir -p /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config
cp -r ~/.dotfiles/config/.config/qutebrowser/* /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config

# vim/gvim
# added words from Windows vim spelling file added to the local spelling file in repository
# config files made read-only to avoid me accidentally editing them in Windows
[ ! -d /mnt/c/Users/"$USER"/vimfiles/vimrc.d ] && mkdir -p /mnt/c/Users/"$USER"/vimfiles/vimrc.d
cd /mnt/c/Users/"$USER"/vimfiles || { echo "ERROR" >&2; exit 1; }
winspell="spell/en.utf-8.add"
localspell="$HOME/.dotfiles/config/.config/vim/spell/en.utf-8.add"
if [ -e "$winspell" ]; then
  comm -1 -3 <(sort "$localspell") <(sort "$winspell") > /tmp/difference
  cat "$localspell" /tmp/difference > /tmp/concatenated
  if ! cmp /tmp/concatenated "$localspell" >/dev/null >/dev/null; then
    cp /tmp/concatenated "$localspell"
  fi
  rm /tmp/{difference,concatenated}
fi
files=('vimrc' 'gvimrc' 'vimrc.d/autocmds.vim' 'vimrc.d/common.vim' 'vimrc.d/plugins.vim' 'vimrc.d/xdg.vim')
for f in "${files[@]}"; do
  attrib.exe -R "$f" >/dev/null
done
cp -r ~/.dotfiles/config/.config/vim/* .
for f in "${files[@]}"; do
  attrib.exe +R "$f"
done

# mpv
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/mpv ] && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/mpv
cp -r ~/.dotfiles/config/.config/mpv/* /mnt/c/Users/"$USER"/AppData/Roaming/mpv

# ranger
# rifle.conf file swapped over with one that works with Windows and change ignored by git
cd ~/.dotfiles
if [ ! -L config/.config/ranger/rifle.conf ]; then
  rm config/.config/ranger/rifle.conf
  ln -s config/.config/ranger/rifle.conf.windows config/.config/ranger/rifle.conf
  git update-index --skip-worktree config/.config/ranger/rifle.conf
fi

# alacritty
# the Windows base file is renamed when copied to %APPDATA%
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/alacritty ] && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/alacritty
cp ~/.dotfiles/config/.config/alacritty/alacritty.windows.yml /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/alacritty.yml
cp ~/.dotfiles/config/.config/alacritty/alacritty.main.yml /mnt/c/Users/"$USER"/AppData/Roaming/alacritty/alacritty.main.yml

# Windows Terminal
# includes hacky way to get a copy of any changed settings back to the repository
if [ -d /mnt/c/Users/"$USER"/winfiles/Windows_Terminal ]; then
  [ ! -d /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState ] \
    && mkdir -p /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
  cp /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json \
    /mnt/c/Users/"$USER"/winfiles/Windows_Terminal/settings.json.bak
  unix2dos -q /mnt/c/Users/"$USER"/winfiles/Windows_Terminal/settings.json.bak
  cp /mnt/c/Users/"$USER"/winfiles/Windows_Terminal/settings.json \
    /mnt/c/Users/"$USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
fi
