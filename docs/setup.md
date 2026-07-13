# Setup and Layout

## Bootstrap

Install `chezmoi` using your operating system's package manager or the instructions at [chezmoi.io/install](https://www.chezmoi.io/install/). Do not run an unreviewed remote installer script.

Clone a reviewed revision of this repository, replacing `OWNER` after publication:

```sh
git clone https://github.com/OWNER/configarium.git "$HOME/src/configarium"
chezmoi init --source "$HOME/src/configarium"
chezmoi diff
chezmoi apply
```

The optional zsh bootstrap is disabled by default. After reviewing `run_once_after_initialize.sh.tmpl`, opt in for one apply only:

```sh
CHEZMOI_INSTALL_OPTIONAL_TOOLS=1 chezmoi apply
```

It installs Oh My Zsh and zsh plugins from the fixed revisions in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md), then adds a source line to `~/.zshrc`.

## Layout

| Source | Target | Purpose |
| --- | --- | --- |
| `dot_agents/` | `~/.agents/` | Shared Agent Skills links. |
| `dot_claude/` | `~/.claude/` | Claude Code instructions and coding Skill links. |
| `dot_config/` | `~/.config/` | Ghostty configuration, OpenCode instructions, and plugin links. |
| `dot_zsh/` | `~/.zsh/` | Shared zsh configuration and functions. |
| `agents/` | Not deployed | Source for Skills, instructions, and local agent plugins. |
| `run_once_after_initialize.sh.tmpl` | Run once | Optional zsh bootstrap. |

`~/.zshrc` remains machine-local. Its first line should source the managed shared configuration:

```zsh
[[ -f ~/.zsh/.zshrc.common ]] && source ~/.zsh/.zshrc.common
```

Do not manage credentials or tool-owned local state here, including `~/.ssh/`, `~/.npmrc`, and `~/.config/gh/`.

On Windows, `.chezmoiignore` skips zsh files and Ghostty configuration.

## Common Commands

```sh
chezmoi edit <target>
chezmoi diff
chezmoi apply
chezmoi cd
chezmoi update
```
