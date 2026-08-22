---
name: bugbounty-program-selection
description: Decide which bug-bounty program, scope asset or target deserves the next block of hours, using an expected-value rubric (bounty table x scope breadth x asset freshness x competition x triage speed x duplicate risk x payment trigger), platform-specific notes for CyScope.io / HackerOne / Intigriti / Bugcrowd / YesWeHack, the private-invite reputation math, a go/no-go gate and a hard scope-and-legality gate that must pass before the first packet. Use when the operator says "which program should I hunt", "is this program worth it", "should I keep hunting this target", "compare these programs", "do the EV math", "vale la pena este programa", "que programa cazo ahora", "en que target invierto las horas", "esto paga poco, me cambio?", "me conviene el VDP", "cual plataforma me paga mas", or before starting any new hunting wave on a platform.
---

# bugbounty-program-selection

Program selection dominates bug-finding skill. Every figure in this skill is **indicative, as of 2026-08**, gathered from public platform pages and industry reports — re-read the program's own policy and reward table before betting hours on any number here. The market direction that matters: submission volume is growing faster than bounty pools, and only a minority of incoming reports are confirmed valid platform-wide. You are not competing on cleverness — you are competing on **where you point the cleverness**. This skill turns "which program?" into arithmetic you can defend, and blocks any hours being spent before scope and legality are settled.

Output of this skill = one filled scoring table + a GO / NO-GO / TIMEBOX verdict written into the engagement notes (`pentest-memory-feedback`).

## 1. Workflow

1. **Collect candidates.** 5-15 programs max per pass. Sources: platform program list filtered by "recently updated scope", invitations inbox, VDP-to-private feeders, programs where you already have context (a re-test, an old dup, a known mobile app).
2. **Run the scope-and-legality gate (§2).** Any candidate that fails is dropped now, before a single request. Non-negotiable.
3. **Fill the rubric (§3)** — one row per candidate, one number per column. Do not skip a column by guessing "average"; an unknown column is itself a signal (opaque program = risk).
4. **Compute EV/hour (§4)** and rank.
5. **Apply the decision procedure (§5)** — GO, TIMEBOX, or NO-GO. Write the timebox in hours, with a kill criterion.
6. **Bootstrap the winner**: `pentest-engagement-init` folder + `scope.md` plus a machine-readable `oos.txt`, then `bugbounty-asset-monitoring` for the continuous delta feed.
7. **Instrument it.** Log hours, reports, verdicts, payouts per program from hour one (§6). Selection is only as good as last quarter's measured $/h.
8. **Re-run this skill every 2 weeks** or on any of these events: scope change, reward-table change, three consecutive dups, a private invite, a program going from bounty-on-triage to bounty-on-fix.

## 2. Scope and legality gate (must pass before any packet)

Hard stop. If any line is unchecked, the program is NO-GO regardless of how good the money looks.

- [ ] Policy page read **in full**, today, and its last-updated date noted.
- [ ] Program is live and accepting submissions (not paused, not "budget exhausted").
- [ ] The exact asset you intend to touch is on the **in-scope** list — wildcard interpretation confirmed in writing on the policy page, not assumed.
- [ ] Out-of-scope list transcribed verbatim into `oos.txt` as regexes; enforced by tooling, not memory.
- [ ] Forbidden techniques noted verbatim: automated-scanning caps, DoS/stress/load testing, social engineering and phishing of staff or users, physical intrusion, out-of-band interaction hosts (`interactsh` / `oast.pro` style, when the policy forbids third-party callback infrastructure), any interaction with real users' accounts or data, credential brute-force or password spraying. If the policy is silent on a technique, treat it as forbidden and ask the program, do not infer permission.
- [ ] Test data rule set: you register your own accounts; you never authenticate as, enumerate, or read the data of a real user. Cross-tenant proofs use two accounts **you** control.
- [ ] Required identification honoured: test-account email prefix, `X-Bug-Bounty-CyScope` / User-Agent header carrying your handle, source-IP registration.
- [ ] Rate ceiling stated by the program is set as the hard cap in every requester (`http-async-rotate --workers`, `nuclei -rl`). Where no ceiling is published, pick a conservative one yourself and record it. Source-IP rotation stays **off** unless the policy explicitly allows it: rotating to spread load past a stated cap, past a WAF, or past a block is evasion and gets the account banned.
- [ ] Safe-harbour / legal-authorisation clause present. No safe harbour, and jurisdiction unclear ⇒ NO-GO.
- [ ] Data-handling rule read, and the minimum-proof budget written down before testing: stop at the smallest evidence that proves the class (one foreign object id, response length + a masked field, a 200-vs-403 delta), never a bulk dump. Redact PII in evidence, keep the raw capture out of the report, delete local copies when the report closes.
- [ ] Paid-vs-VDP scope disambiguated per asset — same bug, one asset pays and the neighbouring one does not.
- [ ] Nothing from a paid client engagement is being reused, referenced or leaked into a public platform report — no client name, host, credential, national id, employee name or engagement path. Client work and bounty work stay in separate trees, separate notes and separate browser profiles.

