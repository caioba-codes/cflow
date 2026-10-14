---
name: explain-flow
description: "Write a one-page guide that teaches someone else how an agent workflow works, built around one worked example: every step from setup to shipped, each marked as the human's or the agent's, plus the commands they will actually type. Use for /explain-flow, 'explain this flow', 'explain my workflow to a friend', 'write a how-it-works doc for <workflow>'."
disable-model-invocation: true
---

# Explain flow

**You write the page a newcomer reads to learn a workflow by example: which steps are theirs, which are the agents', and what they type.** The model answer is `references/example-cflow.md`, written for cflow (it is also cflow's own how-it-works guide). Read it before you write, and match its shape, length and tone.

## Inputs

- **The workflow.** Find its source of truth: the entry skill (for cflow, `skills/cflow/SKILL.md`), the playbooks it routes to, and the setup skill. Read them. Every step on the page must trace to something the workflow actually says. Never describe what you think it should do.
- **The example.** Use the feature the person names. Otherwise pick one realistic, multi-step feature that exercises planning, building, review and shipping. One example for the whole page.
- **The reader.** By default, someone who has never seen the workflow and works in a different repo.

## Rules

1. **Agnostic.** Nothing specific to the author's machines, accounts, repos, people, in-flight PRs or private hosts. Write "your repo", "the app", "your standing orders". The page must work when pasted to a friend. If a step only exists because of the author's setup, drop it or state it generically. One exception: the workflow's own public install source (its clone URL and setup commands) stays, because the reader needs it.
2. **Every step has an owner.** Number the steps and give each a Who column: 🧑 for the human, 🤖 for an agent. Use one table per phase.
3. **Setup comes first, as step 0.** Split it into "once per computer" and "once per repo". Give exact commands for install and configuration (clone, the install script, the setup slash command). These are lettered A, B, C… so the feature steps keep numbers 1, 2, 3….
4. **Then the feature, phase by phase.** Use the workflow's own phase boundaries (for cflow: idea → plan, plan → merged, merged → understood). Bold the human gates, and say for each gate what the human decides and that the agents keep going on reversible work meanwhile, if the workflow says so.
5. **Answer the obvious question up front.** Below the intro, answer the question a newcomer asks first in two or three sentences (for cflow: "do you discuss the feature with the agent first?").
6. **End with two summaries.** First "Your part, all in one place": setup steps, then per-feature steps with their step numbers. Then "Commands you'll actually type": a table of command or phrase, and when to use it.
7. **Plain English.** Short sentences. No long dashes. Name each mechanism once in plain words (for example, "a script-backed skill that starts your app and drives it like a real user"), not by internal jargon alone. Run the prose through the **unslop** skill.
8. **One page.** Aim for the example's length. Cut anything that doesn't change what the reader does.

## Steps

1. Read the workflow's source files and list its phases, gates, setup commands and user-facing commands, each with the file and line it came from.
2. Pick the example, and map every workflow step onto it with concrete example details (what the human types, what the agent checks, which questions only the human can answer).
3. Write the page in the shape of `references/example-cflow.md`.
4. Check it against the rules above, rule 1 first. Search the page for the author's names, hostnames, repo names and PR numbers, and remove any that remain, except the workflow's own install source (rule 1).
5. Save it where the person asks. Otherwise use `docs/how-<workflow>-works.md` in the workflow's repo, or a shared folder when there's no repo. Reply with the path and one line on the example you used.
