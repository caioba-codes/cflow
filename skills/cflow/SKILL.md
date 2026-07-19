---
name: cflow
description: Explains Cflow, the user's agentic engineering workflow for building software with coding agents. Use when starting, planning, implementing, reviewing, shipping, or improving work through Cflow, or when an agent needs the canonical Cflow stages and operating rules.
---

# Cflow Workflow

Cflow is the operating system for building software with coding agents. The human owns goals, taste, product judgment, and risk decisions. Agents do bounded mechanical work. Verifiers decide whether the loop can advance.

Use this skill as the explanation of the workflow. Use `cflow-status` when you need to inspect the current repo state and decide the next step.

## Canonical Flow

Read [FLOW.md](FLOW.md) for the canonical Cflow stages. Do not invent a second stage list in another skill. If a status, checklist, or loop controller needs step names, it should reference `FLOW.md`.

The short shape is:

1. Understand and research the task.
2. Scope a small branch.
3. Implement the minimal behavior.
4. Verify locally with objective checks and by driving the real flow end to end.
5. Open a PR to `staging`.
6. Run review loops (default-on code review; security review when the diff warrants it) until clean enough or blocked.
7. Merge to `staging` and validate there.
8. Run cleanup as a separate pass when useful.
9. Harden recurring issues into automation (lint/CI/skill/`REVIEW.md`) as a triggered pass.
10. Promote `staging` to `main`.

## Operating Rules

- Keep work PR-sized. Split broad work into stacked branches.
- Research before editing. Read the relevant code, tests, schema, migrations, and any plan/spec the user names.
- Write plans in the two-audience format defined in [PLANS.md](PLANS.md): a plain-language Spec for the human reviewer (which must include a "How it will be built" architecture explanation), a separator, then the agent-facing Plan. The Spec must be readable without opening the code.
- Every plan header declares who implements what in an `Execution:` line, per branch/PR (format in [PLANS.md](PLANS.md)). Default split under the current harness roles: backend/mechanical work → the executor (Codex, headless `codex exec`); design-heavy frontend/UX → the orchestrator (Claude) directly. One writer per branch at a time; the orchestrator owns review gates and merges regardless of assignment.
- Use plan filenames as the implementation-status indicator: `<NNN>-<slug>.md` while any scoped work remains, and `<NNN>-DONE-<slug>.md` only after the entire plan is implemented and validated. Update references when renaming; review approval or one finished PR does not make a multi-part plan `DONE`.
- Use `source-code-context` before integrating nontrivial package, SDK, API client, or framework behavior.
- Build the smallest working behavior before cleanup or broad refactors.
- Verify behavior, don't assume it. When a change has a runtime surface, drive the real flow end to end (invoke `verify`) — not just unit checks — before opening the PR.
- Treat tests, lint, typechecks, browser checks, CI, and review tools as external verifiers.
- Default on the review gates: run `/code-review` on every non-trivial product-source PR, and `security-review` whenever the diff touches auth, data access, external input, permissions, secrets, or money. Load the repo's `REVIEW.md` criteria when reviewing.
- Open feature/fix PRs against `staging`, not `main`.
- Use `greploop` for full Greptile review loops and `check-pr` for one-pass PR readiness.
- Run `code-structure-cleanup` as a separate pass after behavior works when the feature left duplicated mechanics or messy structure.
- Encode recurring knowledge as infra (Stage 10, Harden). When the same class of issue is hand-fixed twice, stop fixing instances — write the lint rule, CI check, test, skill, or `REVIEW.md`/`CLAUDE.md` rule that kills the class. Automation is how domain knowledge reaches the next contributor without a prompt.
- Maintain the per-repo conventions when they exist (see below): `REVIEW.md`, `RECOVERY.md`, `MAINTAINER.md`, and a versioned E2E playbook.
- Stop when the loop reaches its success condition, repeats the same failure, exceeds the iteration budget, or needs human product/security judgment.

## Harness Defaults

