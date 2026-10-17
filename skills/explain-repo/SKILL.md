---
name: explain-repo
description: "Write one HTML recap of a whole repo for someone coming back to it after time away: what the product does, how it's used, the architecture and why it was built that way, the stack, how the pieces work together, and what changed lately. Published the same way as explain-diff pages. Use for /explain-repo, 'recap this repo', 'refresh me on this codebase', 'I've been away, what is this again'."
disable-model-invocation: true
---

# Explain repo

**When the user has been away from a repo, they get one page that puts the whole thing back in their head: the product first, then the machine behind it, and the reasons it's shaped that way.** It's the whole-repo sibling of `explain-diff`. An explain-diff page goes deep on one change; this page goes wide over the whole system and stays at the level of "what is this part for and how does it talk to the others". It is longer than an explain-diff page and much shallower than reading the code.

## Inputs

- **The repo.** Default to the current checkout. Read from `origin`'s default branch, not a feature branch someone has open, so the page describes what's live. `git fetch` first; if other agents are working in the checkout, read with `git show origin/<default>:<path>` or a fresh worktree rather than switching branches.
- **The reader.** The repo's owner, who built most of it and forgot the details. They don't need beginner background on the languages or tools. They need the map back, the reasons back, and what moved while they were gone.
- **The time away.** If the user says how long ("I've been away a month"), use it for the "Lately" section. Otherwise use the last 30 days.

## Sources of the "why"

Every reason the page gives must come from something the repo or its history says, never from what seems plausible. Look in this order and cite each one with a link:

1. Plans, design docs, ADRs, decision logs (`plans/`, `docs/`, `adr/`, `DECISIONS.md` and the like).
2. The README, `FEATURES.md`, `CHANGELOG`, runbooks, `AGENTS.md`/`CLAUDE.md` (they often record rules with their reasons and dates).
3. PR descriptions: `gh pr list --state merged --limit 200 --json number,title,mergedAt,body`. Search them for the decision you're explaining, then read the one that made it.
4. Commit messages and code comments that state a reason.

When nothing records why something is the way it is, say so in a short "not recorded" note instead of inventing a reason. A few honest gaps are fine.

## What to read

Spend the effort on breadth. Use the `how` skill's approach, or parallel read-only subagents (one per top-level area), to get each area's purpose, entry points and what it talks to. Then read the sources above for the reasons. Collect, before writing:

- The top-level directories and what each one is.
- Entry points: what starts the system (servers, daemons, crons, CLIs, scheduled jobs, the app's main).
- External services and data stores, and which part talks to each.
- Where it runs (machines, hosts, cloud) and how code gets there (deploy scripts, CI).
- The 3 to 6 decisions that shaped the system most, each with its source.
- The merged PRs of the time-away window, grouped into a handful of themes.

## Writing the page

One long page with these sections, in order. Each section header gets a one-line summary under it so a skimmer gets the gist.

- **What it is.** The product in plain words: who uses it, what they get, a few lines. If the product has a name different from the repo's, use the product's name and say what the repo is called. Then **a day with it**: two or three concrete things a user does, each traced from what they see to what the system does, with toy data.
- **The big picture.** One system diagram of the main components and the data flowing between them, with example data on the arrows. This is the page's anchor figure; later sections reuse it, highlighting the part they're about.
- **Why it's built this way.** The 3 to 6 shaping decisions. For each one: what was chosen, what it was chosen over, the reason, and the source link. Use callouts.
- **The stack.** A compact table: layer, what's used, what it's for. Languages, runtimes, frameworks, data stores, external APIs, hosting, CI. Only what the repo actually uses.
- **How the pieces work together.** Two or three end-to-end flows through the big-picture diagram (one request, one scheduled job, one deploy), each step naming the file or module that does it.
- **Where things live.** A map of the repo: each top-level directory, what's in it, and the one or two files to open first. Note conventions an agent or the owner must know (where tests go, how to deploy, the rule files).
- **Lately.** What changed in the time-away window, grouped by theme, each theme with its PR links. Then what's still open: open PRs, unfinished plans, known blockers, each with a link.
- **Quiz.** Five questions about the system, not trivia: which part handles X, why Y was chosen over Z, what breaks if W is down. Interactive multiple choice, as in explain-diff.

Keep each section short enough to read in a few minutes. The whole page should take 15 to 25 minutes. When a section starts explaining one change in depth, link to that change's PR or explainer instead.

Format follows explain-diff's rules: one self-contained HTML file with inline CSS and JS, a table of contents, no tabs for the top-level structure, readable on a phone, light and dark via `prefers-color-scheme`, a closing `</body>`, HTML diagrams (never ASCII), `pre`/`pre-wrap` on every code block, callouts for key ideas. Write with the clarity of Martin Kleppmann and run the prose through the **unslop** skill. No secrets, tokens, private message contents or personal data in examples; hostnames and account names only where the reader needs them to find something, and never credentials.

Write it outside the code repo, for example `/tmp/<slug>.html`.

## Publishing

Use explain-diff's publisher, so recaps land in the same place and the same review list as feature explainers:

```
~/.claude/skills/explain-diff/scripts/publish.sh /tmp/<slug>.html --slug <YYYY-MM-DD>-<repo>-recap --title "<Product>: repo recap" --repo <owner/repo>
```

Write `<repo>` in the slug lowercase with dots and underscores as hyphens, since the publisher only accepts `[a-z0-9-]`. Leave out `--prs` (the page covers the whole repo). Reply with the printed link on its own line, plus a one-line summary of what the page covers. If publishing fails, say so and attach the HTML instead.

Then write the Notion copy exactly as explain-diff's **Notion copy** section says (`~/.claude/skills/explain-diff/SKILL.md`), when the user's instructions name a database for it, and put its link in the reply too.

## Check before publishing

1. Every "why" has a source link or a "not recorded" note.
2. Every file path and command on the page exists on the default branch.
3. Search the page for tokens, keys, passwords, phone numbers and email addresses; remove any.
4. Open it in a browser if you can, on a laptop width and a phone width.
