#!/usr/bin/env bash
# install.sh — install cflow's skills into Claude Code and Codex.
#   ~/.claude/skills/<name>/   ~/.codex/skills/<name>/   ~/.codex/prompts/<name>.md
# Usage: scripts/install.sh [--dry-run]
# Re-run after pulling to update. Only the skills under cflow's skills/ are touched.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
run() { if [ "$DRY" = 1 ]; then echo "  would: $*"; else "$@"; fi; }
CLAUDE_SKILLS="$HOME/.claude/skills"; CODEX_SKILLS="$HOME/.codex/skills"; CODEX_PROMPTS="$HOME/.codex/prompts"
run mkdir -p "$CLAUDE_SKILLS" "$CODEX_SKILLS" "$CODEX_PROMPTS"
n=0
for src in "$ROOT"/skills/*/; do
  name=$(basename "$src"); [ -f "$src/SKILL.md" ] || continue
  for dest in "$CLAUDE_SKILLS/$name" "$CODEX_SKILLS/$name"; do
    [ -L "$dest" ] && run rm "$dest"
    run rm -rf "$dest"; run cp -R "${src%/}" "$dest"
  done
  prompt="$ROOT/harnesses/codex/prompts/$name.md"
  [ -f "$prompt" ] && run cp "$prompt" "$CODEX_PROMPTS/$name.md"
  n=$((n+1))
done
[ "$DRY" = 1 ] && echo "dry run: $n cflow skills" || echo "installed $n cflow skills into $CLAUDE_SKILLS and $CODEX_SKILLS"
