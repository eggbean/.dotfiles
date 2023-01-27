#!/bin/bash

if [ "$(id -u)" -eq "0" ]; then { echo "This script shouldn't be run as root." >&2; exit 1; }; fi

cd "${TMPDIR:-/tmp}" || exit 1
python3 -m pip -V || {
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py --user --no-warn-script-location
  rm get-pip.py
}

ansible --version && {
  python3 -m pip install --upgrade --user ansible
} || {
  python3 -m pip install --user ansible --no-warn-script-location
}
