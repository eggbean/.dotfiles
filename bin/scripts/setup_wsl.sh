#!/bin/bash

# Does various things to setup Windows Subsystem for Linux

# Check if this is a WSL system
if ! grep -qi microsoft /proc/version; then
  { echo "This isn't a Windows WSL system" >&2; exit 1; }
fi

# Check if superuser
[[ $(id -u) == 0 ]] && { echo "This script is not supposed to be run as root" >&2; exit 1; }

# Set variable for Windows home directory
WIN_HOME_RAW="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
WIN_HOME="$(wslpath "$WIN_HOME_RAW")"

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

# Set wsl.conf
cat <<-EOF | sudo tee /etc/wsl.conf > /dev/null
	[automount]
	enabled = true
	options = "metadata,uid=1000,gid=1000,umask=0022,fmask=11,case=off"
	mountFsTab = true

	[network]
	generateHosts = false
	generateResolvConf = false
	hostname = $(hostname -s)

	[filesystem]
	umask = 0022

	[user]
	default=$(whoami)

	[boot]
	systemd=true
EOF

# Set /etc/resolv.conf
cat <<-EOF | sudo tee /etc/resolv.conf > /dev/null
	nameserver 1.1.1.1
EOF

# Set /etc/hosts
cat <<-EOF | sudo tee /etc/hosts > /dev/null
	127.0.0.1   localhost
	127.0.1.1   $(hostname -s).jinkosystems.co.uk  $(hostname -s)

	# The following lines are desirable for IPv6 capable hosts
	::1     ip6-localhost ip6-loopback
	fe00::0 ip6-localnet
	ff00::0 ip6-mcastprefix
	ff02::1 ip6-allnodes
	ff02::2 ip6-allrouters
EOF

# Set gtk3 settings for xfce4
cat <<-'EOF' > ~/.dotfiles/config/.config/gtk-3.0/settings.ini
	[Settings]
	gtk-application-prefer-dark-theme=0
	gtk-theme-name=windows-10-dark
	gtk-icon-theme-name=windows-10
	gtk-font-name=Sans 10
	gtk-cursor-theme-name=Adwaita
	gtk-cursor-theme-size=0
	gtk-toolbar-style=GTK_TOOLBAR_BOTH
	gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
	gtk-button-images=1
	gtk-menu-images=1
	gtk-enable-event-sounds=1
	gtk-enable-input-feedback-sounds=1
	gtk-xft-antialias=1
	gtk-xft-hinting=1
	gtk-xft-hintstyle=hintfull
EOF
# Make git ignore these changes
git update-index --skip-worktree ~/.dotfiles/config/.config/gtk-3.0/settings.ini

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

# --------------------
# exit now as currently my laptop's Windows Shell folders are not
# in the standard locations, so the rest of this script won't work
exit 0

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
