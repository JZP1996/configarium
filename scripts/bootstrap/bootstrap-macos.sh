#!/usr/bin/env sh

set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' 'error: this bootstrap script only supports macOS' >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  printf '%s\n' 'error: install Homebrew from https://brew.sh, then rerun this script' >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
brew bundle --file="$script_dir/Brewfile.macos"

printf '%s\n' 'macOS bootstrap complete; install runtimes with mise as needed'
