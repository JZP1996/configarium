#!/usr/bin/env sh

set -eu

step() {
  printf '\n==> %s\n' "$1"
}

enable_idiomatic_version_file() {
  tool="$1"
  current=$(mise settings get idiomatic_version_file_enable_tools 2>/dev/null || printf '[]')
  case "$current" in
    *\"$tool\"*) ;;
    *) mise settings add idiomatic_version_file_enable_tools "$tool" ;;
  esac
}

step 'Checking WSL environment'
if [ -z "${WSL_DISTRO_NAME:-}" ] && ! grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
  printf '%s\n' 'error: this bootstrap script only supports WSL' >&2
  exit 1
fi

step 'Checking apt'
if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'error: this bootstrap script requires a Debian- or Ubuntu-based WSL distribution' >&2
  exit 1
fi

step 'Installing WSL system packages'
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  ca-certificates \
  curl \
  extrepo \
  git \
  ripgrep \
  tree \
  unzip \
  zsh

export PATH="$HOME/.local/bin:$PATH"

step 'Installing mise'
if ! command -v mise >/dev/null 2>&1; then
  sudo extrepo enable mise
  sudo apt-get update
  sudo apt-get install -y mise
fi

step 'Installing uv'
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi

step 'Installing Node LTS and Python 3.12 with mise'
mise use --global node@lts python@3.12

step 'Enabling project version files for Node and Python'
enable_idiomatic_version_file node
enable_idiomatic_version_file python

step 'WSL bootstrap complete'
printf '%s\n' 'Review chezmoi diff before applying the configuration.'
