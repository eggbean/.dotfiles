#!/bin/bash

# run as sudo from main user account, after stowing

[[ "$(id -u)" != "0" ]] && ( echo "This script must be run as root" >&2; exit 1 )

# ne
while true; do
	read -p "Do you want to make a symlink for ne?  " yn
	case $yn in
		[Yy]* )	pushd /root/ >/dev/null || ( echo "ERROR" >&2; exit 1 )
				rm -rf .ne/ 2>/dev/null
				ln -s /home/"$(logname)"/.ne .ne
				popd >/dev/null || ( echo "ERROR" >&2; exit 1 )
				break ;;
		[Nn]* )	break ;;
	esac
done

# git
while true; do
	read -p "Do you want to make a symlink for git?  " yn
	case $yn in
		[Yy]* )	pushd /root/ >/dev/null || ( echo "ERROR" >&2; exit 1 )
				rm .gitconfig 2>/dev/null
				[ ! -d .config/ ] && mkdir .config
				pushd .config/ >/dev/null || ( echo "ERROR" >&2; exit 1 )
				rm -rf git/ 2>/dev/null
				ln -s /home/"$(logname)"/.dotfiles/config/.config/git git
				echo "DONE"
				break ;;
		[Nn]* )	break ;;
	esac
done

# nvim/vi
while true; do
	read -p "Do you want to set the default editor to vi, or nvim if it's installed?  " yn
	case $yn in
		[Yy]* )	[ -x /usr/bin/nvim ] && update-alternatives --set editor /usr/bin/nvim || update-alternatives --set editor /usr/bin/vi
				break ;;
		[Nn]* )	break ;;
	esac
done
