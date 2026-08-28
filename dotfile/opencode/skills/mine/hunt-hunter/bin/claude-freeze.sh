#!/usr/bin/env bash
# Freeze (SIGSTOP-equivalent) or thaw every Claude Code instance running in the
# capped claude.slice — coordinator, its Task subagents, and all their child
# processes (sweeps, browsers, curl) — atomically via the cgroup2 freezer.
#
# It NEVER freezes the session that invokes it: the caller's own cgroup (and any
# ancestor) is skipped. Instances launched WITHOUT the claude.slice wrapper are
# not managed here (nothing to freeze / left running by design).
#
# Usage: claude-freeze.sh pause|resume|restart|status
#   pause    -> freeze all other claude scopes
#   resume   -> thaw them   (restart is an alias for resume)
#   status   -> list claude scopes and their freeze state
set -euo pipefail

mode="${1:-}"
case "$mode" in
  pause)            val=1 ;;
  resume|restart)   val=0 ;;
  status)           val=- ;;
  *) echo "usage: claude-freeze.sh pause|resume|restart|status" >&2; exit 2 ;;
esac

cg=/sys/fs/cgroup
rel=$(systemctl --user show claude.slice -p ControlGroup --value 2>/dev/null || true)
if [ -z "$rel" ]; then
  echo "claude.slice is not active — no capped Claude instances are running."
  exit 0
fi
slice="$cg$rel"
# cgroup2 unified hierarchy is the line starting with "0::" — NOT the legacy
# net_cls line ("1:net_cls:/"), whose field 3 is just "/" and would match no
# scope, causing the self-skip to fail and this very session to be frozen.
self_cg=$(awk -F: '/^0::/ {print $3; exit}' /proc/self/cgroup)

shopt -s nullglob
count=0
found=0
for scope in "$slice"/*.scope; do
  [ -d "$scope" ] || continue
  found=$((found + 1))
  srel="${scope#$cg}"
  if [ "$srel" = "$self_cg" ] || [[ "$self_cg" == "$srel"/* ]]; then
    echo "skip (self): $srel"
    continue
  fi
  fz="$scope/cgroup.freeze"
  [ -e "$fz" ] || { echo "no freezer: $srel"; continue; }
  if [ "$val" = "-" ]; then
    printf 'scope %s  freeze=%s\n' "$srel" "$(cat "$fz" 2>/dev/null)"
    continue
  fi
  if echo "$val" > "$fz" 2>/dev/null; then
    printf '%s: %s (freeze=%s)\n' \
      "$([ "$val" = 1 ] && echo FROZE || echo THAWED)" "$srel" "$(cat "$fz")"
    count=$((count + 1))
  else
    echo "PERMISSION DENIED writing $fz" >&2
  fi
done

if [ "$found" -eq 0 ]; then
  echo "claude.slice active but no member scopes — nothing running to manage."
elif [ "$val" != "-" ]; then
  echo "$([ "$val" = 1 ] && echo Paused || echo Resumed) $count claude scope(s) (self skipped)."
fi
