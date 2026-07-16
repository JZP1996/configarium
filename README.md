# Configarium

This is a **PERSONAL** [chezmoi](https://www.chezmoi.io/) source for managing common configuration and agent instructions/skills/plugins across macOS and WSL. Machine-local shell files, runtimes, package selections, and credentials remain unmanaged. It is **NOT** intended as a general-purpose distribution or a supported setup guide.

## Docs

- [Setup and Layout](docs/setup.md)
- [Agent Skills](docs/agent-skills.md)
- [Agent Instructions](docs/agent-instructions.md)
- [Claude Code Plugins](docs/claude-plugins.md)
- [OpenCode Plugins](docs/opencode-plugins.md)
- [Third-Party Notices](THIRD_PARTY_NOTICES.md)

Before applying a change, run `chezmoi diff`; use `chezmoi apply` only after reviewing the result.
