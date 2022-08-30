#!/bin/bash

eval "$(ssh-agent -s)" > /dev/null
find ~/.ssh -regextype egrep -regex '.*/id_[^.]+$' | xargs ssh-add
ln -sf "${SSH_AUTH_SOCK}" ~/.ssh/ssh_auth_sock
