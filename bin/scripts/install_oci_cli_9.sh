#!/bin/bash -e

# Installs the OCI Command Line Interface for Oracle Linux 9
# for updates: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root." >&2; exit 1; }; fi

dnf -y install oraclelinux-developer-release-el9
dnf -y install python39-oci-cli
