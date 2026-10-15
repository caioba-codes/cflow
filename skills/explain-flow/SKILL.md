---
name: explain-flow
description: "Write a one-file HTML page for an agent workflow with two tabs: Get started (prerequisites, then one canned feature step by step, each step marked you or agent) and a one-screen cheat sheet of what the human types or decides. The page opens on Get started until the reader clicks \"I'm set up\", then always on the cheat sheet. Works for any workflow. Use for /explain-flow, 'explain this flow', 'explain my workflow to a friend', 'make a cheat sheet for <workflow>'."
disable-model-invocation: true
---

# Explain flow

**You write the one page someone keeps open next to them for a workflow: first how to get set up and what a feature looks like end to end, then, for every day after, a one-screen cheat sheet of what they type or decide.** The model answer is `references/how-cflow-works.html`, cflow's own page. Copy its structure, CSS and script, and replace the content. Match its length and tone.

## Inputs

- **The workflow.** Default to cflow when the person names none. Find its source of truth: the entry skill (for cflow, `skills/cflow/SKILL.md`), the playbooks it routes to, and the setup skill. Read them. Every step and command on the page must trace to something the workflow actually says.
- **The example.** One canned feature, the same one every time the page is regenerated for that workflow. For cflow it's the comments feature in the model answer. For another workflow, pick one realistic multi-step feature that runs through the workflow's default path, and keep it. Every choice the reader has to make is a step, placed where they make it, with its options listed (cflow: whether to get grilled, and autopilot, both chosen in the first message). Modes nobody has to choose (a written plan) go on the cheat sheet.
- **The reader.** Someone who has never seen the workflow and works in a different repo. Later, the same person who just needs a reminder.

## The page

One self-contained HTML file with two tabs. Keep the model answer's script: it opens on **Get started** until the reader clicks **I'm set up, show my cheat sheet**, then always opens on **Cheat sheet**. "Show setup again" undoes that. Give `FLOW_KEY` a value unique to the workflow.

**Get started tab**

Write it for two readers: an engineer, and a non-technical person who doesn't know what to buy or install. Use the **signal** skill's lens if it's installed.

1. **What you need.** One collapsed row per tool, subscription or kind of model: its icon and name on the row, and a few plain sentences inside: what it does in the workflow, why it's needed, and any companion command ("more than one Claude Max plan, because several agents run at once; `/subswitch` moves them to another account when one hits its limit"). Leave out optional extras and internal skill names. Reuse the model answer's inline SVG icons and draw a simple new one when a tool has none.
2. **Set up.** Numbered steps, as few as possible. Split them by when ("once per computer", "once per project") only if a step really repeats; if the workflow already offers it where needed, fold it into the step that triggers the offer. Each step is one plain line plus its exact command in a copy box. Any "why" goes in the collapsed part. One way in per step, never "say yes when offered, or run X".
3. **One feature, start to finish.** Open with a callout box naming the canned feature ("The feature: Let people comment on posts"), with no line explaining how to read the timeline. Then one timeline, with the workflow's phases as labels on it. Only the human's steps are steps: shaded boxes headed "Step N" plus a short title of a few words ("Talk it out", "Approve the plan"), with a small "← you" on the right, each saying what to do or decide in one sentence. Fold each run of agent steps into one collapsed agent line (a `<details>` with a short summary like "It writes the plan" and a dropdown arrow). Inside, list the skills and playbooks that step runs, one line each saying what it does for this example, and drop agent rows the reader can't act on. Never turn a choice the workflow makes on its own into a step.

End the tab with the **I'm set up, show my cheat sheet** button and nothing else.

**Cheat sheet tab**

A card that fits one screen and prints on one landscape page.

- **The turn.** One column per phase, in order, like the phases on a game card. Under each phase are 1–3 things the **human** types or decides there.
- **Anytime.** The commands the human reaches for between phases, each with a few words on when.
- **Footer.** The human's gates in one line, plus the Print and Show setup again links.

Only commands the human types belong here. Leave out anything only agents run.

## Rules

1. **Agnostic and private.** Nothing about the author's machines, accounts, repos, people, PRs or private hosts. Never state prices, plan counts or spending. Describe the kind of plan, like "more than one Max plan works best". Write "your repo" and "the app". The workflow's own public install command stays.
2. **Plain English.** Short sentences, no long dashes. Name each mechanism once in plain words, not internal jargon alone. Run the prose through the **unslop** skill.
3. **Cut hard.** If a line doesn't change what the reader does, it goes. The cheat sheet must fit one screen at 1280×800.
4. **Self-contained.** Inline CSS and JS, no external requests, light and dark via `prefers-color-scheme`, readable on a phone.
5. **Plain look.** Off-white and black, one small accent color. No gradients, hero sections or marketing copy. It should look like a good README, not a product homepage.

## Steps

1. Read the workflow's source files. List its phases, human gates, setup commands and user-typed commands, each with the file it came from.
2. Map every phase onto the canned example with concrete details.
3. Write the page from `references/how-cflow-works.html`.
4. Check it against the rules, rule 1 first. Search the page for names, hostnames, repo names, PR numbers, prices and plan counts.
5. Open it in a browser if you can. Confirm both tabs, the I'm-set-up memory across a reload, and that the cheat sheet fits one screen.
6. Save it where the person asks. Otherwise save `how-<workflow>-works.html` in the current folder. Reply with the path and a one-line suggestion to open it in a browser.
