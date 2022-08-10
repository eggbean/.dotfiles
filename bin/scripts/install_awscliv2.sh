#!/bin/bash

# AWS CLI v2 install/update script
# For v2 you either need to install manually
# or use a script like this
#
# For bash v5 >
#
# For updates go to:
url='https://gist.github.com/eggbean/345e28e2d7d878f2cce68f45eeb50a38'

set -eo pipefail

fingerprint='FB5DB77FD5C118B80511ADA8A6310ACC4672475C'
expires=$(date -d 2023-09-17 +%s)
pubkey=$(cat <<'EOV'
-----BEGIN PGP PUBLIC KEY BLOCK-----
mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
YLZATHZKTJyiqA==
=vYOk
-----END PGP PUBLIC KEY BLOCK-----
EOV
)

# Check if expired
if (( EPOCHSECONDS > expires )); then
  echo "PGP key expired - for script update go to:" >&2
  echo "${url}" >&2
  exit 1
fi

# Check for dependencies
deps=( curl gpg unzip )
unset bail
for i in "${deps[@]}"; do command -v "$i" >/dev/null 2>&1 || { bail="$?"; echo "$i" is not available; }; done
if [ "$bail" ]; then exit "$bail"; fi

# Check if root
[ "$(id -u)" -ne "0" ] && { echo "This script must be run as root" >&2; exit 1; }

# Check architecture
[ "$(arch)" = "aarch64" ] && arch='aarch64'
[ "$(arch)" = "x86_64" ] && arch='x86_64'
[ -z "${arch}" ] && { echo "CPU architecture not supported" >&2; exit 1; }

cd "${TMPDIR:-/tmp}"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip"

gpg --list-keys ${fingerprint} >/dev/null 2>&1 || gpg --import <(echo "${pubkey}") >/dev/null 2>&1
curl -so awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip.sig
gpg --verify awscliv2.sig awscliv2.zip >/dev/null 2>&1
unzip -qo awscliv2.zip

if [ -L /usr/local/bin/aws ]; then
  ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
else
  ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
fi

printf "%s\n" "complete -C aws_completer aws" > /etc/bash_completion.d/aws_bash_completer

rm -rf awscliv2.{zip,sig} aws/
