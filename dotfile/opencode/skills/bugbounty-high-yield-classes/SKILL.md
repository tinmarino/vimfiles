---
name: bugbounty-high-yield-classes
description: Ranked dollars-per-hour playbook of bug-bounty vulnerability classes (IDOR/BOLA, broken auth chains, business logic and races, SSRF to cloud metadata, GraphQL authz, mass assignment, JWT, upload-to-RCE, cloud/CI exposure, mobile-only API surface, subdomain takeover) with per-class hunting checklist, keep-digging signal, escalation move that raises the severity tier, and the usual informative-closure to pre-empt. Use when choosing what to hunt next on a program, when a target's tech stack is known and the next attack class must be picked, or when a finding needs to be escalated a tier before submission. Triggers on "what should I hunt next", "which bug class pays best", "highest paying vulnerability", "how do I escalate this finding", "why do my reports get closed as informative", "pick the next attack surface", "que busco ahora", "que clase de bug paga mas", "como subo la severidad de este hallazgo", "por que me lo cerraron como informativo", "elige el proximo vector", "cual es el mejor uso de mi tiempo en este programa".
---

# bugbounty-high-yield-classes

Bug count is not the metric. Realized dollars-per-hour is set by three multipliers: **class base rate** (authz/logic classes pay 3–10x reflected-XSS-tier on the same program), **the escalation move** (the one extra step that crosses a tenant/user boundary or reaches cloud credentials), and **triage friction** (an Informative closure is pure unpaid time). This skill ranks the classes and, for each, gives the four things that decide the money: what to check, when to keep digging, how to escalate a tier, and which closure reason to pre-empt in the report body. All ratios and dollar figures here are indicative orders of magnitude observed across public platform data as of 2026-08; re-read the program's own reward table before trusting any of them.

> **Identify your traffic on every request.** Set the attribution header the program asks for; if the policy names none, set one anyway so the blue team can separate you from a real incident. On CyScope.io the byte-exact value is:
>
> ```
> X-Bug-Bounty-CyScope: Tinmarino
> ```
>
> On HackerOne / Bugcrowd / Intigriti / YesWeHack use the handle-based header or UA the program specifies. A wrong-cased header returns the same 200 as the correct one, so verify with `grep`, never assume. See `pentest-scope-gate`.


Authorized, in-scope testing only. Read the program policy and `oos.txt` before the first request; honour stated rate ceilings and any required test-account convention; never brute-force credentials or touch a real user's account; no social engineering, phishing or physical testing; no availability testing. Put your platform handle in the User-Agent (`User-Agent: bb-<handle>`) so the blue team can attribute the traffic.

## 1. Workflow — pick the next class in 7 steps

1. **Fingerprint the stack.** `~/go/bin/httpx -u https://target.example.com -tech-detect -title -sc -favicon -json` plus the mobile app presence, GraphQL endpoint presence, and cloud provider. (Absolute path: `~/.local/bin/httpx` is the *Python* client, not ProjectDiscovery.)
2. **Read the reward table and the exclusions.** A program that excludes DoS, self-XSS and rate-limiting deletes half the class list before you start.
3. **Select with the decision table (§2)** — highest ranked class whose precondition the stack satisfies and whose exclusion does not apply.
4. **Time-box it** (§3). Blow the box → move to the next class, do not sink cost.
5. **Hunt with the class section's checklist**, watching for that class's keep-digging signal.
6. **Before writing anything: run the escalation move.** One tier of severity is 2–4x the payout and costs 30–60 minutes.
7. **Pre-empt the closure reason** in the report body, then hand off to `bugbounty-report-en` / `pentest-report-package`. Escalation detail lives in `bugbounty-impact-escalation`; whether the program is worth the hours at all is `bugbounty-program-selection`.

## 2. Decision table — stack observed → class to hunt

