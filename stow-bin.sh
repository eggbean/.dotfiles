#!/bin/bash

## Usage: ./stow-bin.sh

set -e

pushd /home/"$(logname)"/.dotfiles >/dev/null

bind=(bin/*)
for b in "${bind[@]}"; do
	[ -e /usr/local/bin/"$(basename $b)" ] && (rm /usr/local/bin/"$(basename $b)" && echo "Existing /usr/local/bin/$(basename $b) deleted")
done
stow -Svt /usr/local/bin bin || (echo "Error stowing bin package" >&2 && exit 1)
[ $? == 0 ] && echo "DONE: bin package stowed"

exit
