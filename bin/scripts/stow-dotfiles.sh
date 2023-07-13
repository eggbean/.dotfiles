#!/bin/bash -e

[ "$(id -u)" = "0" ] && \
  { echo "This script is not supposed to be run as root" >&2; exit 1; }

# Make some dummy files to prevent stow folding
[ ! -d ~/.config ] && mkdir ~/.config
touch ~/.config/.stow-no-folding
[ ! -d ~/.local/share ] && mkdir -p ~/.local/share
touch ~/.local/share/.stow-no-folding
[ ! -d ~/.ssh ] && mkdir ~/.ssh
touch ~/.ssh/.stow-no-folding

# Delete existing shell configuration files
pushd ~ >/dev/null
shellfiles=( .bash_aliases .bash_login .bash_logout \
  .bash_profile .bashrc .inputrc .zcompdump .zshrc )
for file in "${shellfiles[@]}"; do
  if [ -e $file ] && [ ! -L $file ]; then
    rm $file
  fi
done

pushd ~/.dotfiles >/dev/null

if [[ -e ${TMPDIR:-/tmp}/stow-dotfiles.$USER.log ]]; then
  rm ${TMPDIR:-/tmp}/stow-dotfiles.$USER.log
fi

stow --adopt -Rv -d ~/.dotfiles -t ~ config \
  2> >(tee -a ${TMPDIR:-/tmp}/stow-dotfiles.$USER.log >&2)
