#!/bin/bash

# run as sudo from main user account

exit_error() { echo Error && exit 2 ; }

pushd /root || exit_error
rm -rf .ne/ 2>/dev/null
ln -s /home/"$(logname)"/.ne /root/.ne
popd || exit_error

pushd /root || exit_error
rm .gitconfig
cd .config/ || exit_error
ln -s /home/"$(logname)"/.dotfiles/config/.config/git git
popd || exit_error
