# Claude Code Plugins

This repository ships a personal Claude Code marketplace of runtime hook plugins. Each plugin extends Claude Code through the hook system (`PreToolUse` / `PostToolUse`) rather than through pure prompt behavior.

These plugins are the origin side of the OpenCode ports documented in [opencode-plugins.md](opencode-plugins.md); behavior that depends on runtime events lives here, while pure prompt behavior belongs in Agent Skills under `agents/skills`.

## Layout

`agents/claude-code/marketplace/plugins/<name>/` contains each plugin: a `.claude-plugin/plugin.json` manifest, `hooks/hooks.json` wiring, the hook scripts, and a `tests/` directory. This tree is repository-only (ignored via `.chezmoiignore`) because Claude Code reads plugins directly from the source path — nothing is deployed to the home directory.

`agents/claude-code/marketplace/.claude-plugin/marketplace.json` registers every local plugin. `install.sh` registers the marketplace and installs local plugins. See [agents/claude-code/marketplace/README.md](../agents/claude-code/marketplace/README.md) for the add-a-plugin flow.

## Plugins

| Plugin                   | Hook events                              | Category    | Notes                                                                                                                                                     |
| ------------------------ | ---------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sleep-cap`              | `PreToolUse` (Bash)                      | guardrail   | Blocks `sleep` longer than `SLEEP_CAP_THRESHOLD` (default 60s) and suggests `run_in_background`. `# sleep-cap:ignore` in the command bypasses the check.  |
| `bash-error-diagnostics` | `PreToolUse` + `PostToolUse` (Bash)      | diagnostics | Warns on piped commands missing `pipefail` (pre) and classifies Bash errors with structured diagnostics (post) to prevent blind retries.                  |
| `git-author-check`       | `PreToolUse` (Bash)                      | git         | Validates git author email before commits. Resolves from `EXPECTED_GIT_EMAIL`, repo `.git-author-check.json`, or `~/.git-author-check.json`.              |
| `retry-loop-detector`    | `PreToolUse` (all tools)                 | guardrail   | Tracks consecutive identical tool calls; warns, then blocks at the threshold to stop context-wasting retry loops.                                         |
| `circuit-breaker`        | `PreToolUse` + `PostToolUse` (all tools) | guardrail   | Tracks consecutive identical tool failures and blocks further attempts after 3. Allowlists transient errors (429, ETIMEDOUT, DNS).                        |
| `time-awareness`         | `PreToolUse` (all tools)                 | utility     | Opt-in via `.time-awareness.json`; injects current system time and timezone into context.                                                                 |
| `compaction-monitor`     | `PreToolUse` (all tools)                 | utility     | Opt-in via `.compaction-monitor.json`; warns about context-pressure and compaction frequency when thresholds are exceeded.                                |
| `conversation-summary`   | `PreToolUse` (all tools)                 | utility     | Opt-in via `.conversation-summary.json`; reminds the agent to maintain a running summary. Skill body comes from `agents/skills/conversation-summary`.     |

## Design Notes

Hooks run on every matching tool call, so keep them fast: each `hooks.json` sets a short `timeout` (2–5s) and the scripts fail open rather than blocking work on an internal error.

Hard guardrails may expose a user-controlled bypass, but be deliberate about who can trigger it. Claude Code `sleep-cap` honors the inline `# sleep-cap:ignore` comment; the OpenCode port intentionally does **not**, because there the model can add that comment itself after seeing a block reason (see [opencode-plugins.md](opencode-plugins.md) design notes). Prefer environment variables or config files over model-writeable inline comments for guardrails the model should not self-exempt from.

Opt-in plugins (`time-awareness`, `compaction-monitor`, `conversation-summary`) stay dormant until a per-repo config file enables them, so they add no context noise by default.

Pure prompt behavior belongs in Agent Skills under `agents/skills`, not in a hook plugin. Only add a plugin here when the behavior depends on runtime events or must ship bundled runtime files. See [agent-skills.md](agent-skills.md).

## Validation

Run a plugin's tests:

```sh
bash agents/claude-code/marketplace/plugins/<name>/tests/*.sh
```

Run every plugin's tests:

```sh
for t in agents/claude-code/marketplace/plugins/*/tests/*.sh; do
  bash "$t" || exit 1
done
```

Install or refresh the marketplace and plugins in Claude Code (idempotent):

```sh
agents/claude-code/marketplace/install.sh
```
