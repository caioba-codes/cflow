# cflow repo

- `skills/explain-flow/references/how-cflow-works.html` is the page `/explain-flow cflow` hands every new user. A change that alters what the human does (a step, a choice, a default, a command, a prerequisite or the install) updates that page in the same PR, following `skills/explain-flow/SKILL.md`. A new skill that agents don't run on their own goes on its cheat sheet.
- After editing a `skills/<name>/SKILL.md`, regenerate `harnesses/codex/prompts/<name>.md` (the SKILL.md without its frontmatter).
