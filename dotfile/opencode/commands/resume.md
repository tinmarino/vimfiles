---
description: "Restart the hunt coordinator from its last saved state"
allowed-tools: Agent, Read, Bash, Write
---
Restart the hunt coordinator from where it left off when paused.

## Steps

1. **Find paused hunts:**
   ```bash
   find ~/Pawn -name "PAUSED.json" -path "*/hunt/*" 2>/dev/null
   ```

2. **For each paused engagement:**
   - Read `hunt/PAUSED.json` to see what was stopped
   - Read `hunt/COORDINATOR-STATE.json` to get last state
   - Report to user what will restart

3. **Respawn the coordinator:**
   ```python
   Agent({
     "name": "hunt-coordinator",
     "description": f"Resuming hunt for {ROOT}",
     "prompt": f"""RESUME hunt coordination for {ROOT}.
     
You were paused. Your last state is in hunt/COORDINATOR-STATE.json.

READ THAT STATE FIRST, then continue from where you left off:
- Current wave: {wave}
- Queue size: {queue_size}
- Findings so far: {findings_summary}

Now continue the hunting loop exactly as before:
1. Reap any completed hunters (if any)
2. Check queue, refill if needed
3. Spawn hunters to fill pool to 10
4. Update state and log
5. Yield and wait for next hunter return

Follow the full coordinator instructions from /hunt.
Start immediately.
"""
   })
   ```

4. **Clean up pause state:**
   ```bash
   rm "$ROOT/hunt/PAUSED.json"
   ```

5. **Report to user:**
   ```
   Hunt resumed:
   
   Root: {ROOT}
   Coordinator: Restarted from wave {wave}
   Queue: {queue_size} tasks pending
   Findings: {findings_count} so far
   
   Check hunt/LOOP.md for live progress.
   Main session stays free for your prompts.
   ```

## Ask user about multi-root scenarios

If multiple paused hunts found, ask:
- "Resume all hunts, or select one?"
- Show: Root path, last wave, findings count, queue size

## Important Notes

- The coordinator reads its last state from `hunt/COORDINATOR-STATE.json`
- Partial hunter work was lost when they were stopped — coordinator will requeue those tasks
- The hunt loop is event-driven, so it resumes immediately
- Main session stays free for user interaction
- Use `/pause` again to stop if needed
