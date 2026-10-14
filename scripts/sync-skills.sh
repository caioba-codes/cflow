#!/usr/bin/env bash
# sync-skills.sh — if cskills is cloned (CSKILLS_DIR, or ~/stuff/projects/cskills), run its aggregate
# installer for both repos (flags: --dry-run --prune --check --local-only --host H --pack P).
# Without cskills, fall back to cflow's own scripts/install.sh.
set -euo pipefail
CSKILLS="${CSKILLS_DIR:-$HOME/stuff/projects/cskills}"
[ -x "$CSKILLS/scripts/sync-all-skills.sh" ] && exec "$CSKILLS/scripts/sync-all-skills.sh" "$@"
exec "$(dirname "$0")/install.sh" "$@"
