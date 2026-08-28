#!/usr/bin/env python3
"""Manage the hunt/ task queue that feeds the overnight bug-bounty loop.

The queue is a set of flat, human-readable Markdown-ish files under
`<engagement-root>/hunt/`.  The coordinator and up to five hunter subagents all
call this script concurrently, so every mutation takes an exclusive flock on
`hunt/.lock` — claims never double-serve the same task.

Files (one task per line, ` | ` separated):
  hunt/QUEUE.md   pending tasks, highest EV first
  hunt/DOING.md   claimed, in-flight (carries claimed=<hunter> at=<iso>)
  hunt/DONE.md    finished (carries verdict + evidence path)
  hunt/LOOP.md    append-only wave/tick narrative (never rewritten by this tool)
  hunt/BUDGET.md  per-day money-transfer ledger (write-cap enforcement)

Task line:  Q<nnn> | <EV> | <class> | <target> | <hypothesis> [| k=v ...]
  EV is an integer 0-100 (expected value); QUEUE stays sorted by it, desc.

Subcommands: init, add, claim, done, requeue, reap-stale, status, list,
             budget-check, budget-commit, next-id.
"""

from argparse import ArgumentParser
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
import fcntl
import os
import re
import sys


QUEUE = 'QUEUE.md'
DOING = 'DOING.md'
DONE = 'DONE.md'
BUDGET = 'BUDGET.md'
CAP_USD = 5.0      # hard daily ceiling on money moved, per user authorization
CAP_CLP = 5000.0


def now_iso():
    """Return current UTC time as a compact ISO string."""
    return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')


def today():
    """Return current UTC date as YYYY-MM-DD."""
    return datetime.now(timezone.utc).strftime('%Y-%m-%d')


def find_root(start):
    """Walk up from start until a dir holding AGENTS.md is found; else start."""
    cur = Path(start).resolve()
    for cand in [cur, *cur.parents]:
        if (cand / 'AGENTS.md').exists():
            return cand
    return cur


def hunt_dir(root):
    """Return the hunt/ dir for an engagement root, creating it on demand."""
    d = Path(root) / 'hunt'
    d.mkdir(exist_ok=True)
    return d


@contextmanager
def locked(hdir):
    """Hold an exclusive flock on hunt/.lock for the duration of the block."""
    lock = hdir / '.lock'
    fd = os.open(str(lock), os.O_CREAT | os.O_RDWR, 0o644)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX)
        yield
    finally:
        fcntl.flock(fd, fcntl.LOCK_UN)
        os.close(fd)


def read_lines(path):
    """Return non-empty, non-comment lines of a file (empty list if absent)."""
    if not path.exists():
        return []
    out = []
    for raw in path.read_text().splitlines():
        s = raw.strip()
        if s and not s.startswith('#'):
            out.append(s)
    return out


def write_lines(path, lines):
    """Overwrite path with lines (trailing newline), atomically via rename."""
    tmp = path.with_suffix(path.suffix + '.tmp')
    tmp.write_text('\n'.join(lines) + ('\n' if lines else ''))
    tmp.replace(path)


def parse(line):
    """Split a task line into its ` | ` fields."""
    return [c.strip() for c in line.split('|')]


def ev_of(line):
    """Return the integer EV of a task line (field 1), or -1 if unparseable."""
    f = parse(line)
    try:
        return int(f[1])
    except (IndexError, ValueError):
        return -1


def task_key(line):
    """Dedup key for a task: normalized (class, target)."""
    f = parse(line)
    cls = f[2].lower() if len(f) > 2 else ''
    tgt = re.sub(r'\s+', '', f[3].lower()) if len(f) > 3 else ''
    return (cls, tgt)


def sort_queue(lines):
    """Return queue lines sorted by EV descending, stable on ties."""
    return sorted(lines, key=ev_of, reverse=True)


# --------------------------------------------------------------------------- #
# Subcommands
# --------------------------------------------------------------------------- #

