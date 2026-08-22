---
name: bugbounty-asset-monitoring
description: Continuous attack-surface monitoring for first-mover advantage on bug-bounty programs — passive subdomain enumeration, certificate-transparency polling and streaming, httpx liveness/fingerprint diffing, JS bundle content diffing to catch newly shipped endpoints, cloud/bucket discovery, verified secret-leak watch, all scheduled with systemd user timers and alerting on DIFF ONLY. Use when the operator says "monitor new subdomains", "watch for new assets", "cert transparency", "certstream", "diff the JS bundles", "set up recon cron", "quiero enterarme primero de la nueva superficie", "monitorear nuevos subdominios", "vigilar nueva superficie", "diff de bundles JS", "cron de recon", "alertame cuando aparezca un host nuevo", or when starting a long-running public/private program where duplicates are the main threat to dollars-per-hour.
---

# bugbounty-asset-monitoring

On a mature public program almost every non-duplicate high bounty comes from surface that did not exist last week. The edge is **latency, not cleverness**. Target: new asset discovered → tested in under 4 hours. That is a scheduling problem. Everything here is cron-able, idempotent, and emits a **diff**; the diff is the work queue.

Rule that governs the whole skill: every stage ends in `... | anew state/X.txt > new/$D/X.txt`. `anew` appends only unseen lines to the baseline **and prints exactly those new lines**. Non-empty file ⇒ something shipped ⇒ go hunt.

## 0. Environment gotchas — read before copy-pasting anything

> **`httpx` NAME COLLISION.** `$PATH` puts `~/.local/bin` before `~/go/bin`, and `~/.local/bin/httpx` is the *Python* HTTP client, NOT ProjectDiscovery httpx. Every command below uses the absolute path `~/go/bin/httpx`. Silently breaks every recon one-liner you paste from the internet. Set `HTTPX=~/go/bin/httpx` in the monitor script.

Already installed: `assetfinder ffuf gobuster httprobe ~/go/bin/httpx interactsh-client naabu nuclei shuffledns subfinder waybackurls` in `~/go/bin`, `amass` in `/snap/bin`, `gitleaks` in `~/.local/bin`, plus `jq git curl systemctl python3.12`.

Install the rest once:

```bash
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest && pdtm -ia   # dnsx katana tlsx notify uncover alterx cdncheck
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/BishopFox/jsluice/cmd/jsluice@latest
go install github.com/trufflesecurity/trufflehog/v3@latest   # v3 is Go; the old PyPI "truffleHog" is v2, do not use it
pipx install git+https://github.com/initstring/cloud_enum    # not on PyPI under that name
go install github.com/glebarez/cero@latest
npm -g install js-beautify
```

## 1. Directory contract

Mirrors `pentest-engagement-init`. One directory per program.

```
~/Bounty/<program>/
  scope.txt          # wildcard roots, one per line, copied from the program page (`*.` stripped — see 2.1)
  oos.txt            # out-of-scope regexes — ENFORCED on every stage, never optional
  state/             # the baseline; a GIT REPO
    subs.txt live.txt urls.txt js.txt endpoints.txt ports.txt
    js/<sha1>.js     # beautified bundle bodies
  new/<YYYY-MM-DD>/  # today's deltas only == the work queue
  log/
  bin/monitor.sh
```

`state/` being a git repo is not decoration: `git log -p state/subs.txt` is your free history **and your timestamped proof of first discovery**, which is what settles duplicate disputes. Commit at the end of every run.

## 2. Numbered workflow

### 2.1 Passive subdomain enumeration (hourly)

```bash
cd ~/Bounty/acme; D=$(date +%F); mkdir -p new/$D log
sed 's/^\*\.//' scope.txt | grep -v '^$' > /tmp/roots.txt     # grep -Ff never matches a literal "*." prefix
subfinder -dL /tmp/roots.txt -all -silent > /tmp/sf.txt
amass enum -passive -df /tmp/roots.txt >> /tmp/sf.txt          # amass v4 dropped -silent; check `amass enum -h` for your build
assetfinder --subs-only $(tr '\n' ' ' < /tmp/roots.txt) >> /tmp/sf.txt
grep -Ff /tmp/roots.txt /tmp/sf.txt | grep -vEf oos.txt | anew state/subs.txt > new/$D/subs.txt
```

Brute/permutation tier is noisy and costly — **daily, not hourly**:

