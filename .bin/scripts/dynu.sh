#!/bin/bash

# dynu.com dynamic IP update script

set -e

oauth2=''
ipv4Address=''
domainid='100119111'
name='rover.jinkosystems.co.uk'
group='rover'
ttl='60'

# Source variables file if it exists,
# so that they can be left out of git repository
if [ -e ./dynu.env ]; then source ./dynu.env; fi

# Check for dependencies
deps=( curl jq )
unset bail
for i in "${deps[@]}"; do command -v "$i" >/dev/null 2>&1 || { bail="$?"; echo "$i" is not available; }; done
if [ "$bail" ]; then exit "$bail"; fi

help() {
	cat << EOF
  Options:
   --help
   --get-list
   --check
   --current
   -o OAuth2
   -4 IPv4
   -i DomainID
   -n Domain
   -g Group
   -t TTL
EOF
}

exit_error() {
 	help
	exit 1
}

getoptions () {
	while getopts ':o:4:i:n:g:t:' arg; do
		case "${arg}" in
			o) 	oauth2=${OPTARG};;
			4) 	ipv4Address=${OPTARG}
				re_isaipaddress='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
				if ! [[ ${ipv4Address} =~ ${re_isaipaddress} ]]; then
					echo "Error: ${ipv4Address} is not a valid IPv4 address"
					exit 1
				fi;;
			i)	domainid=${OPTARG};;
			n)	name=${OPTARG};;
			g)	group=${OPTARG};;
			t)	ttl=${OPTARG};;
			:)	echo "Error: -${OPTARG} requires an argument"
				exit_error;;
			*)	exit_error;;
		esac
	done
}

gettoken () {
	if [ -z "${oauth2}" ]; then echo "Error: No OAuth2 key supplied" && exit 1; fi
	token=$(curl -sX GET https://api.dynu.com/v2/oauth2/token \
			-H "accept: application/json" \
			-u "${oauth2}" | jq -r '.access_token')
}

getdomainlist () {
	curl -sX GET "https://api.dynu.com/v2/dns" \
			-H "accept: application/json" \
			-H "Authorization: Bearer ${token}" | jq -r
}

getaddress() {
	ipv4=$(curl -sX GET "https://api.dynu.com/v2/dns/${domainid}" \
			-H "accept: application/json" \
			-H "Authorization: Bearer ${token}" | jq -r '.ipv4Address')
	echo "Current record address: ${ipv4}"
}

postaddress () {
	curl -sX POST "https://api.dynu.com/v2/dns/${domainid}" \
			-H "accept: application/json" \
			-H "Authorization: Bearer ${token}" \
			-H "Content-Type: application/json" \
			-d "{
				\"name\":\"${name}\",
				\"group\":\"${group}\",
				\"ipv4Address\":\"${ipv4Address}\",
				\"ttl\":${ttl},
				\"ipv4\":true,
				\"ipv6\":false,
				\"ipv4WildcardAlias\":false,
				\"ipv6WildcardAlias\":false,
				\"allowZoneTransfer\":false,
				\"dnssec\":false
			}" | jq -r
}

if [[ "$*" =~ "--help" ]]; then
	help
elif [[ "$*" =~ "--get-list" ]]; then
	gettoken && getdomainlist
elif [[ "$*" =~ "--check" ]]; then
	gettoken && getaddress
elif [[ "$*" =~ "--current" ]]; then
	getoptions && ipv4Address="$(curl -s https://ipv4.icanhazip.com)" && gettoken && postaddress && getaddress
else
	getoptions "$@" && gettoken && postaddress && getaddress
fi

exit 0
