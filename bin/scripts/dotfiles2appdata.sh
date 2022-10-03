#!/bin/bash

# This script essentially copies Linux configuration files from the dotfiles repository to Windows

# qutebrowser
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config ] \
  && mkdir -p /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config
cp -r ~/.dotfiles/config/.config/qutebrowser/* /mnt/c/Users/"$USER"/AppData/Roaming/qutebrowser/config

# vim/gvim
# added words from Windows vim spelling file added to the local spelling file in repository
# config files made read-only to avoid me accidentally editing them in Windows
cd /mnt/c/Users/"$USER" || { echo "ERROR" >&2; exit 1; }
[ ! -d vimfiles/vimrc.d ] && mkdir -p vimfiles/vimrc.d && attrib.exe +H vimfiles
cd vimfiles || { echo "ERROR" >&2; exit 1; }
winspell="spell/en.utf-8.add"
localspell="$HOME/.dotfiles/config/.config/vim/spell/en.utf-8.add"
if [ -e "$winspell" ]; then
  comm -1 -3 <(sort -u "$localspell") <(sort -u "$winspell") > /tmp/difference
  cat "$localspell" /tmp/difference | awk "!a[\$0]++{print}" > /tmp/concatenated
  if ! cmp --silent /tmp/concatenated "$localspell"; then
    cp /tmp/concatenated "$localspell"
  fi
  rm /tmp/{difference,concatenated}
fi
files=('vimrc' 'gvimrc' 'vimrc.d/autocmds.vim' 'vimrc.d/common.vim' 'vimrc.d/distraction_free_mode.vim' \
  'vimrc.d/plugins.vim' 'vimrc.d/restore_position.vim' 'vimrc.d/xdg.vim')
for f in "${files[@]}"; do
  if [ -f "$f" ]; then attrib.exe -R "$f" >/dev/null; fi
done
cp -r ~/.dotfiles/config/.config/vim/{vimrc,gvimrc} .
vimdirs=('after' 'autoload' 'colors' 'compiler' 'doc' 'ftdetect' 'ftplugin' \
  'indent' 'keymap' 'plugin' 'spell' 'syntax' 'templates' 'UltiSnips' 'vimrc.d')
for d in "${vimdirs[@]}"; do
  if [ -d "$HOME/.dotfiles/config/.config/vim/$d" ]; then
    rsync --recursive --delete "$HOME/.dotfiles/config/.config/vim/$d/" "$d"
  fi
done
for f in "${files[@]}"; do
  attrib.exe +R "$f"
done

# mpv
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/mpv ] \
  && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/mpv
cp -r ~/.dotfiles/config/.config/mpv/* /mnt/c/Users/"$USER"/AppData/Roaming/mpv

# ranger
# rifle.conf file swapped over with one that works with Windows and change ignored by git
cd ~/.dotfiles || { echo "ERROR" >&2; exit 1; }
if [ ! -L config/.config/ranger/rifle.conf ]; then
  rm config/.config/ranger/rifle.conf
  ln -s config/.config/ranger/rifle.conf.windows config/.config/ranger/rifle.conf
  git update-index --skip-worktree config/.config/ranger/rifle.conf
fi

# alacritty
# the Windows base file is renamed when copied to %APPDATA%
[ ! -d /mnt/c/Users/"$USER"/AppData/Roaming/alacritty ] \
  && mkdir /mnt/c/Users/"$USER"/AppData/Roaming/alacritty
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
