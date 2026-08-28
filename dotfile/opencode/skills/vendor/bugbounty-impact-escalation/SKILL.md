---
name: bugbounty-impact-escalation
description: Turn a Low/Medium bug-bounty finding into a High/Critical payout by chaining primitives and proving business impact — the per-class escalation ladder, safe maximum-impact PoCs, cross-account and privilege-boundary proofs, and how to document a chain so triage scores the chain, not its weakest link. Use when the operator says "how do I escalate this finding", "can I chain these two bugs", "this is only medium", "prove business impact", "cómo escalo este hallazgo", "puedo encadenar esto", "me lo van a cerrar como informativo". For picking what to hunt next, use bugbounty-high-yield-classes.
source: public-methodology
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
---

# bugbounty-impact-escalation

Payout is superlinear in severity: on most published bounty tables a Critical pays several times a Medium — roughly 3–10x on mature programs, but the only number that matters is the one in *this* program's table, so read it before deciding an escalation is worth the hour (ratios indicative, checked 2026-08). So the highest-ROI hour in bug bounty is almost never "find another bug" — it is "spend 60 more minutes on the bug I already have until it crosses a boundary that costs the customer money".

> **Identify your traffic on every request.** Set the attribution header the program asks for; if the policy names none, set one anyway so the blue team can separate you from a real incident. On CyScope.io the byte-exact value is:
>
> ```
> X-Bug-Bounty-CyScope: Tinmarino
> ```
>
> On HackerOne / Bugcrowd / Intigriti / YesWeHack use the handle-based header or UA the program specifies. A wrong-cased header returns the same 200 as the correct one, so verify with `grep`, never assume. See `pentest-scope-gate`.


Rule: **never submit the primitive. Submit the consequence.** A primitive is what the server let you do; a consequence is what it lets you do *to somebody else*.

Authorized, in-scope testing only. Every rung below is legal only inside a program whose policy covers the asset. Re-read the policy before escalating: escalation is exactly where a valid test turns into an out-of-scope or destructive one. Honour stated rate ceilings, keep your platform handle in the `User-Agent`, never touch an account, tenant or bucket you did not create, and never social-engineer staff or users — that is out of scope on every platform.

## 1. Workflow

1. **Name the primitive in one line.** "I can read object N belonging to another tenant", "I can make the server fetch a URL", "I can set a field the UI does not expose". If you cannot write that line, you do not have a finding yet.
2. **Classify the boundary you have already crossed** (§2). None crossed ⇒ this is Informative today; keep digging or drop it.
3. **Walk the ladder for the class** (§3) one rung at a time, stopping at the highest rung you can prove *safely and in scope*.
4. **Look for a chain partner** (§4): does any earlier finding, JS-recon leak, or mobile-only endpoint supply the missing input of the next rung?
5. **Build the safe maximum-impact PoC** (§5) — smallest action that is unambiguous, on assets you control, bounded, reversible.
6. **Quantify** (§6): records, users, dollars, regulated data classes, blast radius of the credential.
7. **Score the chain, not the link** (§7): one report, chain title, CVSS vector for the end state.
8. **Time-box.** If a rung has not moved in 90 minutes, submit the highest proven rung and note the next rung as "believed reachable, not demonstrated"; do not sit on a valid High for a week chasing a Critical.

## 2. Boundary table — what actually moves severity

| Boundary crossed | Typical band | Proof required |
| --- | --- | --- |
| None (own data, own session) | Informative | — |
| Own account → another **user** in the same tenant | Medium → High | two accounts you control, distinct semantic marker (email, total, name) |
| Tenant A → tenant B | High → Critical, often `S:C` | two orgs you registered, screenshot of both org ids |
| User → **staff/admin** role | Critical | one admin-only read performed with the escalated identity |
| App → **infrastructure** (metadata, internal service, bucket, CI) | Critical | named internal asset + live principal (`sts:GetCallerIdentity`-class call only) |
| Read → **write** on any of the above | +1 band | benign, reversible mutation, then revert |
| Interaction required → **zero-click** | +1 band | say explicitly "attacker knows only the victim's email" |
| Authenticated → **unauthenticated** | +1 band, `PR:N` | reproduce in a clean browser profile / `curl` with no cookies |

