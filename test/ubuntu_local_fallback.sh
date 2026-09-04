#!/usr/bin/env bash
# Fallback: prueba la config directamente en la maquina local (sin docker).
# No sustituye al test en Ubuntu pelado, pero valida que vim/tmux sourceen sin error.
set -u
here="$( cd "$(dirname "$0")" && pwd -P )"
root="$( cd "$here/.." && pwd -P )"
declare -i fail=0
echo "==> Fallback local (sin docker)"

echo "--> vim -Es -u dotfile/vimrc +qall!"
if TERM=xterm vim -N -Es -u "$root/dotfile/vimrc" -c 'qall!' >/tmp/vl 2>&1; then
  echo "  [PASS] vim salio 0"
else
  echo "  [FAIL] vim salio $?"; sed 's/^/    /' /tmp/vl; ((fail++))
fi

echo "--> tmux -L t -f dotfile/tmux.conf new -d + source-file"
tmux -L ubtestlocal kill-server >/dev/null 2>&1
if tmux -L ubtestlocal -f "$root/dotfile/tmux.conf" new-session -d 2>/tmp/tl; then
  echo "  [PASS] tmux arranco"
else
  echo "  [FAIL] tmux fallo"; sed 's/^/    /' /tmp/tl; ((fail++))
fi
tmux -L ubtestlocal source-file "$root/dotfile/tmux.conf" 2>>/tmp/tl
if grep -qiE 'error|unknown|invalid|no such' /tmp/tl; then
  echo "  [FAIL] tmux con errores:"; sed 's/^/    /' /tmp/tl; ((fail++))
else
  echo "  [PASS] tmux sin errores"
fi
tmux -L ubtestlocal kill-server >/dev/null 2>&1
echo "==> fallback fail=$fail"
exit "$fail"