| Rank | Class | Hunt it when you observe | Skip it when | Dup risk | Scriptable |
| --- | --- | --- | --- | --- | --- |
| 1 | IDOR / BOLA at scale | Any numeric/UUID object id in path, query, body or header; multi-tenant product; self-registration open | Ids are 128-bit with no leak path anywhere | low | yes (`http-async-rotate`) |
| 2 | Broken auth / ATO chains | Password reset, email change, OAuth/SSO callback, invite accept, magic link, MFA | Single-sign-on delegated entirely to a third party out of scope | low | partly |
| 3 | Business logic & races | Money, quota, seats, coupons, credits, withdrawals, points | Program excludes "business risk accepted" classes | lowest | minimal concurrency only |
| 4 | SSRF → cloud metadata | Webhooks, avatar-by-URL, PDF/HTML render, import-from-URL, SVG/XML/DOCX parsing, SSO metadata URL | No URL-fetch primitive anywhere | medium | no |
| 5 | GraphQL authz | `/graphql`, `/api/graphql`, `/gql`, or a graph seen in the mobile bundle | Graph is a thin proxy over an already-tested REST tier | low | yes |
| 6 | Mobile-only API surface | An APK/IPA in scope | No app in scope | low | after teardown |
| 7 | Mass assignment | REST/GraphQL CRUD where read fields exceed documented write fields | Write API is a strict allowlisted DTO with no echo | medium | yes |
| 8 | File upload → RCE | Avatar, KYC doc, CSV/XLSX import, attachment, theme/plugin, resume | Uploads land on an isolated CDN origin and are never parsed | medium | no |
| 9 | JWT / session | JWT in any header/cookie; multi-service estate | Opaque server-side session ids only | medium | yes (offline crack) |
| 10 | CI/CD & bucket exposure | Public org repos, bucket names in JS/APK, `/actuator`, sourcemaps in prod | Program excludes third-party repos | high | yes |
| 11 | Subdomain takeover | Freshly added scope, dangling CNAME/NS | Mature scope already swept by everyone | very high | yes |

Rule that predicts dup rate: **dup risk is inversely proportional to the authenticated state a bug requires.** Two provisioned accounts, a paid tier, or a mobile binary is where the low-competition money is.

## 3. Time-boxes

| Class | Box | Exit condition |
| --- | --- | --- |
| Mobile teardown (6) | 4–8 h, do it FIRST on any target with an app | Hidden host/endpoint list extracted, then feed 1/5/7 |
| IDOR sweep (1) | 2–4 h | No shape inconsistency across ids after full request-set replay |
| GraphQL (5) | 2 h | Schema recovered and every sensitive field authz-checked |
| Auth chains (2) | 3 h | All credential flows mapped, tokens bound correctly |
| Logic/race (3) | 2 h per state machine | No server-computed value influenceable |
| SSRF (4) | 2 h per primitive | No DNS callback from any candidate |
| Upload (8) | 2 h | File served off-origin, no parser reachable |
| Mass assignment (7) | 1 h per CRUD resource | Every extra read field round-tripped and rejected |
| JWT / session (9) | 1–2 h | Signature verified everywhere, lifecycle revokes correctly |
| CI/CD & buckets (10) | 2 h | No verified live secret, no anonymous bucket verb |
| Takeover (11) | 1 h total | Nothing dangling; move on |

## 4. Class playbooks

### 4.1 IDOR / BOLA at scale — rank 1

- Enumerate every object-carrying parameter from Burp history (`burp-history-reader`): `id`, `uuid`, `*_id`, `ref`, `folio`, `documentId`, base64/UUID blobs, ids in JSON bodies, headers (`X-Account-Id`) and path segments.
- Provision two accounts in the **same** tenant and two in **different** tenants. Replay account A's full request set with B's session; diff status + body length + a semantic marker (an email, a total, a name).
- Four mutations per request: id only; id + own auth; method swap (GET→PUT/DELETE, `X-HTTP-Method-Override`); array/object wrapping (`id=1` → `id[]=1`, `{"id":["1","2"]}`) to defeat single-value authz checks.
- Sweep predictable ranges with the async rotator, `--resume`, `--max-authfail`. Grade hits by **PII density**, not count.
- Test read **and** write: an unauthorized `PATCH` is a full tier above an unauthorized `GET`.

