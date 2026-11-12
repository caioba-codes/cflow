---
name: setup-cflow
description: Configure which models cflow uses per role and at what reasoning budget, and unblock the project so agents run requests end to end (permission rules for the tools it uses, auto mode trust, a signed-in browser, the cflow rule in each repo and Claude Project so cloud sessions follow it). Use for /setup-cflow, "configure cflow models", "cflow budget", changing cflow's model choices, or agents stopping on permission prompts or auto mode blocks, or cloud threads not following cflow.
---

# Setup cflow

Write `~/.claude/cflow-models.md`, an always-imported rule (from `~/.claude/CLAUDE.md` via `@cflow-models.md`, and from `~/.codex/AGENTS.md`) that sets cflow's model per role. Then unblock the project (step 7) so agents stop only at cflow's own gates, in cloud sessions and Claude Projects too.

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

Write `~/.claude/cflow-models.md` with a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels cflow uses. Overwrite the whole file so re-runs stay idempotent. Then make sure it is imported: `~/.claude/CLAUDE.md` needs the line `@cflow-models.md`, and `~/.codex/AGENTS.md` needs a line pointing at `~/.claude/cflow-models.md`. Add either line if missing. Also add the lines `Load the cflow skill first for any build, fix or plan task.` and `Default to short replies: lead with the answer in a few lines, and add detail only when asked.` to both files if missing. They keep cflow and concise replies in effect on every turn in every repo, so nobody has to add them per project. Shape:

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

