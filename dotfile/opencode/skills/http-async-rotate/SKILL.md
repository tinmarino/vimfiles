---
name: http-async-rotate
description: Write Python scripts that fan out many HTTP requests concurrently with a CONTINUOUS bounded worker pool (always N workers busy, no per-batch fork-join — when one finishes another starts) and rotate the source IP through AWS API Gateway via requests-ip-rotator. Use whenever building a mass-enumeration / IDOR / fuzzing / bulk-fetch script that hits one endpoint with many inputs (RUTs, phones, ids) from --file/--start/--end, needs --workers and --rotate, must dodge IP-based rate limits, writes one output file per input plus a consolidated hits.csv one level up, supports --resume to skip already-fetched ids, and (when auth is short-lived) follows a session.yaml refreshed by a sidecar keepalive job with a --max-authfail abort guard. Composes with the python-writer skill for style.
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
  reference-projects: pentest-requesters
  reference-impl: skills/http-async-rotate/reference.py
---

# http-async-rotate

Loaded whenever Tinmarino asks to "fan out / fuzz / enumerate / mass-fetch over a list", to add `--file`/`--workers`/`--rotate`/`--resume` to a requester, or to "rotate IPs". It captures a pattern proven across Tinmarino's bulk-fetch requesters (REST and GraphQL, with and without short-lived auth). Always write code in Tinmarino's style — defer to the **python-writer** skill for layout, naming, imports, docstrings.

Defaults to bake into EVERY requester: continuous pool (§2), per-input file + `hits.csv` one level up (§5), `--resume` skip (§8), and — when the target needs a short-lived token — `--follow session.yaml` + `--max-authfail` (§6).

## 1. When to use / not use

- USE for: many independent HTTP requests to ONE host (one input → one request → one output file), where throughput matters and the target may IP-rate-limit. Authorised pentest / bug-bounty enumeration only.
- DO NOT use rotation for: a handful of requests, an endpoint with no IP limiting, or anything where the extra AWS API Gateway hop would obscure debugging. `--rotate` is opt-in; the script must run fine with `--no-rotate` (direct, single source IP).
- Rotation needs AWS API Gateway resources — it costs a little and **must be torn down** (`gateway.shutdown()` in `finally`). Never leave gateways behind.

## 2. The core idea — CONTINUOUS bounded worker pool (NOT fork-join)

The wrong way (per-batch fork-join): build a list of N, open a `ThreadPoolExecutor`, wait for ALL N to finish, then start the next N. The pool idles waiting for the slowest item in each batch — throughput sags to the slowest-per-batch.

The right way (what Tinmarino uses): ONE long-lived `ThreadPoolExecutor(max_workers=N)`, keep at most `MAX_IN_FLIGHT ≈ N` futures submitted, and as soon as ANY ONE finishes (`wait(..., return_when=FIRST_COMPLETED)`) submit the next input. The pool stays saturated — always ~N requests in flight, when one finishes another starts immediately. Memory stays O(N) even for millions of inputs because you stream the producer instead of submitting everything up front.

```python
from concurrent.futures import ThreadPoolExecutor, wait, FIRST_COMPLETED

MAX_WORKERS   = i_workers      # threads doing HTTP
MAX_IN_FLIGHT = i_workers      # outstanding futures (== workers keeps pool full)

in_flight = set()
try:
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        for i, mutator in enumerate(produce_inputs()):     # a GENERATOR, not a list
            in_flight.add(executor.submit(make_one_request, gateway, i, mutator))

            # Refill point: block only until ONE frees up, then loop submits the next.
            if len(in_flight) >= MAX_IN_FLIGHT:
                done, in_flight = wait(in_flight, return_when=FIRST_COMPLETED)
                for fut in done:
                    handle_result(fut)

        # Drain the tail.
        for fut in in_flight:
            handle_result(fut)
finally:
    if gateway:
        gateway.shutdown()


def handle_result(fut):
    try:
        print(fut.result())
    except Exception as err:                # never let one bad input kill the run
        print(f"Error processing request: {err}")
```

