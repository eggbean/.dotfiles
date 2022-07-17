#!/bin/bash

if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root." >&2; exit 1; }; fi

apt-get update && apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sh -c "printf 'deb\t[arch=amd64]\thttps://apt.releases.hashicorp.com\t$(lsb_release -cs)\tmain\n' > /etc/apt/sources.list.d/hashicorp.list"
