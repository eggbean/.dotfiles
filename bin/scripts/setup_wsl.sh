#!/bin/bash

# Does various things to setup/update the Windows partition

if ! grep -qi microsoft /proc/version; then
  { echo "This isn't a Windows WSL system" >&2; exit 1; }
fi

[[ $(id -u) == 0 ]] && { echo "This script is not supposed to be run as root" >&2; exit 1; }

WIN_HOME_RAW="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
WIN_HOME="$(wslpath "$WIN_HOME_RAW")"

# Copy qutebrowser config to Windows
[[ ! -d $WIN_HOME/AppData/Roaming/qutebrowser/config ]] \
  && mkdir -p "$WIN_HOME"/AppData/Roaming/qutebrowser/config
cp -r "$HOME"/.dotfiles/config/.config/qutebrowser/* "$WIN_HOME"/AppData/Roaming/qutebrowser/config

# Copy vim/gvim config to Windows
# added words from Windows vim spelling file added to the local spelling file in repository
# config files made read-only to avoid me accidentally editing them in Windows
cd "$WIN_HOME" || { echo "ERROR" >&2; exit 1; }
[[ ! -d vimfiles/vimrc.d ]] && mkdir -p vimfiles/vimrc.d
cd vimfiles || { echo "ERROR" >&2; exit 1; }
winspell="spell/en.utf-8.add"
localspell="$HOME"/.dotfiles/config/.config/vim/spell/en.utf-8.add
if [[ -e $winspell ]]; then
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
  if [[ -f $f ]]; then attrib.exe -R "$f" >/dev/null; fi
done
cp -r "$HOME"/.dotfiles/config/.config/vim/{vimrc,gvimrc} .
vimdirs=('after' 'autoload' 'colors' 'compiler' 'css' 'doc' 'ftdetect' 'ftplugin' \
  'indent' 'keymap' 'plugin' 'spell' 'syntax' 'templates' 'UltiSnips' 'vimrc.d')
for d in "${vimdirs[@]}"; do
  if [[ -d $HOME/.dotfiles/config/.config/vim/$d ]]; then
    rsync --links --recursive --delete "$HOME/.dotfiles/config/.config/vim/$d/" "$d"
  fi
done
# config files made read-only to avoid me accidentally editing them in Windows
for f in "${files[@]}"; do
  attrib.exe +R "$f"
done
# added words from Windows vim spelling file added to the local spelling file in repository
# (only if file is encryption unlocked, as otherwise things get messed up)
syncdict() {
  local winspell="spell/en.utf-8.add"
  local localspell="$HOME"/.dotfiles/config/.config/vim/spell/en.utf-8.add
  if [ -e "$winspell" ]; then
    comm -1 -3 <(sort -u "$localspell") <(sort -u "$winspell") > /tmp/difference
    cat "$localspell" /tmp/difference | awk "!a[\$0]++{print}" > /tmp/concatenated
    if ! cmp --silent /tmp/concatenated "$localspell"; then
      cp /tmp/concatenated "$localspell"
    fi
    rm /tmp/{difference,concatenated}
  fi
  rsync --recursive --delete "$HOME/.dotfiles/config/.config/vim/spell" "$WIN_HOME/vimfiles"
}
git config -f ~/.dotfiles/.git/config --get filter.git-crypt.smudge >/dev/null && syncdict

# Copy mpv config to Windows
[[ ! -d $WIN_HOME/AppData/Roaming/mpv ]] \
  && mkdir "$WIN_HOME"/AppData/Roaming/mpv
cp -r "$HOME"/.dotfiles/config/.config/mpv/* "$WIN_HOME"/AppData/Roaming/mpv

# Copy GitHub CLI config to Windows
[[ ! -d $WIN_HOME/AppData/Roaming/"GitHub CLI" ]] \
  && mkdir "$WIN_HOME/AppData/Roaming/GitHub CLI"
cp -r "$HOME"/.dotfiles/config/.config/gh/{config,hosts}.yml "$WIN_HOME/AppData/Roaming/GitHub CLI"

# Modify ranger config to work in Windows
# rifle.conf file swapped over with one that works with Windows and change ignored by git
cd "$HOME"/.dotfiles || { echo "ERROR" >&2; exit 1; }
if [[ ! -L config/.config/ranger/rifle.conf ]]; then
  rm config/.config/ranger/rifle.conf
  ln -s config/.config/ranger/rifle.conf.windows config/.config/ranger/rifle.conf
  git update-index --skip-worktree config/.config/ranger/rifle.conf
fi

# Copy alacritty config to Windows
# the Windows base file is renamed when copied to %APPDATA%
[[ ! -d $WIN_HOME/AppData/Roaming/alacritty ]] \
  && mkdir "$WIN_HOME"/AppData/Roaming/alacritty
cp "$HOME"/.dotfiles/config/.config/alacritty/alacritty.windows.yml "$WIN_HOME"/AppData/Roaming/alacritty/alacritty.yml
cp "$HOME"/.dotfiles/config/.config/alacritty/alacritty.main.yml "$WIN_HOME"/AppData/Roaming/alacritty/alacritty.main.yml

# Copy Windows Terminal config from winfiles repository to $WIN_HOME/AppData/Local
# includes hacky way to get a copy of any changed settings back to the repository
if [[ -d $WIN_HOME/winfiles/Windows_Terminal ]]; then
  [[ ! -d $WIN_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState ]] \
    && mkdir -p "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
  cp "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json \
    "$WIN_HOME"/winfiles/Windows_Terminal/settings.json.bak
  unix2dos -q "$WIN_HOME"/winfiles/Windows_Terminal/settings.json.bak
  cp "$WIN_HOME"/winfiles/Windows_Terminal/settings.json \
    "$WIN_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
fi

# Using the PuTTY ssh agent with WSL through wsl2-ssh-pageant.exe
if [[ ! -L $HOME/.ssh/wsl2-ssh-pageant.exe ]]; then
  ln -s "$WIN_HOME"/winfiles/bin/wsl2-ssh-pageant.exe "$HOME"/.ssh/wsl2-ssh-pageant.exe
  chmod +x "$HOME"/.ssh/wsl2-ssh-pageant.exe
fi

# Get native Windows notifications from Linux with wsl-notify-send.exe
if [[ ! -x "$WIN_HOME"/winfiles/bin/wsl-notify-send.exe ]]; then
  chmod +x "$WIN_HOME"/winfiles/bin/wsl-notify-send.exe
fi

# Install xdg-open-wsl
if [[ ! -x /usr/local/bin/xdg-open ]]; then
  sudo wget -qO /usr/local/bin/xdg-open https://github.com/cpbotha/xdg-open-wsl/raw/master/xdg_open_wsl/xdg_open_wsl.py
  sudo chmod +x /usr/local/bin/xdg-open
fi

# WSL uses its own subnet, so replace arp with Windows
# arp.exe as its NIC is on the normal LAN network.
# Needed for my ssh_config bastion bypass directive (https://bit.ly/3OHRKEu)
if [[ ! -L /usr/local/bin/arp ]]; then
  sudo ln -s $(which arp.exe) /usr/local/bin/arp
fi

# Set some xdg-user-dirs to NTFS locations
xdg-user-dirs-update \
  --dummy-output ~/.dotfiles/config/.config/user-dirs.dirs \
  --set DESKTOP $WIN_HOME/Desktop
xdg-user-dirs-update \
  --dummy-output ~/.dotfiles/config/.config/user-dirs.dirs \
  --set DOWNLOAD $WIN_HOME/Downloads
xdg-user-dirs-update \
  --dummy-output ~/.dotfiles/config/.config/user-dirs.dirs \
  --set DOCUMENTS $WIN_HOME/Documents
xdg-user-dirs-update \
  --dummy-output ~/.dotfiles/config/.config/user-dirs.dirs \
  --set MUSIC $WIN_HOME/Music
xdg-user-dirs-update \
  --dummy-output ~/.dotfiles/config/.config/user-dirs.dirs \
  --set PICTURES $WIN_HOME/Pictures
xdg-user-dirs-update \
  --dummy-output ~/.dotfiles/config/.config/user-dirs.dirs \
  --set VIDEOS $WIN_HOME/Videos
# Make git ignore these changes
git update-index --skip-worktree ~/.dotfiles/config/.config/user-dirs.dirs

# Make .hidden files in every NTFS xdg-user-dir and subdirectory
# to hide files in Thunar/Nautilus that are hidden in Windows
dirs=( \
  "$WIN_HOME" \
  "$(xdg-user-dir DESKTOP)" \
  "$(xdg-user-dir DOWNLOAD)" \
  "$(xdg-user-dir DOCUMENTS)" \
  "$(xdg-user-dir MUSIC)" \
  "$(xdg-user-dir PICTURES)" \
  "$(xdg-user-dir VIDEOS)" \
)
for dir in "${dirs[@]}"; do
  windir="$(wslpath -w "$dir")"
  powershell.exe -File F:\\Users\\jason\\winfiles\\scripts\\make-hidden.ps1 "$windir"
done

# Fix xfce "authentication is required to create a colour managed device" problem
if [[ ! -e /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla ]]; then
	sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla > /dev/null <<-'EOF'
	[Allow Colord all Users]
	Identity=unix-user:*
	Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
	ResultAny=no
	ResultInactive=no
	ResultActive=yes
	EOF
fi