def cmd_init(args, hdir):
    """Create the four queue files and a LOOP header if missing."""
    for name in (QUEUE, DOING, DONE):
        p = hdir / name
        if not p.exists():
            p.write_text('')
    loop = hdir / 'LOOP.md'
    if not loop.exists():
        loop.write_text('# Hunt loop log\n\n')
    budget = hdir / BUDGET
    if not budget.exists():
        budget.write_text('# Money-transfer ledger (cap %.0f USD / %.0f CLP per UTC day)\n'
                          % (CAP_USD, CAP_CLP))
    print('init ok: %s' % hdir)


def next_id(hdir):
    """Return the next free Q id by scanning all three queue files."""
    mx = 0
    for name in (QUEUE, DOING, DONE):
        for line in read_lines(hdir / name):
            m = re.match(r'Q(\d+)', parse(line)[0])
            if m:
                mx = max(mx, int(m.group(1)))
    return 'Q%03d' % (mx + 1)


def cmd_next_id(args, hdir):
    """Print the next free task id."""
    with locked(hdir):
        print(next_id(hdir))


def cmd_add(args, hdir):
    """Append a task to QUEUE, skipping duplicates by (class, target)."""
    with locked(hdir):
        q = read_lines(hdir / QUEUE)
        doing = read_lines(hdir / DOING)
        done = read_lines(hdir / DONE)
        key = (args.cls.lower(), re.sub(r'\s+', '', args.target.lower()))
        if not args.force:
            for line in q + doing + done:
                if task_key(line) == key:
                    print('dup skip: %s %s already tracked' % (args.cls, args.target))
                    return
        tid = next_id(hdir)
        line = '%s | %d | %s | %s | %s' % (tid, args.ev, args.cls, args.target, args.hypo)
        if args.note:
            line += ' | note=%s' % args.note.replace('|', '/')
        q.append(line)
        write_lines(hdir / QUEUE, sort_queue(q))
        print(tid)


def cmd_claim(args, hdir):
    """Atomically move the top eligible QUEUE task to DOING and print it.

    Prints nothing (exit 0) when the queue holds no eligible task, so the
    coordinator can tell 'pool full / nothing to do' from a real claim.
    """
    with locked(hdir):
        q = sort_queue(read_lines(hdir / QUEUE))
        if not q:
            return
        pick = None
        rest = []
        for line in q:
            cls = parse(line)[2].lower() if len(parse(line)) > 2 else ''
            if pick is None and (not args.cls or cls == args.cls.lower()):
                pick = line
            else:
                rest.append(line)
        if pick is None:
            return
        stamped = '%s | claimed=%s at=%s' % (pick, args.hunter, now_iso())
        write_lines(hdir / QUEUE, rest)
        doing = read_lines(hdir / DOING)
        doing.append(stamped)
        write_lines(hdir / DOING, doing)
        print(pick)


def cmd_done(args, hdir):
    """Move a task from DOING to DONE with a verdict and optional evidence."""
    with locked(hdir):
        doing = read_lines(hdir / DOING)
        keep, moved = [], None
        for line in doing:
            if parse(line)[0] == args.id:
                moved = line
            else:
                keep.append(line)
        if moved is None:
            print('not in DOING: %s' % args.id, file=sys.stderr)
            sys.exit(2)
        write_lines(hdir / DOING, keep)
        done = read_lines(hdir / DONE)
        tail = 'verdict=%s at=%s' % (args.verdict, now_iso())
        if args.severity:
            tail += ' severity=%s' % args.severity
        tail += ' reachable=%s' % ('true' if args.reachable else 'false')
        if args.evidence:
            tail += ' evidence=%s' % args.evidence
        done.append('%s | %s' % (moved, tail))
        write_lines(hdir / DONE, done)
        print('done: %s %s' % (args.id, args.verdict))


