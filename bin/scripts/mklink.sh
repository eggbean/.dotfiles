#!/usr/bin/env bash

# Alias: mklink=" . mklink.sh"
# USAGE: mklink <mylink> <target>

cmd.exe /c "mklink /J "${1//\//\\}" "${2//\//\\}
