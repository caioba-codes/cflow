---
name: cflow
description: Caio's engineering workflow for any repo — a king conversation plans with Caio and starts one worker per job; each worker syncs, builds in small commits, gets a cross-lab review on risky surfaces, lands, and proves it on the running system. Load at the start of any build, fix, or plan task in a repo whose AGENTS.md names cflow.
---

# Cflow

Modelled on how Lobster ships: few rules, small changes, proof from the live system. The repo's `AGENTS.md` owns its commands, branches, plan naming and risky surfaces; this skill is only the loop around them. v1 is archived in `skills-archive/cflow-v1/` (tag `cflow-v1`).

Ask Caio only about one-way doors (data loss, prod schema, money, messages to people, auth changes). Decide everything reversible yourself and say what you chose.

## The king and its workers

- **King** — one conversation per repo (e.g. "nodus king" in the Claude desktop sidebar). Caio talks only to it. It writes plans with Caio, gets GO, starts workers, tracks them, and reports verified outcomes. It never writes or reviews code, so it is always free to talk.
- **Worker** — one sidebar conversation per job (a job = one approved plan or fix), on its own worktree/branch. The king starts it with `spawn_task` (the brief is its first message; Caio clicks once), sets its model and effort from the roles table (`set_session_model`, `set_session_effort`), and follows it with `list_sessions` / `get_session` / `send_message`. Caio can open it any time.
- **Naming** — every worker conversation is titled `worker N · <what it's doing>` (e.g. `worker 3 · matrix export to Excel`), set with `set_session_title` right after it starts. N is the next number after the highest worker in the repo's sidebar group (`list_sessions`), so numbers never repeat while a worker is live. The king refers to workers by that number when it reports.
- **Subagents** — short-lived helpers a worker starts (Agent tool) for search, review, or parallel builders in separate worktrees on a job that splits cleanly. One level only: subagents never start subagents.
- A one-file fix skips the sidebar: the king runs one background subagent with `isolation: "worktree"`.

## The worker's loop

1. **Sync** the trunk. Never build on a stale clone.
2. **Build in small commits.** One behavior per commit; the message says what now happens ("mail: an info session from a GT person is noise, not an alert").
3. **Test what you touched.** Never weaken or delete a test to go green; name the root cause before fixing.
4. **Review by someone who didn't write it** — on a risky surface, the reviewer role (cross-lab); elsewhere CI, plus `/code-review low` when a second look is cheap. Verify each finding by quoting the code or reproducing it; fix or say why not. Two rounds max.
5. **Land the way `AGENTS.md` says.** Plans and docs ride with their code.
6. **Prove it on the running system:** the deployed page driven in Caio's Chrome (`claude-in-chrome`), a live call, the log. An agent saying "done", or green tests alone, is not proof.
7. **Report to the king** only when landed and proven, or blocked on a one-way door. Record commit hashes and named leftovers in the plans index; then `scripts/prune-worktrees.sh --apply` and archive the conversation.

## Risky surfaces

Each repo lists its own in `AGENTS.md`. On them: plan first with a cross-lab review of the plan, cross-lab review of the diff, and for **SQL against a shared database** a `SAFE TO RUN` verdict on the statements *and* the real schema, findings reproduced on a throwaway DB, apply, then confirm the objects exist. Never skipped.

## Plans

One file per plan with a `Status:` line; the folder's `README.md` indexes plan, status and shipped commits (template: `templates/plans-README.md`). A plan says: goal, what changes where, how it will be proven running, open one-way-door questions. Done plans stay.

## Roles and models

Models come from the **cflow roles** table in `~/stuff/cortex/stack/model-fit.md` (column `Applied`). The nightly stack job keeps it current and only changes `Applied` on its own at `high` confidence; anything weaker is proposed in the morning report for Caio to approve. Read the table when starting a worker; never hardcode a model here.

Snapshot 2026-09-30, for when the table can't be read: king Opus 5.5 medium · worker Opus 5.5 medium (xhigh for long runs) · reviewer GPT-6 Astra via `codex exec` · backup builder GPT-6 Astra when the Claude weekly limit is tight. Smoke-test `codex exec` for 60s before relying on it; it can hang silently.

A session that can't finish pushes its branch and writes a handoff (`handoff` skill).
