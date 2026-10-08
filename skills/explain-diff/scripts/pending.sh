#!/usr/bin/env bash
# pending.sh — explainers Caio has not reviewed yet, one per line:
#   <title><TAB><url>
# Prints "none" when nothing is pending and "unknown: <why>" when the list
# can't be read. Always exits 0. The list is pending.json on the explain-pages
# branch of [private-repo], which the M1 refreshes from Notion every
# ~10 min (a review marked in the last few minutes may still show).
REMOTE=${EXPLAIN_REMOTE:-}
if [ -z "$REMOTE" ]; then
  REMOTE=https://github.com/[private-repo].git
  [ -d "$HOME/src/lobster/.git" ] && REMOTE=$(git -C "$HOME/src/lobster" remote get-url origin)
fi
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
if ! err=$(git clone -q --depth 1 --filter=blob:none --no-checkout --branch explain-pages "$REMOTE" "$TMP/w" 2>&1); then
  case "$err" in
    *"not found in upstream"*|*"Remote branch"*) echo none ;;
    *) echo "unknown: can't read $REMOTE (${err%%$'\n'*})" ;;
  esac
  exit 0
fi
json=$(git -C "$TMP/w" show HEAD:pending.json 2>/dev/null) || { echo none; exit 0; }
PENDING_JSON=$json python3 - <<'PY'
import json, os
rows = json.loads(os.environ["PENDING_JSON"]).get("pending") or []
print("\n".join(f"{r.get('title') or r['slug']}\t{r['url']}" for r in rows) or "none")
PY
exit 0