Stop-and-report triggers, decided before you start: live production credentials, another company's data, evidence of prior compromise. On any of these — stop testing, report as urgent, do not enumerate further.

## 3. Scoring rubric — fill one row per program

Score each column 1-5 (5 = best for you). `Money`, `Freshness` and `Dup` carry double weight.

| Column | 1 | 3 | 5 | How to check |
|---|---|---|---|---|
| **Money** (x2) | median reward under platform median; Low <$100 | Medium ~$500, High ~$1.5k | High >$3k, Critical >$10k, published table | Program page reward table; Bugcrowd P1-P5 ranges; Intigriti per-asset tier |
| **Scope breadth** | one host, no wildcard | a few hosts + one app | wildcard `*.target.example.com` + mobile + API + cloud | Bugcrowd data: open scope gets ~10x more P1s |
| **Freshness** (x2) | scope static >12 months | occasional additions | asset added <30 days, acquisition, new app/API version | scope changelog, CT feed, program activity tab |
| **Competition** | public, top-10 leaderboard saturated, years old | public but niche stack | private / invite-only, or launched <2 weeks ago | participant count, resolved-report count, leaderboard depth |
| **Triage speed** | no published SLA, months of silence | ack in days | published ack <24-72h, triage <5 business days, bounty on triage | program stats: time-to-first-response, time-to-triage, time-to-bounty |
| **Dup risk** (x2) | unauth web surface, scanner-reachable | mixed | needs 2 provisioned accounts / mobile app / paid tier / GraphQL state | your class ranking, §7 |
| **Fit** | stack you have no tooling for | generic web | GraphQL, mobile app, multi-tenant B2B, IDOR-rich object model | your stack: Burp, Frida, async Python, APK reversing |
| **Payment trigger** | bounty on fix, slow vendor | bounty on fix, fast vendor | bounty on triage | policy page; decides cash-flow, 60-120d vs days |
| **Relationship** | no history | you filed there before | retests offered, known triager, prior bonus | your own log (§6) |

Fill it literally, as a markdown table, in the notes. A program with a 5 in Money and a 1 in Dup risk is a trap: everyone else also saw the 5.

## 4. EV math

Per program, per planned block of hours:

```
EV_report   = P(valid) x P(not-dup) x E[bounty | valid]
EV_hour     = (EV_report x reports_per_hour) - signal_cost
signal_cost = P(N/A) x cost_of_invite_damage
```

Calibration defaults — **rough priors, not measured constants**; replace each cell with your own log (§6) after one wave:

| Quantity | Public mature program | Public fresh scope (<30d) | Private / invite |
|---|---|---|---|
| P(valid) | 0.20 | 0.35 | 0.50 |
| P(not-dup) | 0.35 | 0.75 | 0.85 |
| Median bounty on a High | 1x table | 1x table | 1.2-2x table (rates rising here) |

Two arithmetic facts to internalise:

- **The invite pool is the real paycheck.** HackerOne has published an invite score of roughly (Signal%ile x 3 + Impact%ile x 1 + Reputation%ile x 6)/10 over a **90-day rolling** window — treat the exact weights as indicative (2026-08) and the ordering as the durable part: Reputation > Signal > Impact. A single N/A dents Signal, which dents invites, which locks you out of the tier where the rates hold up; several large public programs have cut public payouts while keeping top rates invite-only. Expected loss from one N/A routinely exceeds a $50 Low.
- **Never submit a "maybe".** If `P(valid) x bounty < P(N/A) x invite_damage`, do not send it. At a $50 Low with 40% N/A risk, the answer is always no.

Cadence rule that falls straight out of the 90-day window: a few valid reports per quarter, always. Going dark for a quarter decays you out of the invite logistic; a burst pulls a newcomer in fast. Chasing one legendary crit is worse for invites (Impact weight 1) than a steady stream of solid Highs (Reputation weight 6).

