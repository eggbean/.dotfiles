#!/bin/bash

## Usage: ./standard-setup.sh [PACKAGE] [PACKAGE] [PACKAGE]

set -e

shopt -s dotglob nullglob

pushd ~/.dotfiles > /dev/null

while :; do
	case $1 in
		config) if [ ! -d ~/.config ]; then mkdir ~/.config; fi
				pushd config/.config > /dev/null
				configd=(*)
				popd > /dev/null
				for i in "${configd[@]}"; do
					[ -e ~/.config/"$i" ] && rm -rf ~/.config/"$i" && echo "Existing ~/.config/$i deleted"
				done
				stow -Svt ~ config || echo "Error stowing config package" && exit 1
				;;
		ne)		if [ -d ~/.ne/ ]; then rm -rf ~/.ne/ && echo "Existing ~/.ne directory deleted"; fi
				stow -vt ~ ne || echo "Error stowing ne package" && exit 1
				;;
		shell)	mkdir ~/default-shell-files
				pushd shell > /dev/null
				shelld=(*)
				popd > /dev/null
				for i in "${shelld[@]}"; do
					[ -e ~/"$i" ] && mv ~/"$i" ~/default-shell-files && echo "Existing ~/$i moved to ~/default-shell-files"
				done
				stow -Svt ~ shell || echo "Error stowing shell package" && exit 1
				;;
		?*)		stow -vt ~ "$1" || echo "Error stowing $1 package" && exit 1
				;;
		*)		break
	esac
	shift
done

exit
