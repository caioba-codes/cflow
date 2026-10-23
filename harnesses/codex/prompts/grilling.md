
Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Before the first round, post a short **opener**: the idea you have in mind, in a few plain sentences. Say what it is for the user of the product, what already exists and what would change, and where it would live (the screens or routes, the files or modules, the tables or data it reads and writes). Ground it in what you read, not in guesses. Keep it under ten lines so the user can correct the premise before answering anything. Then start the rounds, in the same message or the next.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

Post each round as one message (in a Claude Projects thread, one `reply`), so the user can answer by number ("1 yes, 2 the second option, 3 no, here's why").

When the user confirms, write the shared understanding down (the decisions, the user's answers, and what stays out of scope) as the brief. If this ran inside `/cflow`, hand that brief to the matched playbook and continue it without asking again.