```bash
alterx -l state/subs.txt -silent | dnsx -silent -r ~/wordlist/resolvers.txt | grep -vEf oos.txt | anew state/subs.txt
shuffledns -d target.example.com -mode bruteforce -w ~/wordlist/subs-top100k.txt -r ~/wordlist/resolvers.txt -silent | grep -vEf oos.txt | anew state/subs.txt
```

### 2.2 Certificate transparency (15 min poll, or streaming)

```bash
curl -s --retry 3 --max-time 60 "https://crt.sh/?q=%25.target.example.com&output=json" > /tmp/crt.json
jq -r '.[].name_value' /tmp/crt.json | tr '[:upper:]' '[:lower:]' | sed 's/^\*\.//' \
 | sort -u | grep -Ff /tmp/roots.txt | grep -vEf oos.txt | anew state/subs.txt >> new/$D/subs.txt
```

crt.sh 502s under load. **Treat empty output as failure, not as "nothing new"** — otherwise you never notice the feed died:

```bash
jq -e 'length > 0' /tmp/crt.json >/dev/null 2>&1 || echo "CT FEED DOWN $(date -Is)" >> log/health.txt
```

Same query shape works on `https://api.certspotter.com/v1/issuances?domain=target.example.com&include_subdomains=true&expand=dns_names`.

Streaming is where first-mover really lives (minutes after issuance): a small persistent Python consumer of a CertStream-compatible websocket filtering `data.leaf_cert.all_domains` against scope regexes into `state/subs.txt`. Run it as a **systemd user service with `Restart=always`**, never cron. The public certstream endpoint is flaky — self-host `calidog/certstream-server-go`. A cert is often issued *before* the service goes live: re-probe such hosts every 10 min for the first few hours.

### 2.3 Liveness / fingerprint diffing (hourly, chained after 2.1)

```bash
~/go/bin/httpx -l new/$D/subs.txt -silent -sc -title -tech-detect -cdn -favicon -location \
  -json -o log/httpx-$D.json -rl 10 -H "User-Agent: bugbounty-<your-platform-handle>"
jq -r '[.url,.status_code,((.tech//[])|join(",")),.title,.favicon]|@tsv' log/httpx-$D.json \
  | anew state/live.txt > new/$D/live.txt
cut -f1 new/$D/live.txt > new/$D/live-urls.txt
```

`-rl 10` (req/s) is a deliberately dull default: raise it only to whatever the program policy explicitly permits, and lower it the moment you see 429s or WAF blocks. Diff on the **tuple, not the hostname**. A host flipping 403→200, or whose title/tech/favicon-hash changed, is as interesting as a brand-new host. Favicon mmh3 hash is the cheapest "same app, new hostname" pivot: `uncover -q 'http.favicon.hash:<h>'`.

Ports, weekly: `naabu -list state/subs.txt -top-ports 1000 -silent | anew state/ports.txt`.

### 2.4 JS bundle diffing — the highest-yield signal (every 2 h)

New endpoints appear in JS minutes before they appear anywhere else, and feature-flagged functionality is routinely reachable.

```bash
katana -list state/live-urls.txt -jc -d 3 -silent -em js | anew state/js.txt >  new/$D/js.txt
gau --subs target.example.com   | grep -E '\.js(\?|$)'   | anew state/js.txt >> new/$D/js.txt
waybackurls target.example.com  | grep -E '\.js(\?|$)'   | anew state/js.txt >> new/$D/js.txt

while read -r u; do
  h=$(printf '%s' "$u" | sha1sum | cut -c1-12)
  curl -sL --max-time 30 "$u" | js-beautify -f - > /tmp/$h.new 2>/dev/null || continue   # `-f -` = read stdin
  if [ -f state/js/$h.js ]; then
    diff -u state/js/$h.js /tmp/$h.new > new/$D/jsdiff-$h.patch || echo "CHANGED $u" >> new/$D/js-events.txt
  else
    echo "NEW $u" >> new/$D/js-events.txt
  fi
  cp /tmp/$h.new state/js/$h.js
done < state/js.txt
```

**Beautify before hashing/diffing** or every rebuild is a false positive (minifier chunk-hash churn). Then mine only the `+` lines — that is the day's new attack surface:

```bash
grep -h '^+' new/$D/jsdiff-*.patch | jsluice urls -R | jq -r '.url' | anew state/endpoints.txt > new/$D/endpoints.txt
grep -h '^+' new/$D/jsdiff-*.patch | jsluice secrets | jq -c 'select(.severity=="high")'
```

`jsluice` parses the AST and reconstructs `fetch(BASE + "/v2/" + id)` — regex-grep cannot. Also pull `.js.map` → `.sourcesContent` when present: pre-minification code and internal path names. New GraphQL operation names or route strings feed straight into `pentest-lot-idor`.

