
Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering. Use `AskUserQuestion` in Claude Code, or one `ask_decision` card per question in a Claude Projects thread.

If a *fact* can be found by exploring the codebase, look it up rather than asking me. The *decisions*, though, are mine — put each one to me and wait for my answer.

Do not enact the plan until I confirm we have reached a shared understanding.

When I confirm, write the shared understanding down (the decisions, my answers, and what stays out of scope) as the brief. If this ran inside `/cflow`, hand that brief to the matched playbook and continue it without asking again.
