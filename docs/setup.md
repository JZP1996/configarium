# Setup and Layout

## Bootstrap

Bootstrap installs platform infrastructure plus the common Node LTS and Python 3.12 runtimes. It runs from the chezmoi source directory and does not run `chezmoi apply`.

### macOS

Install Homebrew from [brew.sh](https://brew.sh), install chezmoi, then initialize this repository using chezmoi's default source directory:

```sh
brew install chezmoi
chezmoi init https://github.com/JZP1996/configarium.git
```

Review the source, then run the bootstrap:

```sh
"$(chezmoi source-path)/scripts/bootstrap/bootstrap-macos.sh"
```

This installs the formulae declared in `scripts/bootstrap/Brewfile.macos`, installs Node LTS and Python 3.12 with mise, and enables `.nvmrc` and `.python-version`. Apple Git remains the default; the Brewfile does not install another Git.

### WSL

On a Debian- or Ubuntu-based WSL distribution, install chezmoi with its official installer, then initialize this repository:

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
chezmoi init https://github.com/JZP1996/configarium.git
```

Review the source, then run the bootstrap:

```sh
"$(chezmoi source-path)/scripts/bootstrap/bootstrap-wsl.sh"
```

This installs Linux prerequisites and mise through apt, installs uv with its official installer, then installs Node LTS and Python 3.12 with mise and enables `.nvmrc` and `.python-version`. It does not use Homebrew.

### Use Windows Git Credential Manager From WSL

Git for Windows normally installs GCM outside the Windows PATH. Check its standard location in Windows PowerShell:

```powershell
$gcm = "C:\Program Files\Git\mingw64\bin\git-credential-manager.exe"
Test-Path $gcm
& $gcm --version
```

If the standard path does not exist, search the Git for Windows installation:

```powershell
Get-ChildItem "C:\Program Files\Git" `
  -Filter git-credential-manager.exe `
  -Recurse `
  -ErrorAction SilentlyContinue
```

In WSL, confirm Windows interoperability and convert the standard path:

```sh
powershell.exe -NoProfile -Command '$PSVersionTable.PSVersion'
wslpath 'C:\Program Files\Git\mingw64\bin\git-credential-manager.exe'
```

Create a local link to avoid spaces in the Windows path, then configure Git:

```sh
mkdir -p "$HOME/.local/bin"
ln -s '/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe' \
  "$HOME/.local/bin/git-credential-manager.exe"
"$HOME/.local/bin/git-credential-manager.exe" --version
git config --global credential.helper \
  "$HOME/.local/bin/git-credential-manager.exe"
```

The browser authentication and stored credentials remain on Windows. Keep the discovered Windows path machine-local; do not add it to this repository or the common Bootstrap.

### Apply configuration

Install additional runtimes with mise as needed. If Node is unavailable despite Bootstrap, the managed Claude and OpenCode JSON modifiers print a warning and leave their target JSON unchanged.

After Bootstrap, review and apply the managed configuration with `chezmoi diff` and `chezmoi apply`.

The initialization script always ensures that `~/.zshrc` loads the managed common configuration. Oh My Zsh and the optional plugins remain disabled by default; after reviewing `run_onchange_after_initialize.sh.tmpl`, opt in explicitly:

```sh
CHEZMOI_INSTALL_OPTIONAL_TOOLS=1 chezmoi apply
```

The optional path installs Oh My Zsh and zsh plugins from the fixed revisions in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). The script is idempotent and reruns when its rendered opt-in value or source changes.

## Layout

| Source                                  | Target        | Purpose                                                                      |
| --------------------------------------- | ------------- | ---------------------------------------------------------------------------- |
| `dot_agents/`                           | `~/.agents/`  | Shared Agent Skills links.                                                   |
| `dot_claude/`                           | `~/.claude/`  | Claude Code instructions and coding Skill links.                             |
| `dot_config/`                           | `~/.config/`  | Ghostty configuration, OpenCode instructions, permissions, and plugin links. |
| `dot_zsh/`                              | `~/.zsh/`     | Shared zsh configuration and functions.                                      |
| `agents/`                               | Not deployed  | Source for Skills, instructions, and local agent plugins.                    |
| `run_onchange_after_initialize.sh.tmpl` | Run on change | Optional, idempotent zsh bootstrap for macOS and WSL.                        |
| `scripts/bootstrap/`                    | Not deployed  | Explicit platform bootstrap scripts and package lists.                       |

`~/.zshrc` remains machine-local. Its first line should source the managed shared configuration:

```zsh
[[ -f ~/.zsh/.zshrc.common ]] && source ~/.zsh/.zshrc.common
```

The common configuration adds `~/.local/bin` to PATH, activates mise when available, and safely skips Oh My Zsh when it is not installed. Shared functions include `run_bash` for platform-appropriate Bash and `mise_update` for previewing and interactively selecting runtime updates.

Do not manage credentials or tool-owned local state here, including `~/.ssh/`, `~/.npmrc`, and `~/.config/gh/`.

Platform deployment boundaries:

| Platform    | zsh common | Ghostty | AI common |
| ----------- | ---------- | ------- | --------- |
| macOS       | Yes        | Yes     | Yes       |
| WSL         | Yes        | No      | Yes       |
| Other Linux | No         | No      | Yes       |

WSL is detected when chezmoi reports Linux and `WSL_DISTRO_NAME` is set.

## Common Commands

```sh
chezmoi edit <target>
chezmoi diff
chezmoi apply
chezmoi cd
chezmoi update
```