The last three rows are the cheapest upgrades in the game. Before writing anything, re-test the finding (a) with no session, (b) with the write verb, (c) with no victim interaction.

## 3. Escalation ladders by class

Read each ladder left to right; stop when the next rung would need harm, out-of-scope assets, or a forbidden technique.

| Class | Rung 1 (Low) | Rung 2 (Medium/High) | Rung 3 (Critical) |
| --- | --- | --- | --- |
| IDOR / BOLA | read own-tenant object by id | read a **second account you own** across the boundary; if scale is genuinely in doubt, sample the smallest set that proves non-randomness (~10–20 ids) and stop | cross-tenant read plus an unauthorized `PATCH`/`DELETE` **on your own second tenant's object**, or leaked email → password reset → ATO of your own second account |
| Info disclosure (JS, sourcemap, `.git`) | endpoint names, internal paths | a live key / internal admin route reached | key used for a single read-only identity call (`whoami`-class) that proves the scope it grants — name the reachable data, do not download it |
| Improper access control | hidden route returns 200 | route performs a privileged read | route performs a privileged *write* against a tenant you control from an account that must not be able to |
| Mass assignment | injected field echoed back | `role`/`plan`/`tenantId` accepted | escalated account performs an admin-only action that was previously 403 |
| SSRF | DNS-only callback | full response read from an internal service, named | IMDSv2 token → role creds → **one** read-only `sts:GetCallerIdentity`; only if the policy names cloud-credential retrieval as permitted, otherwise stop at proving `169.254.169.254` responds |
| GraphQL | introspection enabled (never file alone) | field-level authz leak on a list query | alias batching defeats the OTP/2FA rate limit **against your own second account** (count the accepted aliases; never guess a real user's code), or a nested edge crosses tenants |
| JWT / session | decodable token, missing flags | token accepted after logout / role downgrade | forged token for your own second account performs an action its role forbids |
| File upload | arbitrary type stored | parser bug (SVG/XLSX XXE, headless-renderer SSRF) | executed code (`id` only) or XXE reaching metadata |
| Mobile (APK/Frida) | hardcoded key, exported component | mobile-only endpoint with weaker authz | that endpoint swept cross-tenant, or deeplink hands over a session token |
| Subdomain takeover | claimable host, unused | host referenced in live `script src` / CSP / CORS allowlist | claim the host only if the policy permits it, serve a single inert marker file, prove script execution / cookie scope with your own browser, then release the host and say so |
| Business logic | limit bypassed once | reproducible economic effect | quantified loss: "coupon worth $X redeemed N times", ledger before/after |

## 4. Chain patterns that pay

Keep a running `doc/summary/chain-<program>.md` per program — one line per primitive you hold, filed or not: `<date> | <primitive in one sentence> | <endpoint> | <what input it produces> | <what input it still needs>`. Grep it by the *needs* column before every submission; most Criticals are two Lows you already had.

| Have | + Have | = Report |
| --- | --- | --- |
| user-id enumeration | password-reset that binds weakly | zero-click ATO |
| JS-leaked internal route | missing role check | admin panel access |
| SSRF (blind) | internal service with unauth admin API | full read + config change |
| mobile-only endpoint | sequential object ids | cross-tenant mass PII read |
| self-XSS | login CSRF or cookie-scope bug | stored XSS firing in a second browser profile you control, never a real user's session |
| takeoverable subdomain | `Domain=.target.example.com` cookie | session theft |
| verified leaked key | a bucket/DB it opens (list one prefix, read nothing) | data exposure with the key as vector, quantified by object count only |

Chain hygiene: **one report per root cause**. A chain with one root cause and five endpoints is one report; two independent root causes chained are still best filed as one report *if* the chain is the impact — say so explicitly in the summary ("Bug A alone is Low; combined with B it yields full ATO, filed together as the chain is the impact").

## 5. Safe maximum-impact PoC rules

Hard limits, no exceptions:

- Only accounts, orgs, tenants, buckets and callback hosts **you** created or own (`rat-c2-tmux` for callbacks — never a third-party interaction host if the program forbids it).
- **Sample, do not harvest.** Two accounts you own prove the authz break; ~10–20 ids prove the pattern is enumerable; hundreds or thousands of real customers' records prove nothing extra and are a policy violation. Redact every third-party value in the report (keep a stable hash or the first two characters so triage can match), say that you redacted, and delete local copies once the report is triaged.
- Writes must be **benign, randomly named, reversible**: one file `poc-<rand>.txt`, one cosmetic field, then revert and say you reverted with a timestamp.
- RCE proof stops at `id` / `hostname`. No persistence, no lateral movement, no reading other customers' data, artifact path disclosed in the report.
- Cloud creds: retrieve only if the program allows it; one identity call; never enumerate. If out of scope, prove the token endpoint responds and stop, stating why.
- Race conditions: minimum concurrency that proves it (20–50 parallel requests, one burst), never sustained thousands. Over-firing is the fastest way to a ban and a paused program.
- No DoS, no stress/load testing, no automated scanners against production unless the policy names them as allowed — an escalation that degrades service is unpaid and reportable against you.
- **Stop-and-report triggers**: real production credentials, another company's data, evidence of prior compromise. Stop testing, report as urgent immediately.

Quick re-test harness (run before writing, catches the three cheap upgrades):

```bash
# 1. does it work UNAUTHENTICATED?  (PR:N is worth a full band)
curl -si 'https://target.example.com/api/v2/orders/1337' | head -20

# 2. does the WRITE verb work too?  (read -> write is +1 band)
for m in GET PUT PATCH DELETE POST; do
  printf '%s -> ' "$m"
  curl -s -o /dev/null -w '%{http_code}\n' -X "$m" \
    -H "Authorization: Bearer $TOKEN_A" \
    'https://target.example.com/api/v2/orders/1337'
done

# 3. cross-ACCOUNT and cross-TENANT with a semantic marker, not just a status code
for T in "$TOKEN_A" "$TOKEN_B"; do
  curl -s -H "Authorization: Bearer $T" \
    'https://target.example.com/api/v2/orders/1337' | jq -r '.customer.email // "DENIED"'
done
```

Scale evidence (sampled, resumable, rate-limited — build it with `http-async-rotate`):

```bash
python3 Script/sweep.py -f ../Lot/order-ids-20.txt --workers 5 --resume \
  --out ../Findings/AI042/wave01 --max-authfail 3
# grade hits by PII density, not by count
jq -r '[.id, ((.customer.email//"-")|.[0:2]+"***"), (.customer.national_id|"REDACTED")]|@csv' \
  ../Findings/AI042/wave01/*.json | sort -u \
  | tee ../Findings/AI042/hits-orders-pii-redacted.csv | wc -l
```

## 6. Quantify the impact

Write the impact sentence in the customer's units, first paragraph, before any technical detail:

- **Records + identities**: "20 sequential ids returned 18 distinct customers' full name, national ID and address; ids are sequential, so the pattern extends to the whole table — I stopped at 20."
- **Money**: "a 40 USD coupon redeemed 12 times on one order I created"; "23 seats provisioned on a 5-seat plan".
- **Regulated classes**: national ID, health, payment, credentials — name them, they drive the customer's own risk math.
- **Blast radius** for infra: which service, which permission class, how many objects — without enumerating.
- **Attacker preconditions**, stated honestly and up front: an honest `UI:R` beats an inflated `UI:N` that a triager catches.

## 7. Documenting the chain so triage scores the end state

- **Title = end state, not primitive.** "Chained JS-leaked internal route + missing role check allows any registered user to read arbitrary tenants' invoices on `api.target.example.com`" — not "information disclosure in main.js".
- **Summary** names each link and the end state in 2–3 sentences: "Step 1 (Low on its own) yields X; step 2 consumes X to reach Y; combined result is Z."
- **A numbered chain diagram in text**: `leaked ORG_UUID -> /internal/orgs/{uuid}/invoices (no role check) -> invoices of tenant B`.
- **Steps to reproduce start from a fresh account** and never assume state built during your recon; every value concrete, both identities annotated.
- **CVSS vector for the end state**, pasted in full, with one clause per metric a triager could contest — especially `S:C` when the chain crosses a tenant boundary.
- **Say the sentence explicitly**: "Filed as one report because the links share a root cause / because the chain is the impact; each link in isolation is Low."
- On Bugcrowd cite the **VRT path of the end state**; on Intigriti confirm the **asset tier** of the final endpoint (same chain on a tier-1 asset can pay 5x).
- Keep the raw evidence with its mtimes intact — the full request/response pairs under `Findings/<case>/`, the sweep JSON, and a `.har` or Burp export — then `sha256sum` the bundle into the report. Timestamps are what settle a duplicate dispute.
- If the top rung is only *believed* reachable, say so in one line and offer to demonstrate on request. Never imply you did something you did not do.

## 8. Anti-patterns

- **Filing the primitive.** "Introspection enabled", "JWT is decodable", "cert pinning bypassed", "app is decompilable", "app allows uploads" — all Informative, all Signal damage.
- **Splitting the chain into three reports.** One dup, one Low, one N/A instead of one Critical.
- **Bundling unrelated root causes** into one report to look impressive — you get paid once and triage picks the cheapest link.
- **Severity padding.** One dishonest metric and every future report from you is discounted. Inflated `S:C` on a same-account bug is the classic tell.
- **Harvesting to "prove scale."** 50k records is not stronger evidence than 100; it is a policy violation and can void the bounty.
- **Escalating on assets you do not own** — a real user's account, a third-party SaaS tenant, another company's bucket. Never, regardless of how good the PoC would be.
- **Destructive proof.** Deleting, defacing, persisting, pivoting. Prove capability, not damage.
- **Chasing rung 3 forever** while a solid High rots unsubmitted and someone else files it. Time-box.
- **Arguing severity with adjectives** after submission instead of adding evidence once (see `bugbounty-report-en` §B4).
- **Testing scope you never checked**: match the host and path of every rung against `scope.md` / `oos.txt` *before* the escalation, not after. A chain whose Critical rung lands on an out-of-scope asset pays the Low.

## 9. Pre-submit checklist

- [ ] A boundary from §2 is crossed and demonstrated, not asserted
- [ ] Re-tested unauthenticated, with write verbs, and without victim interaction
- [ ] Highest safe rung of the class ladder reached; next rung noted honestly if unproven
- [ ] Chain partners searched in `chain.md` and prior findings
- [ ] PoC uses only assets I own; sampled, redacted, reversible, cleaned up
- [ ] No real user's account, data or availability was touched at any rung; third-party values redacted
- [ ] Impact quantified in records / money / regulated data in the first paragraph
- [ ] Title states the end state; CVSS vector is for the end state
- [ ] One root cause per report; chain justification sentence present
- [ ] Scope + program policy re-checked (`oos.txt`, rate rules, forbidden techniques)
- [ ] Evidence archived with timestamps before submitting

## Composes with

`pentest-lot-idor` (build the id lots for scale evidence) · `http-async-rotate` (bounded, resumable, rate-limited sweeps) · `pentest-js-recon` (leaks that become chain inputs) · `mobile-hacking-frida` (mobile-only surface = lowest-dup rungs) · `pentest-findings-http` (raw request/response evidence + negative controls) · `pentest-endpoint-summary` (record which rung each endpoint reached) · `rat-c2-tmux` (own callback host for SSRF/XXE/upload proofs) · `bugbounty-report-en` (write the English report and argue severity) · `pentest-report-package` (bundle + adversary review) · `vuln-reporter` (Spanish/CyScope conversion) · `bugbounty-asset-monitoring` (catch new surface first, before duplicates) · `pentest-memory-feedback` (persist the chain and what the rung cost you).
