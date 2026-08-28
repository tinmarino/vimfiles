#!/usr/bin/env bash
# Pause / resume ONLY the current Claude Code session's background work.
#
# Unlike claude-freeze.sh (which freezes every OTHER session's whole scope via
# the cgroup2 freezer), this acts on THIS session only and, within it, on the
# subagent/tool CHILD PROCESSES (bash sweeps, curl, python fan-outs, browsers) —
# never on the main `claude` process itself. That is deliberate: the main agent
# must stay alive so it can return to the prompt and so `/resume` still works.
#
# In-process Task subagents are threads of the main `claude` process, so they
# cannot be stopped separately from it; pausing their external child processes
# is what actually halts the runaway work and frees the machine.
#
# Usage: claude-pause-session.sh pause|resume|status
set -euo pipefail

mode="${1:-}"
case "$mode" in
  pause|resume|restart|status) ;;
  *) echo "usage: claude-pause-session.sh pause|resume|status" >&2; exit 2 ;;
esac
[ "$mode" = restart ] && mode=resume

cg=/sys/fs/cgroup
self_cg=$(awk -F: '/^0::/ {print $3; exit}' /proc/self/cgroup)
if [ -z "$self_cg" ]; then
  echo "cannot resolve this session's cgroup — aborting (nothing touched)." >&2
  exit 1
fi
cgpath="$cg$self_cg"
if [ ! -e "$cgpath/cgroup.procs" ]; then
  echo "no cgroup.procs at $cgpath — this session is not in a managed scope." >&2
  echo "(Was this claude launched through the claude.slice wrapper in ~/.bashrc?)" >&2
  exit 1
fi

scope_id=$(basename "$self_cg")
state_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-pause"
mkdir -p "$state_dir"
statefile="$state_dir/$scope_id.pids"

# Ancestry of THIS script = {script bash, main claude, launching shell, ...}.
# Everything on this chain is protected: we never SIGSTOP the main agent or the
# shell running this very command.
protected=" "
p=$$
while [ "$p" -gt 1 ]; do
  protected+="$p "
  p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
  [ -z "$p" ] && break
done

is_protected() { case "$protected" in *" $1 "*) return 0;; *) return 1;; esac; }
pstate() { ps -o state= -p "$1" 2>/dev/null | tr -d ' '; }
pcomm() { ps -o comm= -p "$1" 2>/dev/null; }

if [ "$mode" = status ]; then
  echo "session scope: $scope_id"
  for pid in $(cat "$cgpath/cgroup.procs" 2>/dev/null); do
    tag=$(is_protected "$pid" && echo "[main/self]" || echo "[child]     ")
    printf '  %-12s pid %-8s state=%-2s %s\n' "$tag" "$pid" "$(pstate "$pid")" "$(pcomm "$pid")"
  done
  [ -f "$statefile" ] && echo "  paused-set on record: $(tr '\n' ' ' < "$statefile")"
  exit 0
fi

if [ "$mode" = pause ]; then
  : > "$statefile"
  count=0
  for pid in $(cat "$cgpath/cgroup.procs" 2>/dev/null); do
    is_protected "$pid" && continue
    if kill -STOP "$pid" 2>/dev/null; then
      echo "$pid" >> "$statefile"
      printf 'STOPPED child pid %-8s %s\n' "$pid" "$(pcomm "$pid")"
      count=$((count + 1))
    fi
  done
  if [ "$count" -eq 0 ]; then
    echo "No background child processes to pause — this session has no active sweeps."
    rm -f "$statefile"
  else
    echo "Paused $count child process(es) of THIS session. Main agent left running."
  fi
  exit 0
fi

# resume
count=0
declare -A done=()
if [ -f "$statefile" ]; then
  while read -r pid; do
    [ -n "$pid" ] || continue
    done["$pid"]=1
    if kill -CONT "$pid" 2>/dev/null; then
      printf 'RESUMED child pid %-8s %s\n' "$pid" "$(pcomm "$pid")"
      count=$((count + 1))
    fi
  done < "$statefile"
  rm -f "$statefile"
fi
# Fallback: CONT any still-stopped (state T) child in the scope we did not record.
for pid in $(cat "$cgpath/cgroup.procs" 2>/dev/null); do
  is_protected "$pid" && continue
  [ -n "${done[$pid]:-}" ] && continue
  case "$(pstate "$pid")" in
    T*) kill -CONT "$pid" 2>/dev/null && { printf 'RESUMED (stray) pid %-8s %s\n' "$pid" "$(pcomm "$pid")"; count=$((count + 1)); } ;;
  esac
done
echo "Resumed $count child process(es) of THIS session."
