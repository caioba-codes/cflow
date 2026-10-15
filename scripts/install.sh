#!/usr/bin/env bash
# install.sh — install cflow's skills into Claude Code and Codex.
#   ~/.claude/skills/<name>/   ~/.codex/skills/<name>/   ~/.codex/prompts/<name>.md
#   ~/.claude/agents/<name>.md (cflow-agent, comment-sicko)
# Usage: scripts/install.sh [--dry-run]
# Re-run after pulling to update. Only cflow's own skills and agents are touched.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
run() { if [ "$DRY" = 1 ]; then echo "  would: $*"; else "$@"; fi; }
CLAUDE_SKILLS="$HOME/.claude/skills"; CODEX_SKILLS="$HOME/.codex/skills"; CODEX_PROMPTS="$HOME/.codex/prompts"
CLAUDE_AGENTS="$HOME/.claude/agents"
run mkdir -p "$CLAUDE_SKILLS" "$CODEX_SKILLS" "$CODEX_PROMPTS" "$CLAUDE_AGENTS"
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
for agent in "$ROOT"/agents/*.md; do [ -f "$agent" ] && run cp "$agent" "$CLAUDE_AGENTS/"; done
[ "$DRY" = 1 ] && echo "dry run: $n cflow skills" || echo "installed $n cflow skills into $CLAUDE_SKILLS and $CODEX_SKILLS"
missing=""
command -v gh >/dev/null || missing="$missing gh (https://cli.github.com, then gh auth login)"$'\n'
command -v bun >/dev/null || missing="$missing bun (https://bun.sh; agents use it to watch pull requests)"$'\n'
command -v node >/dev/null || missing="$missing node (https://nodejs.org)"$'\n'
[ -z "$missing" ] || printf 'Also install:\n%s' "$missing"
