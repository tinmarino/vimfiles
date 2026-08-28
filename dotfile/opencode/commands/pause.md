---
description: "Stop the hunt coordinator and all its hunters gracefully using Claude's task management"
allowed-tools: ListAgents, TaskStop, Write, Read, Bash
---
Stop the hunt coordinator and all its active hunters using Claude's internal task management.

## Steps

1. **Find running coordinator and hunters:**
   ```bash
   # Look for coordinator state to find the engagement root
   ROOTS=$(find ~/Pawn -name "COORDINATOR-STATE.json" -path "*/hunt/*" 2>/dev/null)
   ```

2. **List all agents to find coordinator + hunters:**
   - Call `ListAgents` to enumerate background agents
   - Identify coordinator by name pattern: "hunt-coordinator"
   - Identify hunters by name pattern: "Hunter-*" or similar

3. **Stop coordinator first:**
   ```python
   TaskStop(task_id="hunt-coordinator")
   ```

4. **Stop all hunters:**
   - For each hunter agent found in ListAgents
   - Call `TaskStop(task_id=<hunter-id>)`

5. **Record what was stopped:**
   ```bash
   # For each engagement root found
   ROOT=<root-from-state-file>
   
   cat > "$ROOT/hunt/PAUSED.json" <<EOF
   {
     "paused_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
     "coordinator": {
       "id": "hunt-coordinator",
       "stopped": true
     },
     "hunters": [
       {"id": "Hunter-113", "task": "IDOR testing", "stopped": true},
       ...
     ],
     "can_resume": false,
     "note": "Tasks were gracefully terminated, not frozen. Resume will restart the coordinator from last state."
   }
   EOF
   ```

6. **Cancel any scheduled wakeups:**
   ```python
   ScheduleWakeup(stop=True)
   ```

7. **Report concisely:**
   ```
   Hunt paused:
   • Coordinator stopped
   • 5 hunters stopped (Hunter-113, Hunter-128, ...)
   • State saved to hunt/PAUSED.json
   
   Main session free. Use /resume to restart the hunt.
   ```

## Important Notes

- Stopping with `TaskStop` terminates agents gracefully, doesn't freeze them
- The coordinator's state in `hunt/COORDINATOR-STATE.json` persists
- Hunters' partial work is lost (they were stopped mid-task)
- `/resume` will restart the coordinator, which will respawn hunters from the queue
- This is MUCH cleaner than SIGSTOP — no stale processes, no memory leaks
