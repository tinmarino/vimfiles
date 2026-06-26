---
name: python-writer
description: Write Python modules, CLIs, and tests in Tinmarino's personal style (shebang + module docstring layout, verb-first function docstrings, overindented multi-line signatures, paragraph comments, `argparse` + `argcomplete` CLI dispatcher pattern, `from X import Y` stdlib imports for early-fail, closures over one-shot helpers, flat branches via guard clauses / dispatch tables). Use whenever you are about to create or substantially edit a `.py` file in Stock, sistema-fair-risk, libreriactf, or any future Python project of Tinmarino's.
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
  reference-projects: stock,sistema-fair-risk,libreriactf
---

# python-writer

Writes Python code the way Tinmarino writes it. Loaded any time we are
about to create a new `.py` file, add a function, or refactor an
existing one inside any of Tinmarino's Python projects.

## 1. Hard rules (never violate)

1. **Preserve user-authored comments and docstrings verbatim.** Never
   delete, reword, or paraphrase a `#` comment or a triple-quoted
   docstring that the user wrote. You may add new ones. You may not
   touch existing ones.
2. **Shebang first.** Every `.py` file starts with
   `#!/usr/bin/env python3` on line 1, before the module docstring.
3. **No single-letter identifiers** except classical loop indices
   (`i`, `j`, `k`). Prefer `value_str`, `file_path`, `engine`, not
   `s`, `p`, `e`.
4. **English** for all new code comments and docstrings.
5. **Never `git push`.** Commits are fine; remote pushes must come
   from the user.
6. **Prefer `from X import Y` over bare `import X` for stdlib modules.**
   Import every name you use explicitly so that a missing/renamed
   attribute fails at startup (early-fail) instead of the first call
   site.

   ```python
   # GOOD — fails immediately if any of these names moves or disappears
   from logging import getLogger, FileHandler, Formatter, INFO
   from os import environ
   from os.path import expanduser
   from subprocess import run as subprocess_run, TimeoutExpired
   from threading import Thread, Event, Lock

   # BAD — `logging.getLogger` is only resolved the first time you call it
   import logging
   log = logging.getLogger(__name__)
   ```

   Exceptions:
   - `import numpy as np`, `import pandas as pd`,
     `import matplotlib.pyplot as plt`, `import pdfplumber`,
     `import yfinance as yf` and other third-party libs whose
     idiomatic usage is the module alias.
   - `import X as _X` when you need to rebind a module-level setter
     (e.g. `_threading.excepthook = …`).
7. **Early-fail, closures, low cyclomatic complexity.**
   - Validate inputs and preconditions at the top of a function
     (guard clauses); return or raise as soon as the failure is
     observable. Do not carry optional data through nested `if`s.
   - Prefer closures over class attributes for one-shot callbacks
     that capture a handful of local variables (e.g. pytest
     fixtures, `requests` adapters, argparse completers).
   - Keep cyclomatic complexity low:
     - Replace a chain of nested `for`s with a helper function that
       yields an iterator.
     - Replace nested `if` pyramids with either (a) a dispatch
       dictionary (`mapping[key] = handler`) or (b) a small
       `@dataclass` that encapsulates the branches as attributes.
     - Extract any loop whose body is > 10 lines into its own
       helper so the outer function stays readable at a glance.

## 2. File layout template

```python
#!/usr/bin/env python3

"""
One-line module summary ending with period.

Longer explanation of what lives here, any gotchas, which modules it
must NOT import from (to keep the dependency graph clean), etc.

"""

# -- pylint: disable=invalid-name  # only when a pylint rule collides with style

# Imports, grouped: stdlib -> third-party -> local (PEP 8 style)
# Prefer `from X import Y` so a missing attribute surfaces at import time.
from dataclasses import dataclass
from os.path import expanduser
from typing import Iterable

import pandas as pd
from sqlalchemy import create_engine

from .models import StockRecord
```

Rules for this block:

- The opening `"""` sits alone on its own line.
- A blank line follows it and precedes the closing `"""`.
- Imports are grouped **stdlib / third-party / local** with a single
  blank line between groups, PEP 8 style.
