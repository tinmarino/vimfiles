---
name: bugbounty-report-en
description: "Write the English-language bug-bounty report that maximizes payout on HackerOne, Bugcrowd, Intigriti and YesWeHack — impact-first structure, defensible CVSS vector / VRT path, minimal-but-complete reproduction from a clean account, evidence packaging with PII discipline, and the negotiation playbook for duplicate, informative, N/A and severity-downgrade closures plus mediation. Use when the operator says 'write the H1 report', 'submit to HackerOne', 'draft this for Bugcrowd', 'pick the VRT category', 'argue severity', 'they downgraded my report', 'this was marked duplicate', 'closed as informative', 'request mediation', 'convert this CyScope finding to English', 'escribir el reporte en ingles', 'subir a Bugcrowd', 'pasar este hallazgo a bounty', 'me lo cerraron como duplicado', 'me lo bajaron de severidad', 'pedir subida de severidad', 'pedir mediacion'."
---

# bugbounty-report-en

The English counterpart to `vuln-reporter`. On a bounty platform the report is a **sales document read in about 90 seconds by a triage contractor with a queue**. Payout is set by how fast they reproduce it, what business impact they can forward verbatim to the customer, and whether you made the severity easy to agree with. Technical quality is necessary and not sufficient.

> **Identify your traffic on every request.** Set the attribution header the program asks for; if the policy names none, set one anyway so the blue team can separate you from a real incident. On CyScope.io the byte-exact value is:
>
> ```
> X-Bug-Bounty-CyScope: Tinmarino
> ```
>
> On HackerOne / Bugcrowd / Intigriti / YesWeHack use the handle-based header or UA the program specifies. A wrong-cased header returns the same 200 as the correct one, so verify with `grep`, never assume. See `pentest-scope-gate`.


Everything here is for **authorized, in-scope** testing under a published program policy. Read the policy before the first request, not after.

Non-negotiable, on every platform: no denial-of-service or load testing, no automated scanning where the policy forbids it, no social engineering of staff or users, no persistence/backdoors, no pivoting to out-of-scope hosts, and no touching accounts you do not own. Test cross-account authorization with **two accounts you registered yourself** — never against a real customer's record. Stop enumerating the moment the boundary is proven. Rate-limit yourself to what the policy states and identify your traffic with the header the program asks for (commonly `X-Bug-Bounty: <handle>` or a program-specified UA); if none is specified, set one anyway so the blue team can tell you apart from an incident.

## 0. Activation

Use when drafting, converting or defending a finding on HackerOne / Bugcrowd / Intigriti / YesWeHack. Do **not** use for CyScope Spanish deliverables — that is `vuln-reporter`. Do not use for internal engagement notes — that is `pentest-findings-http`.

## 1. Workflow

1. **Gate the submission.** Answer in one sentence: *who* can do *what* to *whom*, crossing which boundary. If the answer contains "could", "might", or "an attacker with admin access", stop — see §7. A single Informative/N/A costs more expected dollars (lost private invites) than a Low pays.
2. **Confirm scope.** Asset in `scope.txt`, not matching `oos.txt`. Check whether the asset sits in the *paid* scope or a VDP scope on the same program — same bug, one pays and one does not.
3. **Re-reproduce from zero.** Clean browser profile, freshly registered account A, second account B you also control. The number-one cause of a downgrade to Informative is silent dependence on stale state.
4. **Choose the root cause boundary.** One root cause = one report, endpoints listed as evidence. N distinct root causes = N reports. Never split one authz flaw across 12 endpoints; never bundle 12 unrelated bugs.
5. **Chain before you write.** Info leak → IDOR → ATO is a Critical; the same three filed separately are one dup, one Low, one N/A. Spend the extra hour on the chain, not on the prose.
6. **Score it.** CVSS 3.1 vector (H1 / Intigriti / YWH) *and* the exact VRT path (Bugcrowd). See §3.
7. **Write the body top-down** in the §2 order. Impact before technical detail, always.
8. **Package evidence** per §4: sampled, redacted, timestamped, minimal.
9. **Self-check** against the §6 payout checklist. Cut everything that is not needed to reproduce or to price the bug.
10. **Submit, then shut up.** Answer triage questions; do not add "additional observations" to a live report.
11. **Negotiate once, with evidence, before resolution** (§5). After payment the bounty is final.
12. **Take the retest** when offered — loaded context, fixed fee, best dollars-per-hour on the platform.

## 2. Canonical body order

Do not reorder. Triage reads top-down and stops early.

