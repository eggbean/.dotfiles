#!/bin/bash -e

# Installs or updates the Digital Ocean doctl cli binary

if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root." >&2; exit 1; }; fi

cd /tmp
nameregex='^doctl-\d[\d.]+?\d?-linux-amd64\.tar\.gz$'
wget -q "$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | jq -r '.assets[] | select(.name|test($name)).browser_download_url' --arg name "${nameregex}")"
tar -xvf doctl-* -C /usr/local/bin
rm doctl-*
