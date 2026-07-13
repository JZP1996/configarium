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

## Validation

Render a template directly:

```sh
chezmoi execute-template < dot_claude/CLAUDE.md.tmpl
chezmoi execute-template < dot_config/opencode/AGENTS.md.tmpl
```

Apply the composed entry documents:

```sh
chezmoi apply ~/.claude/CLAUDE.md ~/.config/opencode/AGENTS.md
opencode debug startup
```