## 5. Decision procedure

Weighted score `S` = sum of columns with Money/Freshness/Dup doubled (max 60).

| Condition | Verdict |
|---|---|
| Any §2 gate line unchecked | **NO-GO** |
| Payment trigger = bounty-on-fix AND vendor has no published remediation SLA | **NO-GO** (cash-flow trap) |
| S >= 42 and Dup >= 4 | **GO** — allocate a full wave (12-20 h) |
| S 32-41 | **TIMEBOX** — 4 h, with an explicit kill criterion |
| S 24-31 | **TIMEBOX** — 2 h recon-only; go/no-go again on what the surface looks like |
| S < 24 | **NO-GO** — do not hunt out of sunk cost |
| VDP (pays $0) | **TIMEBOX** — budgeted marketing spend only: cap at 10% of the quarter's hours, and only when the org also runs a paid private program on the same platform or your 90-day score needs a lift |

Kill criteria to write down with every TIMEBOX (whichever hits first ends the block): no interesting authenticated surface after 2 h; three consecutive dups; triage silence past the program's own published SLA + 100%; measured $/h below your floor.

Set the **hourly floor** as a number, once per quarter, and enforce it mechanically: floor = the $/h of your best alternative use of the hour (your consulting day-rate / 8, or the median realized $/h of your top-2 logged programs — whichever is higher). Any program whose measured $/h (§6) sits under the floor for two consecutive waves is killed, not "given one more session". Sunk cost is the single most expensive bias in this trade.

## 6. Instrument every program (feeds the next selection pass)

Keep one row per program in the engagement notes, updated after every wave — this replaces the §4 defaults with your own measured numbers:

| Field | Note |
|---|---|
| hours_spent | wall-clock hunting, not recon-cron time |
| reports_filed / valid / dup / N/A | valid-rate and dup-rate are the two you tune on |
| median_hours_to_first_valid_bug | the best single predictor of a program's worth to *you* |
| gross_paid, days_to_cash | cash-flow, not just headline bounty |
| $/h realized | gross_paid / hours_spent |
| retests_offered | always accept — best $/h on any platform |
| bonuses / severity upgrades won | direct financial return on report quality |

Persist with `pentest-memory-feedback`. Review the table before every selection pass and at each quarter boundary.

## 7. Class-fit shortcut (what makes Dup risk high or low)

Dup rate is inversely proportional to the amount of **authenticated state** a bug class requires. Prefer programs whose surface is rich in the low-dup classes:

| Class | Payout trend | Dup risk | Prefer program if... |
|---|---|---|---|
| IDOR / BOLA, broken object-level auth | rising | low | multi-tenant, object-id-rich API, self-registration allows 2+ accounts |
| Improper access control, hidden admin routes | rising | low | role hierarchy, staff/partner portals in scope |
| Business logic / payments / race | high | lowest | money or quota state machines in scope |
| SSRF to cloud metadata | rising | medium | URL-fetch features: webhooks, renderers, import-from-URL |
| Mobile-derived hidden API surface | high | lowest | an APK/IPA is in scope — this is your edge, most hunters never open the binary |
| Info disclosure (JS, source maps, .git, keys) | rising | **high** | only worth it on scope <72 h old — first-come |
| Prompt injection / AI features | new grids, volume rising fast | low today | AI feature in scope and no published triage rubric yet: land grab — confirm first that the program actually pays for it rather than closing it informative |
| Reflected XSS, SQLi, subdomain takeover | falling / flat | very high | avoid unless chained |

Rule: if a program's scope offers you nothing above the "medium" dup line, its Money score does not matter.

## 8. Platform notes

