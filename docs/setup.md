# Setup and Layout

## Bootstrap

Bootstrap installs platform infrastructure only. It does not install language runtimes or run `chezmoi apply`.

The bootstrap scripts run from a reviewed checkout of this repository. Clone it before running the platform script.

### macOS

Install Homebrew from [brew.sh](https://brew.sh). Its Command Line Tools dependency provides Apple Git. Then clone and review the repository:

```sh
git clone https://github.com/JZP1996/configarium.git "$HOME/src/configarium"
cd "$HOME/src/configarium"
```

Run the bootstrap:

```sh
./scripts/bootstrap/bootstrap-macos.sh
```

This installs the formulae declared in `scripts/bootstrap/Brewfile.macos`. Apple Git remains the default; the Brewfile does not install another Git.

### WSL

On a Debian- or Ubuntu-based WSL distribution, install Git, then clone and review the repository:

```sh
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/JZP1996/configarium.git "$HOME/src/configarium"
cd "$HOME/src/configarium"
```

Run the bootstrap:

```sh
./scripts/bootstrap/bootstrap-wsl.sh
```

This installs Linux prerequisites and mise through apt, then installs chezmoi and uv with their official installers. Both binaries are installed under `~/.local/bin`, and the installers do not modify shell profiles. It does not use Homebrew, Scoop, or Winget.

### Windows

The native Windows bootstrap is not implemented yet. The intended split is Scoop for developer CLI tools, Winget for GUI and system applications, and mise for runtimes.

### Apply configuration

Install runtimes with mise as needed. Node is optional; when it is unavailable, the managed Claude and OpenCode JSON modifiers print a warning and leave their target JSON unchanged.

Initialize chezmoi from the reviewed checkout:

```sh
chezmoi init --source "$HOME/src/configarium"
chezmoi diff
chezmoi apply
```

The optional zsh bootstrap is disabled by default. After reviewing `run_onchange_after_initialize.sh.tmpl`, opt in explicitly:

```sh
CHEZMOI_INSTALL_OPTIONAL_TOOLS=1 chezmoi apply
```

It installs Oh My Zsh and zsh plugins from the fixed revisions in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md), then adds a source line to `~/.zshrc`. The script is idempotent and reruns when its rendered opt-in value or source changes.

## Layout

| Source | Target | Purpose |
| --- | --- | --- |
| `dot_agents/` | `~/.agents/` | Shared Agent Skills links. |
| `dot_claude/` | `~/.claude/` | Claude Code instructions and coding Skill links. |
| `dot_config/` | `~/.config/` | Ghostty configuration, OpenCode instructions, permissions, and plugin links. |
| `dot_zsh/` | `~/.zsh/` | Shared zsh configuration and functions. |
| `agents/` | Not deployed | Source for Skills, instructions, and local agent plugins. |
| `run_onchange_after_initialize.sh.tmpl` | Run on change | Optional, idempotent zsh bootstrap for macOS and WSL. |
| `scripts/bootstrap/` | Not deployed | Explicit platform bootstrap scripts and package lists. |

`~/.zshrc` remains machine-local. Its first line should source the managed shared configuration:

```zsh
[[ -f ~/.zsh/.zshrc.common ]] && source ~/.zsh/.zshrc.common
```

Do not manage credentials or tool-owned local state here, including `~/.ssh/`, `~/.npmrc`, and `~/.config/gh/`.

Platform deployment boundaries:

| Platform | zsh common | Ghostty | AI common |
| --- | --- | --- | --- |
| macOS | Yes | Yes | Yes |
| WSL | Yes | No | Yes |
| Windows | No | No | Yes |
| Other Linux | No | No | Yes |

WSL is detected when chezmoi reports Linux and `WSL_DISTRO_NAME` is set.

## Common Commands

```sh
chezmoi edit <target>
chezmoi diff
chezmoi apply
chezmoi cd
chezmoi update
```