### 2.5 Cloud and TLS-derived assets (daily)

```bash
cloud_enum -k acme -k acme-prod -k acmecdn -t 20            # keywords derived from the ORG's own naming only
cero target.example.com | grep -Ff scope.txt | anew state/subs.txt
tlsx -l state/subs.txt -san -cn -silent -resp-only | grep -Ff scope.txt | anew state/subs.txt
```

Bucket names also fall out of the JS diffs (`jsluice urls` catches bucket hosts). Org-owned buckets are usually in scope; third-party SaaS tenants usually are not — check `oos.txt` **before** touching anything. On an open bucket, prove it with a directory listing plus **one** benign object HEAD; do not download the corpus and do not open files containing other people's data — the listing is the finding.

### 2.6 Secret / code-leak watch (every 6 h)

```bash
trufflehog github --org=acme --only-verified --json | jq -c 'select(.Verified==true)' | anew state/secrets.jsonl
trufflehog filesystem state/js --only-verified --json | jq -c 'select(.Verified==true)'
gitleaks dir . --report-format json --report-path log/gitleaks-$D.json   # `gitleaks detect --source .` on <8.19
```

`--only-verified` is the difference between 5 alerts and 500. Keep the same idea on GitHub code search, on a slow cron (a few queries/hour, respect the API rate limit):

```bash
gh api -X GET search/code -f q='"target.example.com" api_key' --jq '.items[].html_url' | anew state/ghcode.txt
gh api -X GET search/code -f q='"target.example.com" authorization' --jq '.items[].html_url' | anew state/ghcode.txt
```

Also watch npm/PyPI for newly published org-scoped packages (dependency-confusion candidates) — observe only; never publish a package into a namespace you do not own.

**Credential handling, non-negotiable.** `--only-verified` authenticates the key against its vendor; that single verification call is the whole PoC. Do **not** then use the credential to list, read, or move data, and do not test it against the program's production tenant. Report the key redacted (first/last 4 chars), state where it was found and what the verification proved, and file immediately — verified credentials are triaged fast and rotate fast, so latency is worth more here than polish (severity/payout varies by program; treat any figure you have seen as indicative, not a quote).

### 2.7 Auto-triage the delta only

```bash
[ -s new/$D/live-urls.txt ] && nuclei -l new/$D/live-urls.txt -severity medium,high,critical \
  -es info -rl 10 -c 10 -silent -H "User-Agent: bugbounty-<your-platform-handle>" -o new/$D/nuclei.txt
```

Never run nuclei over the whole surface every cycle — that is a re-scan of things you already cleared, at program-annoying volume. Exclude intrusive template families unless the policy allows them: add `-etags dos,fuzz,intrusive,brute-force` (and never `-etags`-override a program that bans automated scanning outright — some programs forbid nuclei entirely; read the policy before the first run).

### 2.8 Commit and alert

```bash
git -C state add -A && git -C state commit -qm "monitor $D $(date +%H:%M)" || true
[ -s new/$D/live.txt ] && notify -silent -bulk -data new/$D/live.txt -id bounty
```

## 3. Cadence table

| Job | Cadence | Mechanism | Alert on |
| --- | --- | --- | --- |
| CT stream consumer | continuous | systemd user *service*, `Restart=always` | every in-scope hostname |
| crt.sh / certspotter poll | 15 min | timer | new subs only |
| passive subfinder/amass/assetfinder | 1 h | timer | new subs only |
| httpx liveness + fingerprint diff | 1 h | chained after enum | NEW HOST / STATUS FLIP / TECH CHANGE |
| JS collect + bundle content diff | 2 h | timer | NEW BUNDLE / BUNDLE CHANGED / new endpoint |
| nuclei on `new/` only | on-delta | triggered by non-empty file | medium+ |
| trufflehog org scan | 6 h | timer | verified only |
| alterx / shuffledns / cloud_enum | daily | timer, `RandomizedDelaySec` | new subs only |
| naabu top-1000 | weekly | timer | new port |

## 4. systemd wiring

Prefer systemd user timers over cron: journald logging, `Persistent=true` catches runs missed while the laptop was asleep, no mail spam.

```ini
# ~/.config/systemd/user/bounty-monitor@.service
[Unit]
Description=Bounty surface monitor for %i
[Service]
Type=oneshot
WorkingDirectory=%h/Bounty/%i
ExecStart=%h/Bounty/%i/bin/monitor.sh %i
```