def cmd_requeue(args, hdir):
    """Move a task back from DOING to QUEUE (e.g. hunter gave up cleanly)."""
    with locked(hdir):
        doing = read_lines(hdir / DOING)
        keep, moved = [], None
        for line in doing:
            if parse(line)[0] == args.id:
                moved = re.sub(r' \| claimed=.*$', '', line)
            else:
                keep.append(line)
        if moved is None:
            print('not in DOING: %s' % args.id, file=sys.stderr)
            sys.exit(2)
        write_lines(hdir / DOING, keep)
        q = read_lines(hdir / QUEUE)
        q.append(moved)
        write_lines(hdir / QUEUE, sort_queue(q))
        print('requeued: %s' % args.id)


def cmd_reap_stale(args, hdir):
    """Return DOING tasks older than --minutes back to QUEUE (crash recovery)."""
    cutoff = args.minutes
    with locked(hdir):
        doing = read_lines(hdir / DOING)
        keep, revived = [], []
        for line in doing:
            m = re.search(r'at=(\S+)', line)
            age_min = None
            if m:
                try:
                    t = datetime.strptime(m.group(1), '%Y-%m-%dT%H:%M:%SZ').replace(
                        tzinfo=timezone.utc)
                    age_min = (datetime.now(timezone.utc) - t).total_seconds() / 60
                except ValueError:
                    pass
            if age_min is not None and age_min > cutoff:
                revived.append(re.sub(r' \| claimed=.*$', '', line))
            else:
                keep.append(line)
        if revived:
            write_lines(hdir / DOING, keep)
            q = read_lines(hdir / QUEUE)
            q.extend(revived)
            write_lines(hdir / QUEUE, sort_queue(q))
        print('reaped %d stale task(s)' % len(revived))


def cmd_wave_bump(args, hdir):
    """Increment the wave counter and print 'count triage' or 'count'.

    Prints a second field 'triage' when the new count is a positive multiple
    of --every (default 5), so the coordinator knows to spawn a triage pass.
    """
    with locked(hdir):
        wf = hdir / '.waves'
        try:
            n = int(wf.read_text().strip())
        except (FileNotFoundError, ValueError):
            n = 0
        n += 1
        wf.write_text('%d\n' % n)
        if args.every > 0 and n % args.every == 0:
            print('%d triage' % n)
        else:
            print('%d' % n)


def cmd_status(args, hdir):
    """Print queue/doing/done counts and the number of live hunters."""
    q = read_lines(hdir / QUEUE)
    doing = read_lines(hdir / DOING)
    done = read_lines(hdir / DONE)
    verdicts = {}
    for line in done:
        m = re.search(r'verdict=(\S+)', line)
        if m:
            verdicts[m.group(1)] = verdicts.get(m.group(1), 0) + 1
    print('QUEUE=%d DOING=%d DONE=%d' % (len(q), len(doing), len(done)))
    print('inflight=%d' % len(doing))
    if verdicts:
        print('verdicts=' + ' '.join('%s:%d' % kv for kv in sorted(verdicts.items())))


def cmd_list(args, hdir):
    """Print the raw contents of one queue file (QUEUE/DOING/DONE)."""
    name = {'queue': QUEUE, 'doing': DOING, 'done': DONE}[args.which]
    for line in read_lines(hdir / name):
        print(line)


def _budget_today(hdir):
    """Return (usd, clp) already moved today from the ledger."""
    usd = clp = 0.0
    for line in read_lines(hdir / BUDGET):
        f = parse(line)
        if f and f[0] == today():
            try:
                usd += float(re.search(r'USD ([\d.]+)', line).group(1))
            except (AttributeError, ValueError):
                pass
            try:
                clp += float(re.search(r'CLP ([\d.]+)', line).group(1))
            except (AttributeError, ValueError):
                pass
    return usd, clp


