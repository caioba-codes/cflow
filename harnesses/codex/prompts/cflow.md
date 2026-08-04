
# Cflow Workflow

Cflow is the operating system for building software with coding agents. The human owns goals, taste, product judgment, and risk decisions. Agents do bounded mechanical work. Verifiers decide whether the loop can advance.

Use this skill as the explanation of the workflow. Use `cflow-status` when you need to inspect the current repo state and decide the next step.

## Canonical Flow

Read [FLOW.md](FLOW.md) for the canonical Cflow stages. Do not invent a second stage list in another skill. If a status, checklist, or loop controller needs step names, it should reference `FLOW.md`.

The short shape is:

1. Understand and research the task.
2. Write the plan; for non-trivial plans, pass the cross-model plan review gate (two rival-lab models check the plan against the real code) before any code is written.
3. Scope a small branch.
4. Implement the minimal behavior.
5. Verify locally with objective checks and by driving the real flow end to end — user-facing changes are graded by a fresh agent that didn't write the code.
6. Open a PR to `staging`.
7. Run the review tier the diff warrants (trivial → CI only; standard → cross-model review; high-stakes → greploop + cross-model; security review when triggered) — capped at two rounds per reviewer.
8. Merge to `staging`; before applying any migration to a shared database, pass the migration gate (cross-model review of the SQL itself, findings reproduced against a throwaway database, explicit `SAFE TO RUN`). Then validate there.
9. Run cleanup as a separate pass when useful.
10. Harden recurring issues into automation (lint/CI/skill/`REVIEW.md`) as a triggered pass.
11. Promote `staging` to `main`.

## Operating Rules

- Keep work PR-sized. Split broad work into stacked branches.
- Research before editing. Read the relevant code, tests, schema, migrations, and any plan/spec the user names.
- Write plans in the two-audience format defined in [PLANS.md](PLANS.md): a plain-language Spec for the human reviewer (which must include a "How it will be built" architecture explanation), a separator, then the agent-facing Plan. The Spec must be readable without opening the code.
- Every plan header declares who implements what in an `Execution:` line, per branch/PR (format in [PLANS.md](PLANS.md)). Default split under the current harness roles: backend/mechanical work → the executor (Codex, headless `codex exec`); taste-sensitive UI (new pages, layout, visual polish, wording) → the designer; routine frontend plumbing → the executor like any other mechanical work. The orchestrator does not implement by default — typing burns the attention it needs for judgment; it writes code only as a declared exception in the `Execution:` line. One writer per branch at a time; the orchestrator owns review gates and merges regardless of assignment.
- Before implementing a non-trivial plan, run the cross-model plan review gate (`plan-review` in `cross` mode): two models from rival labs independently check the plan against the real code — named files and functions exist, steps don't contradict, claimed parallelism is real. Cap: two plan revisions, then the human decides. A plan error caught here costs minutes; after implementation it costs hours.
- Use plan filenames as the implementation-status indicator: `<NNN>-<slug>.md` while any scoped work remains, and `<NNN>-DONE-<slug>.md` only after the entire plan is implemented and validated. Update references when renaming; review approval or one finished PR does not make a multi-part plan `DONE`.
- **Plans and docs land on the trunk, not on a feature branch.** Plans steer every branch, so a plan edit stranded on one of them is invisible to the rest — worst on long-lived integration branches, where it can hide for days behind a stack of PRs. Commit Markdown-only changes (`docs/**`, `*.md`) straight to the integration branch (`staging`), or as a docs-only PR merged immediately. Two carve-outs: a plan **status flip** caused by code landing (the `DONE` rename, ticking an acceptance criterion) rides the code PR so plan and implementation stay atomic; and a docs change that only makes sense alongside its diff (a README for a new module) rides that PR too. Never commit docs to `main` — docs that `main` has and `staging` lacks invert the promotion flow and conflict at the next promote. This only pays off if branches actually pick the update up, so merge the trunk down into long-lived branches regularly (see [FLOW.md](FLOW.md) Stage 2).
- Use `source-code-context` before integrating nontrivial package, SDK, API client, or framework behavior.
- Use the `subswitch` skill when a Claude or Codex worker hits a session/usage limit. Preserve successful sibling work and relaunch only the failed bounded task after rotation; an account-limit interruption does not consume a verifier retry or review round.
- Build the smallest working behavior before cleanup or broad refactors.
- Verify behavior, don't assume it. When a change has a runtime surface, drive the real flow end to end (invoke `verify`) — not just unit checks — before opening the PR.
- The builder never grades its own work. For user-facing changes, end-to-end verification is done by a fresh agent that did not write the code, instructed to prove each acceptance criterion broken — including empty, loading, and error states, mobile widths, and the browser console — not to confirm it works.
- Treat tests, lint, typechecks, browser checks, CI, and review tools as external verifiers.
- Route review effort by the stakes of the diff, not by default (tier detection lives in [FLOW.md](FLOW.md) Stage 6): trivial diffs (docs, renames, config, pure styling) → CI only; standard PRs — including ordinary frontend changes — → cross-model code review only (two rival-lab reviewers, blind, run locally in the background as implementation finishes); high-stakes PRs (big diffs, schema/migrations, auth/data/money surfaces, new public endpoints, new dependencies, architecture-adjacent work) → `greploop` **plus** the cross-model review. Run `security-review` whenever the diff touches auth, data access, external input, permissions, secrets, or money — regardless of tier. Load the repo's `REVIEW.md` criteria when reviewing.
- A review finding only counts if it quotes the offending code verbatim at a real `file:line`. Verify the quote exists where claimed before acting; set aside findings that don't verify — they cannot block a merge. A hallucinated bug cannot produce a real quote from a real file.
- Review loops are capped at two rounds per reviewer per PR. A third round reliably produces only nitpicking. Findings still open after round two go to the orchestrator/human to accept or fix deliberately — the loop does not continue on its own.
- **Never apply a migration to a shared database on a reading.** Every migration gets its own cross-model review immediately before it runs (Stage 7b), separate from the PR review that approved it — the PR gate reviews a diff, this gate reviews the statements about to execute. Require an explicit `SAFE TO RUN` verdict, and reproduce each finding against a throwaway database at the same major version rather than arguing about it. Both times this gate was skipped in practice, the migration contained a defect that would have corrupted live data.
- Never weaken, skip, or delete a test to make it pass. The test caught something real — fix the code instead.
- Open feature/fix PRs against `staging`, not `main`.
- Use `greploop` for full Greptile review loops on high-stakes PRs (per the Stage 6 tiering — not on every PR) and `check-pr` for one-pass PR readiness.
- Run `code-structure-cleanup` as a separate pass after behavior works when the feature left duplicated mechanics or messy structure.
- Tear down the workspace when a PR merges: `git worktree remove` then `git branch -d`, in the same motion as closing the PR. Worktrees live under one durable root (`~/stuff/_worktrees/<repo>-<slug>/`) and exist only when two branches must be open at once — otherwise `git switch`. Sweep leftovers with `scripts/prune-worktrees.sh`, which refuses to touch anything holding uncommitted or unpushed work and detects squash-merged branches that `git branch --merged` cannot see. Details in [FLOW.md](FLOW.md) → "Worktree And Branch Hygiene".
- Encode recurring knowledge as infra (Stage 10, Harden). When the same class of issue is hand-fixed twice, stop fixing instances — write the lint rule, CI check, test, skill, or `REVIEW.md`/`CLAUDE.md` rule that kills the class. Automation is how domain knowledge reaches the next contributor without a prompt.
- Maintain the per-repo conventions when they exist (see below): `REVIEW.md`, `RECOVERY.md`, `MAINTAINER.md`, and a versioned E2E playbook.
- Stop when the loop reaches its success condition, repeats the same failure, exceeds the iteration budget, or needs human product/security judgment.

