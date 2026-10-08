#!/usr/bin/env bash
# publish.sh — ship one explainer page to Caio's M1.
#
#   publish.sh <page.html> --slug <YYYY-MM-DD-repo-feature> --title "<feature>" --repo <owner/repo> [--prs "12 13 14"]
#
# Pushes pages/<slug>/index.html + meta.json to the explain-pages branch of
# [private-repo]. The M1 picks it up within ~10 min (scripts/plans-sync.sh
# → bridge/scripts/explain.py sync): serves it at the URL printed below and
# opens a Notion review task. Re-publishing the same slug replaces the page.
# EXPLAIN_REMOTE overrides the remote (tests; the M1 uses its own origin).
set -euo pipefail
die() { echo "publish.sh: $*" >&2; exit 2; }

PAGE=${1:-}; shift || true
SLUG= TITLE= REPO= PRS=
while [ $# -gt 0 ]; do
  case "$1" in
    --slug) SLUG=$2; shift 2 ;;
    --title) TITLE=$2; shift 2 ;;
    --repo) REPO=$2; shift 2 ;;
    --prs) PRS=$2; shift 2 ;;
    *) die "unknown argument $1" ;;
  esac
done
[ -f "$PAGE" ] || die "page not found: $PAGE"
[[ "$SLUG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9][a-z0-9-]*$ ]] || die "--slug must look like 2026-10-08-lobster-multi-user"
[ -n "$TITLE" ] || die "--title is required"
grep -qi "</body>" "$PAGE" || die "page has no </body>; write a full HTML document"

if [ -z "${EXPLAIN_REMOTE:-}" ]; then
  EXPLAIN_REMOTE=https://github.com/[private-repo].git
  [ -d "$HOME/src/lobster/.git" ] && EXPLAIN_REMOTE=$(git -C "$HOME/src/lobster" remote get-url origin)
fi
PAGE=$(cd "$(dirname "$PAGE")" && pwd)/$(basename "$PAGE")
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
W=$TMP/w
if ! git clone -q --depth 1 --branch explain-pages "$EXPLAIN_REMOTE" "$W" 2>/dev/null; then
  git init -q "$W"
  git -C "$W" checkout -q --orphan explain-pages
  git -C "$W" remote add origin "$EXPLAIN_REMOTE"
  printf '# explain-pages\n\nFeature explainers (cflow explain-diff). Served by the M1 at /explain/. Not code.\n' > "$W/README.md"
fi
mkdir -p "$W/pages/$SLUG"
cp "$PAGE" "$W/pages/$SLUG/index.html"
python3 - "$W/pages/$SLUG/meta.json" "$TITLE" "$REPO" "$PRS" <<'PY'
import json, sys, datetime
path, title, repo, prs = sys.argv[1:5]
now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
try:
    old = json.load(open(path))
except Exception:
    old = {}
json.dump({"title": title, "repo": repo, "prs": prs.split(), "created": old.get("created", now), "updated": now},
          open(path, "w"), indent=1)
PY
git -C "$W" add -A
git -C "$W" -c user.name="${GIT_AUTHOR_NAME:-cflow}" -c user.email="${GIT_AUTHOR_EMAIL:-cflow@example.com}" \
  commit -q -m "explain: $SLUG"
for wait in 2 4 8 16 0; do
  git -C "$W" push -q origin HEAD:explain-pages 2>/dev/null && break
  [ "$wait" = 0 ] && die "push failed"
  sleep "$wait"
  git -C "$W" pull -q --rebase origin explain-pages 2>/dev/null || true
done
echo "https://explain.example.com/explain/$SLUG/"
