# Skills

OpenCode skills. Each directory holds one `SKILL.md`; OpenCode selects a skill by matching the request against its `description`, so descriptions carry the trigger phrases (English and Spanish) rather than a summary.

**This folder is published publicly.** No client name, real hostname, credential, token, national ID, employee name or engagement path may appear in any file. Run `./check-leaks.sh` before pushing — exit 1 means do not push. It derives the forbidden-word list from the engagement directories on the machine, so it stays current without maintenance.

## Pentest suite

The engagement lifecycle, in order. `pentest-router` is the entry point when the next step is unclear.

| Skill | Use it for |
| --- | --- |
| `pentest-router` | Which skill next, given a fresh engagement or an ambiguous request |
| `pentest-scope-gate` | Hard pre-flight gate: nothing leaves before scope, technique, identity and PII rules are confirmed |
| `pentest-engagement-init` | Repo skeleton, `AGENTS.md`, the todo -> done loop, the finding-ID counter |
| `pentest-recon-surface` | One-shot attack-surface map at the start: hosts, CT history, ports, stack, API specs |
| `pentest-js-recon` | Frontend bundles into `Lot/Js/`, prettified into `Pretty/`, mined for endpoints and secrets |
| `pentest-endpoint-summary` | `doc/summary/endpoint-<title>.md` registry so no agent re-tests a closed endpoint |
| `pentest-lot-idor` | Value corpora under `Lot/` — building, naming, crossing, resuming |
| `pentest-auth-session` | Holding auth alive across long sweeps: `session.yaml`, keepalive sidecar, `--max-authfail` |
| `pentest-burp-to-script` | One Burp request into a parameterised resumable requester under `Script/wave<NNN>/` |
| `pentest-authz-matrix` | IDOR / BOLA / BFLA: account matrix, cross-account grid, the four negative controls |
| `pentest-graphql-hunt` | GraphQL end to end: schema recovery, per-field authz, batching, error oracles |
| `mobile-hacking-frida` | Android: APK decompile/patch/sign, Frida gadget, pinning bypass, traffic logging |
| `pentest-findings-http` | Raw request/response evidence into `Findings/` with reproducible curl |
| `pentest-report-package` | `Report/<ID>/` + `Ad/` attachments + the adversary review pass before submission |
| `pentest-memory-feedback` | `doc/feedback/feedback-<NNN>-<title>.md` and `MEMORY.md`, written at the end of every task |

## Bug-bounty suite

Earnings-oriented. Where the pentest suite asks "how do I test this", these ask "is this worth my hours and how do I get paid the most for it".

| Skill | Use it for |
| --- | --- |
| `bugbounty-program-selection` | Expected-value math on which program deserves the next block of hours |
| `bugbounty-high-yield-classes` | Ranked dollars-per-hour playbook: what to hunt, when to keep digging, what gets closed |
| `bugbounty-asset-monitoring` | Continuous diff-and-alert on new surface — the first-mover lever against duplicates |
| `bugbounty-impact-escalation` | Turning a Low into a Critical by chaining and by proving business impact |
| `bugbounty-report-en` | The English report that maximises payout, plus the duplicate/severity negotiation playbook |

`vuln-reporter` (Spanish, CyScope format) is the counterpart of `bugbounty-report-en`; `vuln-reproducer` drives either from a `todo.md` item.

## Supporting skills

`http-async-rotate` (concurrent sweeps with IP rotation), `burp-history-reader`, `burp-repeater-capture`, `rat-c2-tmux` (own C2 for callbacks), `persistent-terminal-control`, `python-writer` (code style), `write-feedback`, `opencode-chat-history`, `slide-writer`, `dalle-prompt`.

## Conventions the pentest suite shares

- Engagement root holds `AGENTS.md`, `todo.md`, `done.md`, `MEMORY.md`, `program*.md`, `scope.md`, and the directories `Report/`, `Findings/`, `Script/`, `Lot/`, `doc/`.
- Agents own the `AI###` finding namespace; the human's own prefix is never assigned by an agent.
- Read-only by default — state-changing methods need explicit human authorisation for a concrete payload.
- **Every HTTP request carries `X-Bug-Bounty-CyScope: Tinmarino`**, byte-exact. Required by CyScope.io; unattributed traffic gets the program blocked. Wrong casing returns the same 200 as the right value, so it is verified with grep, never assumed. See `pentest-scope-gate`.
- Evidence is copied into `Report/<ID>/Ad/`, never moved out of `Findings/`.
- Markdown is never hard-wrapped; one line per paragraph, bullet or table cell.
- Nothing lives in `/tmp`. What is not on local disk is not evidence later.