| # | Section | Rule |
| --- | --- | --- |
| 1 | **Title** | `<Vuln class> in <component> allows <unauthenticated?> attacker to <business outcome>`. The H1 AI triage layer dup-clusters on title + first paragraph, so carry the concrete endpoint and impact — never "IDOR in /v1/users". |
| 2 | **Summary** | 2–3 sentences. Who can do what to whom. No hidden preconditions. |
| 3 | **Impact** | *Before* the technical detail. Quantified: how many records, whose data, what an attacker monetizes, whether it chains. One sentence of regulatory/financial exposure. No FUD. |
| 4 | **Steps to reproduce** | Numbered, copy-pasteable, from a fresh account. Concrete values. Verbatim curl with your own token as `<TOKEN_A>`. Name both account identities. |
| 5 | **Proof of concept** | 30–90 s video or annotated screenshots; a self-contained script when enumeration is the point. |
| 6 | **Impact at scale** | Argue the *reachable population* from the id space and the response codes, not from harvested data: "IDs are sequential 32-bit integers with no authorization check; 5 adjacent ids returned HTTP 200 with distinct Content-Length. No third-party records were retrieved." |
| 7 | **Severity rationale** | Vector string + one clause per metric a triager might contest. |
| 8 | **Remediation** | 2–4 concrete lines a dev can ship this sprint. Costs nothing, buys goodwill and speed. |
| 9 | **References** | CWE id, OWASP, vendor doc. |

Title examples:

```text
GOOD  IDOR in GET /api/v2/orders/{id} on api.target.example.com allows any authenticated user to read arbitrary customers' PII (full name, national ID, address)
GOOD  Cross-tenant PII read of arbitrary users via unauthenticated GraphQL field `customer.email` on api.target.example.com
BAD   IDOR found in orders endpoint
BAD   Critical vulnerability - full data leak!!
```

## 3. Severity: what actually pays, per platform