Key points:
- `MAX_IN_FLIGHT == MAX_WORKERS` → the pool is always full. Set `MAX_IN_FLIGHT` a bit higher (e.g. `2*N`) only if producing inputs is slow and you want a submit buffer.
- The producer (`produce_inputs()`) must be a generator so you never materialise the whole input set.
- Catch exceptions in `handle_result` — a timeout/RST on one input must not abort the sweep.
- Per-input output files make the run idempotent: skip inputs whose output already exists (`--resume`).

## 3. IP rotation via requests-ip-rotator (AWS API Gateway)

```python
from requests import Session
from requests_ip_rotator import ApiGateway
from urllib3 import disable_warnings
from urllib3.exceptions import InsecureRequestWarning
disable_warnings(InsecureRequestWarning)   # rotated Host != cert host → verify=False

# Default to a SINGLE region (us-east-1) — fewer gateways to create/tear down.
DEFAULT_REGIONS = ["us-east-1"]
# Opt in to wider IP spread only when one region's pool isn't enough:
WIDE_REGIONS = ["us-east-1","us-east-2","us-west-1","us-west-2",
                "eu-west-1","eu-west-2","eu-west-3","eu-central-1","ca-central-1"]

# Creds: pass explicitly from env, or leave None to use boto3's default chain
# (env AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN, or ~/.aws).
gateway = ApiGateway(
    s_site,                                  # scheme+host ONLY, e.g. "https://api.example.com"
    regions=["us-east-1"],                   # or WIDE_REGIONS for more IP spread
    access_key_id=getenv("AWS_ACCESS_KEY_ID"),
    access_key_secret=getenv("AWS_SECRET_ACCESS_KEY"),
)
gateway.start()                              # creates the API Gateway endpoints (slow-ish)
try:
    ...                                      # run the pool (section 2)
finally:
    gateway.shutdown()                       # ALWAYS tear down

# Inside each worker thread:
def make_one_request(gateway, i, mutator):
    session = Session()
    if gateway is not None:
        session.mount(s_site, gateway)       # route this host through the rotator
    resp = session.post(url, json=body, headers=hdr, timeout=i_timeout, verify=False)
    ...
```

- `ApiGateway` signature: `ApiGateway(site, regions=[...], access_key_id=None, access_key_secret=None, verbose=True)`.
- `session.mount(s_site, gateway)` only matches that host; other hosts (e.g. a JWT-refresh endpoint on a different domain) go direct. Mount per-thread `Session` (cheap) or share one `Session` (also fine — `requests.Session` is thread-safe for sending).
- `verify=False` is required: the request egresses via an AWS API Gateway URL whose TLS host differs from the target; keep `disable_warnings`.
- Each request gets a random `X-Forwarded-For`; the visible source IP is AWS's. More regions = more distinct IPs but more setup time and more teardown.
- Cost/cleanup: `start()`/`shutdown()` create and delete real AWS resources. If the process is killed (`kill -9`) before `shutdown()`, orphan gateways remain — `requests-ip-rotator` can clean them, or do it in the AWS console. Prefer one `start()` for the whole run, not per batch.

## 4. CLI contract (match across Tinmarino's requesters)

Inputs (accept all three; a generator merges them — see §2):
- positional inputs, `--file PATH` (one input per line, `#` comments and blanks skipped), and a numeric range `--start N --end M` (exclusive end) for enumerating ids/RUTs. `--start` requires `--end`.

Throughput / rotation:
- `--workers N` / `-w` — pool size AND max-in-flight (default modest, e.g. 10; the operator passes `--workers 100`).
- `--step N` — increment per iteration for `--start/--end` range (default 1). Pass `--step 10` to skip through a numeric space faster (e.g. test every 10th RUT).
- `--rotate` — enable AWS rotation (default OFF so the script runs without AWS). `--region R` (repeatable; default a single region, `us-east-1`).
- `--timeout SECONDS` (default 20–30), `--sleep SECONDS` (optional per-request throttle to avoid DoS-ing the target).

