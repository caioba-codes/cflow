# Set up cflow

In this page you install the skills, pick which models cflow uses, and run your first task. Setup is one command plus a short conversation.

## Install the skills

In a terminal, clone cflow and run its install script:

```bash
git clone https://github.com/caioba-codes/cflow
cflow/scripts/install.sh
```

The script installs the skills into `~/.claude/skills` and `~/.codex/skills`.

## Pick your models

Run:

```text
/setup-cflow
```

[`/setup-cflow`](../../skills/setup-cflow/SKILL.md) detects the models you have access to, asks for a reasoning budget, shows you each role (code delegates, judgment, the review panels), and asks what you want. Answer the questions. It writes `~/.claude/cflow-models.md`, a small rule imported from `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` that every cflow skill reads.

The defaults run at `xhigh` reasoning, the same as the `large` budget. `unlimited` lifts each model to its highest tier, up to `max`. Opus 5.5 and GPT-6 Astra both go to `max`. `medium` and `small` lower the reasoning and spend fewer tokens.

You only override what you care about. A role with no line in the rule keeps the skill's default. To restore a default, delete that role's line. A rerun of `/setup-cflow` keeps any role whose model differs from the default. When a default changes, a rule written before the change still pins the old default, so delete those role lines, or delete the file, then run `/setup-cflow` again.

You might be wondering how to run a role on your chat's own model. Set a role to `inherit-parent` or `auto` and cflow omits the subagent `model` field, so the subagent inherits your parent chat model. Both values mean the same thing, and neither is a model slug. For a panel role the value is a list, and one subagent runs per entry, so the list length sets the panel size. Setup also configures `swarm workers`, the default model for every `/swarm` worker unless a race names a model for each arm.

## Accept the verification offer, or don't

At the end of setup, `/setup-cflow` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.claude/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. In every other repo, cflow makes the same offer the first time you start a feature there, so there's no per-project setup. You can also run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers it in depth.

If you're new to cflow, say yes. An agent that can check its own work keeps going until the check passes. An agent that can't hands every result back to you to check by hand. Of everything in this guide, the verification skill pays off the most.

After setup, start a new chat. The model rule applies to new sessions.

## Keep the cost in check

cflow spends extra tokens on subagents and review panels. That's the price of the rigor. To spend fewer:

- Rerun `/setup-cflow` and pick a smaller reasoning budget or cheaper models. A strong model in the main chat with cheaper, faster models in the code roles is a good split.
- Set a role to `auto` or `inherit-parent` so it runs on the chat's own model.
- Shorten a panel list. Each entry runs one subagent.
- Save `/cflow` for work that needs rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/cflow add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/cflow` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. cflow stays on for the whole chat, in every repo, because `/setup-cflow` added the line "load the `cflow` skill first for any build, fix or plan task" to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`. Claude Code and Codex both read those files on every turn.

Next: [Route work through `/cflow`](./02-cflow.md).
