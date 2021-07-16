#!/bin/bash

## Usage: sudo ./stow-bin.sh

set -eo pipefail

pushd /home/"$(logname)"/.dotfiles >/dev/null

[[ "$(id -u)" != "0" ]] && (echo "This script must be run as root" >&2 && exit 1)
[[ "$(uname -m)" == "armv7l" ]] && arch='armv7l'
[[ "$(uname -m)" == "x86_64" ]] && arch='x86_64'
[[ -z "${arch}" ]] && (echo "CPU Architecture unknown" >&2 && exit 1)

pushd .bin >/dev/null
bind=("${arch}"/*)
for b in "${bind[@]}"; do
	[ -e /usr/local/bin/"$(basename "$b")" ] && (rm /usr/local/bin/"$(basename "$b")" && echo "Existing /usr/local/bin/$(basename "$b") deleted")
done
stow -Rvt /usr/local/bin bin"${arch}" && echo "DONE: bin package stowed" || (echo "ERROR stowing bin package" >&2 && exit 1)
popd >/dev/null

pushd .man >/dev/null
mand=(*)
for m in "${mand[@]}"; do
	stow -Rvt /usr/share/man/"$m" "$m"
done && echo "DONE: man package stowed" || (echo "ERROR stowing man package" >&2 && exit 1)
popd >/dev/null

stow -Rvt /etc/bash_completion.d .completions && echo "DONE: bash completions package stowed" || (echo "ERROR stowing bash completions package" >&2 && exit 1)

exit
