# Agent Skills

This directory is the source of truth for centrally managed Agent Skills. Third-party source, license, revision, and modification details are recorded in [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

## Policy

- Keep all personal reusable workflows in `agents/skills/<name>` and expose agent-specific subsets through symlinks in `dot_agents/skills`, `dot_claude/skills`, or other deployment adapters.
- Do not vendor third-party skills unless the license permits reuse and the source is recorded in `THIRD_PARTY_NOTICES.md`.
- Prefer symlinking to an installed upstream marketplace for complex external skills that include scripts, agents, assets, or other supporting files.
- When vendoring external content, update `THIRD_PARTY_NOTICES.md` with its upstream source, license, revision, and local modifications.
- Review upstream diffs before refreshing vendored content; do not blindly overwrite local copies.

## Refreshing Vendored Skills

`agents/skills/sources.json` records each upstream repository, immutable commit, source path, license, and refresh policy. It is the machine-readable counterpart to `THIRD_PARTY_NOTICES.md`.

Check whether the upstream default branch has advanced without changing the worktree:

```sh
node scripts/refresh-vendored-skills.mjs check
```

Only skills marked `verbatim` can be refreshed automatically. Supply a reviewed, full commit SHA, then inspect the diff and commit it normally:

```sh
node scripts/refresh-vendored-skills.mjs refresh skill-creator <40-character-commit-sha>
git diff -- agents/skills/skill-creator agents/skills/sources.json THIRD_PARTY_NOTICES.md
```

Skills marked `manual` contain local adaptations. The command reports this instead of overwriting them; review the upstream change and port the relevant content manually.

## Vendored Skills

| Skill                    | Classification         | Notes                                                                                |
| ------------------------ | ---------------------- | ------------------------------------------------------------------------------------ |
| `code-review`            | Third-Party Adaptation | See `THIRD_PARTY_NOTICES.md`.                                                        |
| `code-simplifier`        | Third-Party Adaptation | See `THIRD_PARTY_NOTICES.md`.                                                        |
| `conversation-summary`   | Personal               | Central skill body; Claude hook runtime remains in `agents/claude-code/marketplace`. |
| `dotnet-best-practices`  | Third-Party Vendored   | Complete upstream skill directory; see `THIRD_PARTY_NOTICES.md`.                     |
| `find-skills`            | Third-Party Vendored   | Complete upstream skill directory; see `THIRD_PARTY_NOTICES.md`.                     |
| `karpathy-guidelines`    | Third-Party Adaptation | See `THIRD_PARTY_NOTICES.md`.                                                        |
| `multi-stage-dockerfile` | Third-Party Vendored   | Complete upstream skill directory; see `THIRD_PARTY_NOTICES.md`.                     |
| `permissions-manager`    | Personal               | Pure skill moved to the central registry.                                            |
| `pr-feedback-addresser`  | Personal               | Pure skill moved to the central registry.                                            |
| `python-playbook`        | Personal               | Language playbook moved to the central registry.                                     |
| `wsl-remote-development` | Personal               | Local-network WSL2 remote development guidance with a portproxy update script.       |
| `skill-creator`          | Third-Party Vendored   | Complete upstream skill directory; see `THIRD_PARTY_NOTICES.md`.                     |
| `tdd`                    | Third-Party Vendored   | Complete upstream skill directory; see `THIRD_PARTY_NOTICES.md`.                     |
| `web-search`             | Personal               | Pure skill moved to the central registry.                                            |
| `write-commit`           | Personal               | Pure skill moved to the central registry.                                            |
| `write-pr`               | Personal               | Pure skill moved to the central registry.                                            |

## External Symlinked Skills

There are currently no deployed skill symlinks that point to installed external marketplaces. If one is added later, record the source and reason here.
