---
name: setup-cflow
description: Configure which models cflow uses per role and at what reasoning budget, and unblock the project so agents run requests end to end (permission rules for the tools it uses, auto mode trust, a signed-in browser). Use for /setup-cflow, "configure cflow models", "cflow budget", changing cflow's model choices, or agents stopping on permission prompts or auto mode blocks.
---

# Setup cflow

Write `~/.claude/cflow-models.md`, an always-imported rule (from `~/.claude/CLAUDE.md` via `@cflow-models.md`, and from `~/.codex/AGENTS.md`) that sets cflow's model per role. Then unblock the project (step 7) so agents stop only at cflow's own gates.

## Steps

### 1. Detect available models

Enumerate the models you can pass as the Agent tool's `model` in this session (`opus`, `sonnet`, `haiku`, `fable`). That is the dependable source. Add the Codex models `codex exec` accepts (`gpt-6-astra`, `gpt-6-sol`, `gpt-6-luna`), confirming each with a smoke prompt (`codex exec -m <model> "reply ok"` answering within 60 s). Each detected model with each effort on the ladder in step 3 is a detected slug, written `<model>-<effort>` (`opus-xhigh`, `gpt-6-astra-xhigh`). If you cannot detect any, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available. The aliases `inherit-parent` and `auto` are always valid even though they are not detected slugs.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below. If `~/.claude/cflow-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer AskUserQuestion (in a Claude Projects thread, the `ask_decision` card) over free text. Offer these four options with these exact labels, and name the current budget when the rule records one. With no rule, say that `large` matches the skill defaults.

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by family, list, or alias (`inherit-parent`, `auto`). `unlimited`, `large`, `medium`, and `small` set the effort token of every real slug, panel entries included, to `max`, `xhigh`, `high`, or `medium`. The effort token is the last token, on the ladder `max` > `xhigh` > `high` > `medium` > `low`. If the result is not a detected slug, use the same family's detected slug with the highest effort at or below the target, else mark the role as needing a choice. `inherit-parent` and `auto` do not change. So `unlimited` turns `opus-xhigh` into `opus-max` and `gpt-6-astra-xhigh` into `gpt-6-astra-max`. `large` keeps every default. `small` turns `opus-xhigh` and `gpt-6-astra-xhigh` into `opus-medium` and `gpt-6-astra-medium`.

**(c) Show the roles and confirm.** Show every role with its model, marking any real slug not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model) as the options. Prefer AskUserQuestion over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Write `~/.claude/cflow-models.md` with a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels cflow uses. Overwrite the whole file so re-runs stay idempotent. Then make sure it is imported: `~/.claude/CLAUDE.md` needs the line `@cflow-models.md`, and `~/.codex/AGENTS.md` needs a line pointing at `~/.claude/cflow-models.md`. Add either line if missing. Also add the line `Load the cflow skill first for any build, fix or plan task.` to both files if missing. It keeps cflow in context on every turn in every repo, so nobody has to add it per project. Shape:

```
# cflow model configuration. One line per role. Delete a line to fall back to the skill default.
# A value is `<model>-<effort>`: `opus`, `sonnet`, `haiku`, `fable` go to the Agent tool as `model` with the effort as `effort`; `gpt-6-*` runs as `codex exec -m <model> -c model_reasoning_effort=<effort>`, split at the last `-` (`gpt-6-astra-xhigh` → `-m gpt-6-astra -c model_reasoning_effort=xhigh`).
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Agent `model`). Alias entries in a panel list still count toward its fan-out.
# budget: large (xhigh)
feature, refactoring: opus-xhigh
bug-fix: opus-xhigh
perf-issue: opus-xhigh
hillclimb: opus-xhigh
judgment and prose: opus-xhigh
hardest tasks: opus-xhigh
how explorer: opus-xhigh
how explainer: opus-xhigh
why investigators: opus-xhigh
why synthesizer: opus-xhigh
reflect tooling: opus-xhigh
reflect judgment, divergent, synthesizer: opus-xhigh
arena runners: opus-xhigh, gpt-6-astra-xhigh
arena cross-judge pool: opus-xhigh, gpt-6-astra-xhigh
swarm workers: opus-xhigh
architect runners: opus-xhigh, gpt-6-astra-xhigh
interrogate reviewers: opus-xhigh, gpt-6-astra-xhigh
```