def cmd_budget_check(args, hdir):
    """Exit 0 if moving usd/clp keeps today within cap, else exit 3."""
    with locked(hdir):
        usd, clp = _budget_today(hdir)
        nu, nc = usd + args.usd, clp + args.clp
        if nu > CAP_USD or nc > CAP_CLP:
            print('DENY: today USD %.2f+%.2f>%.2f or CLP %.0f+%.0f>%.0f'
                  % (usd, args.usd, CAP_USD, clp, args.clp, CAP_CLP))
            sys.exit(3)
        print('OK: room today USD %.2f/%.2f CLP %.0f/%.0f' % (nu, CAP_USD, nc, CAP_CLP))


def cmd_budget_commit(args, hdir):
    """Record a money transfer in the ledger after the check passed."""
    with locked(hdir):
        usd, clp = _budget_today(hdir)
        if usd + args.usd > CAP_USD or clp + args.clp > CAP_CLP:
            print('DENY: over cap, refusing to record', file=sys.stderr)
            sys.exit(3)
        with (hdir / BUDGET).open('a') as fh:
            fh.write('%s | USD %.2f | CLP %.0f | %s | %s\n'
                     % (today(), args.usd, args.clp, args.who, now_iso()))
        print('recorded')


def build_parser():
    """Return the argparse dispatcher for all subcommands."""
    p = ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument('--root', default=os.getcwd(),
                   help='engagement root or any dir inside it (default: cwd)')
    sub = p.add_subparsers(dest='cmd', required=True)

    sub.add_parser('init')
    sub.add_parser('next-id')
    sub.add_parser('status')

    w = sub.add_parser('wave-bump')
    w.add_argument('--every', type=int, default=5)

    a = sub.add_parser('add')
    a.add_argument('--ev', type=int, required=True)
    a.add_argument('--cls', required=True)
    a.add_argument('--target', required=True)
    a.add_argument('--hypo', required=True)
    a.add_argument('--note', default='')
    a.add_argument('--force', action='store_true')

    c = sub.add_parser('claim')
    c.add_argument('--hunter', required=True)
    c.add_argument('--cls', default='')

    d = sub.add_parser('done')
    d.add_argument('--id', required=True)
    d.add_argument('--verdict', required=True,
                   choices=['VULN', 'SAFE', 'BLOCKED', 'DUP', 'FAKE', 'INFO'])
    d.add_argument('--severity', default='', choices=['', 'CRIT', 'ALTA', 'MEDI', 'BAJO'])
    d.add_argument('--reachable', action='store_true',
                   help='mark the finding attacker-reachable (passes the reachability gate)')
    d.add_argument('--evidence', default='')

    r = sub.add_parser('requeue')
    r.add_argument('--id', required=True)

    s = sub.add_parser('reap-stale')
    s.add_argument('--minutes', type=float, default=45)

    li = sub.add_parser('list')
    li.add_argument('which', choices=['queue', 'doing', 'done'])

    bc = sub.add_parser('budget-check')
    bc.add_argument('--usd', type=float, default=0)
    bc.add_argument('--clp', type=float, default=0)

    bk = sub.add_parser('budget-commit')
    bk.add_argument('--usd', type=float, default=0)
    bk.add_argument('--clp', type=float, default=0)
    bk.add_argument('--who', default='?')
    return p


DISPATCH = {
    'init': cmd_init, 'next-id': cmd_next_id, 'add': cmd_add, 'claim': cmd_claim,
    'done': cmd_done, 'requeue': cmd_requeue, 'reap-stale': cmd_reap_stale,
    'status': cmd_status, 'list': cmd_list, 'wave-bump': cmd_wave_bump,
    'budget-check': cmd_budget_check, 'budget-commit': cmd_budget_commit,
}


def main():
    """Parse args, resolve the engagement root, dispatch the subcommand."""
    args = build_parser().parse_args()
    root = find_root(args.root)
    hdir = hunt_dir(root)
    DISPATCH[args.cmd](args, hdir)


if __name__ == '__main__':
    main()
