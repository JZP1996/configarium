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

step 'Checking macOS platform'
if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' 'error: this bootstrap script only supports macOS' >&2
  exit 1
fi

step 'Checking Homebrew'
if ! command -v brew >/dev/null 2>&1; then
  printf '%s\n' 'error: install Homebrew from https://brew.sh, then rerun this script' >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
step 'Installing common Homebrew formulae'
brew bundle --file="$script_dir/Brewfile.macos"

step 'Installing Node LTS and Python 3.12 with mise'
mise use --global node@lts python@3.12

step 'Enabling project version files for Node and Python'
enable_idiomatic_version_file node
enable_idiomatic_version_file python

step 'macOS bootstrap complete'
printf '%s\n' 'Review chezmoi diff before applying the configuration.'
