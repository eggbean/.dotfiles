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

# Move existing shell configuration files into a directory
pushd ~ >/dev/null
shellfiles=( .bash_aliases .bash_login .bash_logout .bash_profile .bashrc .inputrc )
for file in "${shellfiles[@]}"; do
  if [ -e "$file" ] && [ ! -L "$file" ]; then
    if [ ! -d "${TMPDIR:-/tmp}/existing_files" ]; then
      mkdir "${TMPDIR:-/tmp}/existing_files"
    fi
    mv "$file" "${TMPDIR:-/tmp}/existing_files"
  fi
done

pushd ~/.dotfiles >/dev/null

if [[ -e ${TMPDIR:-/tmp}/stow-dotfiles.sh.log ]]; then
  rm ${TMPDIR:-/tmp}/stow-dotfiles.sh.log
fi

stow --adopt -Rv -d ~/.dotfiles -t ~ config \
  2> >(tee -a ${TMPDIR:-/tmp}/stow-dotfiles.sh.log >&2)
