# Third-Party Notices

The root [LICENSE](LICENSE) applies only to original material in this repository. Third-party material remains under its own license.

| Files/Directory | Upstream Source | Version | License | Modified | License / Notice |
| --- | --- | --- | --- | --- | --- |
| `agents/skills/code-review/` | [claude-plugins-official/code-review](https://github.com/anthropics/claude-plugins-official/tree/85822066fd6435dd39806f7b26b0a739444c3bcd/plugins/code-review) | `85822066fd6435dd39806f7b26b0a739444c3bcd` | Apache-2.0 | Yes; converted a Claude Code command into a tool-neutral Skill, removed mandatory subagents, and require explicit permission before posting PR comments | `agents/skills/skill-creator/LICENSE.txt`; no upstream NOTICE at this revision |
| `agents/skills/code-simplifier/` | [claude-plugins-official/code-simplifier](https://github.com/anthropics/claude-plugins-official/tree/85822066fd6435dd39806f7b26b0a739444c3bcd/plugins/code-simplifier) | `85822066fd6435dd39806f7b26b0a739444c3bcd` | Apache-2.0 | Yes; converted a Claude Code agent into a tool-neutral Skill and removed upstream project-specific JavaScript conventions | `agents/skills/skill-creator/LICENSE.txt`; no upstream NOTICE at this revision |
| `agents/skills/karpathy-guidelines/` | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills/tree/2c606141936f1eeef17fa3043a72095b4765b9c2) | `2c606141936f1eeef17fa3043a72095b4765b9c2` | MIT, declared in the upstream README | Yes; converted `CLAUDE.md` into Skill format and removed its closing effectiveness statement | Upstream [README](https://github.com/multica-ai/andrej-karpathy-skills/blob/2c606141936f1eeef17fa3043a72095b4765b9c2/README.md#license). No standalone LICENSE, NOTICE, or copyright notice is present at this revision. |
| `agents/skills/skill-creator/` | [anthropics/skills/skill-creator](https://github.com/anthropics/skills/tree/9d2f1ae187231d8199c64b5b762e1bdf2244733d/skills/skill-creator) | `9d2f1ae187231d8199c64b5b762e1bdf2244733d` | Apache-2.0 | No; vendored verbatim | `agents/skills/skill-creator/LICENSE.txt` |
| [OPTIONAL]<br/>`run_onchange_after_initialize.sh.tmpl`<br/>Oh My Zsh download | [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) | `677a4592b18c08ddea737f8aca70bac0e9fc9313` | MIT | No upstream code is vendored | [LICENSE.txt](https://github.com/ohmyzsh/ohmyzsh/blob/677a4592b18c08ddea737f8aca70bac0e9fc9313/LICENSE.txt) |
| [OPTIONAL]<br/>`run_onchange_after_initialize.sh.tmpl`<br/>zsh-autosuggestions download | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | `85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5` | MIT | No upstream code is vendored | [LICENSE](https://github.com/zsh-users/zsh-autosuggestions/blob/85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5/LICENSE) |
| [OPTIONAL]<br/>`run_onchange_after_initialize.sh.tmpl`<br/>zsh-syntax-highlighting download | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | `1d85c692615a25fe2293bdd44b34c217d5d2bf04` | BSD-3-Clause | No upstream code is vendored | [COPYING.md](https://github.com/zsh-users/zsh-syntax-highlighting/blob/1d85c692615a25fe2293bdd44b34c217d5d2bf04/COPYING.md) |

## Updating pinned bootstrap dependencies

Review the upstream release, commit, license, and any required notices before changing a revision. Update the revision in `run_onchange_after_initialize.sh.tmpl` and this table in the same change. Do not replace these pinned zsh dependencies with remote installers.

## License evidence limitation

The Karpathy upstream declares MIT in its README but does not provide a standalone license text or copyright notice at the pinned revision. This repository preserves that fact rather than supplying an unverified attribution. Confirm the upstream licensing evidence is sufficient for your use before publication.
