#!/bin/sh

set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT HUP INT TERM

render_zsh_script() {
  chezmoi execute-template -f "$root/.chezmoiscripts/run_after_initialize.sh.tmpl"
}

test_new_zsh_profile() {
  home="$temporary_directory/zsh-new"
  mkdir -p "$home"
  HOME="$home" sh -c "$(render_zsh_script)"
  first=$(cksum < "$home/.zshrc")
  HOME="$home" sh -c "$(render_zsh_script)"
  second=$(cksum < "$home/.zshrc")

  [ "$first" = "$second" ]
  [ "$(grep -c '^# BEGIN CONFIGARIUM$' "$home/.zshrc")" -eq 1 ]
}

test_legacy_zsh_profile() {
  home="$temporary_directory/zsh-legacy"
  mkdir -p "$home"
  printf '%s\r\n' \
    'export TEST=keep' \
    '[[ -f ~/.zsh/.zshrc.common ]] && source ~/.zsh/.zshrc.common' > "$home/.zshrc"
  HOME="$home" sh -c "$(render_zsh_script)"

  grep -q '^export TEST=keep$' "$home/.zshrc"
  [ "$(grep -c 'zshrc.common' "$home/.zshrc")" -eq 1 ]
}

test_zsh_conflict() {
  home="$temporary_directory/zsh-conflict"
  mkdir -p "$home"
  # shellcheck disable=SC2016 # This literal is the migration fixture.
  printf '%s\n' 'eval "$(mise activate zsh)"' > "$home/.zshrc"
  cp "$home/.zshrc" "$home/expected"

  if HOME="$home" sh -c "$(render_zsh_script)" </dev/null >/dev/null 2>&1; then
    return 1
  fi
  cmp -s "$home/.zshrc" "$home/expected"
}

test_new_zsh_profile
test_legacy_zsh_profile
test_zsh_conflict

printf '%s\n' 'Profile migration tests passed.'
