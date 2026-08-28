#!/usr/bin/env python3
"""Print a colorized terminal dashboard of report-ready vulnerabilities.

Reads the engagement's confirmed findings from `hunt/DONE.md` (plus filesystem
signals under `Findings/<ID>/`, `Report/<ID>/`, and the dedup oracles) and ranks
each proven, reachable, not-yet-submitted VULN by three axes the operator cares
about:

  P(accept)  probability the program accepts it  — reachable, dedup-clear,
             severity, negative control present.
  Repro      how easy it is to reproduce         — one-shot vs race/multi-step,
             GET vs stateful, reproducer script present.
  Impact     how clearly the real impact reads    — severity + class legibility.

Composite = weighted blend, and the table is sorted by it, most-submittable
first. Colors degrade to plain text when stdout is not a TTY or NO_COLOR is set.
"""

from argparse import ArgumentParser
from pathlib import Path
import os
import re
import sys


# class → (base repro ease, base impact clarity) heuristics, 0..1
CLASS_HINTS = {
    'idor': (0.9, 0.9), 'bola': (0.9, 0.9), 'authz': (0.85, 0.9), 'bfla': (0.85, 0.9),
    'ssrf': (0.7, 0.85), 'sqli': (0.6, 0.95), 'xss': (0.75, 0.7), 'graphql': (0.7, 0.8),
    'xxe': (0.55, 0.85), 'deser': (0.4, 0.95), 'race': (0.35, 0.8),
    'smuggling': (0.3, 0.85), 'cache': (0.5, 0.75), 'info': (0.8, 0.4),
}
SEV_W = {'CRIT': 1.0, 'ALTA': 0.85, 'MEDI': 0.6, 'BAJO': 0.35, '': 0.5}


def parse(line):
    """Split a DONE.md line into ` | ` fields."""
    return [c.strip() for c in line.split('|')]


def kv(line, key, default=''):
    """Extract key=value token from a DONE.md tail."""
    m = re.search(r'%s=(\S+)' % re.escape(key), line)
    return m.group(1) if m else default


def read_lines(path):
    """Return non-empty, non-comment lines of a file (empty if absent)."""
    if not path.exists():
        return []
    return [l.strip() for l in path.read_text().splitlines()
            if l.strip() and not l.strip().startswith('#')]


def find_root(start):
    """Walk up until AGENTS.md is found; else the start dir."""
    cur = Path(start).resolve()
    for c in [cur, *cur.parents]:
        if (c / 'AGENTS.md').exists():
            return c
    return cur


def submitted_ids(root):
    """Return finding-id-ish tokens already listed as submitted (dedup)."""
    text = ''
    for p in [root / 'done.md', root / 'doc/summary/cyscope-submitted-reports.md']:
        if p.exists():
            text += p.read_text()
    return set(re.findall(r'AI\d{2,}|[A-Z][a-z]+\d{3}', text))


def evidence_signals(root, done_line):
    """Return (has_evidence_dir, has_negctrl, has_report, has_script, finding_id)."""
    ev = kv(done_line, 'evidence')
    fid = None
    m = re.search(r'(AI\d{2,}|[A-Z][a-z]+\d{3})', ev)
    if m:
        fid = m.group(1)
    fdir = (root / 'Findings' / fid) if fid else None
    has_dir = bool(fdir and fdir.exists() and any(fdir.iterdir()))
    has_neg = False
    if fdir and fdir.exists():
        has_neg = any(re.search(r'neg', p.name, re.I) for p in fdir.rglob('*'))
    has_report = bool(fid and (root / 'Report' / fid).exists())
    has_script = False
    if fid:
        sdir = root / 'Script'
        if sdir.exists():
            has_script = any(fid.lower() in p.name.lower() for p in sdir.glob('*'))
    return has_dir, has_neg, has_report, has_script, fid


def score(root, line, submitted):
    """Return dict with the three axis scores (0-100) and composite, or None."""
    if kv(line, 'verdict') != 'VULN':
        return None
    f = parse(line)
    cls = f[2].lower() if len(f) > 2 else ''
    target = f[3] if len(f) > 3 else ''
    sev = kv(line, 'severity')
    reachable = kv(line, 'reachable') == 'true'
    has_dir, has_neg, has_report, has_script, fid = evidence_signals(root, line)
    dup = bool(fid and fid in submitted)

    base_repro, base_impact = CLASS_HINTS.get(cls, (0.6, 0.6))
    stateful = bool(re.search(r'race|smuggl|multi|chain|coupon|checkout', cls + ' ' + target, re.I))

    p_accept = 100 * (
        (0.0 if not reachable else 0.4)
        + (0.0 if dup else 0.2)
        + 0.25 * SEV_W.get(sev, 0.5)
        + (0.15 if has_neg else 0.0))
    repro = 100 * (
        0.55 * base_repro
        + (0.2 if has_script else 0.0)
        + (0.15 if has_dir else 0.0)
        + (0.10 if not stateful else 0.0))
    impact = 100 * (0.6 * base_impact + 0.4 * SEV_W.get(sev, 0.5))

    # composite favors things likely to be accepted AND easy — a blend, not a product,
    # so one weak axis doesn't zero a strong finding, but P(accept) dominates.
    composite = 0.45 * p_accept + 0.30 * repro + 0.25 * impact
    return {
        'id': fid or f[0], 'cls': cls, 'target': target, 'sev': sev or '?',
        'reachable': reachable, 'dup': dup, 'has_report': has_report,
        'p_accept': p_accept, 'repro': repro, 'impact': impact, 'composite': composite,
    }