## Harness Defaults

- Cflow is the single source of truth for skills. Edit canonical skills in `~/stuff/projects/cflow/skills/<name>/` and run `scripts/sync-skills.sh`.
- Codex and Claude both receive the same canonical skill content through sync; prompt adapters are generated.
- Default harness roles — three lanes, one manager:
  - **Orchestrator — Claude.** Planning, plan/Spec conversations, dispatching implementation, PR review gates, merges. It does not write code by default: typing burns the attention it needs for judgment. Plan and design talk happens in the orchestrator session, not the executors'.
  - **Executor — Codex (headless `codex exec`).** Backend, mechanical, and routine frontend plumbing work against a written plan.
  - **Designer — Claude.** Only taste-sensitive UI: new pages, layout, visual polish, wording. Routine frontend work does not qualify — it goes to the executor.
- Route work by how big and how well-defined the task is — not by how hard it is. A tricky problem with clear boundaries goes to a cheap model; a vague problem touching many parts of the system goes to a strong one:
  - Small and fully specified (renames, config, boilerplate, doc edits) → cheapest tier.
  - Well-defined implementation against a clear plan → mid tier.
  - Vague, cross-cutting, open-ended investigation, or browser-driving work → frontier tier.
  - Taste-sensitive UI → the designer, regardless of size.
  Declare the actual model and tier per branch/PR in the plan's `Execution:` line — that line is where model choice lives, not this skill. The orchestrator suggests it and stays frontier for planning and review gates. Start at the cheapest tier that could plausibly one-shot the plan.
- Escalation: when output fails the verifier, redo it with a stronger model immediately, without asking. Judge the output, not the cost of producing it — a cheap first attempt that fails costs one retry; starting expensive can never be undone.
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
