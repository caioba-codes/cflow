#!/usr/bin/env bash
# sync-skills.sh — compatibility wrapper. Skills now come from two canonical repos (cflow + cskills);
# the aggregate installer lives in cskills. Same flags: --dry-run --prune --check --local-only --host H --pack P
set -euo pipefail
CSKILLS="${CSKILLS_DIR:-$HOME/stuff/projects/cskills}"
[ -x "$CSKILLS/scripts/sync-all-skills.sh" ] || { echo "cskills not found at $CSKILLS — clone github.com/caioba-codes/cskills next to cflow" >&2; exit 1; }
exec "$CSKILLS/scripts/sync-all-skills.sh" "$@"
