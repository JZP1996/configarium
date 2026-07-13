# Agent Instructions

This repository separates reusable instruction layers from tool-specific entry documents.

## Reusable Layers

`agents/instructions/` is the source of truth for reusable instruction fragments:

- `base.md` — language, response format, general principles, safety, and working style shared by every interactive role.
- `engineering.md` — coding skills, repository-oriented execution, and validation rules.

There is no `shared/` directory. Reuse is expressed by template composition rather than by a `shared` ownership layer.

## Claude Code

`dot_claude/CLAUDE.md.tmpl` renders Claude Code's own `~/.claude/CLAUDE.md` from:

1. `agents/instructions/base.md`
2. `agents/instructions/engineering.md`

Claude Code therefore receives the common interaction rules plus the coding-focused layer.

## OpenCode

`dot_config/opencode/AGENTS.md.tmpl` renders OpenCode's global `~/.config/opencode/AGENTS.md` from:

1. `agents/instructions/base.md`
2. `agents/instructions/engineering.md`

OpenCode is currently engineering-focused. Native profiles can be added later if distinct roles become necessary; no `~/.config/opencode/agents/` profiles are currently managed.

`dot_config/opencode/modify_opencode.json` preserves existing global configuration while managing OpenCode's global permissions. Its native read, glob, grep, LSP, and web tools are available while other operations ask by default. The global policy permits access to `~/.config/opencode/**` as an external directory and denies native edits there. This does not sandbox Bash commands, so it is a convenience policy rather than a filesystem boundary. This follows the [OpenCode permissions documentation](https://opencode.ai/docs/permissions/) and uses the global configuration location documented in [OpenCode config](https://opencode.ai/docs/config/).

## Validation

Render a template directly:

```sh
chezmoi execute-template < dot_claude/CLAUDE.md.tmpl
chezmoi execute-template < dot_config/opencode/AGENTS.md.tmpl
printf '%s' '{}' | sh dot_config/opencode/modify_opencode.json | node -e 'JSON.parse(require("fs").readFileSync(0, "utf8"))'
```

Apply the composed entry documents:

```sh
chezmoi apply ~/.claude/CLAUDE.md ~/.config/opencode/AGENTS.md
chezmoi apply ~/.config/opencode/opencode.json
opencode debug startup
opencode debug config

```
