---
name: cflow
description: Caio's engineering workflow for any repo — sync, plan only when it pays, build in small commits, prove it on the running system, cross-review only risky surfaces, keep a plans index with commit hashes. Load at the start of any build, fix, or plan task in a repo whose AGENTS.md names cflow.
---

# Cflow

Modelled on how Lobster actually ships: few rules, small changes, proof from the live system. The repo's `AGENTS.md` is the source of truth for its commands, branches, and architecture rules; this skill is only the loop around them. v1 (eleven stages, seven skills) is in `skills-archive/cflow-v1/`, tag `cflow-v1`.

## The loop

1. **Sync.** Pull the trunk before touching anything (`scripts/sync.sh` or `git pull --ff-only`). Never work on a stale or diverged clone.
2. **Read, then decide if a plan pays.** Read the code the change touches. Write a plan only when the work spans more than one session or touches a risky surface (below). Otherwise just build.
3. **Build in small commits.** Claude writes the code. One behavior per commit; the message says what now happens, not what was edited ("mail: an info session from a GT person is noise, not an alert").
4. **Test what you touched.** Run the tests the diff can reach, plus lint/typecheck/build if the repo has them. Never weaken or delete a test to go green; name the root cause before fixing.
5. **Land the way the repo says.** Direct to trunk, or a small PR with auto-merge — whatever `AGENTS.md` sets. Plans and docs ride in the same commit/PR as their code.
6. **Prove it on the running system.** Done means the deployed or running thing was checked: a live call, the log, the page driven in the browser. An agent saying "done" is not evidence; tests alone are not evidence for anything with a runtime surface.
7. **Record it.** Plan shipped → its row in the plans index gets the commit hashes and any leftovers, named. Durable operational knowledge goes in the runbook, not in chat.

Ask Caio only about one-way doors (data loss, prod schema, money, messages to people, auth changes). Decide everything reversible yourself and say what you chose.

## Risky surfaces (the only place ceremony is spent)

Each repo lists its own in `AGENTS.md` (Lobster: `lobsterd.mjs`, the display app, boot. Nodus: authz, the LLM id boundary, storage paths, migrations, secrets). On a risky surface:

- **Plan first**, and get a cross-lab review of the plan before building. Save the review next to the plan.
- **Cross-lab review of the diff** before it lands (see models below). Verify each finding by quoting the code or reproducing it; fix or say why not. Two rounds max.
- **SQL against a shared database** (staging/prod): review the statements *and* the real schema for a `SAFE TO RUN` verdict, reproduce any finding on a throwaway DB, apply, then confirm the objects exist. Never skipped, even if the PR was reviewed.

Everything else gets no review gate beyond CI. Use `/code-review low` when you want a cheap second look.

## Plans

- `plans/` (or `docs/plans/`), one file per plan: `YYYY-MM-DD-<slug>.md`, `Status:` line at the top.
- `README.md` in that folder is the index: plan, status, shipped commits. Done plans stay; that is the track record. Nothing is "done" with silent leftovers.
- A plan is short: goal, what changes where, how it will be proven on the running system, open one-way-door questions. Revisions append, they don't rewrite.

## Models (checked 2026-09-30 against `~/stuff/cortex/stack/model-fit.md`)

Re-read that table when it's more than a month newer than this line; it wins over this section.

| Job | Default | When to switch |
|---|---|---|
| Build | Opus 5.5 in Claude Code, `/effort medium` | `xhigh` for a long autonomous run; Codex + GPT-6 Astra when the Max 7-day bucket is tight |
| Plan / architecture | Opus 5.5 `/effort high` | Fable 5.1 for genuinely long-horizon plans, or `/advisor fable` under Opus for the decision points only |
| Cross-lab review (risky surfaces) | `codex exec -m gpt-6-astra` on the diff or plan | Smoke-test `codex exec` for 60s first — it can hang silently |
| Debug a prod bug | GPT-6 Astra via Codex | Opus 5.5 `high` to read an unfamiliar codebase |
| Browser proof | Claude in Caio's Chrome (`claude-in-chrome`), new tab | Astra computer use for long unattended flows |
| Lookups, git ops, small edits | Opus 5.5 `/effort low` | — |

Not used: Sonnet 5.5 (wins benchmarks by burning ~1.8× Opus's tokens — wrong trade on a capped plan). No executor/orchestrator split: Opus 5.5 builds directly; handing work to a second agent costs more than it saves.

## Parallel work: the king and its workers

- **King** — one conversation per repo (e.g. "nodus king" in the Claude desktop sidebar). Caio talks only to it. It discusses plans, gets GO on one-way doors, starts workers, tracks them, and reports verified outcomes. It never writes or reviews code, so it stays free to talk; keep it at low effort.
- **Worker** — one sidebar conversation per job, in the repo's group, on its own worktree/branch. The king starts it with `spawn_task` (the brief is its first message; Caio clicks once to launch), then follows it with the session tools (`list_sessions`, `get_session`, `send_message`). Caio can open it any time to watch or steer.
- **The worker owns the whole job:** build → a fresh reviewer checks it (a subagent told to prove it broken; Astra via `codex exec` on risky surfaces) → the worker reads the verdict and fixes or finishes → lands the PR → proves it on staging. It returns to the king only when landed and verified, or blocked on a one-way door. The author never grades its own work.
- **Subagents, one level only.** A worker may start subagents (Claude Code's Agent tool) for search, review, or — only for a job that splits into parallel pieces — builders in separate worktrees whose work it merges. Subagents never start subagents.
- Tiny jobs (a one-file fix) skip the sidebar: the king runs one background subagent in a worktree (Agent tool, `isolation: "worktree"`).
- A worker's conversation is archived once its PR lands. When Claude Code Projects reaches this account, the king maps onto its main chat and workers onto its threads.

## When a session can't finish

Push the branch and write a short handoff (`handoff` skill). An unpushed branch at session end is the only real loss.