**Keep digging when:** response *shape* varies across ids (200 / 403 / 404 with different body lengths) — authz is per-handler, so some handler lacks it. Also when a foreign UUID is *accepted* but returns "not found": lookup is scoped, permission check is not — find the sibling endpoint that leaks the UUID.

**Escalation move:** quantified mass-extraction PoC — 50–100 records, distinct victims, one unambiguously regulated PII field, consolidated CSV row count screenshotted. Then chain leaked email + internal id → password-reset/invite → ATO. "Read PII" is High; "read arbitrary users' PII at scale, then take over one" is Critical.

**Usual closure:** same-account/same-tenant access, or an unguessable id with no leak path. Pre-empt by always including the **discovery path for the id** and a second unrelated victim account.

### 4.2 Broken auth & ATO chains — rank 2

- Map every credential-bearing flow: register, login, MFA, reset, email change, OAuth/SSO callback, invite accept, magic link, session refresh, device de-registration.
- Reset tokens: entropy, reuse after use, expiry, **binding** (swap the `email`/`user` param, keep the token), leakage via `Referer` or the reset page's HTML/JS.
- Email change: does it require the current password? invalidate sessions? accept a normalizing collision (`victim+x@`, unicode, trailing dot, case)?
- OAuth: `redirect_uri` path/subdomain laxity, missing or replayable `state`, code substitution across clients, `id_token` audience unverified.
- MFA: does the pre-MFA session already authorize API calls? are backup-code/reset endpoints rate-limited? can the second step simply be omitted?
- Session invalidation on password change, logout, role revocation.

**Keep digging when:** an endpoint accepts *both* an identifier and a secret in one request (`?email=&token=`) — that pairing is where binding checks are forgotten. Or a pre-auth token that any authenticated-looking endpoint accepts.

**Escalation move:** zero-interaction, no-prior-knowledge ATO on a second account you control, recorded end to end, with preconditions stated ("attacker knows only the victim's email"). Interaction-required drops a tier.

**Usual closure:** "requires the victim to click your link" without showing the link is same-origin/legitimate; bypass shown only against your own session; rate-limiting-only with no takeover.

### 4.3 Business logic & race conditions — rank 3

- Inventory state machines touching money or entitlement: checkout, refund, coupon, credit transfer, plan upgrade, seat quota, withdrawal, points, referral.
- Per machine: out-of-order steps (skip 2, replay 3), negative/zero/overflow quantities, currency and decimal precision, re-submitting a terminal step (`confirm` twice).
- Race: single-packet (HTTP/2) or last-byte sync on the **limit-enforcing** endpoint — redeem, withdraw, accept-invite, vote, claim. **20–50 parallel is plenty; never thousands.** Over-firing is the fastest route to a program ban.
- TOCTOU across services: check-balance in A, debit in B.
- Limits enforced client-side, per-session instead of per-user, or per-endpoint instead of per-resource.

**Keep digging when:** a response reflects a server-computed total, remaining quota or price that you can influence with a parameter you were not meant to send; or the same operation exists on web API + mobile API + GraphQL mutation and only one enforces the limit.

**Escalation move:** express it in the program's own money units — "coupon worth $X redeemed N times on one order", "23 seats on a 5-seat plan", "withdrew 4x balance" — with a before/after ledger screenshot. Unquantified logic bugs sit at Medium.

**Usual closure:** "works as designed" / accepted business risk; race proven only in your own account with no economic consequence; non-reproducible timing. Always state exact concurrency and ≥3 successes out of N attempts.

### 4.4 SSRF, including cloud metadata — rank 4

