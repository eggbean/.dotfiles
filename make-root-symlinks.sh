#!/bin/bash

# run as root

pushd /root
rm -rf .ne/
ln -s /home/jason/.ne /root/.ne
popd

pushd /root
rm .gitconfig
cd .config
ln -s ~jason/.dotfiles/config/.config/git git
popd
