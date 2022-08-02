#!/bin/bash

if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root." >&2; exit 1; }; fi

echo 'deb [trusted=yes] https://repo.charm.sh/apt/ /' | tee /etc/apt/sources.list.d/charm.list > /dev/null
apt update