```ini
# ~/.config/systemd/user/bounty-monitor@.timer
[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=300
[Install]
WantedBy=timers.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now bounty-monitor@acme.timer
loginctl enable-linger $USER      # keeps timers running while logged out
journalctl --user -u bounty-monitor@acme -f
```

`notify` fans out to Telegram/Discord/Slack from `~/.config/notify/provider-config.yaml`.

## 5. Alerting rules that keep the pipeline usable

| Rule | Why |
| --- | --- |
| Alert only on non-empty diffs, never on run completion | a monitor that pings every hour gets muted in a week, and then it is worthless |
| One batched message per run | phone triage needs one glance, not 40 notifications |
| Prefix the reason: `NEW SUB` / `STATUS FLIP` / `JS CHANGED` / `VERIFIED SECRET` | you decide whether to open the laptop from the lock screen |
| Hard-suppress anything matching `oos.txt` before the alert stage | out-of-scope testing is the cheapest reputation loss in the game |
| If `wc -l new/$D/subs.txt` > 200, tag `WILDCARD-SUSPECT`, dedupe by response-body hash, do not page | a DNS wildcard will otherwise page you 400 times at 03:00 |
| Health line when a feed returns empty | a dead crt.sh feed looks exactly like "no new assets" |

## 6. Legal and program-hygiene guardrails

- Never touch a host until it matches `scope.txt` **and** fails `oos.txt`. Enforce it as a pipeline stage, not as a habit.
- Honour the program's stated automation and request-rate rules; `-rl` on httpx and nuclei, and your platform handle in the User-Agent (many programs require it, and it stops your automation reading as an attack).
- Never brute-force credentials, never run `cloud_enum` against third-party SaaS tenants, never scan an asset that only *looks* like the target's (confirm ownership via WHOIS/ASN/CT issuer before probing; a shared-hosting neighbour is someone else's machine).
- No DoS, no load/stress testing, no automated account creation beyond what the policy allows, no social engineering of staff or support — these are ToS violations on every platform, not grey areas.
- Never touch another user's account or data. Prove multi-tenant impact with **two accounts you registered yourself**; if a bug can only be shown against a real user's record, stop and describe the mechanism instead.
- Keep raw evidence (`log/httpx-*.json`, the `.patch` files, the git history) — it timestamps discovery and settles duplicate disputes.
- Verified live credentials, another company's data, or signs of prior compromise: stop, do not explore, report as urgent.
- PII discipline: capture the **minimum** record count that proves the class (typically 1-2 redacted samples plus a count), never a bulk dump; store evidence locally, never in a public repo or paste service.

## 7. Anti-patterns

- **Alerting on run completion instead of on diff.** The single fastest way to make yourself ignore your own monitor.
- **Diffing minified JS.** Every deploy rehashes chunks; you drown in false positives and stop reading the patches. Beautify first.
- **Diffing on hostname only.** You miss the 403→200 flip on a host you already knew about, which is exactly the surface nobody else re-checks.
- **Treating an empty feed as "nothing new".** crt.sh dies quietly; log a health line and check it.
- **Copy-pasting `httpx` without the absolute path.** Runs the Python client, exits weirdly, and you conclude nothing is live.
- **Running nuclei across the entire baseline every cycle.** Re-tests cleared surface, burns hours, and looks like a scan campaign to the program.
- **Bruteforcing subdomains hourly.** Cost and noise for near-zero marginal discovery; passive hourly, brute daily.
- **No `oos.txt` until after the first report gets closed Out-of-Scope.** Write it during setup, from the policy page.
- **Not committing `state/`.** You lose the only proof you found it first.
- **Monitoring 20 programs shallowly.** Latency is the product; 3 programs monitored at 1 h beats 20 at 24 h.
- **Firing nuclei at a program whose policy bans automated scanning.** Instant ban, and the templates were not going to find the paying bug anyway.
- **Hunting the delta later "when there is time".** A 4-hour-old delta is worth several times a 3-day-old one; if you cannot work the queue, reduce the number of programs.

## Composes with

`pentest-engagement-init` (bootstrap the folder skeleton and finding IDs) → this skill's `new/` queue feeds `pentest-js-recon` (deep bundle mining) and `pentest-lot-idor` (build the enumeration lots) → `http-async-rotate` (run the mass sweep) → `pentest-findings-http` + `burp-history-reader` (capture evidence) → `pentest-endpoint-summary` (record what is already covered so no wave re-tests it) → `pentest-report-package` / `vuln-reporter` for the deliverable. Persist per-program $/h and dup-rate notes with `pentest-memory-feedback`.
