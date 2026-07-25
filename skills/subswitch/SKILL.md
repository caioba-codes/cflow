---
name: subswitch
description: Keep Cflow workers running across the user's own Claude and Codex subscriptions with Subswitch. Use when setting up or checking account rotation, when a worker hits a session or usage limit, or when a Cflow review/executor must resume on another account.
---

# Subswitch

Subswitch is Cflow's optional local account-continuity runtime. It observes each
enrolled subscription, selects one with headroom, and preserves work across the
switch.

## Find the runtime

Use `$SUBSWITCH_HOME` when set; otherwise use `~/stuff/projects/subswitch`. If
the checkout is missing, clone `https://github.com/Gus1403/subswitch.git` there.

Before installing, repairing, updating, or enrolling accounts, read the
checkout's `AGENTS.md` completely and follow its ordered gates. Treat that file
and the current source as authoritative; do not reproduce its ceremony from
memory.

## Set up or repair rotation

Follow the upstream `AGENTS.md` procedure without skipping gates. Stop at every
human browser-login step and wait for confirmation. Keep enforcement off until
every enrolled account is distinct, usage is readable, the quick doctor passes,
and the dry-run sees every account.

Codex authentication is fragile. Always pin login to an explicit `CODEX_HOME`
or use the upstream relogin helper. Never copy `auth.json` between homes. Never
run `codex logout`. The upstream danger document is mandatory before touching
Codex authentication.

Setup is complete only when the upstream final gate passes: enforcement is on,
account identities are distinct, the Claude switch round-trip succeeds, and the
Codex pointer names either the default home or an authenticated thin home.

## Recover an interrupted Cflow worker

1. Preserve completed sibling work, reports, session ids, and the working tree.
   A rate-limit interruption is infrastructure failure, not a failed verifier
   or review round.
2. Run one daemon tick from the runtime checkout, then inspect its status and
   latest log decisions. Continue only when a known account with headroom is
   active. If every account is red or unknown, report the earliest reset and
   stop.
3. Relaunch only the failed bounded task:
   - Claude workers see a keychain switch shortly after rotation, but a worker
     that already terminated must be started again with the same assignment.
   - Codex keeps credentials for the life of a process. Start a new process
     through the installed shim; resume the recorded session when possible,
     otherwise rerun the exact prompt. The tmux/cmux watcher may do this
     automatically.
4. Keep one writer per branch. Before retrying an executor, prove the prior
   process exited so two accounts cannot continue editing the same branch.

For a cross-model review, retain the successful lab's report and replace only
the rate-limited reviewer. The replacement must still be fresh and blind to the
other report.

Useful checks from the runtime checkout:

```sh
bin/doctor.sh --quick
daemon/subswitchd.py --once
daemon/subswitchd.py --status
tail -30 ~/.config/subswitch/logs/subswitchd.log
```
