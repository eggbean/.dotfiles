#!/bin/bash

# AWS CLI v2 install/update script
# For v2 you either need to install manually
# or use a script like this
#
# For bash v5 >
#
# For auto-completion add `cli_auto_prompt = on` to config
# ..or add AWS_CLI_AUTO_PROMPT=on environment variable
# see: https://go.aws/3BiT8WJ
#
# For updates go to:
url='https://gist.github.com/eggbean/345e28e2d7d878f2cce68f45eeb50a38'

set -eo pipefail

fingerprint='FB5DB77FD5C118B80511ADA8A6310ACC4672475C'
expires=$(date -d 2025-07-24 +%s)
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
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4CGwMF
CwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQT7Xbd/1cEYuAURraimMQrMRnJHXAUC
ZqFYbwUJCv/cOgAKCRCmMQrMRnJHXKYuEAC+wtZ611qQtOl0t5spM9SWZuszbcyA
0xBAJq2pncnp6wdCOkuAPu4/R3UCIoD2C49MkLj9Y0Yvue8CCF6OIJ8L+fKBv2DI
yWZGmHL0p9wa/X8NCKQrKxK1gq5PuCzi3f3SqwfbZuZGeK/ubnmtttWXpUtuU/Iz
VR0u/0sAy3j4uTGKh2cX7XnZbSqgJhUk9H324mIJiSwzvw1Ker6xtH/LwdBeJCck
bVBdh3LZis4zuD4IZeBO1vRvjot3Oq4xadUv5RSPATg7T1kivrtLCnwvqc6L4LnF
0OkNysk94L3LQSHyQW2kQS1cVwr+yGUSiSp+VvMbAobAapmMJWP6e/dKyAUGIX6+
2waLdbBs2U7MXznx/2ayCLPH7qCY9cenbdj5JhG9ibVvFWqqhSo22B/URQE/CMrG
+3xXwtHEBoMyWEATr1tWwn2yyQGbkUGANneSDFiTFeoQvKNyyCFTFO1F2XKCcuDs
19nj34PE2TJilTG2QRlMr4D0NgwLLAMg2Los1CK6nXWnImYHKuaKS9LVaCoC8vu7
IRBik1NX6SjrQnftk0M9dY+s0ZbAN1gbdjZ8H3qlbl/4TxMdr87m8LP4FZIIo261
Eycv34pVkCePZiP+dgamEiQJ7IL4ZArio9mv6HbDGV6mLY45+l6/0EzCwkI5IyIf
BfWC9s/USgxchg==
=ptgS
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

if [ -L /usr/local/bin/aws ]; then update='--update'; fi
./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli $update

rm -rf awscliv2.{zip,sig} aws/
/usr/local/bin/aws --version
