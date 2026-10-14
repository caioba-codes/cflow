# How cflow works: shipping a feature from just an idea

cflow is an agent workflow for Claude Code, adapted from Lauren Tan's (poteto) pstack. You give the agents an idea. They plan it, build it, prove it works, review each other's work and merge it. You come in at a few clear points.

This page walks through one example: adding multi-user accounts to an app that today serves only one person. Your repo and feature will differ, but the steps are the same.

**Do you discuss the feature with the agent first?** Not as a separate step. Your first message is the brief. The agent doesn't interview you. It reads the code and runs small tests to settle what it can, then asks you only the few product questions no test can answer.

Legend: 🧑 = you, 🤖 = an agent.

## 0. Setup (first time only)

**Once per computer:**

| # | Who | What happens |
|---|---|---|
| A | 🧑 | Install the skills: `git clone https://github.com/caioba-codes/cflow`, then `cflow/scripts/install.sh`. The script installs the skills for Claude Code and Codex. |
| B | 🧑 | Run **`/setup-cflow`** in any Claude Code session. It detects which models you have, asks one budget question (pick **large**), shows which model does each job (building, judging, the review panels), and asks you to confirm. Then start a new chat so the settings apply. |

**Once per repo:**

| # | Who | What happens |
|---|---|---|
| C | 🧑 | **Say yes to the verification offer.** At the end of `/setup-cflow`, or any time with `/create-verification-skill`, cflow offers to build your repo's verify skill. |
| D | 🤖 | It builds that skill: a script-backed skill that starts your app, drives it like a real user (a browser for a web app, a terminal for a CLI) and captures evidence. It proves the skill works once before handing it over. Every later PR uses it as proof that the change works. This is the setup step that pays off most. |
| E | 🧑 | Add one line to the repo's `AGENTS.md` or `CLAUDE.md`: "load the `cflow` skill first for any build, fix or plan task". This line keeps cflow on for every chat in the repo. Without it, `/cflow` applies to one message at a time. |
| F | 🧑 | Optional: install the **Claude Code Review** GitHub app on the repo. It's an automated reviewer that comments on every PR, and cflow weighs its comments on their merits. |
| G | 🧑 | Try a small task first, the way you'd describe it to a colleague: `/cflow add a --json flag to this command. text output stays byte-identical. verify both.` |

## 1. Idea → plan

| # | Who | What happens |
|---|---|---|
| 1 | 🧑 | You write the idea in your own words: "Make the app multi-user. Each user has their own data and their own connected accounts, with a cheap paid tier." A couple of lines is enough. |
| 2 | 🤖 | **Reading list.** The agent links any unread explainers for you to read when convenient. Unread pages or an unavailable check never block the work or its merges. |
| 3 | 🤖 | It recognizes a multi-PR feature and runs the **Multi-phase plan** playbook. The rule there is that the plan is the deliverable, and nothing gets built yet. |
| 4 | 🤖 | Subagents read the code that matters (where users are identified, where sessions and permissions live, how deploys work) and bring back file pointers and test commands. |
| 5 | 🤖 | **Small throwaway prototypes settle every question a test can answer.** Does row-level security in the database really keep two users apart? Can a request be routed to a per-user worker fast enough? The results, with screenshots, go in the plan. |
| 6 | 🧑 | **The product calls.** These are the questions no test can answer. Each comes as a card with options and a recommendation: "Paid tier: hard budget cap or real billing?", "Can admins read users' conversations?", "Which database?". Expect a handful of them. The agent keeps working on its recommended option while it waits. |
| 7 | 🤖 | It writes the plan: one section per PR. Each PR has its tests, a live proof on the running app, and a performance check, plus who merges it. The PRs that change what users see are marked "review-gated". |
| 8 | 🤖 | It posts the plan and **stops**. |
| 9 | 🧑 | **GO.** This is the one big gate. You can read the plan, but you don't have to. You also choose how it ships: **autopilot-full**, where agents merge each verified PR themselves, or **autopilot-stack**, where they line up a verified chain and you merge it. |

## 2. Plan → merged

| # | Who | What happens |
|---|---|---|
| 10 | 🤖 | The lead agent starts an hourly audit loop over the whole job. It posts to you only when something changed. |
| 11 | 🤖 | One agent per PR, working in parallel. Each builds its PR in small commits, tests behavior (not implementation), and proves the change on the running app with the verify skill. |
| 12 | 🤖 | **Independent review.** On the exact commit, reviewers that didn't write the code (a model from a second AI lab is best) re-run the checks and the live proof, then say PASS or FAIL. A green CI run alone never merges anything. A FAIL goes back to the builder. |
| 13 | 🧑 | **Review-gated PRs only.** For a change users will see (a sign-up page, what the app says to a new user), the agent posts screenshots or a video and you approve. Everything else merges without you. |
| 14 | 🤖 | It merges on a PASS plus green CI, rebased onto main right before the merge. |
| 15 | 🧑 | **Deploys.** A deploy is on cflow's always-ask list, so the agent asks first. After your yes, it deploys and proves the change again in production. |
| 16 | 🧑 | **Other things nobody can undo for you.** Emailing real users, deleting data, force-pushing a shared branch. The agent asks once per action, in one line, with a recommended default. |

## 3. Merged → you understand it

| # | Who | What happens |
|---|---|---|
| 17 | 🤖 | When the feature's last PR lands, the agent writes **one explainer page** with `/explain-diff`. It covers the background, the core idea with small examples and diagrams, a walkthrough of the code, and a 5-question quiz. The final report links it. |
| 18 | 🧑 | You read it, take the quiz, and mark it reviewed. That's how you keep understanding your own codebase without reading every diff. |
| 19 | 🤖 | **Learning loop.** Anything you correct twice, or that a reviewer flags twice, becomes structure (a test, a lint rule, a type), not another note in a doc. |

## Your part, all in one place

- **First time only:** install the skills, run `/setup-cflow`, say yes to the verify skill, add the `AGENTS.md` line, and try one small task.
- **Each feature:**
  1. The idea (step 1).
  2. A few taps on product cards (step 6).
  3. **GO**, plus how it ships (step 9).
  4. Screenshot reviews for user-facing PRs (step 13).
  5. One yes per deploy and per irreversible action (steps 15 and 16).
  6. Reading the explainer and taking the quiz (step 18).

Everything else is the agents'.

## Commands you'll actually type

| Command | When |
|---|---|
| `/setup-cflow` | Once per computer, or to change models or budget |
| `/create-verification-skill` | Once per repo, if you skipped the offer in setup |
| Your idea, in plain words (or `/cflow <idea>` without the `AGENTS.md` line) | Every feature |
| `/cflow-help` | When you're unsure which playbook or skill fits |
| `/explain-diff` | To get an explainer for any PR on demand |
