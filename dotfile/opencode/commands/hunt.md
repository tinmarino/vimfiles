---
description: "Spawn a background coordinator agent that manages bug-bounty hunters — keeps your main session free for prompts"
allowed-tools: Agent, Write, Read, Bash, CronCreate, CronList, ListAgents, Skill, SendMessage
---
**ANTES DE NADA: cargá el skill `hunt-orchestration`** (`Skill(skill="hunt-orchestration")`) y pasáselo COMPLETO al coordinador que spawnees, o instruílo a cargarlo él mismo como primera acción. Ese skill es el contrato del coordinador: pool sin goteo, caza dirigida al premio en vez de a la superficie, tesis falsable con marcador, modelo más barato que sirva, lotes con controles reales, refutar barato, no cerrar de más, dedup de dos índices, informe en sesión + escritura con Bash heredoc, y bloqueos que sólo el humano destraba. Lo de abajo (slicing a Haiku, HUNTQ, plantilla del brief) es el detalle operativo que lo complementa; ante conflicto, manda `AGENTS.md` del engagement, después `hunt-orchestration`.

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
   - Also run `HUNTQ session-check`. Exit 3 = no live credential: spawn ONLY
     unauth/static tasks this wave and log 'sesion muerta' in hunt/LOOP.md.
     NEVER attempt to log in or ask a hunter to. A human re-login is the only
     way to re-seed session.yaml; say so in COORDINATOR-STATE.json blockers.

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

