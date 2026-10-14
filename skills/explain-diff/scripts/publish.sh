#!/usr/bin/env bash
# publish.sh — save one explainer page and, if configured, publish it.
#
#   publish.sh <page.html> --slug <YYYY-MM-DD-repo-feature> --title "<feature>" [--repo <owner/repo>] [--prs "12 13 14"]
#
# Saves <slug>/index.html + meta.json under $EXPLAIN_DIR (default ~/explainers) and prints
# where the page lives. If an executable `cflow-explain-publish` is on PATH, it is called
# with the same arguments instead, and its last output line is the page's URL. That hook
# is how you publish to your own host (a server, a static site, a Notion task, ...).
set -euo pipefail
die() { echo "publish.sh: $*" >&2; exit 2; }
if command -v cflow-explain-publish >/dev/null; then exec cflow-explain-publish "$@"; fi

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
[[ "$SLUG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9][a-z0-9-]*$ ]] || die "--slug must look like 2026-10-08-myapp-multi-user"
[ -n "$TITLE" ] || die "--title is required"
grep -qi "</body>" "$PAGE" || die "page has no </body>; write a full HTML document"

DIR="${EXPLAIN_DIR:-$HOME/explainers}/$SLUG"
mkdir -p "$DIR"
cp "$PAGE" "$DIR/index.html"
python3 - "$DIR/meta.json" "$TITLE" "$REPO" "$PRS" <<'PY'
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
echo "file://$DIR/index.html"
