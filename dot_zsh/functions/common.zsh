# Common shell utility functions

# Use a current Homebrew Bash on macOS and the system Bash elsewhere.
run_bash() {
  if [[ "$OSTYPE" == darwin* ]]; then
    local homebrew_bash
    for homebrew_bash in /opt/homebrew/bin/bash /usr/local/bin/bash; do
      if [[ -x "$homebrew_bash" ]]; then
        "$homebrew_bash" "$@"
        return
      fi
    done

    print -u2 'error: Homebrew Bash is required on macOS'
    return 127
  fi

  command bash "$@"
}
