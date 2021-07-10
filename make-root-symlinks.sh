#!/bin/bash

# run as sudo from main user account, after stowing

# ne
pushd /root >/dev/null || exit 1
rm -rf .ne/ 2>/dev/null
ln -s /home/"$(logname)"/.ne /root/.ne
popd >/dev/null || exit 1

# git
pushd /root >/dev/null || exit 1
rm .gitconfig
pushd .config/ || exit 1
ln -s /home/"$(logname)"/.dotfiles/config/.config/git git
