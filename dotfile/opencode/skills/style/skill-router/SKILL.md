---
name: skill-router
description: "Top-level entry point for the WHOLE skill suite — decides which skill to load and in what order, across pentest/bug-bounty work, report writing and skill authoring. Use on 'qué skill uso', 'no sé qué hacer ahora', 'which skill', 'route this', 'where do I start', 'por dónde arranco', or whenever a request is ambiguous or a session opens cold. Inside a pentest engagement root, hand off to pentest-router (the lifecycle dispatcher); this one is the suite-wide entry above it."
source: mine
license: MIT
metadata:
  audience: opencode-agents
---

# skill-router

The single entry point for the suite. Load this when the next step is unclear, a request is ambiguous, or a session opens without obvious context. Its job is to send you to the right skill in the right order — not to do the work itself. Once the target skill is chosen, load it and follow it; come back here only when the situation changes.

The suite is split into five directories under `skills/`:

- **`pentest/`** — engagement lifecycle + vulnerability classes + hunt loop
- **`bugbounty/`** — program selection, earnings, English reporting
- **`report/`** — evidence capture, report packaging, memory/feedback
- **`tooling/`** — Burp, HTTP rotation, C2, terminal, browser evidence
- **`style/`** — code style, skill authoring, slides, image prompts, session mgmt

## Fast routing

**If you are inside a pentest engagement root** (has `scope.md` / `program*.md` / `AGENTS.md`) → hand off to `pentest-router`, the lifecycle dispatcher for the whole engagement (scope gate → recon → registry → lot → exploitation → evidence → report → memory). It is the specialised router; this one only points you at it.

**Otherwise pick the lane:**

| The request is about… | Go to |
| --- | --- |
| "which program is worth my hours", EV math on a program | `bugbounty-program-selection` |
| "what should I hunt next", best-paying bug class | `bugbounty-high-yield-classes` |
| escalating one finding Low→High, chaining, business impact | `bugbounty-impact-escalation` |
| watching for new subdomains/assets, cert-transparency, JS diff | `bugbounty-asset-monitoring` |
| writing the English H1/Bugcrowd/Intigriti report, negotiating severity | `bugbounty-report-en` |
| writing the Spanish CyScope finding | `vuln-reporter` (mine) |
| reproducing a vuln from a `todo.md` item | `vuln-reproducer` (mine) |
| a specific injection/protocol class (SQLi, XSS, SSRF, XXE, smuggling, race, cache) | the matching `pentest-*` class skill |
| writing/reviewing/packaging a skill | `skill-writer` (mine) |
| Python code in house style | `python-writer` (mine) |
| a slide deck | `slide-writer` (mine) |
| a DALL-E / image prompt | `dalle-prompt` (mine) |
| persisting findings / feedback to memory | `write-feedback` or `pentest-memory-feedback` |

## Full catalog

### style/ — code, skills, slides & prompts
- `python-writer` — Python in Tinmarino's house style.
- `slide-writer` — Markdown decks (AcademyBook).
- `dalle-prompt` — image-generation prompts, house visual style.
- `opencode-chat-history` — inspect/resume OpenCode sessions.
- `skill-writer` — author/review/package a skill (meta-skill for this folder).
- `skill-router` — this dispatcher.

### pentest/ — lifecycle + vuln classes + hunt
`pentest-router` (lifecycle entry) · `pentest-scope-gate` · `pentest-engagement-init` · `pentest-recon-surface` · `pentest-js-recon` · `pentest-endpoint-summary` · `pentest-lot-idor` · `pentest-auth-session` · `pentest-burp-to-script` · `pentest-authz-matrix` · `pentest-graphql-hunt` · `mobile-hacking-frida` · `hunt-hunter` · `hunt-triage` · `pentest-injection-server` · `pentest-xss` · `pentest-ssrf` · `pentest-deserialization-xxe` · `pentest-http-desync` · `pentest-race-conditions` · `pentest-web-cache`.

### bugbounty/
`bugbounty-program-selection` · `bugbounty-high-yield-classes` · `bugbounty-asset-monitoring` · `bugbounty-impact-escalation` · `bugbounty-report-en`.

### report/ — evidence, packaging & memory
`pentest-findings-http` · `pentest-report-package` · `pentest-memory-feedback` · `vuln-reporter` · `vuln-reproducer` · `write-feedback`.

### tooling/ — Burp, HTTP, C2 & terminal
`http-async-rotate` · `burp-history-reader` · `burp-repeater-capture` · `rat-c2-tmux` · `browser-burp-evidence` · `persistent-terminal-control`.

## Composes with

Everything. This is the top of the chain: `skill-router` → (`pentest-router` for an engagement) → the concrete skill → its `references/`. When two skills seem to overlap, load this and pick by the boundary clause in each description.
