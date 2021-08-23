#!/bin/bash

# run as sudo from main user account, after stowing

# ne
pushd /root/ >/dev/null || ( echo "ERROR" >&2; exit 1 )
rm -rf .ne/ 2>/dev/null
ln -s /home/"$(logname)"/.ne .ne
popd >/dev/null || ( echo "ERROR" >&2; exit 1 )

# git
pushd /root/ >/dev/null || ( echo "ERROR" >&2; exit 1 )
rm .gitconfig 2>/dev/null
[ ! -d .config/ ] && mkdir .config
pushd .config/ >/dev/null || ( echo "ERROR" >&2; exit 1 )
rm -rf git/ 2>/dev/null
ln -s /home/"$(logname)"/.dotfiles/config/.config/git git
echo "DONE"

[ -x /usr/bin/nvim ] && update-alternatives --set editor /usr/bin/nvim || update-alternatives --set editor /usr/bin/vi
