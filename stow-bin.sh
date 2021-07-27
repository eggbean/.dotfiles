#!/bin/bash

## Usage: sudo ./stow-bin.sh

# shellcheck disable=SC2015

set -euo pipefail

pushd /home/"$(logname)"/.dotfiles >/dev/null

[[ "$(id -u)" != "0" ]] && (echo "This script must be run as root" >&2 && exit 1)
[[ "$(arch)" == "armv7l" ]] && arch='armv7l'
[[ "$(arch)" == "x86_64" ]] && arch='x86_64'
[[ "$(arch)" == "aarch64" ]] && arch='aarch64'
[[ -z "${arch}" ]] && (echo "CPU architecture unknown" >&2 && exit 1)

pushd .bin >/dev/null
bind=("${arch}"/*)
for b in "${bind[@]}"; do
	[ -e /usr/local/bin/"$(basename "$b")" ] && (rm /usr/local/bin/"$(basename "$b")" && echo "Existing /usr/local/bin/$(basename "$b") deleted")
done
stow -Rvt /usr/local/bin "${arch}" 2>&1 | grep -v "BUG in find_stowed_path" && echo "DONE: bin package stowed" || (echo "ERROR stowing bin package" >&2 && exit 1)
popd >/dev/null

pushd .man >/dev/null
mand=(*)
for m in "${mand[@]}"; do
	stow -Rvt /usr/share/man/"$m" "$m" 2>&1 | grep -v "BUG in find_stowed_path"
done && echo "DONE: man package stowed" || (echo "ERROR stowing man package" >&2 && exit 1)
popd >/dev/null

stow -Rvt /etc/bash_completion.d .completions 2>&1 | grep -v "BUG in find_stowed_path" && echo "DONE: bash completions package stowed" || (echo "ERROR stowing bash completions package" >&2 && exit 1)

exit
