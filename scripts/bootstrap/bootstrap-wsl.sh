#!/usr/bin/env sh

set -eu

if [ -z "${WSL_DISTRO_NAME:-}" ] && ! grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
  printf '%s\n' 'error: this bootstrap script only supports WSL' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'error: this bootstrap script requires a Debian- or Ubuntu-based WSL distribution' >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  ca-certificates \
  chezmoi \
  curl \
  extrepo \
  git \
  pipx \
  ripgrep \
  tree \
  unzip \
  zsh

if ! command -v mise >/dev/null 2>&1; then
  sudo extrepo enable mise
  sudo apt-get update
  sudo apt-get install -y mise
fi

uv_version=$(pipx runpip uv show uv 2>/dev/null | sed -n 's/^Version: //p')
if [ -z "$uv_version" ]; then
  if command -v uv >/dev/null 2>&1; then
    printf '%s\n' 'error: uv exists but is not managed by pipx' >&2
    exit 1
  fi

  pipx install uv==0.11.29
elif [ "$uv_version" != "0.11.29" ]; then
  pipx install --force uv==0.11.29
fi

printf '%s\n' 'WSL bootstrap complete; install runtimes with mise as needed'
