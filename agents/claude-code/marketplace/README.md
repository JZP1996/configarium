# Personal Agent Tools Marketplace

Curated Claude Code plugins for personal use. Managed via chezmoi.

## Layout

```text
~/.local/share/chezmoi/
├── agents/
│   ├── claude-code/
│   │   └── marketplace/              ← this dir (NOT deployed)
│   │       ├── .claude-plugin/
│   │       │   └── marketplace.json
│   │       ├── disabled-plugins.json ← installed plugins disabled by default
│   │       ├── plugins/<name>/...
│   │       └── install.sh            ← register marketplace + install plugins
│   └── skills/<name>/SKILL.md        ← centralized Agent Skills registry
├── dot_agents/
│   └── skills/
│       └── symlink_<name>.tmpl       ← symlinks into agents/skills/<name>
└── dot_claude/
    └── skills/
        └── symlink_<name>.tmpl       ← selected symlinks into agents/skills/<name>
```

- `agents/` is ignored by chezmoi (see `.chezmoiignore`) because Claude
  Code reads plugins directly from this source path — no need to deploy.
- `agents/skills/` is ignored by chezmoi and used as the single source for
  Agent Skills.
- `dot_agents/skills/` deploys to `~/.agents/skills/`, exposing pure-skill
  plugins and shared skills to OpenCode and any other agent that reads
  `~/.agents/skills/`.
- `dot_claude/skills/` deploys the same shared skills to `~/.claude/skills/`,
  which is Claude Code's personal skill discovery path.

## Setup on a new machine

1. `chezmoi init` clones this repo and runs `chezmoi apply` (creates the
   `~/.agents/skills/*` symlinks and personal skills).
2. Install the marketplace and plugins into Claude Code:

   ```bash
  ~/.local/share/chezmoi/agents/claude-code/marketplace/install.sh
   ```

   Idempotent. Re-run anytime to install newly added local plugins.

## Add a plugin

Only add Claude Code runtime extensions here: hooks, agents, commands, MCP/LSP
configuration, monitors, settings, or a skill that must stay bundled with plugin
runtime files. Pure `SKILL.md` content belongs in `agents/skills/` instead; see
`docs/agent-skills.md`.

1. Create the directory under `plugins/`:

   ```text
   plugins/<plugin-name>/
   ├── .claude-plugin/
   │   └── plugin.json          { "name": "...", "version": "...", "description": "..." }
   └── skills/
       └── <plugin-name>/       (directory name MUST match SKILL.md frontmatter `name`)
           └── SKILL.md
   ```

2. Register it in `.claude-plugin/marketplace.json` under `plugins`.

3. Install into Claude Code:

   ```bash
   ./install.sh
   ```

## Add a personal (non-plugin) skill

Drop a directory with `SKILL.md` under
`~/.local/share/chezmoi/agents/skills/<name>/SKILL.md`, then add a
`dot_agents/skills/symlink_<name>.tmpl` pointing at it. Run `chezmoi apply`.

## Disabled plugins

Declare local plugins that should be installed but disabled by default in
`disabled-plugins.json`:

```json
{
  "plugins": []
}
```

## References

- [Claude Code plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [OpenCode agent skills](https://opencode.ai/docs/skills)
