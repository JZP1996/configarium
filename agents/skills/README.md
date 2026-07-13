# Agent Skills

This directory is the source of truth for centrally managed Agent Skills. Third-party source, license, revision, and modification details are recorded in [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

## Policy

- Keep all personal reusable workflows in `agents/skills/<name>` and expose agent-specific subsets through symlinks in `dot_agents/skills`, `dot_claude/skills`, or other deployment adapters.
- Do not vendor third-party skills unless the license permits reuse and the source is recorded in `THIRD_PARTY_NOTICES.md`.
- Prefer symlinking to an installed upstream marketplace for complex external skills that include scripts, agents, assets, or other supporting files.
- When vendoring external content, update `THIRD_PARTY_NOTICES.md` with its upstream source, license, revision, and local modifications.
- Review upstream diffs before refreshing vendored content; do not blindly overwrite local copies.

## Vendored Skills

| Skill | Classification | Notes |
| --- | --- | --- |
| `code-review` | Third-Party Adaptation | See `THIRD_PARTY_NOTICES.md`. |
| `code-simplifier` | Third-Party Adaptation | See `THIRD_PARTY_NOTICES.md`. |
| `conversation-summary` | Personal | Central skill body; Claude hook runtime remains in `agents/claude-code/marketplace`. |
| `karpathy-guidelines` | Third-Party Adaptation | See `THIRD_PARTY_NOTICES.md`. |
| `permissions-manager` | Personal | Pure skill moved to the central registry. |
| `pr-feedback-addresser` | Personal | Pure skill moved to the central registry. |
| `python-playbook` | Personal | Language playbook moved to the central registry. |
| `wsl-remote-development` | Personal | Local-network WSL2 remote development guidance with a portproxy update script. |
| `skill-creator` | Third-Party Vendored | Complete upstream skill directory; see `THIRD_PARTY_NOTICES.md`. |
| `web-search` | Personal | Pure skill moved to the central registry. |
| `write-commit` | Personal | Pure skill moved to the central registry. |
| `write-pr` | Personal | Pure skill moved to the central registry. |

## External Symlinked Skills

There are currently no deployed skill symlinks that point to installed external marketplaces. If one is added later, record the source and reason here.
