#!/bin/bash

##	Usage: ./stow-packages.sh [PACKAGE] [PACKAGE] [PACKAGE]
##
##	?* section cannot currently handle more than one element in a package

# shellcheck disable=SC2015,SC2088

[[ "$(id -u)" = "0" ]] && { echo "This script is not supposed to be run as root" >&2; exit 1; }

set -euo pipefail

shopt -s dotglob nullglob

if [ $# -eq 0 ]; then
	echo "No packages provided" >&2
	echo "Usage: ./stow-packages.sh [PACKAGE] [PACKAGE] [PACKAGE]" >&2
	exit 1
fi

pushd ~/.dotfiles > /dev/null

while :; do
	case ${1-} in
		shell)	pushd shell > /dev/null
				shelld=(*)
				popd > /dev/null
				is_file() { local f; for f; do [[ -e ~/"$f" && ! -L ~/"$f" ]] && return; done; return 1; }
				if is_file "${shelld[@]}"; then [ ! -d ~/default-shell-files ] && mkdir ~/default-shell-files && echo "~/default-shell-files directory created"; fi
				for j in "${shelld[@]}"; do
					[[ -e ~/"$j" && ! -L ~/"$j" ]] && mv ~/"$j" ~/default-shell-files && echo "Existing ~/$j file moved to ~/default-shell-files"
					[[ -e ~/"$j" && -L ~/"$j" ]] && rm ~/"$j" && echo "Existing ~/$j symlink deleted"
				done
				stow -Rvt ~ shell && echo "DONE: shell package stowed" || { echo "ERROR stowing shell package" >&2; exit 1; }
				;;
		config) [ ! -d ~/.local/share ] && mkdir -p ~/.local/share
				pushd config/.local/share > /dev/null
				locald=(*)
				for m in "${locald[@]}"; do
					[ -e ~/.local/share/"$m" ] && rm -rf ~/.local/share/"$m" && echo "Existing ~/.local/share/$m deleted"
				done
				popd > /dev/null
				[ ! -d ~/.config ] && mkdir ~/.config
				pushd config/.config > /dev/null
				configd=(*)
				popd > /dev/null
				for i in "${configd[@]}"; do
					[ -e ~/.config/"$i" ] && rm -rf ~/.config/"$i" && echo "Existing ~/.config/$i deleted"
				done
				stow -Rvt ~ config && echo "DONE: config package stowed" || { echo "ERROR stowing config package" >&2; exit 1; }
				;;
		ssh)	pushd ssh > /dev/null
				sshd=(*)
				find .ssh/ -name 'id_*' ! -name 'id_*.pub' -exec chmod 400 {} \;
				popd > /dev/null
				for s in "${sshd[@]}"; do
					[ -e ~/.ssh/"$s" ] && rm ~/.ssh/"$s" && echo "Existing ~/.ssh/$s deleted"
				done
				stow --no-folding -Rvt ~ ssh && echo "DONE: ssh package stowed" || { echo "ERROR stowing ssh package" >&2; exit 1; }
				;;
		fonts)	[ ! -d ~/.local/share/fonts ] && mkdir -p ~/.local/share/fonts
				pushd fonts > /dev/null
				fontsd=(*)
				popd > /dev/null
				for y in "${fontsd[@]}"; do
					[ -e ~/.local/share/fonts/"$y" ] && rm ~/.local/share/fonts/"$y" && echo "Existing ~/.local/share/fonts/$y deleted"
				done
				stow --no-folding -Rvt ~/.local/share/fonts fonts && echo "DONE: fonts package stowed" || { echo "ERROR stowing fonts package" >&2; exit 1; }
				fc-cache -f && echo "DONE: fonts information cache files built" || { echo "ERROR building fonts information cache files" >&2; exit 1; }
				;;
		?*)		pushd "$1"/ > /dev/null || { echo "ERROR finding $1 package" >&2; exit 1; }
				packaged=(*)
				popd > /dev/null
				[ ${#packaged[@]} -gt 1 ] && { echo "WARNING: This does not currently work well for packages that contain more than one directory (folded)." >&2; exit 1; }
				for k in "${packaged[@]}"; do
					if [ -e ~/"$k" ]; then
						read -rp "Do you want to delete ~/$k and replace it with a stow symlink? (y/n)	" yn
						case $yn in
							[Yy]* )	rm -rf ~/"$k" && echo "Existing ~/$k directory deleted"
									stow -Rvt ~ "$1" && echo "DONE: $1 package stowed" || { echo "ERROR stowing $k" >&2; exit 1; }
									break
									;;
							[Nn]* )	read -rp "Do you want to stow this package unfolded? (y/n)	" yn
									case $yn in
										[Yy]* )	stow --no-folding -Rvt ~ "$1" && echo "DONE: $1 package stowed" || { echo "ERROR stowing $k" >&2; exit 1; }
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
						stow -Rvt ~ "$1" && echo "DONE: $1 package stowed" || { echo "ERROR stowing $1 package" >&2; exit 1; }
						break
					fi
				done
				;;
		*)		break
	esac
	shift
done

exit
