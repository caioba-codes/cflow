#!/usr/bin/env bash
# prune-worktrees.sh — remove merged/abandoned git worktrees and their branches.
#
# Safety is the point: nothing is removed if it holds uncommitted changes or
# commits that are not on the remote. Removing a worktree deletes only that
# directory — commits and branches live in .git — so once work is pushed,
# teardown loses nothing. This script verifies that before acting.
#
# Detects squash-merged branches via `gh pr list --state merged`, which
# `git branch --merged` cannot see (a squash merge rewrites the commit, so the
# branch still looks unmerged).
#
# Usage:
#   scripts/prune-worktrees.sh [--apply] [--repo <path>] [--base <branch>]
#
#   (default)      dry run — report only, change nothing
#   --apply        actually remove clean worktrees and delete merged branches
#   --repo <path>  repo to operate on (default: current directory)
#   --base <name>  integration branch to measure "merged" against (default: staging,
#                  falling back to main when staging does not exist)
set -euo pipefail

APPLY=0
REPO="$PWD"
BASE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --repo)  REPO="${2:?--repo needs a path}"; shift 2 ;;
    --base)  BASE="${2:?--base needs a branch}"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

cd "$REPO"
git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo: $REPO" >&2; exit 1; }

MAIN_WT="$(git rev-parse --show-toplevel)"

if [ -z "$BASE" ]; then
  if git show-ref --verify --quiet refs/remotes/origin/staging; then BASE="staging"; else BASE="main"; fi
fi
git show-ref --verify --quiet "refs/remotes/origin/$BASE" \
  || { echo "no origin/$BASE — fetch first?" >&2; exit 1; }

note() { printf '%s\n' "$*"; }
run()  { if [ "$APPLY" = 1 ]; then "$@"; else printf 'DRY:'; printf ' %q' "$@"; printf '\n'; fi; }

note "repo: $MAIN_WT"
note "base: origin/$BASE"
note "mode: $([ "$APPLY" = 1 ] && echo APPLY || echo 'DRY RUN (pass --apply to act)')"
note ""

git fetch --quiet --prune origin || note "warning: fetch failed, working from stale refs"

# Squash-merged branches, via the PR host. Best effort: gh may be absent or
# unauthenticated, in which case we fall back to ancestry only.
SQUASHED=""
if command -v gh >/dev/null 2>&1; then
  SQUASHED="$(gh pr list --state merged --limit 200 --json headRefName \
    --jq '.[].headRefName' 2>/dev/null || true)"
  [ -z "$SQUASHED" ] && note "note: gh returned nothing — squash-merge detection off"
else
  note "note: gh not installed — squash-merge detection off"
fi

is_squash_merged() {
  [ -n "$SQUASHED" ] && printf '%s\n' "$SQUASHED" | grep -qxF "$1"
}

# ---------------------------------------------------------------- worktrees
note "== worktrees =="
KEPT=0; REMOVED=0

while IFS= read -r line; do
  case "$line" in worktree\ *) WT="${line#worktree }" ;; *) continue ;; esac
  [ "$WT" = "$MAIN_WT" ] && continue

  if [ ! -d "$WT" ]; then
    note "  gone      $WT — directory missing, pruning registration"
    REMOVED=$((REMOVED+1))
    continue
  fi

  BR="$(git -C "$WT" branch --show-current 2>/dev/null || true)"
  DIRTY="$(git -C "$WT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"

  if [ "$DIRTY" != "0" ]; then
    note "  KEEP      $WT [${BR:-detached}] — $DIRTY uncommitted file(s)"
    KEPT=$((KEPT+1)); continue
  fi

  if [ -n "$BR" ]; then
    if git show-ref --verify --quiet "refs/remotes/origin/$BR"; then
      UNPUSHED="$(git -C "$WT" rev-list --count "origin/$BR..$BR" 2>/dev/null || echo 0)"
      if [ "$UNPUSHED" != "0" ]; then
        note "  KEEP      $WT [$BR] — $UNPUSHED unpushed commit(s)"
        KEPT=$((KEPT+1)); continue
      fi
    else
      # No remote counterpart. Only safe if the branch adds nothing over base.
      AHEAD="$(git rev-list --count "origin/$BASE..$BR" 2>/dev/null || echo 0)"
      if [ "$AHEAD" != "0" ]; then
        note "  KEEP      $WT [$BR] — never pushed, $AHEAD commit(s) not on origin/$BASE"
        KEPT=$((KEPT+1)); continue
      fi
    fi
  fi

  note "  remove    $WT [${BR:-detached}]"
  run git worktree remove "$WT"
  REMOVED=$((REMOVED+1))
done < <(git worktree list --porcelain)

run git worktree prune
note "  -> $REMOVED removable, $KEPT kept"
note ""

# ----------------------------------------------------------------- branches
note "== merged local branches =="
CURRENT="$(git branch --show-current 2>/dev/null || true)"
# Branches still checked out in a remaining worktree must not be deleted.
IN_USE="$(git worktree list --porcelain | awk '/^branch /{sub("refs/heads/","",$2); print $2}')"
BCOUNT=0

while IFS= read -r BR; do
  [ -z "$BR" ] && continue
  case "$BR" in main|master|staging|develop) continue ;; esac
  [ "$BR" = "$CURRENT" ] && continue
  printf '%s\n' "$IN_USE" | grep -qxF "$BR" && continue

  if git merge-base --is-ancestor "$BR" "origin/$BASE" 2>/dev/null; then
    REASON="merged into origin/$BASE"
  elif is_squash_merged "$BR"; then
    REASON="squash-merged PR"
  else
    continue
  fi

  note "  delete    $BR — $REASON"
  # -D because a squash-merged branch is not an ancestor, so -d refuses it.
  # Safe here: we only reach this line for branches the host reports as merged.
  run git branch -D "$BR"
  BCOUNT=$((BCOUNT+1))
done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

note "  -> $BCOUNT branch(es)"
note ""
[ "$APPLY" = 1 ] || note "dry run — nothing changed. Re-run with --apply."