Output / resume (see §5):
- `--out DIR` — per-input files go here; the consolidated `hits.csv` is written ONE LEVEL ABOVE it.
- `--resume` — skip inputs whose output file already exists.

Auth (see §6) — when the target needs a Bearer/JWT:
- `--jwt` (or an env var like `$AUTH_JWT`) — a static token for a quick one-off; abort early if already expired.
- `--session PATH` (default `session.yaml`) + `--follow` — read the token from a file a sidecar keepalive job keeps fresh; this is the default for big runs.
- `--max-authfail N` (default 100) — abort the run after N CONSECUTIVE auth failures (dead/expired token), so a sweep never spins for hours producing nothing. Reset the counter on any success.

## 5. Output layout — per-input files + consolidated `hits.csv` one level up

Two outputs, deliberately separated so the consolidated CSV never mixes with the
millions of per-input files (and `--resume`'s `exists()` check stays cheap):

- **Per-input raw**: `{out_dir}/{input}.json` — one file per input (e.g. `{rut}-{dv}.json`). Idempotent, parallel-safe (distinct paths, no lock), and the basis of `--resume`.
- **Consolidated `hits.csv`**: ONE LEVEL ABOVE `--out`, i.e. `dirname(out_dir)/hits.csv`. Only rows that actually carried data (a hit) are appended — one row per record, the fields you care about flattened for grepping/Excel.

```python
def output_path(item, args):
    return join(args.out, f"{item}.json")

def hits_path(args):
    # hits.csv lives ONE level above --out so it doesn't mix with per-input JSON
    return join(dirname(normpath(args.out)) or ".", S_HITS)
```

So `--out Findings/Case01/Detail` yields `Findings/Case01/hits.csv` + `Findings/Case01/Detail/<id>.json`. Append rows under a short lock-free `open(..., "a")` (lines < PIPE_BUF are atomic), or accept minor interleave — never rewrite the whole CSV from threads.

For runs tied to a specific finding, default `--out` to `Findings/<vuln-id>/wave<NN>/`, where `<vuln-id>` is the report identifier and `<NN>` is the next zero-padded wave number inside that finding directory (`wave01`, `wave02`, ...). Create it automatically, never overwrite an existing wave unless the user asks, and keep the absolute input offset/id in the per-input filename so the run is resumable and auditable.

## 6. Auth: a `session.yaml` refreshed by a sidecar keepalive job

When the target needs a short-lived Bearer (e.g. a ~15-min JWT behind cookies that
rotate even faster), do NOT make the sweeper refresh it — that races with itself
and with the browser. Split into two processes sharing a YAML file:

- **Keepalive daemon** (`session_keepalive.py`): owns ONE auth chain, re-mints the token on a heartbeat shorter than its lifetime, and writes `session.yaml` atomically (`{cookie0, cookie1, accessToken, exp, updated}`, mode 0600). Hand-editable: drop fresh cookies in and it takes over.
- **Sweeper** (`--follow`): a thread-safe `TokenManager` reads `accessToken` from `session.yaml` and RELOADS it when it's about to expire; workers call `token_mgr.bearer()` per request. Only the daemon touches the chain, so there's no contention.

```python
class TokenManager:               # one canonical copy, imported by every requester
    def bearer(self):
        with self.lock:
            if self.follow and jwt_remaining_seconds(self.jwt) < I_REFRESH_AT:
                self.jwt = (read_session_state(self.state_path) or {}).get("accessToken", self.jwt)
            return self.jwt
```

Pair this with `--max-authfail` (§4): detect a dead token by HTTP 401/403 or a GraphQL
error mentioning `jwt`/`authoriz`/`expirad`/`could not verify`/`token de autenticaci`,
count CONSECUTIVE failures, and `sys_exit(2)` once the threshold trips so the operator
re-seeds `session.yaml` and resumes with `--resume`. Mount only the TARGET host through
the rotator — the refresh endpoint lives on another domain and must go direct.

## 7. Conventions (Tinmarino's codebase)

- `#!/usr/bin/env python3`, pylint-disable header (`invalid-name`, `broad-exception-caught`, `bare-except`), module docstring with a run-log markdown table: `| N. | Time | IP | Range | Comment |` so each live run is logged.
- Headers always include `"X-Bug-Bounty-Cyscope": "Tinmarino"` (authorised-testing marker for attribution and registry on the client server — this is a bug bounty program).
- One output file per input: `write_response(mutator, json)` → `{out_dir}/{mutator}.json` (or `.txt`/`.pdf`). Makes runs resumable and parallel-safe (distinct paths, no lock needed).
- Imports `from X import Y`; prefixes `s_`/`d_`/`i_`/`a_`; verb-first docstrings.
- Optional JWT refresh every `i_reset` items via a separate `update_jwt()` against a different host (NOT routed through the gateway).

## 8. Resume is MANDATORY — never re-fetch an id already on disk

`--resume` is not optional polish; implement it in EVERY requester so a re-run
(after a token death, a crash, a `kill`, or just continuing a range) skips inputs
already fetched instead of hammering the target again. The mechanism is the
per-input file from §5: before submitting an input, `exists(output_path(...))`?
skip and count it. Make it systematic:

```python
for i, item in enumerate(produce_inputs(args)):
    if args.resume and exists(output_path(item, args)):
        n_skip += 1
        continue
    in_flight.add(executor.submit(make_one_request, gateway, token_mgr, i, item, args))
```

This is why the per-input filename must be the deterministic id (`{rut}-{dv}.json`):
the filename IS the dedup key. Re-running the same command with `--resume` is the
normal recovery path after a `--max-authfail` abort. Default `--resume` to off in
the flag but reach for it on every real run; print the skipped count at the end.

## 9. Other proven patterns

- **Two-stage chains in one worker**: when endpoint B needs an id that endpoint A returns, do both inside `make_one_request` (A → collect ids → loop B). Keeps the unit of work "one input", so `--resume`/pool/rotation all still apply.
- **Derived inputs**: compute what the API needs from the bare input locally (e.g. the Chilean RUT verifier digit via mod-11) instead of requiring it in the `--file`. Keep the helper copied in-file (no cross-repo import for a one-liner).
- **Shared token module**: import `TokenManager`/`read_session_state`/`jwt_remaining_seconds` from one canonical script rather than re-implementing per requester.
- **`X-Bug-Bounty-Cyscope: Tinmarino`** header on every request (authorised-testing marker), and a run-log markdown table in the module docstring.

## 10. RUT helper — `rut.py`

A standalone module lives next to this file: `skills/http-async-rotate/rut.py`. Import it in any requester that sweeps incremental RUT bodies (e.g. `--start 1000000 --end 30000000`).

Three functions:
- `rut_dv(body: int) -> str` — compute the verification digit (módulo 11). Returns `'0'`–`'9'` or `'K'`.
- `rut_format(body: int) -> str` — canonical dotted form: `15487632` → `'15.487.632-4'`.
- `rut_plain(body: int) -> str` — plain hyphenated: `15487632` → `'15487632-4'`.

Usage inside `produce_inputs()` or `make_one_request()`:

```python
from rut import rut_dv, rut_format

for body in range(args.start, args.end, args.step):
    full_rut = rut_format(body)          # "15.487.632-4"
    dv = rut_dv(body)                    # "4"
    yield f"{body}-{dv}"                 # or yield full_rut
```

Copy `rut.py` into the same directory as your requester script, or add the skill directory to `sys.path`. The file has zero dependencies beyond Python stdlib.

## 11. Reference implementation

A complete, runnable template lives next to this file: `skills/http-async-rotate/reference.py`. Copy it, replace `produce_inputs`, `make_one_request`'s URL/body, and `parse_result`. It already wires `--file/--start/--end/--workers/--rotate/--region/--timeout/--sleep/--out/--resume`, the continuous pool, ApiGateway start/shutdown, per-item output, `hits.csv` one level up, and resume-skip. Applied example: a phone-to-PII requester wired with `--file/--workers/--rotate`.
