#!/bin/bash -e

# This script installs or updates to the latest version of Go.
# Multi-platform (Linux and macOS)
# Multi-architecture (amd64, arm64, arm) support

error_string=("Error: This command has to be run with superuser"
  "privileges (under the root user on most systems).")
if [[ $(id -u) -ne 0 ]]; then echo "${error_string[@]}" >&2; exit 1; fi

deps=( curl jq )
unset bail
for i in "${deps[@]}"; do command -v "$i" >/dev/null 2>&1 || { bail="$?"; echo "$i" is not available; }; done
if [ "$bail" ]; then exit "$bail"; fi

version="$(curl -s 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')"
current="$(/usr/local/go/bin/go version 2>/dev/null | awk '{print $3}')"
if [[ "$current" == "$version" ]]; then
  echo "Go is already up-to-date at version ${version}"
  exit 0
fi

update_go() {
  local arch="$1"
  local os="$2"

  local go_url="https://golang.org/dl/${version}.${os}-${arch}.tar.gz"

  curl -so "/tmp/${version}.${os}-${arch}.tar.gz" -L "$go_url" && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/${version}.${os}-${arch}.tar.gz

  tar -C /usr/local -xzf "/tmp/${version}.${os}-${arch}.tar.gz" && \
    echo "Go updated to version ${version}"

  rm "/tmp/${version}.${os}-${arch}.tar.gz"
}

case "$(uname -s)" in
  Linux)
    case "$(uname -m)" in
      armv6l|armv7l)
        update_go "armv6l" "linux"
        ;;
      arm64)
        update_go "arm64" "linux"
        ;;
      x86_64)
        update_go "amd64" "linux"
        ;;
      *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
    esac
    ;;
  Darwin)
    case "$(uname -m)" in
      arm64)
        update_go "arm64" "darwin"
        ;;
      x86_64)
        update_go "amd64" "darwin"
        ;;
      *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

/usr/local/go/bin/go version