| Platform | Authoritative scale | Money lever |
| --- | --- | --- |
| HackerOne | CVSS (3.1 or 4.0 depending on the program's configuration) → severity **band** (None/Low/Med/High/Crit) | The band picks the bounty bracket, not the decimal. Moving 6.9 → 7.0 is worth more than any paragraph. Check which CVSS version the report form offers before you write the rationale. |
| Bugcrowd | **VRT** P1–P5 (CVSS is secondary) | Cite the exact VRT category path verbatim; arguing outside the taxonomy loses. Most unpaid disputes live on the P4/P5 line. |
| Intigriti | Per-asset tier × severity matrix; ranged bounties interpolate within the severity band | Get the asset tier right — the spread between the top and bottom tier of one program is often several-fold. Their scale puts *Exceptional* at the top of Critical, so an extra half-point of vector can change the band. Re-read the program's own matrix; tiers change. |
| YesWeHack | CVSS + program grid ("up to" per severity) | You self-score; the program regrades. Accurate self-scoring feeds the reputation/points system and a wrong one costs you there — treat the vector as graded work, not a bid. |
| CyScope (ES) | CVSS vector + free-form `severity_score`, no bounty | Different skill: `vuln-reporter`. |

Metric-by-metric leverage:

| Metric | Cheap mistake | Prove this instead |
| --- | --- | --- |
| AV | leaving Network unargued | state internet-reachable, give the public URL |
| AC | accepting AC:H for "needs timing" | show ≥3 successes out of N with the exact concurrency |
| PR | filing PR:L when anonymous access exists | self-registration = PR:L; if any unauthenticated path works, prove **PR:N** |
| UI | accepting UI:R | show no victim click is needed, or that the click is a normal in-app action |
| **S** | never claiming it | crossing a tenant/account boundary is frequently **S:C** — the single biggest score jump |
| C/I/A | C:L for "some data" | enumerate the field list; PII, credentials or tokens = **C:H** |

Always paste the **vector string**, never just the number. Never inflate: a triager who catches one dishonest metric discounts everything you ever file.

Platform scales, tiers, bounty tables and reputation formulas change without notice — every figure above is indicative as of **2026-08** and must be re-read on the program page before you cite it in a reply. Never quote a number to a triager that you have not just verified on their own policy page.

Compute the score locally so the number in your report cannot be contradicted:

```bash
pip install cvss   # provides CVSS2/CVSS3/CVSS4 classes
python3 -c '
from cvss import CVSS3
c = CVSS3("CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:N/A:N")
print(c.clean_vector(), c.scores(), c.severities())
'
# -> CVSS:3.1/... (9.3, 9.3, 9.3) ("Critical", "Critical", "Critical")
```

If the band is one notch below the next bounty bracket, re-examine **S** and **PR** first — those are the two metrics with real, arguable evidence behind them.

## 4. Evidence packaging

- **Video**: 30–90 s, no audio, no dead time, both account identities annotated on screen. Over 2 minutes is a downgrade risk.
- **Screenshots**: full window, URL bar visible, red box on the money field, both accounts side by side.
- **Raw HTTP**: request + response in a fenced block. Redact your session tokens and third-party PII — but never so hard that the request stops being reproducible. Pull these from `pentest-findings-http` output.
- **Scripts**: one self-contained file, `argparse`, no embedded secrets, clean before/after output. Compose with `python-writer` and `http-async-rotate`.
- **PII discipline — minimum proof, always**: the boundary is proven by **your two own accounts**, not by volume. Read account B's object from account A, show the negative control, stop. If the program's policy explicitly allows demonstrating scale, prove *enumerability* with the smallest sample that shows the id space is walkable (a handful of ids, response codes and lengths only — no bodies), then stop; do not dump records. Never store, screenshot in the clear, or paste third-party PII, and never enumerate real customers to "count" them. State the discipline in the report: "Confirmed cross-account read with two accounts I registered. Enumerability shown from response codes on 5 adjacent ids; no third-party records were retrieved or stored." If you did unavoidably receive third-party data, say so, redact it, delete the local copies, and say that too. Bulk third-party PII in a report is a policy violation on most programs and can void the bounty.
- **Timestamps**: keep the raw `log/httpx-*.json`, `.patch` files and Burp items — they settle duplicate disputes by proving discovery time.

```bash
# minimal reproducible request block for the report
curl -sS -i 'https://api.target.example.com/api/v2/orders/10432' \
  -H 'Authorization: Bearer <TOKEN_A>' | head -40
# negative control — the SAME object requested with its legitimate owner's token (account B,
# also registered and owned by you). Proves the object exists and that the boundary is what broke.
curl -sS -i 'https://api.target.example.com/api/v2/orders/10432' \
  -H 'Authorization: Bearer <TOKEN_B>' | head -40
# and unauthenticated, to settle PR:N vs PR:L
curl -sS -i 'https://api.target.example.com/api/v2/orders/10432' -o /dev/null -w '%{http_code}\n'
```

## 5. Negotiation playbook

Triagers are contractors under SLA mediating between you and a customer that wants to pay less. They upgrade when you hand them an argument they can forward **verbatim**. Reply **once**, with new *evidence*, not new adjectives. Always close with deference.

**Severity upgrade**

```text
Adding one data point rather than re-arguing: the id space is sequential and the endpoint is
reachable with a freshly self-registered account (no invite, no prior knowledge). Attached is the
cross-account read between two accounts I registered myself, plus response codes (no bodies) for
5 adjacent ids showing the space is walkable. I did not retrieve third-party records.
Since the data crosses a tenant boundary I read this as S:C —
CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:N/A:N = 9.3.
Was the tenant boundary considered for Scope? Happy to defer to your rating either way.
```

**Duplicate contest**

```text
Understood. Could you confirm the original's submission date and whether it covers
POST /api/v2/orders/{id}/refund specifically? My report adds unauthenticated access and a
write primitive (PATCH), which I did not see reflected in the current severity.
If the original does cover it, no objection at all — please close this as duplicate.
```

**Mediation request** (only after the on-report conversation genuinely stalled)

```text
Requesting mediation on response time. Submitted 2026-04-01, triaged 2026-04-03,
no response on the report since. No dispute on the technical content; I am only asking
for a status update and a severity decision.
```

Closure decision table:

| Closure | Contest? | Move |
| --- | --- | --- |
| Duplicate, genuinely earlier and same scope | No | Accept in one line. Contesting real dups burns Signal. |
| Duplicate, but you show materially higher impact | Yes, once | Ask for a partial, a re-open, or an upgrade of the original. Many programs pay. |
| Informative, and you *can* now show consequence | Yes, once | Reply with the new PoC on the same report. Never open a second report. |
| Informative, and you cannot | No | Log it in `pentest-memory-feedback` as a class to stop filing. |
| N/A for scope | No | Your fault. Read `oos.txt` first next time — cheapest reputation loss in the game. |
| Severity downgraded | Yes, once, before resolution | Evidence + vector + question. Anchor on the program's own bounty table or the VRT path, never on what another program paid you. |
| Unresponsive past SLA | Mediation | Factual and dated only. |

Never: all caps, "this is clearly critical", threats to disclose, public tweeting, contacting the company outside the platform, or re-litigating the same point twice. Disclosure happens only through the platform's coordinated-disclosure request — a unilateral write-up forfeits the bounty and can get you banned.

## 6. Payout checklist (run before submit)

- [ ] Reproduces first try, from a clean account, in under 5 minutes
- [ ] Impact in the customer's language (records, users, money, regulation) inside the first 3 sentences
- [ ] Two account identities named; negative control included
- [ ] CVSS vector present and defensible metric by metric; VRT path cited on Bugcrowd; asset tier checked on Intigriti
- [ ] Chained further than the class implies
- [ ] Scale argued from the id space and response metadata, not from harvested records; the sentence saying you minimized, redacted and deleted is present
- [ ] Both accounts are ones you registered yourself; no real customer's account or data was touched
- [ ] Remediation the dev can ship this sprint
- [ ] One root cause per report
- [ ] Zero recon narrative, zero unrelated observations, zero severity padding
- [ ] Filed on the *paid* scope, not a VDP scope
- [ ] Submitted fast on freshly shipped surface — first-mover beats depth on mature programs

## 7. Anti-patterns

| Anti-pattern | Cost |
| --- | --- |
| Filing a "maybe" | N/A and Spam closures drag Signal down, and Signal/Impact gate the private invites where the rates actually are. One Low does not pay for the invite you stop receiving. |
| Recon narrative before the impact | Burns triage patience in the first 90 seconds; measurably lowers payout. |
| Splitting one authz root cause across many reports | Dup cascade + reputation hit. |
| Bundling unrelated bugs into one report | One bounty for N bugs. |
| Reporting the *technique*, not the consequence | "Introspection enabled", "JWT is decodable", "cert pinning bypassed", "app is decompilable", "hardcoded API key in the bundle" — all Informative on their own. File what the technique let you *reach*, and see `bugbounty-impact-escalation` before submitting a bare primitive. |
| Cookie-flag-only / rate-limit-only reports | Informative unless chained to a demonstrated takeover. |
| Inflating one CVSS metric | Permanent credibility discount across everything you file. |
| Pasting bulk third-party PII as proof | Policy violation; can void the bounty. |
| Arguing severity twice, or after resolution | Reputational damage with zero upside; post-payment bonuses rarely land. |
| Automated scanning, high-rate fuzzing or load testing where the policy forbids it | Ban, plus you get blamed for an unrelated outage. Read the rate-limit clause; throttle; identify your traffic. |
| Enumerating real users' records to "show scale" | Policy violation, voided bounty, and in several jurisdictions it exceeds the authorization the program grants. Two own accounts prove the same bug. |
| Leaving a client name, real hostname, national ID, employee name or token in a bounty report | These reports may become public. Scrub to `target.example.com` / ACME. |
| Copying the CyScope Spanish skeleton verbatim | Adjuntos/Tiempos tables and Contramedidas-as-mandatory read as noise to English triage. |

## 8. Converting a CyScope finding into a bounty report

1. Hoist **Impacto** to the top and rewrite it in quantified English.
2. Rewrite the title into `<class> in <component> allows <outcome>`.
3. Drop the **Adjuntos** and **Tiempos** tables; use inline media and platform metadata.
4. Compress **Descripción** into Summary; move **Solicitud / Parámetro vulnerable / Carga** into Steps to reproduce.
5. Keep **Contramedidas** but cut it to 2–4 lines as Remediation.
6. Add the severity-rationale paragraph (vector + contested metrics + VRT path).
7. **Scrub every client identifier**, hostname, national ID, employee name, token and engagement path; replace with `target.example.com` / ACME. Assume the report becomes public. Also confirm the finding is *yours to file*: a bug found under a paid consulting engagement belongs to that client's contract and is not a bounty submission unless that client runs the program and the contract permits it.
8. Reverse direction (bounty → CyScope Spanish) is `vuln-reporter`'s job.

## Composes with

`bugbounty-impact-escalation` (raise the band before you file) · `vuln-reporter` (Spanish CyScope counterpart) · `vuln-reproducer` · `pentest-findings-http` (raw evidence capture) · `pentest-report-package` (bundling + adversary review before submit) · `pentest-lot-idor` and `http-async-rotate` (scale evidence) · `pentest-js-recon` and `pentest-endpoint-summary` (surface + coverage) · `mobile-hacking-frida` (lowest-dup mobile findings) · `rat-c2-tmux` (own-infra callbacks for blind PoCs) · `python-writer` (PoC scripts) · `pentest-memory-feedback` (per-program valid-rate, dup-rate and $/hr tracking).
