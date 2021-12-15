#!/bin/bash

# Run as sudo from main user account, after stowing
if [[ "$(id -u)" != "0" ]]; then { echo "This script must be run as root" >&2; exit 1; }; fi

# ne
while read -rp "Do you want to make a symlink for ne?  " yn; do
	case $yn in
		[Yy]* )	pushd /root >/dev/null
				if [ -d .ne ]; then rm -rf .ne; fi
				if [ ! -L .ne ]; then ln -s /home/"$(logname)"/.ne .ne; fi
				popd >/dev/null || { echo "ERROR" >&2; exit 1; }
				break ;;
		[Nn]* )	break ;;
	esac
done

# ssh
while read -rp "Do you want to make a symlink for github ssh key?  " yn; do
	case $yn in
		[Yy]* )	pushd /root >/dev/null
				if [ ! -d .ssh ]; then mkdir .ssh; fi
				if [ ! -L .ssh/id_github ]; then ln -s /home/"$(logname)"/.ssh/id_github .ssh/id_github; fi
				popd >/dev/null || { echo "ERROR" >&2; exit 1; }
				break ;;
		[Nn]* )	break ;;
	esac
done

# GnuPG
while read -rp "Do you want to make a symlink for GnuPG?  " yn; do
	case $yn in
		[Yy]* )	pushd /root >/dev/null
				if [ -d .gnupg ]; then rm -rf .gnupg; fi
				if [ ! -L .gnupg ]; then ln -s /home/"$(logname)"/.gnupg .gnupg; fi
				popd >/dev/null || { echo "ERROR" >&2; exit 1; }
				break ;;
		[Nn]* )	break ;;
	esac
done

# git
while read -rp "Do you want to make a symlink for git?  " yn; do
	case $yn in
		[Yy]* )	pushd /root/ >/dev/null
				if [ -e .gitconfig ]; then rm .gitconfig; fi
				if [ ! -d .config ]; then mkdir .config; fi
				pushd .config >/dev/null || { echo "ERROR" >&2; exit 1; }
				if [ -d git ]; then rm -rf git; fi
				if [ ! -L git ]; then ln -s /home/"$(logname)"/.dotfiles/config/.config/git git; fi
				if [ ! -L hub ]; then ln -s /home/"$(logname)"/.dotfiles/config/.config/hub hub; fi
				echo "DONE"
				break ;;
		[Nn]* )	break ;;
	esac
done

# nvim/vi
while read -rp "Do you want to set the default editor to vi, or nvim if it's installed?  " yn; do
	case $yn in
		[Yy]* )	if [ -x /usr/bin/nvim ]; then update-alternatives --set editor /usr/bin/nvim; else update-alternatives --set editor /usr/bin/vi; fi
				break ;;
		[Nn]* )	break ;;
	esac
done
