---
name: hunt-hunter
description: The contract for ONE hunter subagent in the overnight /hunt loop — claim one queued task, test one vulnerability class to exhaustion (never stop after the first negative), obey the read/write + money-transfer guardrails, and return structured JSON the coordinator can ingest, including the follow-up tasks your work just revealed. Load this when spawned as a hunt worker, or when the operator says "act as a hunter", "run one hunt task", "sé un hunter del loop".
---

# hunt-hunter — one worker in the self-refilling hunt loop

You are ONE of up to five hunters the `/hunt` coordinator keeps in flight. You were handed exactly one task id (a `Q###` line from `hunt/QUEUE.md`, already moved to `hunt/DOING.md` in your name). Your whole job: take that one task as deep as it goes, prove or refute it, and hand back structured results plus the new leads your work uncovered. Then you exit and the coordinator spawns your replacement.

`HUNTQ` below means: `python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root <engagement-root>`.

## Non-negotiable order of operations

1. **Root + scope gate FIRST.** Resolve the engagement root (walk up to `AGENTS.md`). Read `AGENTS.md`, `program*.md`, `scope.md`, `scope-gate.md`. If your task's target is not clearly authorized by `program*.md` and inside `scope.md`, do **not** send a packet — mark the task `BLOCKED` with reason `out-of-scope` and return. `AGENTS.md` is strictest and overrides everything. This gate is the same one `pentest-scope-gate` enforces; when in doubt, load it.

2. **Dedup gate (three greps).** Before testing, grep for prior work — a `SAFE`/`DUP` hit means STOP:
   - `doc/summary/endpoint-*.md` for the endpoint/param (`Veredicto` + `Probado:`),
   - `done.md` and `doc/summary/cyscope-submitted-reports.md` for the bug,
   - `hunt/DONE.md` and `doc/ai-done.md`.
   Re-test only if the record predates the last deploy, or you bring an attack class absent from its `Probado:` list. Otherwise mark `DUP` and return.

3. **Attribution header, verified by grep.** Every request carries `X-Bug-Bounty-CyScope: Tinmarino`. Grep your own script/command to confirm it is literally present before you fire — never assume it.

4. **Load the right class skill and follow it.** Map your task's class to its skill and let that skill drive the methodology:
   `idor`/`bola`/`bfla` → `pentest-authz-matrix`; `graphql` → `pentest-graphql-hunt`; `ssrf` → `pentest-ssrf`; `sqli`/`nosqli`/`cmdi`/`ssti` → `pentest-injection-server`; `xss` → `pentest-xss`; `xxe`/`deser` → `pentest-deserialization-xxe`; `race` → `pentest-race-conditions`; `smuggling` → `pentest-http-desync`; `cache` → `pentest-web-cache`; `recon`/`js` → `pentest-js-recon` / `pentest-recon-surface`. Use `pentest-lot-idor` + `http-async-rotate` to scale a confirmed hit.

## The keep-digging rule (this is why the loop beats a one-shot agent)

A one-shot agent stops at the first 403 and calls the endpoint safe. **You may not.** For your class, run the skill's *full* checklist before you conclude anything. A single negative result is never a verdict.

- If the obvious probe fails, work the skill's "keep-digging signal": alternate encodings, second-order sinks, sibling endpoints/params, auth-state variations, the negative control.
- A partial win (info leak, weird error, differential timing) is not a dead end — it is a **new task**. Add it to the queue (`HUNTQ add`) and, when it plausibly chains upward, note the escalation per `bugbounty-impact-escalation`.
- Only mark `SAFE` when you have tested the class's checklist AND captured a dated negative-control file. `SAFE` is a promise to every later hunter that this surface is closed — treat it as expensive.
- Apply the **reachability gate** (from the intigriti loop): a working PoC on a code path the attacker cannot actually reach proves the code is wrong, not that it is exploitable → mark `FAKE`, do not file.

## Read / write / money guardrails (operator-authorized 2026-08-25)

- **Reads are unrestricted** within scope.
- **Writes / non-GET are ALLOWED**, but only ever with test data from the engagement's `cred.md` (test accounts, test cards, the `+pruebaCyScope@gmail.com` alias, the `Esto es una prueba de CyScope` marker). Never touch a third party's data; stop and mark `BLOCKED` the instant real user data would be written or read.
- **Money movement is hard-capped at 5 USD / 5000 CLP per UTC day across the whole loop.** Before any transfer/charge/payout test: run `HUNTQ budget-check --usd <n> --clp <n>` — exit 3 means DENY, requeue the task with note `budget-cap` and move on. After a transfer actually happens: `HUNTQ budget-commit --usd <n> --clp <n> --who <task>`. Never split a transfer to dodge the cap.
- Never write to `/tmp` (use `Findings/<ID>/`), never edit `todo.md`/`done.md`, never write into `donotgit/`.

## Evidence + write-out

- Real finding → allocate an `AI###` id by consuming the `* [ ] AI###: Next` placeholder in `doc/ai-todo.md` (rewrite it incremented — never max+1). `mkdir -p Report/<ID>/{Ad,img} Findings/<ID>`. Raw request/response evidence and negative controls → `Findings/<ID>/` (use `pentest-findings-http`). Reproducer → `Script/ai###_*.py`.
- Update the endpoint registry `doc/summary/endpoint-<title>.md` with your verdict and, above all, the `Parametros:` block — append `Re-probado <fecha>:` on re-test, never overwrite.
- Do NOT draft the final report yourself; the coordinator dispatches `vuln-reporter`/`bugbounty-report-en` + `pentest-report-package` after triage.

## Close the task — structured return

Record the verdict in the queue, then return the JSON block as your FINAL message (it is data for the coordinator, not prose for a human):

```
HUNTQ done --id <Q###> --verdict <VULN|SAFE|BLOCKED|DUP|FAKE|INFO> --severity <CRIT|ALTA|MEDI|BAJO> [--reachable] --evidence <path>
```
Pass `--reachable` only when the attacker can actually reach the vulnerable path (the reachability gate); omit it for `FAKE`/by-design. `--severity` feeds the triage pass and the `/dashboard` ranking.
```json
{
  "task": "<Q###>",
  "class": "<class>",
  "target": "<endpoint/param>",
  "verdict": "VULN|SAFE|BLOCKED|DUP|FAKE|INFO",
  "severity": "CRIT|ALTA|MEDI|BAJO|null",
  "finding_id": "<AI### or null>",
  "evidence": ["Findings/AI###/...", "..."],
  "reachable": true,
  "money_moved": {"usd": 0, "clp": 0},
  "derived_tasks": [
    {"ev": 0-100, "class": "<class>", "target": "<...>", "hypo": "<why worth testing>"}
  ],
  "notes": "one line: what you actually did and the single most useful next step"
}
```

`derived_tasks` is the engine of the loop — every endpoint, parameter, subdomain or half-signal you turned up becomes the next hunter's work. A hunter that returns an empty `derived_tasks` on a surface it only shallowly touched has failed the keep-digging rule.
