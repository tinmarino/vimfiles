#!/usr/bin/env sh
# Helper generate scope tags (Used for AlmaSw)
# From: https://stackoverflow.com/questions/934233

find . -type f \
\( \
  \( \
  -name '*.py' \
  -o -name '*.java' \
  -o -iname '*.[CH]' \
  -o -name '*.cpp' \
  -o -name '*.cc' \
  -o -name '*.hpp'  \
  \) \
  -and \( -not -type l \) \
\) \
-print \
> cscope.files

# -b: just build
# -q: create inverted index: fast but larger database
# -R search symbols recursively
cscope -b -q
