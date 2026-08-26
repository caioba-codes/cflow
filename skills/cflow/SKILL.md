---
name: cflow
description: Index of Cflow, the user's agentic engineering workflow. Load first for any Cflow task; it gives the stage list, the rules that apply at every stage, and which stage skill to load next (cflow-plan, cflow-implement, cflow-verify, cflow-review, cflow-ship, cflow-harden). Use cflow-status to find out which stage you are in.
---

# Cflow

Cflow is the operating system for building software with coding agents. The human owns goals, taste, product judgment, and risk decisions. Agents do bounded mechanical work. Verifiers decide whether the loop can advance.

This file is the index. Load **only the stage skill you are in** — each owns its procedure, and loading all of them is the bloat this split exists to prevent. [FLOW.md](FLOW.md) is the canonical stage list that `cflow-status` reads.

## The flow

Stages and their skills are in [FLOW.md](FLOW.md): plan → implement → verify → review → ship → harden. Run them in order without stopping for anything reversible after GO.

## Rules that apply at every stage

- **Interview before, autonomy during.** Every question to the human carries a recommendation. Confirmed calls are `LOCKED` and never reopened. After GO, stop only for destructive actions or genuine scope changes.
- **Evidence or it didn't happen.** Every "done"/"green" claim carries pasted output. Unpasted green is re-run. An executor whose check is still running ends with `VERIFICATION_PENDING: <what> | check: <exact command>` — never a claim.
- **Never weaken, skip, or delete a test to go green.** Fix the code.
- **Root cause, never symptoms.** Name the cause before fixing.
- **Surgical changes.** Every modified line traces to the task. Report dead code; don't silently delete it.
- **Plans and docs land on `staging` as a docs-only PR, never on `main`**, except a status flip that rides its code PR. Details in [cflow-plan](../cflow-plan/SKILL.md).
- **Never poll in the foreground.** Background the work and act on the notification; name the liveness signal (log mtime, PID) and post a one-line heartbeat rather than going silent >15 min.
- **Compaction is a memory event, never an endpoint.** Re-read state and continue the in-flight step.
- **Sessions are mortal.** Every session ends *shipped* or *handed off* (brief in the plan file — see cflow-plan). An unshipped branch older than a day is a defect.
- **Delete first.** New machinery needs a measured problem and a fire/catch counter; workflow rules climb prose → counter → enforcement; anything that can block work runs its first 24h in shadow (log-only) mode. Product security is enforced from day one.
- **Browser work happens in the user's own running Chrome** — Claude via the `claude-in-chrome` extension, Codex via its `chrome@openai-bundled` plugin — as a new tab in their window. Never a separate Chrome instance, headless browser, or the `chrome-devtools` MCP unless the user asks.
- **End every final report** with a proof table (cflow-ship) and a friction line: what was unexpectedly hard, and the script/doc/skill fix you propose.

## Harness roles

- **Orchestrator — Claude.** Plans, interviews, dispatches, owns every gate and merge. Does not write code by default; a step it implements carries a written reason in the plan's `Execution:` line.
- **Executor — Codex, headless `codex exec`.** Backend, mechanical, and routine frontend plumbing. Invocation protocol in cflow-implement.
- **Designer — Claude.** Taste-sensitive UI only (new pages, layout, visual polish, wording).
- Route by **scope**, not difficulty: small + fully specified → cheapest tier; well-defined against a plan → mid; vague/cross-cutting/browser-driving → frontier. Model named per PR in `Execution:`. Escalate on a failed verifier without asking.
- `subswitch` when a worker hits a usage limit; an account-limit interruption never consumes a retry or a review round.

## Per-repo conventions

`REVIEW.md`, `RECOVERY.md`, `MAINTAINER.md`, a versioned E2E playbook, `docs/ledger.md`, `scripts/worktree-setup.sh`, `scripts/test-changed.sh`. Templates in [templates/](templates/), scripts in [scripts/](scripts/). Nightly E2E heartbeat and biweekly audit are scheduled, not per-PR.

## Editing cflow

Canonical skills live in `~/stuff/projects/cflow/skills/<name>/`; run `scripts/sync-skills.sh` after editing. Keep each stage skill under ~1,500 words — if a stage needs more, move detail to a `references/` file that is read on demand.
