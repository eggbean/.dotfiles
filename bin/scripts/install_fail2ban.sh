#!/bin/bash -e

# Installs and configures fail2ban on bastion hosts
# excludes IP address of my home IP address

# Do nothing if already installed
if [[ -f /etc/fail2ban/jail.d/101-ignore.conf ]]; then exit 125; fi

redc=$(tput setaf 1)
gren=$(tput setaf 2)
yelw=$(tput setaf 3)
norm=$(tput sgr0)
red_echo() {
  echo "${redc}$1${norm}"
}
green_echo() {
  echo "${gren}$1${norm}"
}
yellow_echo() {
  echo "${yelw}$1${norm}"
}

yellow_echo "Installing & configuring fail2ban"

dnf install -y fail2ban || \
  { red_echo "ERROR: fail2ban installation failed" >&2; exit 1; }

# Ignore addresses
ip_addresses=$(dig church.jinkosystems.co.uk @1.1.1.1 +short)
ip_line="ignoreip = 127.0.0.1/8 ::1 $ip_addresses"
printf "%s\n%s\n" "[DEFAULT]" "$ip_line" > /etc/fail2ban/jail.d/101-ignore.conf

# sshd
cat << EOF > /etc/fail2ban/jail.d/102-sshd.conf
[sshd]
enabled = true
port = ssh
maxretry = 3
bantime = 10m
EOF

green_echo "DONE: fail2ban installed and configured"
systemctl restart fail2ban.service
sleep 5
systemctl status fail2ban.service || \
  { red_echo "FAIL: Problem with fail2ban.service" >&2; exit 1; }
green_echo "DONE: fail2ban.service restarted"
