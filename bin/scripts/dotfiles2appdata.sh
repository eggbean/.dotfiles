#!/bin/bash

# This script essentially copies Linux configuration files from the dotfiles repository to Windows

[[ "$(id -u)" = "0" ]] && { echo "This script is not supposed to be run as root" >&2; exit 1; }

WIN_HOME_RAW="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
WIN_HOME="$(wslpath "$WIN_HOME_RAW")"

# qutebrowser
[ ! -d "$WIN_HOME"/AppData/Roaming/qutebrowser/config ] \
  && mkdir -p "$WIN_HOME"/AppData/Roaming/qutebrowser/config
cp -r "$HOME"/.dotfiles/config/.config/qutebrowser/* "$WIN_HOME"/AppData/Roaming/qutebrowser/config

# vim/gvim
# added words from Windows vim spelling file added to the local spelling file in repository
# config files made read-only to avoid me accidentally editing them in Windows
cd "$WIN_HOME" || { echo "ERROR" >&2; exit 1; }
[ ! -d vimfiles/vimrc.d ] && mkdir -p vimfiles/vimrc.d && attrib.exe +H vimfiles
cd vimfiles || { echo "ERROR" >&2; exit 1; }
winspell="spell/en.utf-8.add"
localspell="$HOME"/.dotfiles/config/.config/vim/spell/en.utf-8.add
if [ -e "$winspell" ]; then
  comm -1 -3 <(sort -u "$localspell") <(sort -u "$winspell") > /tmp/difference
  cat "$localspell" /tmp/difference | awk "!a[\$0]++{print}" > /tmp/concatenated
  if ! cmp --silent /tmp/concatenated "$localspell"; then
    cp /tmp/concatenated "$localspell"
  fi
  rm /tmp/{difference,concatenated}
fi
files=('gvimrc' 'vimrc' 'vimrc.d/autocmds.vim' 'vimrc.d/distraction_free_mode.vim' 'vimrc.d/mappings.vim' \
  'vimrc.d/opts.vim' 'vimrc.d/plugins.vim' 'vimrc.d/restore_position.vim' 'vimrc.d/xdg.vim')
for f in "${files[@]}"; do
  if [ -f "$f" ]; then attrib.exe -R "$f" >/dev/null; fi
done
cp -r "$HOME"/.dotfiles/config/.config/vim/{vimrc,gvimrc} .
vimdirs=('after' 'autoload' 'colors' 'compiler' 'doc' 'ftdetect' 'ftplugin' \
  'indent' 'keymap' 'plugin' 'spell' 'syntax' 'templates' 'UltiSnips' 'vimrc.d')
for d in "${vimdirs[@]}"; do
  if [ -d "$HOME/.dotfiles/config/.config/vim/$d" ]; then
    rsync --links --recursive --delete "$HOME/.dotfiles/config/.config/vim/$d/" "$d"
  fi
done
for f in "${files[@]}"; do
  attrib.exe +R "$f"
done

# mpv
[ ! -d "$WIN_HOME"/AppData/Roaming/mpv ] \
  && mkdir "$WIN_HOME"/AppData/Roaming/mpv
cp -r "$HOME"/.dotfiles/config/.config/mpv/* "$WIN_HOME"/AppData/Roaming/mpv

# GitHub CLI
[ ! -d "$WIN_HOME/AppData/Roaming/GitHub CLI" ] \
  && mkdir "$WIN_HOME/AppData/Roaming/GitHub CLI"
cp -r "$HOME"/.dotfiles/config/.config/gh/{config,hosts}.yml "$WIN_HOME/AppData/Roaming/GitHub CLI"

# ranger
# rifle.conf file swapped over with one that works with Windows and change ignored by git
cd "$HOME"/.dotfiles || { echo "ERROR" >&2; exit 1; }
if [ ! -L config/.config/ranger/rifle.conf ]; then
  rm config/.config/ranger/rifle.conf
  ln -s config/.config/ranger/rifle.conf.windows config/.config/ranger/rifle.conf
  git update-index --skip-worktree config/.config/ranger/rifle.conf
fi

# alacritty
# the Windows base file is renamed when copied to %APPDATA%
[ ! -d "$WIN_HOME"/AppData/Roaming/alacritty ] \
  && mkdir "$WIN_HOME"/AppData/Roaming/alacritty
cp "$HOME"/.dotfiles/config/.config/alacritty/alacritty.windows.yml "$WIN_HOME"/AppData/Roaming/alacritty/alacritty.yml
cp "$HOME"/.dotfiles/config/.config/alacritty/alacritty.main.yml "$WIN_HOME"/AppData/Roaming/alacritty/alacritty.main.yml

# Windows Terminal
# includes hacky way to get a copy of any changed settings back to the repository
if [ -d "$WIN_HOME"/winfiles/Windows_Terminal ]; then
  [ ! -d "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState ] \
    && mkdir -p "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
  cp "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json \
    "$WIN_HOME"/winfiles/Windows_Terminal/settings.json.bak
  unix2dos -q "$WIN_HOME"/winfiles/Windows_Terminal/settings.json.bak
  cp "$WIN_HOME"/winfiles/Windows_Terminal/settings.json \
    "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
fi

# wsl2-ssh-pageant.exe agent
if [ ! -L "$HOME"/.ssh/wsl2-ssh-pageant.exe ]; then
  ln -s "$WIN_HOME"/winfiles/bin/wsl2-ssh-pageant.exe "$HOME"/.ssh/wsl2-ssh-pageant.exe
  chmod +x "$HOME"/.ssh/wsl2-ssh-pageant.exe
fi

# wsl-notify-send.exe
if [ ! -x "$WIN_HOME"/winfiles/bin/wsl-notify-send.exe ]; then
  chmod +x "$WIN_HOME"/winfiles/bin/wsl-notify-send.exe
fi

# Install xdg-open-wsl
if [ ! -x /usr/local/bin/xdg-open ]; then
  sudo wget -qO /usr/local/bin/xdg-open https://github.com/cpbotha/xdg-open-wsl/raw/master/xdg_open_wsl/xdg_open_wsl.py
  sudo chmod +x /usr/local/bin/xdg-open
fi
