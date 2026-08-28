---
description: "Print a colorized terminal dashboard of verified vulns ready to report, ranked by probability of acceptance x ease of reproduction x clarity of real impact"
allowed-tools: Bash(*)
---
Show me the report-ready vulnerabilities for the current engagement, ranked so I know what to submit first.

Resolve the engagement root (walk up from cwd to the nearest `AGENTS.md`; if `$ARGUMENTS` names a root, use it). Then run:

```
python3 ~/.claude/skills/hunt-hunter/bin/dashboard.py --root <ROOT> --color always
```

The dashboard reads `hunt/DONE.md` (confirmed VULNs), the evidence under `Findings/<ID>/`, `Report/<ID>/`, and the dedup oracles, and prints a colored table sorted by a composite of **P(acceptance) 45% · ease of reproduction 30% · clarity of impact 25%**. It only lists proven, attacker-reachable, not-yet-submitted findings.

After printing it, add one line naming the single finding I should package/submit first and why (pull it from the top row). If `hunt/TRIAGE.md` exists, reconcile: mention any finding the triage pass flagged for human review (e.g. money moved over the 5 USD / 5000 CLP cap) so I don't submit it blind. Do not modify any files — this is a read-only view.