- Hunt primitives, not parameter names: webhooks, PDF/HTML render, image resize/proxy, avatar-by-URL, link preview, import-from-URL, XML/SVG/DOCX parsing, SSO metadata URL, S3-compatible endpoint config.
- Blind first — point every candidate at your own callback host (`rat-c2-tmux`) and log DNS + HTTP. A DNS-only hit still proves SSRF.
- Bypass order: 302 redirect to internal → DNS rebinding → alternate encodings/decimal IP → `[::]` / `0.0.0.0` → credentials-in-URL (`http://169.254.169.254@evil`) → protocol swap (`gopher://`, `file://`, `dict://`).
- Metadata: `169.254.169.254` (AWS), `metadata.google.internal` with `Metadata-Flavor: Google`, `169.254.169.254/metadata/instance?api-version=...` with `Metadata: true` (Azure), and ECS/EKS `169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`.
- IMDSv2 is a speed bump only: with method + header control the `PUT /latest/api/token` handshake succeeds and the token unlocks credentials.

**Keep digging when:** timing or error text differs between `127.0.0.1:22` and `127.0.0.1:1`. A full-read SSRF is worth ~5x a blind one — spend the hour proving you can read the body.

**Escalation move:** "internal HTTP reachable" → **named internal service + retrieved credential or internal admin panel**. Retrieving temporary IAM credentials and doing exactly one benign identity call (`aws sts get-caller-identity`, nothing else, never a data API, never a write) is the jump to Critical. Redact the credential body in the report to its first 4 characters and state you deleted the local copy. Where the policy does not explicitly allow credential retrieval, stop at proving `PUT /latest/api/token` responds and say so — that is already enough for the severity argument.

**Usual closure:** DNS-only interaction on a documented webhook feature; metadata endpoint returning nothing because you never obtained an IMDSv2 token. Always name the internal asset reached.

### 4.5 GraphQL abuse — rank 5

```bash
for p in /graphql /api/graphql /v1/graphql /gql /query; do
  curl -s -o /dev/null -w "%{http_code} $p\n" -X POST "https://target.example.com$p" \
    -H 'Content-Type: application/json' -d '{"query":"{__schema{queryType{name}}}"}'
done
```

- Introspection disabled? Brute the schema via field suggestion ("Did you mean…"), or pull it from the mobile bundle / JS chunks (`pentest-js-recon`).
- **Diff the mobile graph against the web graph** — mobile clients reach mutations the web UI never exposes.
- Field-level authz: for every type, request sensitive fields (`email`, `phone`, `role`, `internalNotes`, `paymentMethod`) on objects reachable from a public/list query. The object is authorized; the field often is not.
- Batching & aliasing: 50–100 aliased copies of a login/OTP/redeem mutation in one HTTP request defeats per-request rate limiting.
- Nested traversal: `me { organization { members { email } } }` — walk edges until you cross a tenant boundary.
- Try feature-flagged/legacy mutations anyway; flags are usually front-end only.

**Keep digging when:** a field returns `null` with **no error** — that is a resolver-level check on one path; a sibling path (list query, nested edge, aliased args) usually skips it.

