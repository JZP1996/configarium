# Agent Skills Layout

This repository keeps reusable agent guidance in Agent Skills so multiple tools can consume the same instructions.

## Source of Truth

`agents/skills/<name>/SKILL.md` is the source of truth for all centrally managed skill content.

For third-party skills, `agents/skills/sources.json` additionally records the upstream repository, immutable revision, license, and refresh policy. Run `node scripts/refresh-vendored-skills.mjs check` to detect upstream changes. This check is intentionally separate from `chezmoi apply`: deployment remains local and idempotent, while refreshing vendor content requires review and a normal Git commit.

Put a skill here when the behavior is reusable across agents, such as coding guidelines, review workflows, commit or PR writing, web search guidance, and language playbooks.

Do not put the only copy of reusable guidance inside a Claude Code plugin, OpenCode plugin, Copilot prompt, or another tool-specific config. Those locations should be thin deployment or runtime wrappers.

Record vendored skill origins in [agents/skills/README.md](../agents/skills/README.md), especially for content copied from GitHub or an upstream marketplace.

## Deployment Outputs

`dot_agents/skills/symlink_<name>.tmpl` deploys a symlink to `~/.agents/skills/<name>`. This is the Agent Skills compatible path used by OpenCode and other tools that support the shared standard.

`dot_claude/skills/symlink_<name>.tmpl` deploys a symlink to `~/.claude/skills/<name>`. Claude Code currently discovers personal skills from this path, not from `~/.agents/skills`.

Both outputs point into the centralized `agents/skills/<name>` registry, but each agent adapter may expose a different subset. `dot_agents/skills` currently exposes the full registry; `dot_claude/skills` exposes the coding-focused Claude Code subset.

Claude Code intentionally does not expose `web-search` or `conversation-summary` as personal skills. Web access is already provided by native tools, while conversation-summary behavior is supplied by the Claude Code runtime plugin. Their centralized skill sources remain available to Agent Skills-compatible tools through `~/.agents/skills`.

## Exceptions

All current deployed skills point at `agents/skills`.

`code-review` and `code-simplifier` are Apache-2.0 adaptations of Anthropic Claude Code plugin content. `karpathy-guidelines` is an MIT adaptation of the upstream `CLAUDE.md`. Their fixed revisions, licenses, and local modifications are recorded in `THIRD_PARTY_NOTICES.md`.

`skill-creator` is vendored as the complete official Anthropic skill directory, not as a copied `SKILL.md`. Its bundled agents, scripts, references, assets, eval viewer, and Apache-2.0 license are required for the full workflow. Core skill creation, validation, packaging, and static review generation are portable; description-trigger optimization depends on the Claude Code CLI (`claude -p`), and `quick_validate.py` requires PyYAML.

## Validation

After changing skill templates, validate both deployment outputs:

```sh
for root in dot_agents dot_claude; do
  for tmpl in "$root"/skills/symlink_*.tmpl; do
    target=$(chezmoi execute-template < "$tmpl")
    test -f "$target/SKILL.md" || exit 1
  done
done
```

Apply the affected output explicitly:

```sh
chezmoi apply ~/.agents/skills ~/.claude/skills
```
