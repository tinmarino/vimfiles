#!/usr/bin/env python3
# -- pylint: disable=invalid-name
# -- pylint: disable=broad-exception-caught
# -- pylint: disable=bare-except

"""
http-async-rotate reference template

Fan out many HTTP requests to ONE host with a CONTINUOUS bounded worker pool
(always --workers in flight; when one finishes another starts — no per-batch
fork-join) and optionally rotate the source IP through AWS API Gateway via
requests-ip-rotator. One input per line in --file; one output file per input.

Authorised testing only.

Copy this file and edit the THREE marked spots:
  1) produce_inputs()      — yield your inputs (RUTs, phones, ids …)
  2) make_one_request()    — the URL / method / body for one input
  3) parse_result()        — what to persist per input

| __N.__ | __Time__ | __IP__ | __Range__ | __Comment__ |
| -- | -- | -- | -- | -- |
| 01 |  |  |  |  |

"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from concurrent.futures import ThreadPoolExecutor, wait, FIRST_COMPLETED
from datetime import datetime
from json import dump as json_dump
from os import getenv, makedirs
from os.path import dirname, exists, join, normpath
from sys import stderr
from time import sleep as time_sleep

from requests import Session
from urllib3 import disable_warnings
from urllib3.exceptions import InsecureRequestWarning

disable_warnings(InsecureRequestWarning)

# ── target ──────────────────────────────────────────────────────────────────
S_SITE   = "https://api.example.com"          # scheme+host ONLY (what gets mounted)
S_URL    = S_SITE + "/endpoint"
S_HITS   = "hits.csv"                          # consolidated, one level above --out
D_HEADER = {"X-Bug-Bounty-Cyscope": "Tinmarino"}

# Default to a SINGLE region (us-east-1) — fewer gateways to create/tear down.
# Pass --region repeatedly for wider IP spread (some regions need manual AWS opt-in).
DEFAULT_REGIONS = ["us-east-1"]


def build_gateway(regions):
    """Start an AWS API Gateway IP rotator for S_SITE; creds from env. None on failure."""
    try:
        # pylint: disable=import-outside-toplevel
        from requests_ip_rotator import ApiGateway  # type: ignore[import-untyped]
    except ImportError:
        print("requests_ip_rotator not installed — run without --rotate", file=stderr)
        return None
    gateway = ApiGateway(
        S_SITE, regions=regions,
        access_key_id=getenv("AWS_ACCESS_KEY_ID"),
        access_key_secret=getenv("AWS_SECRET_ACCESS_KEY"),
    )
    gateway.start()                            # creates endpoints; tear down in finally
    return gateway


def produce_inputs(args):
    """(EDIT 1) Yield inputs one at a time — a GENERATOR, never a full list."""
    if args.file:
        with open(args.file, encoding="utf8") as handle:
            for line in handle:
                line = line.strip()
                if line and not line.startswith("#"):
                    yield line
    for item in args.inputs:
        yield item
    if args.start is not None:                 # numeric range (ids / RUTs)
        for n in range(args.start, args.end, args.step):
            yield str(n)


def make_one_request(gateway, i, mutator, args):
    """(EDIT 2) Send ONE request for `mutator`; persist; return a short status."""
    session = Session()
    if gateway is not None:
        session.mount(S_SITE, gateway)         # route this host through the rotator

    if args.sleep:
        time_sleep(args.sleep)

    response = session.post(
        S_URL, headers=D_HEADER, json={"id": mutator}, timeout=args.timeout,
        verify=False,                          # rotated Host != cert host
        # proxies={'http':'http://127.0.0.1:8080','https':'http://127.0.0.1:8080'},
    )
    parse_result(mutator, response, args)
    return f"{i} {mutator} {response.status_code} {datetime.now():%Y-%m-%dT%H:%M:%S}"


def parse_result(mutator, response, args):
    """(EDIT 3) Persist one result; one file per input keeps the run resumable."""
    try:
        content = response.json()
    except Exception:
        content = {"_raw": response.text}
    with open(output_path(mutator, args), "w", encoding="utf8") as handle:
        json_dump(content, handle, indent=4, ensure_ascii=False)

    # Consolidated hit: only when this input carried data worth flattening.
    # (EDIT 3b) pick the fields you care about; hits.csv lives ONE level above --out.
    value = (content or {}).get("value")
    if value:
        with open(hits_path(args), "a", encoding="utf8") as handle:
            handle.write(f"{mutator},{value}\n")


def output_path(mutator, args):
    """Return the per-input output file path under --out."""
    return join(args.out, f"{mutator}.json")


def hits_path(args):
    """hits.csv lives ONE level above --out so it doesn't mix with per-input files."""
    return join(dirname(normpath(args.out)) or ".", S_HITS)


def run(args):
    """Continuous bounded pool: always ~--workers in flight, refill on FIRST_COMPLETED."""
    makedirs(args.out, exist_ok=True)

    gateway = None
    if args.rotate:
        gateway = build_gateway(args.region or DEFAULT_REGIONS)

    max_in_flight = args.workers               # == workers keeps the pool saturated
    in_flight = set()
    n_ok = n_err = n_skip = 0

    def handle(fut):
        nonlocal n_ok, n_err
        try:
            print(fut.result())
            n_ok += 1
        except Exception as err:
            print(f"Error: {err}", file=stderr)
            n_err += 1

    try:
        with ThreadPoolExecutor(max_workers=args.workers) as executor:
            for i, mutator in enumerate(produce_inputs(args)):
                if args.resume and exists(output_path(mutator, args)):
                    n_skip += 1
                    continue
                in_flight.add(executor.submit(make_one_request, gateway, i, mutator, args))
                if len(in_flight) >= max_in_flight:
                    done, in_flight = wait(in_flight, return_when=FIRST_COMPLETED)
                    for fut in done:
                        handle(fut)
            for fut in in_flight:              # drain tail
                handle(fut)
    finally:
        if gateway is not None:
            gateway.shutdown()                 # ALWAYS tear down AWS resources

    print(f"\ndone: ok={n_ok} err={n_err} skipped={n_skip} hits->{hits_path(args)}", file=stderr)


def main():
    """Parse CLI arguments and run the bounded async fan-out."""
    ap = ArgumentParser(description=__doc__, formatter_class=RawDescriptionHelpFormatter)
    ap.add_argument("inputs", nargs="*", help="inputs (or use --file / --start/--end)")
    ap.add_argument("--file", "-f", help="file with one input per line")
    ap.add_argument("--start", type=int, help="range start (inclusive)")
    ap.add_argument("--end", type=int, help="range end (exclusive)")
    ap.add_argument("--workers", "-w", type=int, default=10,
                    help="concurrent workers (== max in flight). Pass 100 for big runs.")
    ap.add_argument("--rotate", action="store_true",
                    help="rotate source IP via AWS API Gateway (creds from env)")
    ap.add_argument("--region", action="append",
                    help="AWS region (repeatable; default single region us-east-1)")
    ap.add_argument("--timeout", type=int, default=20)
    ap.add_argument("--step", type=int, default=1,
                    help="increment per iteration for --start/--end range (default 1)")
    ap.add_argument("--sleep", type=float, default=0.0, help="per-request throttle (s)")
    ap.add_argument("--out", default="out", help="output directory")
    ap.add_argument("--resume", action="store_true", help="skip inputs already done")
    args = ap.parse_args()
    if args.start is not None and args.end is None:
        ap.error("--start requires --end")
    run(args)


if __name__ == "__main__":
    main()
