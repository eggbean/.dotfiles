#!/bin/bash

# run as sudo from main user account, after stowing

# ne
pushd /root >/dev/null
rm -rf .ne/ 2>/dev/null
ln -s /home/"$(logname)"/.ne /root/.ne
popd >/dev/null

# git
pushd /root >/dev/null
rm .gitconfig
cd .config/
ln -s /home/"$(logname)"/.dotfiles/config/.config/git git
popd >/dev/null
