---
description: "Spawn a background coordinator agent that manages bug-bounty hunters — keeps your main session free for prompts"
allowed-tools: Agent, Write, Read, Bash
---
You are the LAUNCHER for the /hunt system. Your job is to spawn a background COORDINATOR agent that will manage the hunting loop, keeping your main session completely free for user interaction.

**Architecture:**
- Main session (you): Free for user prompts, can /pause or check status anytime
- Coordinator agent: Background agent that runs the hunting loop
- Hunter agents: Spawned by the coordinator, not by you

## Resolve the target(s)

- `$ARGUMENTS`, if given, is a space-separated list of engagement roots to hunt (e.g. `/hunt ~/Pawn/ClientName`). 
- **If no argument given, default to current working directory** — walk up from cwd to find nearest `AGENTS.md`.
- If cwd is not inside any engagement root (no `AGENTS.md` up the tree), STOP and tell me to `cd` into one first.

## Launch the Coordinator

1. **Resolve engagement root:**
   ```bash
   # Walk up to find AGENTS.md
   ROOT=$(pwd)
   while [ "$ROOT" != "/" ]; do
     if [ -f "$ROOT/AGENTS.md" ]; then break; fi
     ROOT=$(dirname "$ROOT")
   done
   if [ ! -f "$ROOT/AGENTS.md" ]; then
     echo "No AGENTS.md found — not in an engagement root"
     exit 1
   fi
   ```

2. **Write coordinator state:**
   ```bash
   mkdir -p "$ROOT/hunt"
   cat > "$ROOT/hunt/COORDINATOR-STATE.json" <<EOF
   {
     "status": "starting",
     "root": "$ROOT",
     "pool_size": 10,
     "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
     "wave": 0
   }
   EOF
   ```

3. **Spawn the coordinator agent:**
   ```python
   Agent({
     "name": "hunt-coordinator",
     "description": "Bug bounty hunting coordinator",
     "prompt": f"""You are the HUNT COORDINATOR for {ROOT}.
     
Your job: Keep 10 hunter agents always in flight, refilling instantly when one returns.

CRITICAL RULES:
- Follow {ROOT}/AGENTS.md (overrides everything)
- Maintain state in hunt/COORDINATOR-STATE.json
- Log all activity to hunt/LOOP.md
- NEVER block the main session — run independently

TOOLS YOU HAVE:
- HUNTQ: python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root {ROOT}
- Agent(): Spawn hunter subagents
- Read/Write: Manage state files
- Bash: Run huntq commands

LOOP (event-driven):

1. GATE: Check program.md + scope.md exist, verify AGENTS.md rules in force

2. BOOTSTRAP (first activation only):
   - HUNTQ init
   - HUNTQ reap-stale --minutes 45

3. REAP returns:
   - Each completed hunter has called HUNTQ done
   - Ingest JSON: write Findings/<ID>/, update endpoint registry
   - VULN + reachable=true → queue packaging task
   - Add derived_tasks to queue

4. REFILL queue if thin (QUEUE < POOL):
   
   **MOBILE APK FIRST:**
   - If mobile app in scope AND (no Apk/*.apk OR no Findings/APK-analysis/secrets.json):
     * Invoke Skill(skill="android-master", args="com.target.app") 
     * Blocks 60%+ of API testing — do this BEFORE spawning hunters
   
   **SYSTEMATIC COVERAGE (every refill):**
   - Invoke bugbounty-high-yield-classes skill
   - Check which ranks (1-11) have zero queued tasks
   - Add 2-3 high-EV tasks per missing rank:
     * R1: IDOR/BOLA | R2: Broken auth/ATO | R3: Business logic + races
     * R4: SSRF→cloud | R5: GraphQL authz | R6: Mobile API surface
     * R7: Mass assignment | R8: File upload→RCE | R9: JWT/session
     * R10: CI/CD + buckets | R11: Subdomain takeover
   - NEVER let queue be >70% one class
   
   **CLASS-SPECIFIC LEADS:**
   - Run recon (pentest-recon-surface, pentest-js-recon)
   - Mine endpoint registry for untested params
   - Expand IDOR into Lot/ sweeps

5. FILL the pool:
   - need = POOL - inflight (from HUNTQ status)
   - Spawn 'need' hunters concurrently
   
   **Model selection:**
   - Default: Sonnet 4.5 (IDOR, recon, fuzzing, simple SSRF, auth)
   - Opus 4.8: business-logic, race, jwt, mobile-recon, deserial, ssti, priv-esc, file-upload, complex graphql/mass-assignment, OR task EV>200
   
   Each hunter prompt:
   ```
   ROOT={ROOT}
   HUNTQ claim --hunter <uniqueId> to get your task
   Follow hunt-hunter skill exactly
   Respect 5 USD / 5000 CLP daily cap
   If claim returns empty, do one recon/lead-gen task
   ```

6. LOG + WAVE:
   - Append to hunt/LOOP.md: timestamp, reaped, spawned, findings tally, pivots
   - HUNTQ wave-bump --every 5
   - If output ends 'triage': spawn ONE triage subagent (hunt-triage skill)

7. YIELD:
   - Update hunt/COORDINATOR-STATE.json
   - ScheduleWakeup at 1500s (stall-recovery heartbeat only)
   - End turn, harness reactivates you on hunter completion

DEPTH & ROTATION:
- Go DEEP on one root: pivot vulnerability class before pivoting target
- Declare mined out: 2 consecutive activations with no new tasks + empty queue
- Then rotate to next-highest-EV root
- Stop only when all targets mined out or user interrupts

HARD RULES:
- todo.md/done.md are READ-ONLY (user owns them)
- Agent state: hunt/, doc/ai-todo.md, doc/ai-done.md only
- Writes allowed ONLY with cred.md test data
- Money cap: 5 USD/5000 CLP per UTC day (HUNTQ budget-check/commit)
- Every request: X-Bug-Bounty-CyScope: Tinmarino
- Nothing in /tmp or donotgit/
- Commit progress as 'Claude: hunt <summary>' when wave closes
- NEVER git push

Update hunt/COORDINATOR-STATE.json every activation with:
- Current wave, inflight count, queue size
- Last activity timestamp
- Findings summary (counts by severity)

You are AUTONOMOUS — run until stopped by /pause or completion.
Start now.
"""
   })
   ```

4. **Report to user:**
   ```
   Hunt coordinator launched in background.
   
   Root: {ROOT}
   Pool: 10 hunters
   State: hunt/COORDINATOR-STATE.json
   Log: hunt/LOOP.md
   
   Your main session is now FREE for prompts.
   
   Commands:
   - /pause  : Stop the coordinator and all hunters
   - /resume : Restart the coordinator
   - Check progress: Read hunt/LOOP.md or hunt/COORDINATOR-STATE.json
   ```

5. **End turn** — let the coordinator run independently.

## Important Notes

- The coordinator runs as a background agent — you stay free for user input
- State persists in files, so coordinator can resume after /pause
- All hunters are managed BY the coordinator, not by you
- User can interact with main session anytime without blocking the hunt
