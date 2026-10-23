---
name: explain-diff
description: "Write one rich HTML explainer of a finished feature (background, intuition, code walkthrough, quiz), publish it (or put it in the user's Notion), and check which explainers the user hasn't reviewed yet. Use when a feature's last PR lands, for 'explain this diff/PR/feature', and at the start of a new feature conversation (pending check)."
disable-model-invocation: true
---

# Explain diff

**Once agents merge their own PRs, the user stops reviewing every diff, so each finished feature leaves them one page that makes them actually understand it.** Adapted from Geoffrey Litt's `explain-diff-html` skill (https://gist.github.com/geoffreylitt/a29df1b5f9865506e8952488eac3d524, announced at https://x.com/geoffreylitt/status/2072522251300409556). The page format below is his. When it's sent, where it goes, and the review loop are cflow's.

## When

- **A feature is finished.** That means its last PR has merged, been verified, and been deployed if the repo deploys. A multi-PR program that ships three features writes three pages, each one as its feature lands. Write the page, publish it, and put the link in the final report. Don't write one when a thread merely goes idle, because idle can also mean blocked.
- **The user asks** for one on any PR, branch, or diff.
- **A one-PR fix gets no page** unless they ask.

## The pending check (start of a new feature conversation)

At the start of a new feature, list the explainers the user hasn't reviewed, as an informational reading-list check. When a Notion destination is set (see **Notion destination**), they are its database's rows whose review checkbox is unticked, read with the Notion connector. Otherwise run `scripts/pending.sh` (installed at `~/.claude/skills/explain-diff/scripts/pending.sh`): each line is one (`<title><TAB><url>`). Unreviewed pages, a missing script, or an unknown result never block planning, implementation, merges, deployments, or subsequent features. Do not ask for review acknowledgment or repeat the check as a merge gate.

- **Anything pending.** Link each page for the user to read when convenient, then continue the authorized work.
- **`none`.** Say nothing about it.
- **Missing script, an unreachable Notion, or `unknown: ...`.** Report the limitation briefly, then continue the authorized work.

Review tracking is optional. Without a Notion destination or a `cflow-explain-pending` hook on PATH (see Publishing), the check prints `none`.

## Writing the page

Make a rich, interactive explanation of the feature's whole change: every PR in it, read as one diff (`git diff <base-before-the-first-PR>..<merge-of-the-last-PR>`). It has these sections.

- **Background.** Explain the existing system relevant to this change, exploring the surrounding code broadly. We don't know how much the reader already knows, so include a deep background for beginners (note that it can be skipped if the reader is already familiar), then a narrower background directly relevant to the change.
- **Intuition.** Explain the core intuition for the change. Focus on the essence, not the full details. Use concrete examples with toy data, and figures and diagrams liberally.
- **Code.** A high-level walkthrough of the code changes, grouped and ordered so they're easy to follow. Link each PR (`https://github.com/<owner>/<repo>/pull/<n>`) and its verifier verdict, and say how each was proven on the running app.
- **Quiz.** Five medium-difficulty questions that test the reader's knowledge of this change. They should be hard enough that answering needs the substance of the change, but not gotchas. Present them as interactive multiple-choice questions. A click tells the reader whether they were right and gives feedback.

Format:

- **One self-contained HTML file** with its CSS and JavaScript inline. One long page with section headers and a table of contents, and no tabs for the top-level structure. Responsive, so it reads on a phone. Light and dark via `prefers-color-scheme`. It must have a closing `</body>`, so a publish hook can add to the page there.
- **Write with the clarity and flow of Martin Kleppmann**, engaging and in classic style, with smooth transitions between sections. Run the prose through the **unslop** skill.
- **Diagrams.** Pick a small number of diagram families and reuse them to explain different cases. Useful kinds: a very simplified version of the UI the user sees (for UI changes), and a system diagram of data flow between components, with example data.
- **No ASCII diagrams.** Use simple HTML for diagrams and HTML lists for lists. Code blocks use `<pre>`. A custom styled div must have `white-space: pre-wrap`, or the browser collapses its newlines. Before saving, check every code block's CSS has `pre` or `pre-wrap`.
- **Callouts** for key concepts, definitions, and important edge cases.
- **No secrets, tokens, or private data** in examples. The page may be published somewhere other people can read.

Write it outside the code repo, for example `/tmp/<slug>.html`.

## Publishing

```
scripts/publish.sh /tmp/<slug>.html --slug <YYYY-MM-DD>-<repo>-<feature> --title "<Feature in plain words>" --repo <owner/repo> --prs "<n> <n> ..."
```

It prints where the page lives. Put that in the feature's final report as its own line. With a Notion destination, the Notion page is the link the user gets; see **Notion destination**. By default it saves the page to `$EXPLAIN_DIR/<slug>/index.html` (default `~/explainers`) and prints its `file://` path.

To publish somewhere else, put an executable `cflow-explain-publish` on PATH. `publish.sh` passes it the same arguments, and the hook prints the page's URL as its last line. It can upload to a server or static site, open a review task, or anything else. A matching `cflow-explain-pending` hook feeds the pending check. If a hook fails, say in the report that publishing failed and attach the HTML instead.

## Notion destination

The user can make Notion the place their lessons live: their instructions (`CLAUDE.md`, `AGENTS.md`, project instructions or memory), or an installed skill named `explain-destination`, name a Notion database for explainers. Keep it in a skill when the user works from cloud sessions too, since those can't read files on their machine; the skill's name is the contract. Read that skill or instruction before publishing: it says which properties to fill and which checkbox means "reviewed". Without a named database, skip this section and don't ask.

With a destination set, every explainer becomes one page in that database, written with the Notion connector or API, from whatever machine the session runs on. It is a page to read, not a task: no checklist items, due dates or reminders. Leave the review checkbox unticked; the user ticks it. Fetch the database first and fill its title property with the page's title, plus the properties the destination names.

Run `publish.sh` too. When it prints an `http(s)` URL, put it in the page's first line and in the property the destination names for it. A `file://` path from a machine the user isn't on goes nowhere, so leave it out. The final report links the Notion page. If the Notion connector is missing or needs authorization, say so in the report with what the user must connect, and attach the HTML instead.

The Notion page is a rewrite for reading on a phone in the Notion app, not a paste of the HTML:

- **Same sections, same order, same prose.** Keep the substance; drop only what Notion can't show.
- **Headings and short paragraphs.** `##` for sections, `###` for subsections, paragraphs of two to four sentences. A one-line summary under each section heading.
- **Callouts** for the key ideas, definitions and edge cases the HTML marks as callouts.
- **Diagrams** become a Mermaid code block when it's a flow between components (Notion renders it), or a numbered list of steps with the example data inline. Never an image of text, never ASCII art.
- **Tables** of at most three narrow columns; wider ones become a bulleted list per row.
- **Code** in code blocks with the language set, kept short; long listings go in a toggle.
- **Long detail** (beginner background, per-file notes) goes in toggles so the page scrolls fast.
- **Quiz:** each question as a numbered item with its options, and the answer with its explanation inside a toggle under it.
- **Links** to PRs, files and sources stay as links.

The same privacy rule applies: no secrets, tokens or private data.
