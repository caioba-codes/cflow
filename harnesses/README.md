# harnesses/

Harness-specific adapters. **Generated from the SKILL.md files — do not hand-edit.**
Edit the canonical skill in `../skills/<name>/SKILL.md` and re-run sync.

- `codex/AGENTS.md` — "when to use" snippet (between `cflow:skills` markers) that
  `init-project` splices into a project's `AGENTS.md` so Codex knows when each skill applies.
- `codex/prompts/<name>.md` — frontmatter-stripped prompt form, for Codex's slash-prompt path.

There is **no `claude/` mirror**: Claude Code consumes `SKILL.md` unchanged, so the canonical
`../skills/` *is* the Claude format. Sync installs it straight to `~/.claude/skills/`.

## Reliability layers (per skill)
1. **Native skill** — `~/.claude/skills/<name>/` and `~/.codex/skills/<name>/`.
2. **Prompt fallback** — `~/.codex/prompts/<name>.md`.
3. **Always-on** — `AGENTS.md` references, so the agent knows the skill exists even if not invoked.
