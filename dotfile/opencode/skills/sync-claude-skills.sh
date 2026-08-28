#!/usr/bin/env bash
# Rebuild the flat symlink farm that makes this nested skill tree discoverable by
# Claude Code, which scans ONLY one level (~/.claude/skills/<name>/SKILL.md) and
# takes the command name from the directory basename. OpenCode reads the real
# nested tree directly (glob skills/**/SKILL.md) and does NOT use this farm.
#
# Source of truth: this folder, with every skill under <domain>/<name>/
# (domains: pentest, bugbounty, report, tooling, style).
# The root holds no skills. Farm target: ~/.claude/skills (a real dir of
# one-level symlinks, one per skill, each -> the real nested directory).
#
# Idempotent: wipes stale skill symlinks, recreates from the tree. Run it after
# adding, moving or removing a skill. Usage: ./sync-claude-skills.sh [--check]

set -uo pipefail
SRC="$(dirname "$(readlink -f "$0")")"
FARM="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CHECK=0; [ "${1:-}" = "--check" ] && CHECK=1

# Collect real skill dirs: one level under each domain subdir (every skill lives
# in one of the domain trees; the root holds only README/check-leaks/this script).
mapfile -t DIRS < <(
  find "$SRC/pentest" "$SRC/bugbounty" "$SRC/report" "$SRC/tooling" "$SRC/style" \
    -mindepth 1 -maxdepth 1 -type d 2>/dev/null
)

# Guard: every collected dir must hold a SKILL.md, and names must be unique.
declare -A seen; problems=0
for d in "${DIRS[@]}"; do
  n="$(basename "$d")"
  [ -f "$d/SKILL.md" ] || { echo "MISSING SKILL.md: $d"; problems=1; }
  [ -n "${seen[$n]:-}" ] && { echo "DUPLICATE skill name: $n ($d and ${seen[$n]})"; problems=1; }
  seen[$n]="$d"
done
((problems)) && { echo "Fix the above before syncing."; exit 1; }

if ((CHECK)); then
  # Report drift without touching anything (for CI / pre-push).
  drift=0
  for n in "${!seen[@]}"; do
    want="${seen[$n]}"; have="$(readlink -f "$FARM/$n" 2>/dev/null)"
    [ "$have" = "$(readlink -f "$want")" ] || { echo "DRIFT: $n -> ${have:-<missing>} (want $want)"; drift=1; }
  done
  # Stale farm entries pointing back into SRC but no longer a skill.
  for l in "$FARM"/*; do
    [ -L "$l" ] || continue
    tgt="$(readlink -f "$l" 2>/dev/null)"
    case "$tgt" in "$SRC"/*) [ -n "${seen[$(basename "$l")]:-}" ] || { echo "STALE: $(basename "$l")"; drift=1; };; esac
  done
  ((drift)) && exit 1
  echo "OK -- farm in sync (${#seen[@]} skills)"; exit 0
fi

mkdir -p "$FARM"
# Remove only OUR stale symlinks (those resolving into SRC); never touch real dirs
# or foreign symlinks a user may have added.
for l in "$FARM"/*; do
  [ -L "$l" ] || continue
  tgt="$(readlink -f "$l" 2>/dev/null)"
  case "$tgt" in "$SRC"/*) rm -f "$l";; esac
done
for n in "${!seen[@]}"; do ln -sfn "${seen[$n]}" "$FARM/$n"; done
echo "OK -- linked ${#seen[@]} skills into $FARM"
