#!/bin/bash

if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root." >&2; exit 1; }; fi

dnf install -y 'dnf-command(config-manager)'
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y gh
