#!/bin/bash

## Usage: ./stow-packages.sh [PACKAGE] [PACKAGE] [PACKAGE]
##
## This script can easily break with new package elements (eg. config/.local)
## ?* section cannot currently handle more than one element in a package

set -e

shopt -s dotglob nullglob

if [ $# -eq 0 ]; then
	echo "No packages provided" >&2
	echo "Usage: ./stow-packages.sh [PACKAGE] [PACKAGE] [PACKAGE]" >&2
	exit 1
fi

pushd ~/.dotfiles > /dev/null

while :; do
	case $1 in
		shell)	[ ! -e ~/default-shell-files ] && mkdir ~/default-shell-files
				pushd shell > /dev/null
				shelld=(*)
				popd > /dev/null
				for j in "${shelld[@]}"; do
					[ -e ~/"$j" ] && mv ~/"$j" ~/default-shell-files && echo "Existing ~/$j moved to ~/default-shell-files"
				done
				stow -Svt ~ shell && echo "DONE: shell package stowed" || (echo "ERROR stowing shell package" >&2 && exit 1)
				;;
		config) [ ! -d ~/.config ] && mkdir ~/.config
				[ ! -d ~/.local ] && mkdir ~/.local
				[ ! -d ~/.local/share ] && mkdir ~/.local/share
				[ -d ~/.local/share/mc ] && rm -rf ~/.local/share/mc && echo "Existing ~/.local/share/mc deleted"
				pushd config/.config > /dev/null
				configd=(*)
				popd > /dev/null
				for i in "${configd[@]}"; do
					[ -e ~/.config/"$i" ] && rm -rf ~/.config/"$i" && echo "Existing ~/.config/$i deleted"
				done
				stow -Rvt ~ config && echo "DONE: config package stowed" || (echo "ERROR stowing config package" >&2 && exit 1)
				;;
		ssh)	pushd ssh > /dev/null
				sshd=(*)
				popd > /dev/null
				for s in "${sshd[@]}"; do
					[ -e ~/.ssh/"$s" ] && rm ~/.ssh/"$s" && echo "Existing ~/.ssh/$s deleted"
				done
				stow --no-folding -Rvt ~ ssh && echo "DONE: ssh package stowed" || (echo "ERROR stowing ssh package" >&2 && exit 1)
				;;
		?*)		pushd "$1"/ > /dev/null || (echo "ERROR finding $1 package" >&2 && exit 1)
				packaged=(*)
				popd > /dev/null
				[ ${#packaged[@]} -gt 1 ] && (echo "WARNING: This does not currently work well for packages that contain more than one directory (folded)." >&2 && exit 1)
				for k in "${packaged[@]}"; do
					if [ -e ~/"$k" ]; then
						read -rp "Do you want to delete ~/$k and replace it with a stow symlink? (y/n)	" yn
						case $yn in
							[Yy]* )	rm -rf ~/"$k" && echo "Existing ~/$k directory deleted"
									stow -Svt ~ "$1" && echo "DONE: $1 package stowed" || (echo "ERROR stowing $k" >&2 && exit 1)
									break
									;;
							[Nn]* )	read -rp "Do you want to stow this package unfolded? (y/n)	" yn
									case $yn in
										[Yy]* )	stow --no-folding -Svt ~ "$1" && echo "DONE: $1 package stowed" || (echo "ERROR stowing $k" >&2 && exit 1)
												break
												;;
										[Nn]* )	echo "SKIPPED:	$1 package not stowed"; break
												;;
										* )		echo "Please answer yes or no"
												;;
									esac
									;;
								* )	echo "Please answer yes or no"
									;;
						esac
					elif [ ! -e ~/"$k" ]; then
						stow -Svt ~ "$1" && echo "DONE: $1 package stowed" || (echo "ERROR stowing $1 package" >&2 && exit 1)
						break
					fi
				done
				;;
		*)		break
	esac
	shift
done

exit
