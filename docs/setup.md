# Setup

Requires chezmoi and, on Windows, PowerShell 7.

```sh
chezmoi init https://github.com/JZP1996/configarium.git
chezmoi diff
chezmoi apply
```

Run the first apply interactively. If an existing Zsh or PowerShell profile initializes mise or Starship, Configarium offers to back it up and remove the duplicate initialization.

## Development

Contributors need gitleaks and should enable the pre-commit hook:

```sh
git config core.hooksPath .githooks
scripts/check-secrets.sh
```

After changing profile initialization, run the platform test:

```sh
# macOS/Linux
scripts/test-profile-migrations.sh

# Windows
pwsh -NoProfile -File scripts/test-profile-migrations.ps1
```
