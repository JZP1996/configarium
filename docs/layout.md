# Layout

| Source | Target | Purpose |
| --- | --- | --- |
| `dot_config/` | `~/.config/` | Starship, Ghostty, and PowerShell configuration |
| `dot_zsh/` | `~/.zsh/` | Shared Zsh configuration and functions |
| `.chezmoidata/` | Not deployed | Shared template data |
| `.chezmoiscripts/` | Not deployed | Profile and Windows Terminal migration scripts |

## Shell Profiles

On macOS and Linux, Configarium maintains this final block in the user-owned `.zshrc`:

```zsh
# BEGIN CONFIGARIUM
[[ -f ~/.zsh/.zshrc.common ]] && source ~/.zsh/.zshrc.common
# END CONFIGARIUM
```

Windows uses an equivalent marked block in the PowerShell all-hosts profile. Recognized legacy loading methods are removed during migration. Existing direct mise or Starship initialization requires confirmation and creates a timestamped backup; non-interactive migration stops without changing the profile.

## Platforms

| Platform | Zsh | PowerShell | Ghostty | Windows Terminal |
| --- | --- | --- | --- | --- |
| macOS | Yes | No | Yes | No |
| Native Linux | Yes | No | No | No |
| WSL | Yes | No | No | No |
| Windows | No | Yes | No | Yes |

Windows Terminal receives the `Configarium One Half Light` scheme, theme, and profile defaults. Existing legacy names and references are migrated. Unknown JSON fields are preserved, but comments and formatting are not guaranteed to survive serialization. If no settings file exists, the script does nothing.

Credentials and tool-owned state are not managed.
