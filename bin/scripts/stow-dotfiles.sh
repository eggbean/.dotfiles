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

# Move existing shell configuration files into a directory
pushd ~ >/dev/null
shellfiles=( .bash_aliases .bash_login .bash_logout .bash_profile .bashrc .inputrc )
for file in "${shellfiles[@]}"; do
  if [[ -f "$file" ]]; then
    if [[ ! -d existing_files ]]; then mkdir existing_files; fi
    mv "$file" existing_files
  fi
done

pushd ~/.dotfiles >/dev/null
stow --adopt -Rv -d ~/.dotfiles -t ~ config