- Stdlib and project-local modules use `from X import Y` (see hard
  rule #6). Third-party scientific libs keep their `import X as Y`
  conventions (`np`, `pd`, `plt`).
- A `# Comment starting with a verb` appears above every logical block.

## 3. Function and method style

Single-line signature when parameters are short:

```python
def clean_float(raw: str) -> float:
    """ Convert a Chilean-locale number string (1.234,56) into a float. """
    # Remove thousands separator and swap decimal comma
    return float(raw.replace(".", "").replace(",", "."))
```

Multi-line signature when parameters do not fit:

```python
def screen(
        db_config: DatabaseConfig | None = None,
        sort_by: str = "range",
        period: str = "week",
        top: int = 30,
        ) -> None:
    """ Print a ranked table of stocks sorted by range% or performance% over the given period. """
    # Instantiate DB accessor
    if db_config is None:
        db_config = DatabaseConfig()
    ...
```

Rules:

- Docstring is one line when the description is short: `""" Verb phrase. """`
  with a leading and trailing space inside the quotes.
- Use verb-first imperative descriptions (`Return`, `Compute`, `Print`,
  `Upsert`, `Render`).
- Multi-line signatures indent the parameter list **8 spaces** (two
  levels) and place the closing `)` + return annotation aligned with
  those parameters (see `screen` above). The body of the function
  keeps normal 4-space indentation.
- Paragraph comments starting with a verb introduce every logical
  block inside the body.

## 3.b. Control-flow shape (early-fail, closures, flat branches)

Prefer shallow bodies. When a function looks like a pyramid of `if`s
or a nest of `for`s, that is a sign you need a helper or a dispatch
table.

### Guard clauses up top

```python
def build_tech_panel(nemo: str, indicators: dict) -> Panel:
    """ Build the technical-analysis Rich panel for *nemo*. """
    # Clause: refuse to build anything without indicators
    if not indicators:
        return Panel(f"No data for {nemo}", border_style="red")

    last_close = indicators.get("last_close")
    if last_close is None:
        return Panel(f"Missing close for {nemo}", border_style="red")

    # Main body stays at the primary indent level
    ...
```

### Closures over one-shot helpers

```python
def fetch_loop(nemo: str) -> None:
    """ Refresh *nemo* while the dashboard is running. """
    client = BolsaClient()

    # Closure captures client + nemo so the callback stays a pure function
    def _one_cycle() -> None:
        """ Fetch one snapshot and push it to the queue. """
        bars = client.get_intraday(nemo)
        queue.put(bars)

    while not stop.is_set():
        _one_cycle()
```

### Dispatch tables over nested `if`

```python
_SORT_FIELD = {
    "change": "variacion_pct",
    "range":  "range_pct",
    "pe":     "pe",
    "pb":     "pb",
    "vol":    "monto",
}

def apply_sort(rows: list[dict], key: str) -> list[dict]:
    """ Sort *rows* by *key*; unknown keys fall back to ticker order. """
    field = _SORT_FIELD.get(key)
    if field is None:
        return rows
    return sorted(rows, key=lambda row: row.get(field) or 0, reverse=True)
```

### When to extract a helper

Refactor a block into its own function when any of these is true:

- It contains more than two levels of indentation.
- It contains a loop whose body is longer than ~10 lines.
- It is duplicated across two call sites with only cosmetic
  differences.

## 4. CLI scaffold (argparse + argcomplete)

Tinmarino's reference layout lives in
`~/Software/Pentest/libreriactf/lctf.py` (tiny shim) and
`~/Software/Pentest/libreriactf/lctf/run.py` (dispatcher). Copy this
pattern for every new Python project.

### 4.a. Thin shim at the repo root — `<proj>.py`

```python
#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
""" <Proj> CLI """
# Append sys
from os.path import dirname, abspath
from sys import path
path.append(dirname(abspath(__file__)))

# -- pylint: disable=wrong-import-position
from <proj>.run import <proj>_run
<proj>_run()
```

### 4.b. Dispatcher — `<proj>/run.py`

Key moves, in order:

1. Module docstring lists usage examples (one per subcommand).
2. Globals:
   - `arg_default_verbose = 0`, `arg_default_instance = "demo-2025"`, etc.
   - One `OrderedDict` per subcommand describing its flag set:
     ```python
     d_ctfd = OrderedDict()
     d_ctfd["all"]     = "Run all roles in order"
     d_ctfd["apt"]     = "Install apt dependencies (CTFd)"
     ```
   - A master `OrderedDict` `d_all` mapping subcommand name to
     `(flag_dict, subparser_description)`.
3. `parse_argument()` builds the parser:
   ```python
   common_args = add_global(ArgumentParser(add_help=False))
   parser = ArgumentParser(prog="<proj>", description=__doc__,
                           formatter_class=RawTextHelpFormatter)
   add_global(parser, "_main")
   parser.add_argument("-hh", "--help-full", action=_FullHelpAction,
                       help="Print monolithic full help for each command")
   subparser = parser.add_subparsers(dest="command", help="Command to run")
   for subcommand, (d_cmd, desc) in d_all.items():
       sp = subparser.add_parser(subcommand, help=desc, parents=[common_args])
       for action, subdesc in d_cmd.items():
           sp.add_argument(f"--{action}", action="store_true",
                           default=False, help=subdesc)
   autocomplete(parser)
   ```
4. Guard clauses:
   - If `not sys_argv[1:]` → print help.
   - If `not args.command` → print help.
5. Verbose handling via `add_global()` with `dest_suffix` so the
   flag can appear **before or after** the subcommand, and
   `gather_prefix(args, dest_suffix="_main")` merges the two.
6. Dispatch: iterate over `d_all[cmd][0]` to build an Ansible-style
   `args.tags = "apt,install"` string, or run a Python action from a
   local `action_map` when the subcommand lives in pure Python
   (e.g. `local` → `dashboard`, `list_host`, etc.).
7. Custom `_FullHelpAction` that walks `parser._actions` /
   `_SubParsersAction.choices` to print every subparser's help in a
   single output (triggered with `-hh`).
8. Colored console output via a small `utils` module exposing
   `info`, `red`, `green`, `bpurple`, `cpurple`, `creset`. Do **not**
   print raw ANSI codes inline; go through these helpers.
9. Colored argparse help via `ColorHelpFormatter` (see § 4.e).
   Pass `formatter_class=ColorHelpFormatter` to every `ArgumentParser`
   and `add_subparsers().add_parser(...)` call so the colorscheme
   propagates to subcommands.

### 4.c. Argcomplete activation

- Keep `# PYTHON_ARGCOMPLETE_OK` as the second line of the shim.
- Call `autocomplete(parser)` **before** `parser.parse_args(...)`.
- For dynamic completions (e.g., completing cartola filenames),
  define a completer callable and attach it:
  ```python
  def _tf_completer(prefix, **kwargs):
      """ Return cartola file stem names matching *prefix* for argcomplete. """
      _ = kwargs
      if not CARTOLA_DIR.is_dir():
          return []
      return [p.stem for p in sorted(CARTOLA_DIR.glob("*.txt"))
              if p.stem.startswith(prefix)]

  arg = parser.add_argument("--ticker")
  arg.completer = _tf_completer
  ```

### 4.d. Built-in `test` subcommand

Every project should expose a `test` subcommand from the CLI so
that regression is a one-liner without leaving the terminal. Both
Stock (`./stock.py test --unit`) and libreriactf (`./lctf.py local
--test`) do this. Minimum scaffold:

1. Register a `test` subparser in `d_all` (or as a top-level
   subcommand when your CLI is small):

   ```python
   d_test = OrderedDict()
   d_test["unit"]        = "Run fast unit tests (no network, no DB)"
   d_test["integration"] = "Run integration tests (hits fixture files, DB, APIs)"
   d_test["all"]         = "Run the whole suite"
   d_test["lint"]        = "Run pylint / ruff on the package"
   d_all["test"]         = (d_test, "Test runner")
   ```

2. Handle the subcommand inside the dispatcher (top of
   `<proj>_run`) BEFORE falling through to the ansible / main
   branches:

   ```python
   if cmd == "test":
       from .util.test_runner import run_tests
       run_tests(args=args)
       return
   ```

3. Implement `run_tests` (pattern below) so each flag maps to a
   pytest selector. Keep the path list centralised so it is easy to
   add new suites.

   ```python
   import subprocess
   from pathlib import Path

   UNIT_DIRS = ["tests/unit"]
   INTEGRATION_DIRS = ["tests/integration"]

   def run_tests(args) -> None:
       """ Dispatch pytest based on the CLI flags. """
       targets: list[str] = []
       if getattr(args, "unit", False) or getattr(args, "all", False):
           targets += UNIT_DIRS
       if getattr(args, "integration", False) or getattr(args, "all", False):
           targets += INTEGRATION_DIRS
       if not targets:
           targets = UNIT_DIRS   # default: fast unit tests
       cmd = ["python", "-m", "pytest", "-v", *targets]
       subprocess.run(cmd, check=True)

       # Optional lint step
       if getattr(args, "lint", False):
           subprocess.run(["pylint", Path(__file__).parent], check=True)
   ```

4. Wire it in the project README / Makefile so discoverability is
   trivial:

   ```bash
   ./<proj>.py test --unit          # fast loop during development
   ./<proj>.py test --integration   # before committing
   ./<proj>.py test --all --lint    # what CI should run
   ```

Use pytest discovery conventions (`test_*.py`, `tests/` directory)
so `python -m pytest` also works out of the box for editor
integrations (vim-test, VS Code test explorer).

### 4.e. Colored help via `ColorHelpFormatter`

Drop the following formatter into the dispatcher (or into the `utils`
module) and pass it to every `ArgumentParser` and every
`add_subparsers().add_parser(...)` call so subcommands inherit the
same colorscheme. Reference implementations live in
`libreriactf/lctf/run.py` and `AcademyBook/book/run.py`.

Colorscheme (default-terminal ANSI, readable on light **and** dark
backgrounds — do not pick fixed RGB):

| Element                       | Color  | Constant   |
|-------------------------------|--------|------------|
| Box around description/epilog | yellow | `CYELLOW`  |
| Description first line (title)| bold purple | `BPURPLE` |
| Description body lines        | blue   | `CBLUE`    |
| `usage:` keyword              | yellow | `CYELLOW`  |
| Section headings (`options:`) | blue   | `CBLUE`    |
| Choice metavars `{a,b,c}`     | yellow | `CYELLOW`  |
| Option flags (`-h`, `--foo`)  | purple | `CPURPLE`  |
| Indented subcommand names     | purple | `CPURPLE`  |
| Program name                  | green  | `CGREEN`   |

ANSI constants:

```python
CGREEN  = "\033[32m"
CYELLOW = "\033[33m"
CBLUE   = "\033[34m"
CPURPLE = "\033[35m"
CRESET  = "\033[0m"
BPURPLE = "\033[1m\033[35m"
```

`_is_tty()` guard — colors are only emitted when stderr is a real
terminal so piped/scripted output stays clean:

```python
from sys import stderr as sys_stderr

def _is_tty():
    """ True iff stderr is a terminal (gate ANSI output). """
    return hasattr(sys_stderr, "isatty") and sys_stderr.isatty()
```

Formatter (rename `PROG_NAME` to your CLI's actual program name):

```python
from argparse import RawTextHelpFormatter
from re import MULTILINE as re_MULTILINE, sub as re_sub

PROG_NAME = "myproj"  # the value passed as prog= to ArgumentParser


class ColorHelpFormatter(RawTextHelpFormatter):
    """ Argparse formatter that adds ANSI colors when stderr is a TTY.

    Yellow box around the description/epilog (BPURPLE on the first
    line, CBLUE on the rest), blue section headings, purple option
    flags and indented subcommand choices, yellow choice metavars,
    green program name. """

    def _format_text(self, text):
        """ Wrap parser description (and epilog) in a yellow box. """
        if not text or not text.strip() or not _is_tty():
            return super()._format_text(text)
        lines = text.rstrip("\n").split("\n")
        width = max((len(line) for line in lines), default=1)
        indent = " " * self._current_indent
        barr = "═" * (width + 2)
        top    = f"{indent}{CYELLOW}╔{barr}╗{CRESET}"
        bottom = f"{indent}{CYELLOW}╚{barr}╝{CRESET}"
        middle = []
        for i, line in enumerate(lines):
            padded = line.ljust(width)
            inner = f"{BPURPLE}{padded}{CRESET}" if i == 0 else f"{CBLUE}{padded}{CRESET}"
            middle.append(f"{indent}{CYELLOW}║{CRESET} {inner} {CYELLOW}║{CRESET}")
        return "\n".join([top, *middle, bottom]) + "\n\n"

    def format_help(self):
        text = super().format_help()
        if not _is_tty():
            return text

        # 'usage:' -> yellow
        text = re_sub(r"^(usage:)", f"{CYELLOW}\\1{CRESET}", text,
                      flags=re_MULTILINE)

        # Program name -> green
        text = re_sub(rf"\b{PROG_NAME}\b",
                      f"{CGREEN}{PROG_NAME}{CRESET}", text)

        # Section headings ('positional arguments:', 'options:') -> blue
        text = re_sub(r"^([A-Za-z][A-Za-z ]*?):\s*$",
                      f"{CBLUE}\\1:{CRESET}", text, flags=re_MULTILINE)

        # Choice metavars {a,b,c,...} -> yellow (BEFORE option flag rule)
        text = re_sub(r"(\{[\w-]+(?:,[\w-]+)+\})",
                      f"{CYELLOW}\\1{CRESET}", text)

        # Option flags (-h, --help, --foo-bar) -> purple
        text = re_sub(r"(?<![A-Za-z0-9_])(-{1,2}[A-Za-z][\w-]*)",
                      f"{CPURPLE}\\1{CRESET}", text)

        # Subcommand choice names (4-space indent + word + 2+ spaces) -> purple
        text = re_sub(
            r"^(    )([A-Za-z][\w-]*)(\s{2,})",
            lambda m: f"{m.group(1)}{CPURPLE}{m.group(2)}{CRESET}{m.group(3)}",
            text, flags=re_MULTILINE,
        )

        return text
```

Wiring:

```python
formatter = ColorHelpFormatter if _is_tty() else RawTextHelpFormatter
parser = ArgumentParser(prog=PROG_NAME, description=__doc__,
                        formatter_class=formatter)
# Every subparser inherits the same formatter:
sub = parser.add_subparsers(dest="command")
compile_sp = sub.add_parser("compile", help="Compile to PDF",
                            formatter_class=formatter)
```

Notes:

- The choice-metavars regex must run **before** the option-flags
  regex; the option-flag rule would otherwise match `-x` inside
  `{-x,-y}`.
- The "indented subcommand" rule keys on exactly four leading
  spaces followed by 2+ trailing spaces — that's argparse's default
  layout for subparser choices. If you change `max_help_position`,
  re-tune this regex.
- Don't expand the program-name regex to match arbitrary words; the
  literal `PROG_NAME` keeps false positives out (e.g., the word
  "book" appearing inside a help string).

## 5. Tests

- Pytest-style, one file per production module: `tests/test_<module>.py`.
- A `test --unit` / `test --integration` subcommand lives in the CLI
  dispatcher (see Stock's `run.py`) so tests can run without leaving
  the CLI.
- Integration tests are expected to hit a canonical fixture
  (e.g. `pdf/ibd150426.pdf`) rather than a dynamic download.

## 6. Parallel HTTP fan-out and IP rotation → use the `http-async-rotate` skill

When a script must fire many HTTP requests in parallel (enumeration, fuzzing,
bulk API calls) or rotate the source IP through AWS API Gateway, do NOT
re-derive the pattern here. Load the **http-async-rotate** skill instead — it
owns the canonical continuous bounded worker pool (always `--workers` in flight,
refill on `FIRST_COMPLETED`), the `requests_ip_rotator` start/`shutdown`,
the `--workers`/`--rotate`/`--resume` CLI contract, the per-input file +
`hits.csv` output layout, and the short-lived-token `session.yaml` flow.

This skill (python-writer) still governs HOW that code is written — file
layout, naming, `from X import Y` imports, docstrings, guard clauses. The two
compose: http-async-rotate for the concurrency/rotation pattern, python-writer
for the style it is written in.

## 7. When in doubt

- Open the nearest `CLAUDE.md` of the target project first
  (e.g. `~/Software/Python/Stock/CLAUDE.md`,
  `~/Software/Python/sistema-fair-risk/CLAUDE.md`). Project-specific
  rules override anything in this skill.
- If a rule I give here conflicts with the project's `CLAUDE.md`,
  follow the project. This skill captures the shared baseline; each
  project may tighten or relax it.
