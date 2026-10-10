---
name: explain-diff
description: "Write one rich HTML explainer of a finished feature (background, intuition, code walkthrough, quiz), publish it to Caio's M1 at /explain/, and check which explainers he hasn't reviewed yet. Use when a feature's last PR lands, for 'explain this diff/PR/feature', and at the start of a new feature conversation (pending check)."
disable-model-invocation: true
---

# Explain diff

**Caio stops reviewing every diff once agents merge their own PRs, so each finished feature leaves him one page that makes him actually understand it.** Adapted from Geoffrey Litt's `explain-diff-html` skill (https://gist.github.com/geoffreylitt/a29df1b5f9865506e8952488eac3d524, announced at https://x.com/geoffreylitt/status/2072522251300409556). The page format below is his. When it's sent, where it goes, and the review loop are cflow's.

## When

- **A feature is finished.** That means its last PR has merged, been verified, and been deployed if the repo deploys. A multi-PR program that ships three features writes three pages, each one as its feature lands. Write the page, publish it, and put the link in the final report. Don't write one when a thread merely goes idle, because idle can also mean blocked.
- **Caio asks** for one on any PR, branch, or diff.
- **A one-PR fix gets no page** unless he asks.

## The pending check (start of a new feature conversation)

At the start of a new feature, run `scripts/pending.sh` (installed at `~/.claude/skills/explain-diff/scripts/pending.sh`) as an informational reading-list check. Each line is an explainer Caio hasn't reviewed (`<title><TAB><url>`). Unreviewed pages, a missing script, or an unknown result never block planning, implementation, merges, deployments, or subsequent features. Do not ask for review acknowledgment or repeat the check as a merge gate.

- **Anything pending.** Link each page for Caio to read when convenient, then continue the authorized work.
- **`none`.** Say nothing about it.
- **Missing script or `unknown: ...`.** Report the limitation briefly, then continue the authorized work.

Reviewed means the page's Notion task is Done. Caio marks it with the bar at the bottom of the page or in Notion. The list lags by up to ~10 minutes.

## Writing the page

Make a rich, interactive explanation of the feature's whole change: every PR in it, read as one diff (`git diff <base-before-the-first-PR>..<merge-of-the-last-PR>`). It has these sections.

- **Background.** Explain the existing system relevant to this change, exploring the surrounding code broadly. We don't know how much the reader already knows, so include a deep background for beginners (note that it can be skipped if the reader is already familiar), then a narrower background directly relevant to the change.
- **Intuition.** Explain the core intuition for the change. Focus on the essence, not the full details. Use concrete examples with toy data, and figures and diagrams liberally.
- **Code.** A high-level walkthrough of the code changes, grouped and ordered so they're easy to follow. Link each PR (`https://github.com/<owner>/<repo>/pull/<n>`) and its verifier verdict, and say how each was proven on the running app.
- **Quiz.** Five medium-difficulty questions that test the reader's knowledge of this change. They should be hard enough that answering needs the substance of the change, but not gotchas. Present them as interactive multiple-choice questions. A click tells the reader whether they were right and gives feedback.

Format:

- **One self-contained HTML file** with its CSS and JavaScript inline. One long page with section headers and a table of contents, and no tabs for the top-level structure. Responsive, so it reads on a phone. Light and dark via `prefers-color-scheme`. It must have a closing `</body>`, because the M1 adds its review bar there.
- **Write with the clarity and flow of Martin Kleppmann**, engaging and in classic style, with smooth transitions between sections. Run the prose through the **unslop** skill.
- **Diagrams.** Pick a small number of diagram families and reuse them to explain different cases. Useful kinds: a very simplified version of the UI the user sees (for UI changes), and a system diagram of data flow between components, with example data.
- **No ASCII diagrams.** Use simple HTML for diagrams and HTML lists for lists. Code blocks use `<pre>`. A custom styled div must have `white-space: pre-wrap`, or the browser collapses its newlines. Before saving, check every code block's CSS has `pre` or `pre-wrap`.
- **Callouts** for key concepts, definitions, and important edge cases.
- **No secrets, tokens, or private data** in examples. The page lives on a branch of `[private-repo]`.

Write it outside the code repo, for example `/tmp/<slug>.html`.

## Publishing

```
scripts/publish.sh /tmp/<slug>.html --slug <YYYY-MM-DD>-<repo>-<feature> --title "<Feature in plain words>" --repo <owner/repo> --prs "<n> <n> ..."
```

It prints the page's URL (`https://explain.example.com/explain/<slug>/`). Within ~10 minutes the M1 serves it and opens a Notion Checklist task for Caio, "Review explainer: <title>", with the link. Put the URL in the feature's final report as its own line. Before that, the link 404s, so say it goes live within ~10 minutes.

`publish.sh` needs push access to `[private-repo]`. In a Claude Code cloud session without it, add the repo (`add_repo`) or say in the report that publishing failed and attach the HTML instead.
