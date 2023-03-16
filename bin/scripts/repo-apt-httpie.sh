#!/bin/bash

if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root." >&2; exit 1; }; fi

# Install httpie
curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add -
curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list
apt-get update
apt-get install httpie
