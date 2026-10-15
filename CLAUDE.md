# cflow repo

- `skills/explain-flow/references/how-cflow-works.html` is the page `/explain-flow cflow` hands every new user. A change that alters what the human does (a step, a choice, a default, a command, a prerequisite or the install) updates that page in the same PR, following `skills/explain-flow/SKILL.md`. After editing it, check that the cheat sheet still fits one screen at 1280×800.
- After editing a `skills/<name>/SKILL.md`, regenerate `harnesses/codex/prompts/<name>.md` (the SKILL.md without its frontmatter).
