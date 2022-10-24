#!/bin/bash -e

[ "$(id -u)" = "0" ] && (echo "This script is not supposed to be run as root" >&2; exit 1)
[ ! -d ~/.dotfiles ] && (echo "Cannot find ~/.dotfiles" >&2; exit 1)

# Make some files to prevent folding
[ ! -d ~/.config ] && mkdir ~/.config
touch ~/.config/.stow-no-folding
[ ! -d ~/.local/share ] && mkdir -p ~/.local/share
touch ~/.local/share/.stow-no-folding
[ ! -d ~/.ssh ] && mkdir ~/.ssh
touch ~/.ssh/.stow-no-folding

stow --adopt -Rv -d ~/.dotfiles -t ~ config