5. FILL the pool with task-class matching:
   - need = POOL - inflight (from HUNTQ status)
   - Spawn 'need' hunters concurrently, BUT never more than 2 against the same
     host: 10 hunters on one Akamai/Cloudflare host trips 1015 and turns the
     whole wave into false negatives. Spread across hosts; pad the pool with
     static/JS-mining tasks, which cost no packets.
   
   **Model selection — optimize for parallel Haiku (Haiku is ~1/10th cost):**
   - **Haiku 4.5 (DEFAULT, send as many as queue allows):** Dedup, CT sweep, endpoint diffing, 401-vs-403 oracle, periodic re-checks, registry validation, simple GET/POST variations, parameter enumeration, static APK diffing, bundle hash watching, credential testing with pre-loaded session.yaml, mechanical classification (IDOR/auth/info-leak). Haiku in 200k tokens can handle focused HTTP reversals (5-20 variations per task).
   - **Sonnet 4.5:** Complex business logic, race conditions, fuzzing, payload mutation, recon synthesis, mobile-first chains, JWT/session deep-dives, interactive debugging, large dedup sweeps.
   - **Opus 4.8:** Deserialization, SSTI, priv-esc, file-upload chains, complex GraphQL/mass-assignment, multi-stage races, OR task EV>=80 (EV is capped 0-100 by huntq).
   
   **REVERSE WORKFLOW FOR HAIKU PARALLELISM — KEY PATTERN:**
   Instead of one Sonnet trying all variations, break work into focused slices and send Haiku army:
   
   EXAMPLE: Testing 10 parameter combinations for IDOR
   - Traditional: Q999 (Sonnet) — "test params p1-p10 for IDOR on endpoint X" → 50k tokens, one report
   - Haiku army: Q999-A through Q999-J (Haiku x10) — each tests ONE param, each ~5k tokens
   - Coordinator ingests 10 quick reports, dedupes, composes the full finding, queues follow-ups
   - Total cost: ~50k tokens (same), but 10x parallelism = 10x faster wall-clock, and each slice is trivial to verify
   
   SLICING IS MANDATORY, NOT ADVISORY: any task whose success criterion is not
   a single boolean, count or short list MUST be sliced before it is queued.
   Each slice carries its own hypothesis and its own one-question criterion.

   When to split into Haiku tasks:
   - If a task says "test X variations", queue X separate Haiku tasks instead
   - If a task is "check 5 hosts", queue 5 Haiku tasks (each checks 1 host thoroughly)
   - If a task needs "try 8 User-Agent headers", queue 8 Haiku (each tries 1, reports diff or "no diff")
   - Dedup pass on a 200-line registry? Queue 20 Haiku each doing 10 lines
   
   Coordinator responsibility:
   - When ingesting derived_tasks from a Sonnet finding, IMMEDIATELY BREAK complex tasks into Haiku slices before queueing
   - Each Haiku task must have ONE clear success criterion (Boolean or short numeric answer)
   - Coordinator dedupes the slice results and synthesizes the full finding
   
   **RESOLVE THE TASK YOURSELF, THEN SPAWN.**
   Do NOT make the hunter run `HUNTQ claim`. YOU claim it:
     `HUNTQ claim --hunter <uniqueId>` -> prints one line:
       Q<nnn> | <EV> | <class> | <target> | <hypothesis> [| k=v ...]
   Parse those fields and interpolate them into the brief below. A Haiku hunter
   must never have to open a queue file to discover what it is testing.
   If claim prints nothing the queue is empty — do a recon/lead-gen task instead
   of spawning an idle hunter.

   Before spawning ANY hunter that needs auth, run once per wave:
     `HUNTQ session-check`   (exit 0 = live, exit 3 = dead)
   Exit 3 => do not spawn authenticated tasks at all this wave. Spawn only
   unauth/static work and note `sesion muerta` in hunt/LOOP.md.

   **Spawn with an explicit model** — the tier table above is not self-enforcing:
   ```python
   Agent({
     "subagent_type": "general-purpose",
     "model": "haiku",              # DEFAULT. sonnet/opus only per the tier table
     "description": f"Hunter {qid}",
     "prompt": HUNTER_BRIEF,        # the template below, fully interpolated
   })
   ```
   Never spawn a hunter with placeholders left unfilled. If you cannot state the
   success criterion as ONE boolean/count/list, the task is not sliceable yet —
   slice it (see C4 rule below) and queue the slices instead of spawning.

   **HUNTER_BRIEF template — every <...> MUST be interpolated before spawning:**
   ```
   You are hunter <HUNTER_ID> on task <Q###>. ROOT=<ROOT>.
   HUNTQ = python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root <ROOT>

   == HYPOTHESIS (test this and nothing else) ==
   <hypothesis field, verbatim from the queue line>

   == TARGET ==
   Class:  <class>
   Target: <endpoint / parameter / host>
   Notes:  <k=v notes from the queue line>

   == SUCCESS CRITERION ==
   Answer exactly this, as a boolean, a count, or a short list:
   <the ONE question, e.g. "Does GET /prod/v1/x return 401 or 403 with no bearer?">
   Budget: < 10 tool calls. If you cannot answer within it, close BLOCKED and
   say what you learned — do not keep digging past the budget on a slice.

   == AUTH — YOU MAY NEVER LOG IN ==
   Run `HUNTQ session-check` FIRST. Exit 3 => `HUNTQ done --verdict BLOCKED`
   with note no-session, immediately, before any packet.
   Live session file: <ROOT>/session.yaml — read it fresh for every request,
   never cache the bearer between calls (it is ~30 min and there is NO refresh
   route: it can only be replaced by a human re-login).
   NO login form, NO /autenticacion, NO OTP request, NO password anywhere.
   The account lockout threshold is low and cumulative per IP; one automated
   retry has already locked this account once. Test identities live in cred.md —
   reference the file, never copy its contents into any note, report or commit.

   == MANDATORY ON EVERY REQUEST ==
   X-Bug-Bounty-CyScope: Tinmarino    (also in session.yaml identity_header)
   A real browser User-Agent.
   Grep your own command or script and confirm BOTH strings are literally
   present before you fire. Never assume.
   Reading 403/429 correctly, because most false negatives come from here:
     - 403 + no browser UA        => Akamai blocked you. NOT a negative result.
     - 403 "Missing Authentication Token" => route absent at the API gateway.
     - 404 from Spring            => route absent in the microservice.
     - 429 / Cloudflare error 1015 => per-host, shared across all hunters on
       this IP. Mark INCONCLUSIVE, never SAFE. Back off, do not retry-hammer.
   Max 2 in-flight hunters per host; concurrency 1 with seconds between
   requests when you share a host with another hunter.

   == DEDUP GATE — before a single packet ==
   grep your target in: doc/summary/endpoint-*.md, done.md, hunt/DONE.md,
   doc/ai-done.md, AI-*.md, donotgit/Vuln-*.md.
   Any SAFE/closed hit => verdict DUP, stop, zero packets sent.
   Duplicate policy is aggressive: the same parameter, or the same flaw class on
   another endpoint, already counts as a duplicate.

   == EVIDENCE YOU MUST LEAVE ON DISK ==
   For every verdict except DUP, create Findings/<Q###>-<slug>/ containing:
     request.txt   full request line + ALL headers + body, verbatim as sent
     response.txt  status line + ALL headers + body (truncate body at 8KB)
     negative-control.txt  the same probe that SHOULD fail (no token / another
                   RUT / absent param), dated, with its full response
     repro.sh      one runnable curl that reproduces the result end to end
   A verdict with no negative control is not a verdict. SAFE specifically
   requires the full class checklist AND a dated negative control on disk.
   For VULN only: write Script/<id>_<slug>.py. The finding-ID placeholder
   (`* [ ] VulnNN: Next` or `* [ ] AI###: Next` — check which file/format this
   engagement's doc/todo.md or doc/ai-todo.md actually uses, do not assume)
   is NEVER consumed by a hunter unprompted. Stage evidence under a
   provisional slug and ask the coordinator/operator for explicit permission
   before that placeholder is edited/incremented. You do NOT draft the report.
   APPEND (never overwrite) `Re-probado <fecha>: <veredicto>` to the matching
   doc/summary/endpoint-<title>.md.
   A working PoC on a path no attacker can reach is FAKE — do not file it.

   == GUARDRAILS ==
   Reads: unrestricted within scope. Scope is AGENTS.md + program*.md; anything
   else => BLOCKED reason out-of-scope, zero packets.
   Writes / non-GET: ONLY with cred.md test data, marked "Esto es una prueba de
   CyScope". Never modify third-party data beyond the minimum that proves it.
   Money: `HUNTQ budget-check --usd N --clp N` first (exit 3 = DENY: requeue
   with note=budget-cap), then `HUNTQ budget-commit`. Cap 5 USD / 5000 CLP per
   UTC day. Never split a transfer to dodge the cap.
   FORBIDDEN without explicit operator consent: coopeuchpass /otp/v1/solicitar,
   /otp/v1/validar, msfactor otp/validar, any real OTP or biometric prompt sent
   to a third party, any money movement at all.
   On reaching REAL user data: STOP and report. Do not go deeper, do not pull
   more records. Mass enumeration stops once the pattern is shown (~10 ids).
   Impact is argued in the report, never exercised.
   No writes to /tmp, todo.md, done.md, or donotgit/.

   == CLOSE OUT ==
   HUNTQ done --id <Q###> --verdict <VULN|SAFE|BLOCKED|DUP|FAKE|INFO> \
     --severity <CRIT|ALTA|MEDI|BAJO> [--reachable] --evidence <path>

   Then your FINAL message is this JSON and NOTHING else — no prose around it:
   {
     "task": "<Q###>", "class": "<class>", "target": "<endpoint/param>",
     "verdict": "VULN|SAFE|BLOCKED|DUP|FAKE|INFO",
     "severity": "CRIT|ALTA|MEDI|BAJO|null",
     "finding_id": "<AI### or null>",
     "evidence": ["Findings/<Q###>-<slug>/request.txt", "..."],
     "reachable": true,
     "money_moved": {"usd": 0, "clp": 0},
     "derived_tasks": [{"ev": 0-100, "class": "<c>", "target": "<t>",
                        "hypo": "<why it is worth testing>"}],
     "notes": "one line: what you actually did + the single best next step"
   }
   derived_tasks is the engine of the loop. Returning an empty derived_tasks on
   a surface you only touched shallowly is a failed hunt.
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
- Every request: X-Bug-Bounty-CyScope: Tinmarino, plus a browser User-Agent
- NO agent ever authenticates. One human login -> session.yaml -> read-only for all
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

