#!/bin/bash

# run as root

pushd /root
rm -rf .ne/
ln -s /home/jason/.ne /root/.ne
popd