Agents should carry a request end to end and stop only at cflow's own gates: the operator's merge (none under Autopilot-full) and **Always pause**. Permission prompts, auto mode blocks (a deploy of the operator's own app flagged as a production push is the usual one) and browser steps handed to the operator are none of those. Run this from the project's root, show every change as a diff, and write only after the operator's yes. On a re-run, merge into what is there and never drop the operator's own entries.

**(a) Find the tools.** From the repo: `fly.toml` means `fly`, `vercel.json` or `.vercel/` means `vercel`, `supabase/` means `supabase`, Stripe in code or env names means `stripe`, Tailscale or ssh hosts in scripts mean `tailscale` and `ssh <host>`, a Dockerfile means `docker`, plus the package manager's test and build commands and `gh`. From history: search this machine's transcripts for the project (`~/.claude/projects/<project-slug>/*.jsonl`) for denied or auto-mode-blocked calls and for steps handed to the operator ("type", "run this", "click", "open"), and add the tools and systems they name. Also note from that history: MCP tools that were blocked or that the operator had to allow by hand (`mcp__<server>__<tool>`), `sudo` password prompts, and accounts an agent couldn't reach because no connector was signed in (a second mail account, a calendar). On a machine that runs agents for several projects, search every project's transcripts, since the same stops repeat across them. Keep a tool only when `command -v` finds it or the repo clearly uses it. Also list the project's deploy and restart entry points (`scripts/deploy*`, `bin/deploy*`, `scripts/*restart*`, a `deploy` target in a Makefile or package scripts, `fly deploy`, `vercel --prod`, an `ssh <host> '<restart command>'` seen in history) and the targets each one reaches (ssh/scp/rsync hosts, services, apps, projects).

**(b) Routine deploys.** For the operator's own targets (their machines, tailnet hosts, personal apps nobody else depends on) a deploy is undone by the next deploy, and a restart of a service there is undone by the next restart. Stopping on them is the most common auto mode block. Ask once, listing each entry point with its targets: "Let agents run these deploys and restarts without asking?" Recommend yes for the operator's own targets and no for anything with other users or customers. A yes covers that entry point in (c), (d) and (e). A no leaves it to the classifier and **Always pause**.

**(c) Repo allow rules.** A command that matches a `permissions.allow` rule runs without the classifier. Auto mode drops the broad ones (bare `Bash`, `Bash(*)`, interpreter wildcards like `Bash(python*)`, `npm run *`-style run commands, `Agent`, `Monitor`), so a settings file that relies on them still stops on every shell command. Name each one you find and replace it with narrow rules. Merge one narrow rule per tool into `.claude/settings.json` `permissions.allow` (`.claude/settings.local.json` when the folder is not a git repo), such as `Bash(fly *)`, `Bash(vercel *)`, `Bash(stripe *)`. Do the same for each MCP server the project uses (its `.mcp.json`, the plugins it enables, and the MCP tools from (a)): one `mcp__<server>__<tool>` rule per tool that reads or makes a change the next call can undo, and `mcp__<server>__*` only when the server has no tool that deletes or destroys. A server that runs on the operator's machine only goes in the user settings file from (d) instead. For each deploy entry point cleared in (b), add one rule per form an agent writes it in, relative to where sessions start and to the script's own folder: `Bash(sh scripts/deploy.sh *)`, `Bash(bash scripts/deploy.sh *)`, `Bash(./scripts/deploy.sh *)`, plus `Bash(make deploy *)` when that is the entry point (auto mode may drop package-manager run rules like `npm run deploy`, so (d) covers those). A leading `cd <dir> &&` inside the working directory needs no rule of its own. Never a folder wildcard like `Bash(./scripts/*)`: an agent could write a new script there and run it unchecked. Add `permissions.deny` rules for commands that destroy data or accounts (deleting an app, volume or project, resetting a database, `vercel remove`) and anything the project's docs mark as never. Land it as a PR so every machine gets it. Cloud sessions apply these rules only when the cloud project or session has exactly one repository. If it has more, say so in one line: the rules then reach only sessions on the operator's machines.

**(d) Auto mode trust on this machine.** Auto mode reads `autoMode` only from user settings (`~/.claude/settings.json`), managed settings or `--settings`, never from the repo. Merge into the user file:

- `autoMode.environment`: `"$defaults"` plus one entry per system the project owns, by name (GitHub owner, Fly apps, Vercel project, Supabase project ref, Stripe account, tailnet hosts), so the classifier treats them as the operator's own.
- `autoMode.allow`: `"$defaults"` plus using those tools against those systems for reads, logs, secrets, tests and deploys to test targets; and, after the operator asks for full autopilot, merging that program's PRs once an independent verifier PASS covers the head.

- For each deploy cleared in (b), one `autoMode.allow` entry naming the project, its targets and its entry points, such as `"Deploying the blog to home-server (scripts/deploy.sh, or scp/ssh to home-server) is allowed: the operator's own single-user machine, cleared as a standing deploy, and the next deploy undoes it"`. Allow entries override the classifier's **Production Deploy** soft block, so this also covers deploys an agent writes by hand, which the rules in (c) miss.

Keep `"$defaults"` in every list and never edit `hard_deny`. Deploys not cleared in (b) stay blocked by the classifier and by **Always pause**, and the operator's words for that deploy clear both. Run `claude auto-mode critique` on the result and fix what it flags.

Apply it without handing the operator a command. Auto mode never lets an agent write its own settings file, nor the file a symlinked one points to, so the change goes through a review the operator does once per change:

- **Settings in a dotfiles repo** (`~/.claude/settings.json` is a symlink into a git checkout with a remote). Make the change as a PR to that repo, from a fresh clone or a cloud session rather than the checkout the symlink points to. Auto mode blocks writing even that copy as **Self-Modification** unless the operator's own message names the edit, and a general "full autopilot" doesn't count. So batch every settings change from this run into one PR, show the entries, and ask once for a message naming the file and each change (for example `Edit claude/.claude/settings.json in <owner>/dotfiles: allow <x>, allow <y>. Open the PR.`). Never route around the block with another tool or file. The operator reviews and merges it; never merge it yourself, even under full autopilot, because a self-merged settings PR is an agent widening its own permissions. If the full-autopilot merge entry in `autoMode.allow` doesn't already exclude PRs that change the settings file, add that exclusion in the same PR. The machine picks up the merge on its own: offer once to add a login job (a launchd agent on macOS, a systemd user timer on Linux) that runs `git -C <checkout> pull --ff-only` every 15 minutes and leaves a dirty or diverged checkout alone. Installing that job is itself a persistence change, so it needs the operator's yes like any other change in this step. Then this route needs one merge per settings change and nothing typed.
- **No dotfiles repo.** Offer to make one (a private repo with the settings file, symlinked back), since that turns every later settings change into a PR. If the operator declines, write the merged file to a path that survives a reboot and hand them one command that backs up `~/.claude/settings.json` and copies the new file over it.

Each machine that runs agents for the project needs this, and a shared dotfiles repo covers every machine that pulls it. Cloud sessions read no user settings, so only (c) and the organization's server-managed settings reach them. Say so in one line if the operator uses cloud sessions.

**(e) Record the routine deploys.** Add a `Routine deploys` line to the project's `CLAUDE.md` naming each entry point cleared in (b) and its targets, such as `Routine deploys (run without asking): scripts/deploy.sh to home-server; scripts/restart.sh on home-server.` cflow's **Always pause** reads it, and the classifier reads `CLAUDE.md` too.

**(f) A browser signed in as the operator.** **Try it yourself** needs one. On a machine with Chrome, check that Claude Code is logged in with claude.ai (an API key turns Chrome off), the Claude in Chrome extension is installed on the same organization, and `/chrome` is set to **Enabled by default**. Ask the operator to pick that setting if you can't. In the extension's settings, the permission mode should be **Automatically approve**, so safety checks review each action instead of the operator; ask the operator to pick it if you can't. Then open each dashboard the project uses, from (a), plus the operator's own infrastructure accounts named in (d) (network admin such as Tailscale, DNS, cloud consoles, the code host), in a new tab and read whether it is signed in. For each one that is not, open its login page in a tab and leave it there. Never type the operator's passwords. Ask the operator to sign in once in those tabs, and to choose **Always allow actions on this site** the first time Claude acts on each. Those are the only steps here that need them, and they stay. Claude in Chrome still asks before changing permission or access settings on a site, granting an authorization, or entering sensitive information, in every mode. Say in one line which planned browser steps fall under that, so the operator expects them.

**(g) Cloud sessions and Claude Projects.** Step 5's lines live in `~/.claude` and `~/.codex` on this machine, so cloud sessions never load them: a cloud session sees only the repo it clones and, in a Claude Project, the project's instructions. Carry the rule to both.

- **Repo.** Add these lines to the repo's `CLAUDE.md` (and to `AGENTS.md` when it holds the rules rather than pointing at `CLAUDE.md`), creating the file if missing and skipping lines already there: `Load the cflow skill first for any build, fix or plan task.` and `Never ask <operator> to run a command or click through a site; use a Remote Control session on <machine> or Claude in Chrome instead. Don't type their secrets; open the page so they only paste them.` Fill in the operator's name and the machine their Remote Control sessions run on, and ask once if you can't tell. Land it in the PR from (c). In a Claude Project, do the same for every repository the project lists, one PR per repo. The cflow skill must also reach cloud sessions (account skills or a plugin). If `cflow` isn't in a cloud session's skill list, say so in one line.
- **Claude Project instructions.** When this runs inside a Claude Project, every thread should get the rule from the project's instructions. Check them first (they are in the session context) and stop if they already apply cflow. A thread can't edit them, so a thread sends the coordinator one `message_coordinator` asking it to add this line, with the operator's message attached: `Apply cflow (the /cflow skill) in every thread. Never ask <operator> to run a command or click through a site; use a Remote Control session on <machine> or Claude in Chrome instead. Threads don't type secrets for them, but can open the page so they only paste them.` The coordinator adds it itself. If neither can, give the operator the line and a `[Project settings](#project-settings/instructions)` link, as the one paste this step needs from them. Outside a Claude Project, skip this and say in one line that rerunning `/setup-cflow` inside a project adds it there.

**(h) Installs that need root.** If (a) found `sudo` password prompts (installers that brew casks or `.pkg` files run, for example), offer once a sudoers drop-in on that machine for exactly those commands with `NOPASSWD`, such as `/usr/sbin/installer`. Recommend no on a machine other people use or that holds other people's data. Say plainly that it lets any agent on that machine run that command as root without a password. Creating it needs the operator's password once (`sudo visudo -f /etc/sudoers.d/<name>`), so hand them that single command with the exact file contents. On no, agents keep stopping at those installs, and an agent asks for the password step only when it reaches one.

**(i) Connectors.** For each account from (a) an agent couldn't reach, offer its connector once (in a Claude Project, the `suggest_connectors` card). Signing in is the operator's step, once.

### 8. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever cflow is installed: workspace, user, or plugin). On no, move on without pushing.