**Escalation move:** convert a field-authz leak into cross-tenant PII enumeration at scale (feeds §4.1's rotator sweep), or convert alias batching into an actual OTP/2FA bypass. Batching alone is Low; batching that defeats an auth rate limit is High.

**Usual closure:** "introspection enabled" filed alone (informational nearly everywhere), and depth/complexity DoS where the program excludes DoS. Never file introspection — file the data it let you reach.

### 4.6 Mobile-derived hidden API surface — rank 6 (the operator's edge)

Best $/h *ratio* for someone with APK reversing + Frida, because most hunters never open the binary. Full tooling in `mobile-hacking-frida`.

- Static: strings/resources for API keys, Firebase config, hardcoded basic-auth, staging hostnames, and — highest value — **endpoints and GraphQL operations that exist only in the mobile client**.
- `AndroidManifest.xml`: `exported="true"` components, `android:debuggable`, `usesCleartextTraffic`, `allowBackup`, every deeplink/App Link `intent-filter`.
- Deeplinks: fuzz for params reaching a WebView (`?url=`), for auth/reset **token handoff** (an ATO primitive), and for state mutations without confirmation.
- Exported components: invoke from a benign unprivileged app **on your own test device/AVD with your own test account only** (`adb shell am start -n com.acme.app/.SomeActivity -d 'acme://...'`); look for content providers exposing files/DB and services acting on behalf of the logged-in user.
- WebViews: `setJavaScriptEnabled` + `addJavascriptInterface` + attacker-controllable URL = RCE-class; `setAllowFileAccess` / `setAllowUniversalAccessFromFileURLs` = local file theft.
- Bypass pinning with Frida to reveal the hidden API surface — pinning hides, it does not protect.

**Keep digging when:** a mobile-only host or an `X-Api-Version` / `X-Client` header changes behaviour on the *same* endpoint. Legacy mobile API versions are where authz checks were never backported.

**Escalation move:** never stop at "hardcoded key". Take the key to its service and prove the access it grants (another user's record, a bucket LIST, a Firebase query on a test document you created); report as data exposure with the key as vector. An exported activity is Low until it is a token-stealing deeplink or a WebView RCE.

**Usual closure:** public-by-design client identifiers (many Firebase/Maps/analytics keys), `exported` with no reachable sensitive action, pinning bypass or root-detection bypass reported as a bug in itself, "app is decompilable".

### 4.7 Mass assignment / over-posting — rank 7

- For each read endpoint, diff response fields against documented write fields; every extra response field is a candidate to POST back.
- Round-trip the whole read object into the write endpoint; watch for accepted `role`, `isAdmin`, `verified`, `tenantId`, `balance`, `plan`, `emailVerified`, `permissions`, `owner`.
- Alternate content types on the same handler (JSON vs form vs XML) — binders differ in strictness.
- GraphQL input types leak the exact over-postable field names for free.
- Nested (`{"user":{"role":"admin"}}`) and array wrapping when flat fails.

**Keep digging when:** the API echoes the injected field even with no visible effect — the write reached the model; find the read path that honours it (often another service or a delayed job).

**Escalation move:** escalate to a real admin/staff role in a second account, then perform one benign admin-only read to prove the role is live.

**Usual closure:** field changed with no security consequence, or a change the UI reverts / the backend recomputes. Always show a post-change authorized action that was previously denied.

### 4.8 File upload → RCE (and the near misses that still pay) — rank 8

- Enumerate every sink: avatar, KYC document, CSV/XLSX import, attachment, logo, theme/plugin, resume, signature image.
- Order: (a) extension/content-type bypass to a server-executable type, (b) path traversal in the filename, (c) zip-slip, (d) parser bugs — SVG→XXE/stored XSS, XLSX/DOCX→XXE, PDF/HTML→SSRF via headless renderer, ImageMagick/ffmpeg/ghostscript on crafted media.
- Find where the file is **served from**: same origin + executable path = RCE candidate; separate CDN origin caps you at sandbox stored XSS (often Low).
- Is the file processed by a background worker? That is where the unsandboxed converter lives.
- Confirm out-of-band callbacks against your own C2, never a third-party interaction host if the program forbids it.

**Keep digging when:** the server renames your file but preserves the extension, or returns a *different* error for valid-but-wrong-type vs malformed — real parsing is happening, and parsers break.

**Escalation move:** arbitrary file write → code execution, only where the policy permits an execution PoC — `id` / `hostname` and nothing else, no shell, no persistence, no lateral movement, no reading application data, delete the artifact immediately and disclose its full path and timestamps in the report. Where execution PoCs are forbidden, stop at proving the write landed at a server-executable path and argue severity from that. Out of reach? Escalate the parser bug instead — XXE reading `/etc/passwd` or reaching metadata folds into §4.4 and lands High.

**Usual closure:** "uploaded a .php that never executes", stored XSS on an isolated sandbox domain, unrestricted-file-type with no execution or XSS. Always show the retrieval URL and its response `Content-Type`.

### 4.9 JWT & session flaws — rank 9

- Decode every token: `alg` (none / HS-RS confusion), `kid` (traversal, SQLi, remote `jku`/`x5u`), missing `exp`, unverified audience/issuer, and whether the signature is verified at all (flip one claim byte and resend).
- Weak HMAC secret: bounded offline crack against common wordlists. A cracked secret is instant Critical.
- Lifecycle: does logout revoke server-side? does password change revoke other sessions? are tokens accepted after a role downgrade? is a refresh token replayable after logout?
- Cookie hygiene is a **chain input, not a report**: missing `HttpOnly`/`SameSite`/`Secure`, `Domain=.example.com` breadth (chains with §4.11).

**Keep digging when:** a token carries authorization data (`role`, `tenant`, `scope`) in the payload instead of a server-side lookup — that design only holds if verification is perfect on every service, and one legacy service is usually wrong.

**Escalation move:** forge a token for a different account or higher role and perform an authorized action with it; then show the forged token is accepted by multiple services (shared secret across the estate).

**Usual closure:** cookie-flag-only reports, "JWT is decodable" (base64 is not encryption), expiry-too-long without a theft path. Never file token-structure observations without a forged-token action.

### 4.10 CI/CD & cloud-storage exposure — rank 10 (highest single payouts, fastest decay)

```bash
# Only against orgs/repos/buckets the program lists as in scope.
trufflehog github --org=acme-inc --only-verified --json > log/th-acme.json
gitleaks detect --source ~/Lot/Repo/acme-web --report-format json --report-path log/gitleaks-acme-web.json
python3 ~/opt/cloud_enum/cloud_enum.py -k acme -k acme-prod -k acmecdn -t 10 -l log/cloudenum-acme.txt
```

- Buckets: harvest names from JS bundles, APK resources, `Referer`-leaked asset URLs. Test anonymous LIST, READ, and — carefully, with a random harmless key — WRITE. Write access to a bucket serving production JS is Critical.
- Public org repos and forks: `.env`, cloud keys, CI tokens, `*.pem`, webhook URLs; check **deleted files in history** and public CI logs printing env.
- CI surfaces: exposed Jenkins/Actions/GitLab runners, `pull_request_target` + untrusted checkout, self-hosted runners on public repos.
- Config endpoints: `.git/`, `.svn/`, `/actuator/env`, `/debug/pprof`, `.DS_Store`, prod sourcemaps, prod Swagger/OpenAPI.
- **Validate every secret out-of-band and minimally** — one identity call (`aws sts get-caller-identity`, `GET /user` for a GitHub token, `getent`-equivalent whoami for the service), nothing else, never a data read — and report immediately; value decays hourly against rotation. Never commit a found secret anywhere, never test it from an IP you would not want logged.

**Keep digging when:** a credential is *live* (identity call returns a principal). Dead keys pay nothing.

**Escalation move:** name the principal and its blast radius (service, permission class) as the provider reports it — never enumerate or download data to "measure" it. For a writable bucket, write one benign random-named zero-content file (`bb-poc-<handle>-<epoch>.txt`), screenshot it, delete it, and say so; never overwrite an existing key.

**Usual closure:** expired keys, public-by-design static buckets, sourcemaps/Swagger with nothing sensitive, secrets in a repo that is not the target's. Prove asset ownership in the report.

### 4.11 Subdomain takeover & dangling infra — rank 11 (near-commodity)

Only worth it on scope added in the last ~30 days (see `bugbounty-asset-monitoring`).

- Passive CNAME sweep of the full in-scope set; flag PaaS/CDN/SaaS CNAMEs with unclaimed fingerprints, plus dangling `NS`, `MX`, abandoned cloud IPs.
- Verify claimability **without claiming** (fingerprint the unclaimed-service error page, confirm the CNAME resolves to a provider that allows arbitrary claims). Claim only where the policy explicitly permits it; then serve one static text file at a random path (`/bb-poc-<handle>-<epoch>.txt`), never a login form, never JS, never anything that could capture a real user's data, and release the claim once triage confirms.
- Second order: the takeoverable asset referenced in a `script src` on a main site (→ XSS on the main origin), in a CSP allowlist, or in an OAuth `redirect_uri` allowlist.
- Cross-check cookie `Domain=.example.com` scope — session theft turns Low into High.

**Keep digging when:** the dangling host appears in live traffic of a production page (JS include, iframe, CORS allowlist). That is typically the difference between a bottom-of-table payout and a High-tier one (order of magnitude ~$150 vs ~$2,000 on mid-size public programs, indicative 2026-08).

**Escalation move:** cookie/session theft or script execution on the parent origin, or OAuth code interception. Put the chain in the title.

**Usual closure:** no proof it can be claimed; parked host with no traffic; "social engineering only". Most programs default takeover to Low without a chain — do the chain first.

## 5. Anti-patterns

- **Filing the primitive instead of the consequence.** Introspection enabled, cookie flags, decodable JWT, hardcoded client key, "app is decompilable", cert-pinning bypass — every one is unpaid unless a cross-boundary consequence is demonstrated.
- **Splitting one root cause across N endpoints.** One authz flaw on 12 endpoints is ONE report listing 12 evidence lines. Splitting buys duplicates and reputation damage.
- **Bundling N distinct root causes into one report.** The mirror error: one bounty for N bugs.
- **Submitting a "maybe".** Expected value = P(valid)×bounty − P(N/A)×invite-pool damage. A $50 low at 40% N/A risk is negative EV: Informative/N/A drag the rolling signal/accuracy score that platforms use to gate private invites, and private programs are where dup risk is lowest. Sit on a "maybe" until you have the cross-boundary proof, or drop it.
- **Racing with thousands of requests.** 20–50 parallel proves it; more is a ban.
- **Bulk third-party PII pasted into the report.** Sample 50–100, show 3 redacted, say you deleted the local copies. Several programs void bounties over this.
- **Chasing reflected XSS, SQLi and subdomain takeover on mature public scope.** Falling rewards, saturated dup rate. Chain them or skip them.
- **Testing before reading scope.** Out-of-scope submissions are the cheapest possible reputation loss.
- **Sinking the whole day into one class.** Honour the §3 boxes.
- **`httpx` from `~/.local/bin`.** That is the Python HTTP client. Always `~/go/bin/httpx`.
- **Continuing past a stop-and-report trigger.** Live production credentials, another company's data, evidence of prior compromise → stop testing, report as urgent.

## 6. Pre-submission gate

- [ ] Escalation move for the class was attempted, not skipped
- [ ] Two accounts you control; cross-boundary proven, not same-account
- [ ] Scale sampled (50–100), redacted, local copies deleted and said so
- [ ] Discovery path for every id/token included
- [ ] The class's usual closure reason explicitly pre-empted in the body
- [ ] One root cause per report
- [ ] Reproduces first try from a clean profile in under 5 minutes
- [ ] Asset confirmed in scope and not in `oos.txt`, on the paid (not VDP) scope

## Composes with

`bugbounty-program-selection` (is this program worth the hours at all), `bugbounty-impact-escalation` (the full escalation ladder per class), `bugbounty-asset-monitoring` (fresh surface → lowest dup), `bugbounty-report-en` (write and negotiate the English report), `pentest-lot-idor` (build the id lots), `http-async-rotate` (sweep them), `pentest-js-recon` (mine bundles for endpoints and secrets), `mobile-hacking-frida` (APK teardown, class 6), `burp-history-reader` / `pentest-findings-http` (parameter inventory and evidence capture), `pentest-endpoint-summary` (never re-test a closed endpoint), `rat-c2-tmux` (own callback host for SSRF/upload OOB), `pentest-report-package` (bundle and adversary-review), `vuln-reporter` (Spanish CyScope conversion), `pentest-memory-feedback` (per-program $/hr tracking).