- Cflow is the single source of truth for skills. Edit canonical skills in `~/stuff/projects/cflow/skills/<name>/` and run `scripts/sync-skills.sh`.
- Codex and Claude both receive the same canonical skill content through sync; prompt adapters are generated.
- Default harness roles: Claude (Fable 5) is the orchestrator — planning, plan/Spec conversations, PR review gates, and driving the executor headless via `codex exec` for mechanical implementation. Codex is the executor grinding scoped plans. Plan and design talk happens in the Claude session, not the executor's.
- Route the executor model by task difficulty to cap token spend, rather than defaulting every branch to the frontier tier:
  - Trivial/mechanical (renames, config, boilerplate, doc edits) → cheapest tier (GPT-5.6-luna).
  - Standard implementation against a clear plan → mid tier (GPT-5.6-terra).
  - Hard, ambiguous, or architecture-adjacent work → frontier tier (GPT-5.6-sol high).
  Declare the chosen tier per branch in the plan's `Execution:` line; the orchestrator (Fable 5) suggests it and stays frontier for planning and review gates. Start at the cheapest tier that could plausibly one-shot the plan and escalate a tier on repeated failure — don't start at the top.
- One orchestrator session per repo. It supervises executor runs in the background; scale executors only as far as plan dependencies and repo isolation (separate branches, git worktrees) allow — stacked plans run sequentially.
- Interactive Codex terminals are the fallback, not the default: use one when orchestrator usage runs out or when pairing directly on open design questions.
- Prefer the strongest available coding harness/model for the task, but keep the workflow portable across harnesses.
- Use speech-to-text for rich prompts when useful.

## Per-Repo Conventions

Each repo carries a small set of standing documents that let agents work with zero extra context from the prompter. cflow ships templates in [templates/](templates/); copy them into a repo and fill in the real values. Agents load them at the stages noted.

- **`REVIEW.md`** (repo root) — the durable review criteria for this codebase: framework/architecture rules, recurring-issue checklist, "reject if…" rules. Loaded by Stage 6 (Review Loop) and where Stage 10 (Harden) writes newly-encoded review rules. This is how a rejected PR becomes a failure of automation rather than tribal knowledge.
- **`RECOVERY.md`** (repo root) — the disaster-recovery playbook: where backups and point-in-time-recovery live, and the exact steps an agent can execute to restore. Assume that at some point an agent will do something destructive. The `careful` skill points here when it catches a destructive op.
- **`MAINTAINER.md`** (repo root) — the standing reviewer persona and accumulated context for the repo (owner intent, non-obvious invariants, past incidents, style). Loaded by Stage 6 so review carries continuity instead of starting cold each session.
- **Versioned E2E playbook** (e.g. `docs/e2e-playbook.md`) — a checked-in, versioned script for driving the product's critical flow end to end on a real environment, producing a PASS/FAIL report. Used by Stage 4 verification and by the nightly heartbeat below.

### Background heartbeats

Some verification runs on a schedule, not per-PR. The canonical one is a **nightly E2E heartbeat**: a scheduled agent runs the versioned E2E playbook against `staging` and posts a PASS/FAIL report each morning, catching regressions that per-PR checks miss. Schedule it with the `schedule`/cron tooling; keep the playbook versioned so the check improves over time. Standing background reviewers (a persistent maintainer agent that reviews incoming PRs with `MAINTAINER.md` context) are the same pattern and can be added per repo as the loop matures.

## Loop Engineering Direction

Cflow should evolve from a playbook into a loop-engineering system. Each stage should eventually have:

- Goal: what the stage is trying to accomplish.
- Inputs: required repo/user/context state.
- Action: the bounded thing the agent may do.
- Verifier: objective signal that proves progress.
- Memory: what gets written down for future loops.
- Stop/escalate rule: when to continue, stop, split, or ask the human.

`cflow-status` is the first diagnostic layer in that system: it observes the repo, compares it to [FLOW.md](FLOW.md), and tells the user the next action.

## Starter Prompt

```md
Use Cflow for this task.

Rules:
1. Read cflow/FLOW.md for the canonical stages.
2. Research the task and existing code before editing.
3. Keep the change small and reviewable.
4. Build the minimal working behavior first.
5. Run the relevant tests, lint, typechecks, or browser checks.
6. Open the PR against staging.
7. Use check-pr or greploop after the PR exists.
8. Run cleanup as a separate pass if behavior works but structure is messy.

Task:
<describe the feature or fix>
```