| Platform | Selection-relevant mechanics |
|---|---|
| **HackerOne** | LLM triage (Hai) reads first and clusters dups on the title/first paragraph — a generic title *creates* dup risk by itself. Signal goes negative on N/A. 90-day rolling invite score, weights 6/3/1 (Rep/Signal/Impact). Programs publish per-program SLA and reward tables — read time-to-bounty, not just the max number. Crypto/blockchain is the outlier vertical for high/critical averages, well above every other industry, but the scope is smart-contract-heavy and the competition is specialised. |
| **Bugcrowd** | VRT P1-P5 is authoritative, not CVSS — check the public VRT for your target class *before* committing hours; P4/P5 is where unpaid work lives. Bugcrowd's *recommended* ranges (indicative 2026-08; each program overrides them, so read that program's table) run roughly P1 low-thousands to $20k+, P2 mid-four-figures, P3 high-hundreds to low-thousands, P4 low-hundreds, P5 unpaid. Open-scope programs are reported to receive an order of magnitude more P1s than restricted ones. Triage SLA is per-program — read it on the brief rather than assuming the platform benchmark. |
| **Intigriti** | Per-asset tiers (1-5) — same bug on a tier-1 vs tier-3 asset can be a 5x difference, so read the scope table before choosing the target. Ranged bounties interpolate on the CVSS score inside the band, so CVSS argumentation is literally paid work here — chain to `bugbounty-report-en` for the vector. The Exceptional band sits at the very top of the CVSS range (around 9.5+, confirm on the current severity page). |
| **YesWeHack** | The published grid is a *maximum* per severity, not a guarantee; mature EU criticals reach the five-figure EUR range. A credit system taxes submissions and refunds more on acceptance, so low-severity spraying is self-limiting by design — select programs where you expect High+. Reputation points scale with grid severity, with a bonus for a correct self-scored CVSS and for resolution; verify the current credit and point values on the platform before optimising for them. Often less crowded than US platforms for the same asset class. |
| **CyScope.io** | cyscope.io returns HTTP 403 to automated fetches; **no public reward table could be verified**. Before allocating hours, confirm from inside the platform: (a) is this bounty, VDP, or paid per-engagement work; (b) per-finding by severity or per-engagement fee; (c) who owns the finding and can it ever be publicly disclosed. Until (a)-(c) are answered in writing, score Money as unknown and treat it as TIMEBOX only. Reports there are Spanish CyScope format — chain to `vuln-reporter`, not to the English bounty template. |

Cross-platform: if the same asset class is in scope on two platforms, prefer the one with the higher per-asset tier and the less crowded hunter base, not the higher headline maximum.

## 9. Anti-patterns

- **Hunting the biggest brand.** Name recognition correlates with hunter count, not with your payout. The dup rate eats the whole difference.
- **Optimising the reward table alone.** A $20k P1 ceiling on a five-year-old, single-host, unauthenticated scope is worth less per hour than a $1.5k High on a fresh multi-tenant API.
- **Ignoring the payment trigger.** Bounty-on-fix on a slow vendor is 60-120 days of unpaid capital. Check before, not after.
- **Sunk-cost persistence.** "I already spent 12 h here" is not an input to the next hour's decision. Kill criteria exist for this.
- **VDP drift.** Unbudgeted VDP hours are unpaid work dressed as strategy. Cap them, or do not do them.
- **Spraying Lows to "stay active".** Signal damage and (on YWH) credit drain cost more than the bounties. Cadence means *valid* reports, not any reports.
- **Skipping the §2 gate because the program looks obviously fine.** Out-of-scope submissions are the cheapest reputation loss available, and the paid-vs-VDP asset split catches experienced hunters constantly.
- **Selecting once and never re-running.** Scope changes, reward tables get cut, programs pause or exhaust their budget. Re-run every two weeks.
- **Trusting a first-pass rubric filled with guesses.** Replace defaults with your own logged numbers (§6) as soon as you have one wave of data.
- **Splitting one root cause across N reports** to inflate volume — one dup, one Low, one N/A. Group by root cause; that is a reporting decision made at selection time, when you choose a scope with many endpoints behind one flaw.

## Composes with

`pentest-engagement-init` (bootstrap the chosen program's folder, scope.md, todo/done loop) · `bugbounty-asset-monitoring` (continuous CT/JS/subdomain delta feed once GO) · `pentest-js-recon` and `pentest-lot-idor` (consume the delta queue) · `http-async-rotate` (rate-capped mass enumeration within the program's stated ceiling) · `burp-history-reader` and `pentest-findings-http` (evidence capture) · `pentest-endpoint-summary` (never re-test what is closed) · `bugbounty-report-en` (English platform report) · `vuln-reporter` and `pentest-report-package` (CyScope Spanish deliverable) · `bugbounty-impact-escalation` (raise the payout of what you find) · `pentest-memory-feedback` (per-program $/h log that feeds the next selection pass) · `bugbounty-high-yield-classes` (pick the class once the program is chosen) · `mobile-hacking-frida` (the lowest-dup surface, and a Fit=5 signal when an APK is in scope).
