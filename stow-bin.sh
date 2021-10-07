#!/bin/bash

##	Usage: [sudo] ./stow-bin.sh [--user] [--remove]
##
##	--user		Stow/restow/unstow in ~/.local for non-sudoer user
##	--remove	Unstow

# shellcheck disable=SC2015
# (if the echoes fail something strange is happening and I would want to know about it)

set -euo pipefail

# Set variables for (re)stowing or unstowing
if [[ "$*" =~ "--remove" ]]; then
	stowcom='-D'
	stowed='unstowed'
	stowing='unstowing'
else
	stowcom='-R'
	stowed='stowed'
	stowing='stowing'
fi

# Set variables for target locations
if [[ "$*" =~ "--user" ]]; then
	targetdir="$HOME/.local/bin"
	mandir="$HOME/.local/share/man"
	compdir="$HOME/.local/share/bash-completion"
	fontdir="$HOME/.local/share/fonts"
	if [[ ! "$*" =~ "--remove" ]]; then
		for d in "$targetdir" "$mandir" "$compdir" "$fontdir"; do
			if [ ! -d "$d" ]; then mkdir -p "$d"; fi
		done
		pushd "$HOME/.dotfiles/.man" >/dev/null
		mansubs=(*) && popd >/dev/null
		for s in "${mansubs[@]}"; do
			if [ ! -d "${mandir}"/"$s" ]; then mkdir -p "${mandir}"/"$s"; fi
		done
	fi
else
	[[ "$(id -u)" != "0" ]] && { echo "This script must be run as root to install in /usr, or use the --user option to stow in ~/.local." >&2; exit 1; }
	targetdir='/usr/local/bin'
	mandir='/usr/share/man'
	compdir='/etc/bash_completion.d'
	fontdir='/usr/local/share/fonts'
fi

# Use the correct binaries for the CPU architecture
[[ "$(arch)" == "armv7l" ]] && arch='armv7l'
[[ "$(arch)" == "aarch64" ]] && arch='aarch64'
[[ "$(arch)" == "x86_64" ]] && arch='x86_64'
[[ -z "${arch}" ]] && { echo "CPU architecture unknown" >&2; exit 1; }

pushd /home/"$(logname)"/.dotfiles >/dev/null # done this way in case running as root

# Stow/unstow binaries
pushd .bin >/dev/null
bind=("${arch}"/*)
for b in "${bind[@]}"; do
	[ -e "${targetdir}"/"$(basename "$b")" ] && { rm "${targetdir}"/"$(basename "$b")" \
		&& echo "Existing ${targetdir}/$(basename "$b") deleted"; }
done
stow $stowcom -vt "${targetdir}" "${arch}" 2>&1 \
	&& echo "DONE: bin package $stowed" || { echo "ERROR $stowing bin package" >&2; exit 1; }

# Stow/unstow scripts
stow $stowcom -vt "${targetdir}" scripts 2>&1 \
	&& echo "DONE: scripts package $stowed" || { echo "ERROR $stowing scripts package" >&2; exit 1; }
popd >/dev/null

# Stow/unstow man files
pushd .man >/dev/null
mand=(*)
for m in "${mand[@]}"; do
	stow $stowcom -vt "${mandir}"/"$m" "$m" 2>&1 \
		&& echo "DONE: $m package $stowed" || { echo "ERROR $stowing man package" >&2; exit 1; }
done
popd >/dev/null

# Stow/unstow bash completion files
stow $stowcom -vt "${compdir}" .completions 2>&1 \
	&& echo "DONE: bash completions package $stowed" || { echo "ERROR $stowing bash completions package" >&2; exit 1; }

# Stow/unstow fonts
stow $stowcom -vt "${fontdir}" fonts 2>&1 && fc-cache -f -v \
	&& echo "DONE: fonts package $stowed" || { echo "ERROR $stowing fonts package" >&2; exit 1; }

# Clean up any empty directories in ~/.local if using --user and --remove switches
if [[ "$*" =~ "--user " ]] && [[ "$*" =~ "--remove" ]]; then
	pushd .man >/dev/null
	mansubs=(*) && popd >/dev/null
		for r in "${mansubs[@]}"; do
			if [ -d "${mandir}"/"$r" ]; then rmdir --ignore-fail-on-non-empty "${mandir}"/"$r"; fi
		done
	for e in "$targetdir" "$mandir" "$compdir"; do
		if [ -d "$e" ]; then rmdir --ignore-fail-on-non-empty "$e"; fi
	done
fi

exit
