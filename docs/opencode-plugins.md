# OpenCode Plugins

This repository mirrors Claude Code runtime plugins into OpenCode plugins where the behavior depends on runtime events rather than pure Agent Skills.

## Layout

`agents/opencode/plugins/*.js` contains the source implementations. These files are repository-only and are not deployed directly by chezmoi.

`dot_config/opencode/plugins/symlink_*.tmpl` deploys symlinks into `~/.config/opencode/plugins/`, which OpenCode loads at startup as global local plugins.

OpenCode loads local plugins when a session starts. After changing or applying these symlinks, restart any already-running OpenCode session to pick up the new plugin set.

## Migrated Plugins

| Plugin                   | OpenCode events                                        | Notes                                                                                                                                                                                                       |
| ------------------------ | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sleep-cap`              | `tool.execute.before`                                  | Blocks shell commands with `sleep` longer than `SLEEP_CAP_THRESHOLD` seconds. Inline bypass comments are intentionally ignored; set `OPENCODE_SLEEP_CAP_DISABLE=1` before launching OpenCode to disable it. |
| `bash-error-diagnostics` | `tool.execute.before`                                  | Prepends `set -o pipefail;` to shell pipeline commands that do not already set pipefail.                                                                                                                    |
| `git-author-check`       | `tool.execute.before`                                  | Checks `git commit` commands and auto-sets `git config user.email` from `EXPECTED_GIT_EMAIL`, repo `.git-author-check.json`, or `~/.git-author-check.json`.                                                 |
| `retry-loop-detector`    | `tool.execute.before`                                  | Tracks consecutive identical tool calls in-process; warns via logs and blocks at the threshold.                                                                                                             |
| `circuit-breaker`        | `tool.execute.before`, `tool.execute.after`            | Tracks repeated non-transient tool failures and blocks repeated identical attempts after the threshold.                                                                                                     |
| `time-awareness`         | `tui.prompt.append`                                    | Opt-in via `.time-awareness.json`; appends current time context to prompts when enabled.                                                                                                                    |
| `compaction-monitor`     | `tui.prompt.append`, `experimental.session.compacting` | Opt-in via `.compaction-monitor.json`; appends context-pressure warnings from Claude-style token/compaction files when thresholds are exceeded.                                                             |
| `conversation-summary`   | `tui.prompt.append`                                    | Opt-in via `.conversation-summary.json`; reminds the agent to maintain the running summary.                                                                                                                 |

## Design Notes

These are not byte-for-byte ports of Claude Code hooks. Claude Code's `additionalContext` and hook output schema do not map exactly to OpenCode. OpenCode ports should use native OpenCode events and mutate output or throw errors only where the behavior is clear.

Do not expose model-writeable bypasses for hard guardrails. For example, OpenCode `sleep-cap` intentionally ignores `# sleep-cap:ignore` because the model can add that comment itself after seeing a block reason. Use process environment variables for user-controlled bypasses.

Pure prompt behavior belongs in Agent Skills under `agents/skills`, not in OpenCode plugins.

## Instructions

`dot_config/opencode/AGENTS.md.tmpl` composes `agents/instructions/base.md` and `agents/instructions/engineering.md`. Chezmoi renders it to `~/.config/opencode/AGENTS.md`.

OpenCode is currently engineering-focused and does not manage custom profiles under `~/.config/opencode/agents/`. Add native profiles only when distinct roles require different instruction compositions.

## Validation

Validate plugin syntax and symlink targets:

```sh
for file in agents/opencode/plugins/*.js; do
  node --input-type=module --check < "$file" >/dev/null || exit 1
done

for tmpl in dot_config/opencode/plugins/symlink_*.tmpl; do
  target=$(chezmoi execute-template < "$tmpl")
  test -f "$target" || exit 1
done
```

Apply the global OpenCode plugins:

```sh
chezmoi apply ~/.config/opencode/plugins ~/.config/opencode/AGENTS.md
```

Check what is deployed:

```sh
find ~/.config/opencode/plugins -maxdepth 1 -name '*.js' -type l -print
```
