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
  curl \
  extrepo \
  git \
  ripgrep \
  tree \
  unzip \
  zsh

export PATH="$HOME/.local/bin:$PATH"

if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

if ! command -v mise >/dev/null 2>&1; then
  sudo extrepo enable mise
  sudo apt-get update
  sudo apt-get install -y mise
fi

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi

printf '%s\n' 'WSL bootstrap complete; install runtimes with mise as needed'