4. **Arm the credit-refresh watchdog (ALWAYS — this is what makes the hunt survive the night):**

   When the session's usage credit runs out, the coordinator dies mid-wave and nothing restarts it on its own. So right after spawning it, arm a self-rearming watchdog **inside this session** with `CronCreate`:

   ```python
   CronCreate({
     "cron": "*/17 * * * *",          # off-minute on purpose; adjust if the user wants slower
     "recurring": True,
     "prompt": f"""HUNT WATCHDOG for {ROOT} — do this silently and briefly.

   1. ListAgents. If an agent named 'hunt-coordinator' for {ROOT} is still running, do NOTHING and end the turn with one line: 'watchdog: coordinator vivo'.
   2. Otherwise read {ROOT}/hunt/COORDINATOR-STATE.json. If it does not exist or its status is 'stopped-by-user' / there is a {ROOT}/hunt/PAUSED.json, do NOTHING (the user paused on purpose) and say so in one line.
   3. Otherwise the coordinator died — most likely the session credit ran out. Respawn it exactly as /resume does: Agent(name='hunt-coordinator', prompt='RESUME hunt coordination for {ROOT}. Read hunt/COORDINATOR-STATE.json, hunt/QUEUE.md and hunt/LOOP.md first, requeue any task left in-flight (huntq reap-stale --minutes 45), then continue the loop: reap, refill, fill the pool, log, yield. Follow AGENTS.md and the full coordinator instructions from /hunt.').
   4. Append one line to {ROOT}/hunt/LOOP.md: timestamp + 'watchdog: coordinador relanzado tras corte de crédito'.

   If the credit is still exhausted the respawn will fail — that is fine, say so in one line and end; the next tick retries."""
   })
   ```

   Tell the user two limits of this mechanism, because they are real:
   - the cron lives **in this session only** — the terminal must stay open (a paused/backgrounded terminal is fine, a closed one is not), and it fires only while the REPL is idle, so leave the prompt free;
   - `recurring` jobs **auto-expire after 7 days**.

   Also instruct the coordinator, in its own prompt, that a usage-limit error is NOT a stop condition: it must leave `hunt/COORDINATOR-STATE.json` up to date on every activation so the watchdog can resume from it, and never write `status: stopped-by-user` unless the user paused.

