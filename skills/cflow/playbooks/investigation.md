### Investigation

**You own the answer. Plan, route, write.**

Investigation requests are read-only. They produce a cited explanation or a recommendation, not a code change.

A "should we do X or Y" asked mid-conversation is a discussion, not an Investigation. Answer it under cflow's Discussions rule: your pick and the one reason it wins, then hand the turn back. Run this playbook only when the operator asks for a write-up or the answer needs research they can't follow in chat.

1. Route through the **how** skill. For motivation questions, also route through the **why** skill.
2. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only investigation`.
3. Produce the `how`-shaped output (Overview / Key Concepts / How It Works / Where Things Live / Gotchas), or a recommendation with a tradeoffs table if the request is a decision between alternatives.
4. Apply the **unslop** skill to the reply.

No PR, no babysit, no `architect` unless the investigation precedes a code change. If it does, hand back to the user and re-route to Bug fix or Feature.

**Reply:** the investigation output. For "are we sure?" answers, include your real judgment with reasons. Push back if the premise is wrong (see Autonomy).
