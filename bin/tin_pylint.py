#!/usr/bin/env python3
"""
https://stackoverflow.com/questions/2028268/invoking-pylint-programmatically

Message(
    msg_id='C0326',
    symbol='bad-whitespace',
    msg="Exactly one space required before assignment\ninNone    = inColor('\\033[0m')\n          ^", C='C',
    category='convention',
    confidence=Confidence(name='UNDEFINED', description='Warning without any associated confidence level.'),
    abspath='/home/tourneboeuf/Test/ACULinearCoeff.py', path='ACULinearCoeff.py', module='ACULinearCoeff', obj='',
    line=50,
    column=10),
"""

import pprint
import argparse
import re
import tempfile
import shutil
import os
from pylint import lint
from pylint.reporters.collecting_reporter import CollectingReporter


# Define helpers
def create_temporary_copy(path):
    temp_dir = tempfile.gettempdir()
    temp_path = os.path.join(temp_dir, 'temp_file_name')
    shutil.copy2(path, temp_path)
    return temp_path
pp = pp = pprint.PrettyPrinter(indent=2)

# Parse args (To be extended)
parser = argparse.ArgumentParser(description=(
    "Fake Linter, Edit file in place Add:\n"
    "  # pylint: disable=bad-whitespace  # AUTO TOGREP\n"
    "On line before linter detect errors"
    ))
args, remaining_args = parser.parse_known_args()


# Create list appender container
collecting_reporter = CollectingReporter()
# -- Just a bug
# -- pylint: disable=protected-access
collecting_reporter._display = lambda x: None


# Get and copy file (TODO plural)
filename = remaining_args[0]
filename_in = create_temporary_copy(filename)


# Read file
lines_in = []
with open(filename_in, "r") as myfile:
    lines_in = myfile.readlines()

# Parse: Lint
#print('Linting', filename)
run = lint.Run([filename_in, "-sn"], do_exit=False, reporter=collecting_reporter)
n = len(lines_in)
# Sort mesages
msgs_in = [[] for x in range(n)]
for msg in run.linter.reporter.messages:
    msgs_in[msg.line-1].append(msg.symbol)
#print(run.linter.reporter.messages)


# Craft out
lines_out = []
for i, line in enumerate(lines_in):
    # Clause
    if not msgs_in[i]:
        lines_out.append(line)
        continue

    # Get indent
    indent = ''
    try:
        indent = ' ' * re.search(r'\S', line).start()
    except AttributeError:
        pass

    # Append symbols
    for symbol in msgs_in[i]:
        lines_out.append(indent + "# pylint: disable=" + symbol + "  # AUTO TOGREP\n")

    # Append line
    lines_out.append(line)


# Write out
with open(filename, "w") as myfile:
    myfile.writelines(lines_out)

pp.pprint(run.linter.stats)