5. **Report to user:**
   ```
   Hunt coordinator launched in background.
   
   Root: {ROOT}
   Pool: 10 hunters
   State: hunt/COORDINATOR-STATE.json
   Log: hunt/LOOP.md
   Watchdog: cron cada 17 min en esta sesión — relanza al coordinador cuando vuelva el crédito
             (deja el terminal abierto y el prompt libre; el cron caduca a los 7 días)
   
   Your main session is now FREE for prompts.
   
   Commands:
   - /pause  : Stop the coordinator and all hunters
   - /resume : Restart the coordinator
   - Check progress: Read hunt/LOOP.md or hunt/COORDINATOR-STATE.json
   ```

6. **End turn** — let the coordinator run independently.

## Ad-hoc operator investigations (main session, outside the queue)

When the operator hands you a one-off lead mid-session (a screenshot, "check X in Burp", a hunch) instead
of it flowing through the coordinator's queue, do NOT reach for `Agent({subagent_type: "fork"})` by default —
a fork always inherits the parent's model (Sonnet or whatever this session is running), ignores any `model`
override, and costs accordingly. Fork only when you genuinely need the parent's conversation context (e.g.
the operator's last five messages of nuance matter to the investigation).

For a self-contained, mechanically-describable check (dedup a claim against existing findings, pull one
request from Burp history, fire one probe, report VULN/SAFE/DUP/BLOCKED/INFO) — the same shape as a single
hunter task — spawn a **fresh non-fork agent with an explicit model**, same tier table as hunters above
(Haiku default, Sonnet/Opus only for genuinely complex classes), and brief it exactly as you would a hunter:
root, hypothesis, target, one success criterion, dedup gate, evidence contract, guardrails. Do this even
though it is not entering `HUNTQ` — it is not from the queue, so there is no `Q###` to claim, but the
brief shape and the model-tier discipline are identical.

**Register the endpoint in `doc/summary/endpoint-*.md` the MOMENT it is identified — not at the end,
alongside the finished report.** A multi-step brief (confirm → evidence → assign ID → draft report →
THEN update the registry) leaves the registry silently behind for the whole span of the investigation;
if you inspect it mid-flight, or the agent stalls/fails partway, it looks like the endpoint was never
seen at all. Put the registry write as step 2, right after the endpoint/action name and host are known
(even before authorization is confirmed) — write a short stub noting the candidate class and
"EN INVESTIGACIÓN" status, then let the agent's own final step upgrade that stub to the full verdict.
This applies to every brief you write for a spawned agent, ad-hoc or queued: identify → register stub →
investigate → finalize registry entry, in that order, never registry-last.

**Always check Burp Organizer, not just proxy history.** Organizer holds requests the operator manually
saved/pinned as interesting — it is curated signal, often already containing multiple calls to the same
action with different target identifiers (the exact shape of ready-made IDOR evidence: same endpoint,
different id, compare the responses). A Burp-history sweep that only reads passive proxy traffic and never
opens Organizer will miss leads the operator has already done half the work on. When a brief says "check
Burp" for any hunt, explicitly include Organizer as its own step, not a rename of history.

Burp MCP (`burp-history-reader` skill, proxy on localhost:9876) is a normal tool available to spawned
agents in this environment when the operator has Burp running and proxying traffic — never assume it is
unreachable from a "not available in this environment" style read; if a spawned agent reports it missing,
that is more likely a fresh-agent tool-discovery miss than an actual absence, so retry once (ideally with
a fresh non-fork agent, since forks sometimes fail to see MCP tools the parent has) before concluding BLOCKED.

## Important Notes

- The coordinator runs as a background agent — you stay free for user input
- State persists in files, so coordinator can resume after /pause
- All hunters are managed BY the coordinator, not by you
- User can interact with main session anytime without blocking the hunt