# --------------------------- rendering --------------------------------------- #

def use_color(force):
    """Decide whether to emit ANSI color."""
    if force == 'always':
        return True
    if force == 'never' or os.environ.get('NO_COLOR'):
        return False
    return sys.stdout.isatty()


class C:
    """ANSI palette, blanked when color is off."""
    def __init__(self, on):
        self.on = on
        self.RESET = '\033[0m' if on else ''
        self.BOLD = '\033[1m' if on else ''
        self.DIM = '\033[2m' if on else ''
        self.RED = '\033[38;5;203m' if on else ''
        self.YEL = '\033[38;5;221m' if on else ''
        self.GRN = '\033[38;5;114m' if on else ''
        self.BLU = '\033[38;5;75m' if on else ''
        self.MAG = '\033[38;5;176m' if on else ''
        self.GREY = '\033[38;5;245m' if on else ''


def sev_color(c, sev):
    """Color a severity token."""
    return {'CRIT': c.MAG, 'ALTA': c.RED, 'MEDI': c.YEL, 'BAJO': c.BLU}.get(sev, c.GREY)


def bar(c, v):
    """A 10-cell colored meter for a 0-100 score."""
    n = int(round(v / 10.0))
    col = c.GRN if v >= 70 else c.YEL if v >= 45 else c.RED
    return col + '█' * n + c.GREY + '·' * (10 - n) + c.RESET + ' %3d' % round(v)


def render(rows, c, root):
    """Print the dashboard."""
    out = []
    title = ' HUNT DASHBOARD — vulns listas para reportar '
    out.append(c.BOLD + c.BLU + '╔' + '═' * (len(title)) + '╗' + c.RESET)
    out.append(c.BOLD + c.BLU + '║' + c.RESET + c.BOLD + title + c.BLU + '║' + c.RESET)
    out.append(c.BOLD + c.BLU + '╚' + '═' * (len(title)) + '╝' + c.RESET)
    out.append(c.DIM + ' root: %s' % root + c.RESET)
    out.append('')
    if not rows:
        out.append(c.YEL + '  No hay VULN reachable sin enviar todavía.' + c.RESET
                   + c.DIM + ' (corre /hunt o revisa hunt/DONE.md)' + c.RESET)
        print('\n'.join(out))
        return
    hdr = '  %-2s %-10s %-6s %-7s  %-16s %-16s %-16s  %s' % (
        '#', 'ID', 'Sev', 'Score', 'P(accept)', 'Repro', 'Impacto', 'Estado')
    out.append(c.BOLD + hdr + c.RESET)
    out.append(c.GREY + '  ' + '─' * (len(hdr) + 14) + c.RESET)
    for i, r in enumerate(rows, 1):
        estado = (c.GRN + 'empaquetado' if r['has_report'] else c.YEL + 'sin empaquetar') + c.RESET
        if r['dup']:
            estado = c.GREY + 'DUP/enviado' + c.RESET
        sevc = sev_color(c, r['sev'])
        comp = r['composite']
        compc = c.GRN if comp >= 70 else c.YEL if comp >= 45 else c.RED
        out.append('  %s%-2d%s %-10s %s%-6s%s %s%5.1f%s  %s %s %s  %s' % (
            c.BOLD, i, c.RESET, r['id'],
            sevc, r['sev'], c.RESET,
            compc, comp, c.RESET,
            bar(c, r['p_accept']), bar(c, r['repro']), bar(c, r['impact']),
            estado))
        out.append(c.DIM + '     %s  %s' % (r['cls'], r['target']) + c.RESET)
    out.append('')
    top = rows[0]
    out.append(c.BOLD + c.GRN + '  → Reportar primero: ' + c.RESET
               + c.BOLD + top['id'] + c.RESET
               + ' (%s, score %.1f)' % (top['cls'], top['composite']))
    out.append(c.DIM + '  Orden = P(aceptación) 45% · facilidad repro 30% · claridad impacto 25%.' + c.RESET)
    print('\n'.join(out))


def build_parser():
    """Return the argument parser."""
    p = ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument('--root', default=os.getcwd())
    p.add_argument('--color', choices=['auto', 'always', 'never'], default='auto')
    p.add_argument('--top', type=int, default=0, help='show only the top N')
    return p


def main():
    """Resolve root, score DONE.md VULNs, render the ranked dashboard."""
    args = build_parser().parse_args()
    root = find_root(args.root)
    done = read_lines(root / 'hunt' / 'DONE.md')
    submitted = submitted_ids(root)
    rows = [s for s in (score(root, l, submitted) for l in done) if s and s['reachable']]
    rows.sort(key=lambda r: r['composite'], reverse=True)
    if args.top > 0:
        rows = rows[:args.top]
    render(rows, C(use_color(args.color)), root)


if __name__ == '__main__':
    main()
