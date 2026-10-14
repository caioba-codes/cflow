# cflow v3 = pstack, adapted

cflow v3 is [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan (poteto), imported verbatim from `cursor/plugins@d0ef80d` (MIT, see `LICENSE-pstack`). Caio's rule (2026-10-07): **keep it exactly like pstack unless the text is about a tool he doesn't use.** Only those spots change. Wording, structure, principles, playbooks and rigor stay as written.

This file is the mapping every change follows. When pstack updates upstream, re-import and re-apply this table.

## Names

| pstack | cflow v3 | Why |
|---|---|---|
| `poteto-mode` skill, `/poteto-mode` | `cflow` skill, `/cflow` | Caio's repos already point their `AGENTS.md` at `cflow` |
| `poteto-help` | `cflow-help` | same |
| `setup-pstack` | `setup-cflow` | same |
| `poteto-agent` | `cflow-agent` | same |
| "pstack" as the product name | "cflow" | same; credit to poteto stays in README and LICENSE |

Principle skills, playbooks and every other skill keep their names.

## Harness: Cursor → Claude Code / Claude Projects (+ Codex)

| pstack (Cursor) | cflow v3 |
|---|---|
| Cursor, the agents window, the Cursor CLI | Claude Code (CLI, desktop, cloud sessions) and Claude Projects |
| `Task` tool / `Task` subagent | the **Agent** tool (Claude Code subagents) |
| `subagent_type: generalPurpose` | `subagent_type: general-purpose` |
| readonly subagent | `subagent_type: Explore` (read-only) |
| `is_background` / `run_in_background: true` | Agent `run_in_background: true` |
| agent files in a plugin's `agents/` | `~/.claude/agents/<name>.md` (frontmatter `name`, `description`, optional `model`) |
| `AskQuestion` | `AskUserQuestion` in Claude Code; in a Claude Projects thread, the `ask_decision` card |
| Cursor custom mode (option+enter keeps it on every turn); the mode skill's `mode`/`icon`/`color`/`reminder`/`disable-model-invocation` frontmatter | the repo's `AGENTS.md`/`CLAUDE.md` line "load the `cflow` skill first for any build, fix or plan task" (always in context). The `cflow` skill drops the mode-only frontmatter so the model may load it; its `reminder` text moves into the description. Every other skill keeps `disable-model-invocation: true` as in pstack (the `cflow` skill reads them by path) |
| Cursor `/loop` | Claude Code `/loop` (same idea) |
| `~/.cursor/rules/pstack-models.mdc` (`alwaysApply`) | `~/.claude/cflow-models.md`, imported from `~/.claude/CLAUDE.md` with `@cflow-models.md` and from `~/.codex/AGENTS.md` |
| `~/.cursor/projects/<slug>/agent-transcripts` | `~/.claude/projects/<slug>/*.jsonl` |
| Cursor's built-in `create-skill` | the `skill-creator` skill |
| Cursor's built-in `babysit` skill | Claude Code's PR activity subscription (`subscribe_pr_activity`) — cflow's Babysit playbook still owns the behavior |
| Cursor Automations (cloud agents on a schedule/trigger) | Claude Code routines (`create_trigger`) and cloud sessions |
| "coordinator chat" (Orchestrate playbook) | the Claude Projects project chat; each child job is a project thread |
| Bugbot, Cursor's agentic security review | Claude Code Review (GitHub app), `/code-review`, `/security-review` |
| `deslop` from `cursor-team-kit` | the `simplify` skill (`/simplify`) |
| `control-ui` from `cursor-team-kit` | Claude in Chrome (`claude-in-chrome`) for Caio's logged-in browser; Playwright for scripted runs |
| `control-cli` from `cursor-team-kit` | drive the CLI/TUI yourself in a terminal multiplexer (cmux/tmux), capture output |

Integrations that `why` and `recall` discover at runtime (Slack, Linear, Notion, Sentry, Datadog, Databricks, GitHub) stay as written: they are discovered, not assumed.

## Models: Grok/Opus defaults → Caio's subscriptions

Caio has **Claude Max** (Opus 5.5, Fable 5.1, Sonnet 5.5, Haiku) and **ChatGPT/Codex** (GPT-6 Astra, Sol, Luna). Roles follow `~/stuff/cortex/stack/model-fit.md` ("cflow roles"): one Claude builder, a cross-lab reviewer, no Fable/Sonnet/Sol in these roles.

| pstack default | cflow v3 default | How to call it |
|---|---|---|
| `claude-opus-5-5-xhigh` (judgment, prose, hardest tasks) | **Opus 5.5**, effort `xhigh` | Agent tool `model: "opus", effort: "xhigh"` |
| `grok-4.7-xhigh-fast` (code delegates: feature, refactoring, bug-fix, perf, hillclimb) | **Opus 5.5**, effort `xhigh` | Agent tool `model: "opus", effort: "xhigh"` |
| `grok-4.7-xhigh-fast` (fast fan-out: how explorer, why investigators, reflect tooling, swarm workers) | **Opus 5.5**, effort `xhigh` | Agent tool `model: "opus", effort: "xhigh"` |
| Grok as the **second model family** in a panel (arena runners, arena cross-judge pool, architect runners, interrogate reviewers) | **GPT-6 Astra** | `codex exec -m gpt-6-astra -c model_reasoning_effort=<effort>` (read-only sandbox for judges and reviewers), from a Bash call or a subagent that runs it |
| family prefixes `claude-*` / `grok-*` | `claude-*` / `gpt-6-*` | |

Codex can hang silently: smoke it first (`codex exec -m gpt-6-astra "reply ok"` within 60 s). If it fails, run that seat on Opus 5.5 and say so, as pstack does for a rejected slug.

Effort ladder stays pstack's (`max` > `xhigh` > `high` > `medium` > `low`); both Opus 5.5 and Astra accept every step.

Every default runs at `xhigh`, as in pstack (whose defaults are all `xhigh`; Grok's speed came from the model, not a lower effort). The budget question in `/setup-cflow` scales all of them together, so `small` brings everything to `medium`.

## Dropped

- `make-bot-ui` (removed): it is entirely about Cursor's Grok Bot webhook routines, which Caio doesn't use and which have no Claude equivalent.
- The Cursor app-support cache item in the Worktree cleanup playbook.

## Added (not in pstack)

- `explain-diff` (Caio, 2026-10-08): Geoffrey Litt's explain-diff page format (https://gist.github.com/geoffreylitt/a29df1b5f9865506e8952488eac3d524), written once per finished feature. Pages save locally by default; optional `cflow-explain-publish` / `cflow-explain-pending` hooks on PATH publish them and track review. A new feature conversation checks for unread pages and links them as an informational reading list. Unread pages, a missing script, or an unknown result never block work or merges. Shipping and Autopilot-full do not repeat the check as a merge gate. Keep this policy when re-importing upstream. Wired in through two `cflow` triggers and one line in the Multi-phase plan skeleton. pstack's `teach` stays as is: it's the live, quiz-free version.
- `explain-flow` (Caio, 2026-10-08; was `explain-workflow`, moved to cskills 2026-10-10, back into cflow 2026-10-14 so cflow installs on its own): writes a one-page, agnostic "how this workflow works" guide around one worked example, with every step marked human or agent. Its `references/example-cflow.md` is the model answer, and it doubles as the guide for cflow itself.
- `grilling` (Caio, 2026-10-11): Matt Pocock's skill, brought back as an opt-in interview before a playbook, because pstack's few product cards leave fuzzy ideas under-specified. It keeps `disable-model-invocation: true` and runs only when the user asks ("grill me", "grill me first", `/grilling`). Wired in through one `cflow` trigger. Matt's text is unchanged apart from two added sentences: questions go through `AskUserQuestion` or one `ask_decision` card each, and the confirmed brief is handed back to the matched playbook. Keep the trigger and both sentences when re-importing upstream.
- Try-it-yourself-first (Caio, 2026-10-11): an agent sent Caio Supabase dashboard click-steps it could have done with the admin API. One `**Try it yourself before handing the human a step.**` paragraph in the `cflow` skill's Autonomy section and one Pattern bullet in `principle-never-block-on-the-human`: API or CLI first, then browser tools the session has, then the human, and only for an approval, an irreversible step, a secret or data only they have; an ask says what was tried. It narrows pstack's asks and leaves Always pause for irreversible writes untouched. Keep both when re-importing upstream.
