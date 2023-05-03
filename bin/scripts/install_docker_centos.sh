#!/bin/bash -e

starttime="$EPOCHSECONDS"

if [[ $(id -u) -ne 0 ]]; then { echo "This script must be run as root." >&2; exit 1; }; fi

dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
usermod -aG docker "$(logname)"
systemctl enable docker.service
systemctl enable containerd.service
systemctl start docker
docker run hello-world

wget -q https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker -O /home/jason/.dotfiles/bin/zsh-completions/_docker
chown jason:jason /home/jason/.dotfiles/bin/zsh-completions/_docker

seconds=$(( EPOCHSECONDS - starttime ))
printf 'Time taken %d:%02d:%02d\n' $((seconds/3600)) $(((seconds/60)%60)) $((seconds%60))
