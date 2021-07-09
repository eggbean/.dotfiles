#!/bin/bash

## Usage: sudo ./stow-bin.sh

set -e

[ "$(id -u)" != "0" ] && (echo "This script must be run as root" >&2 && exit 1)
[ "$(uname -m)" == "armv7l" ] && arch='armv7l'
[ "$(uname -m)" == "x86_64" ] && arch='x86_64'
[ -z "${arch}" ] && (echo "CPU Architecture unknown" >&2 && exit 1)

pushd /home/"$(logname)"/.dotfiles >/dev/null

bind=(bin"${arch}"/*)
for b in "${bind[@]}"; do
	[ -e /usr/local/bin/"$(basename $b)" ] && (rm /usr/local/bin/"$(basename $b)" && echo "Existing /usr/local/bin/$(basename $b) deleted")
done
stow -Svt /usr/local/bin bin"${arch}" || (echo "Error stowing bin package" >&2 && exit 1)
[ $? == 0 ] && echo "DONE: bin package stowed"

exit