### 6. Confirm

Tell the user the rule was written and that it applies to new sessions. Re-running this skill updates it, and step 7 again.

### 7. Unblock the project

Agents should carry a request end to end and stop only at cflow's own gates: the operator's merge (none under Autopilot-full) and **Always pause**. Permission prompts, auto mode blocks and browser steps handed to the operator are none of those. Run this from the project's root, show every change as a diff, and write only after the operator's yes. On a re-run, merge into what is there and never drop the operator's own entries.

**(a) Find the tools.** From the repo: `fly.toml` means `fly`, `vercel.json` or `.vercel/` means `vercel`, `supabase/` means `supabase`, Stripe in code or env names means `stripe`, Tailscale or ssh hosts in scripts mean `tailscale` and `ssh <host>`, a Dockerfile means `docker`, plus the package manager's test and build commands and `gh`. From history: search this machine's transcripts for the project (`~/.claude/projects/<project-slug>/*.jsonl`) for denied or auto-mode-blocked calls and for steps handed to the operator ("type", "run this", "click", "open"), and add the tools and systems they name. Keep a tool only when `command -v` finds it or the repo clearly uses it.

**(b) Repo allow rules.** Merge one narrow rule per tool into `.claude/settings.json` `permissions.allow`, such as `Bash(fly *)`, `Bash(vercel *)`, `Bash(stripe *)`. Never `Bash(*)` or an interpreter wildcard, which auto mode drops anyway. Add `permissions.deny` rules for commands that destroy data or accounts (deleting an app, volume or project, resetting a database, `vercel remove`) and anything the project's docs mark as never. Land it as a PR so every machine gets it. Cloud sessions apply these rules only when the cloud project or session has exactly one repository. If it has more, say so in one line: the rules then reach only sessions on the operator's machines.

**(c) Auto mode trust on this machine.** Auto mode reads `autoMode` only from user settings (`~/.claude/settings.json`), managed settings or `--settings`, never from the repo. Merge into the user file:

- `autoMode.environment`: `"$defaults"` plus one entry per system the project owns, by name (GitHub owner, Fly apps, Vercel project, Supabase project ref, Stripe account, tailnet hosts), so the classifier treats them as the operator's own.
- `autoMode.allow`: `"$defaults"` plus using those tools against those systems for reads, logs, secrets, tests and deploys to test targets; and, after the operator asks for full autopilot, merging that program's PRs once an independent verifier PASS covers the head.

Keep `"$defaults"` in every list and never edit `hard_deny`. Production deploys stay blocked by the classifier and by **Always pause**, and the operator's words for that deploy clear both. Run `claude auto-mode critique` on the result and fix what it flags. Auto mode blocks an agent from editing its own settings file even with the operator's OK, and it treats staging the merged file as the same edit. So get the operator's OK to stage it, write it to a path that survives a reboot (not a temp dir), and hand the operator one command that backs up `~/.claude/settings.json` and copies the new file over it. Each machine that runs agents for the project needs its own run of this step. Cloud sessions read no user settings, so only (b) and the organization's server-managed settings reach them. Say so in one line if the operator uses cloud sessions.

**(d) A browser signed in as the operator.** **Try it yourself** needs one. On a machine with Chrome, check that Claude Code is logged in with claude.ai (an API key turns Chrome off), the Claude in Chrome extension is installed on the same organization, and `/chrome` is set to **Enabled by default**. Ask the operator to pick that setting if you can't. Then open each dashboard the project uses, from (a), in a new tab and read whether it is signed in. For each one that is not, open its login page in a tab and leave it there. Never type the operator's passwords. Ask the operator to sign in once in those tabs. That is the only step here that needs them, and their sign-ins then stay.

### 8. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever cflow is installed: workspace, user, or plugin). On no, move on without pushing.
