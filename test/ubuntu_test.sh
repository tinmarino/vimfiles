#!/usr/bin/env bash
# Test dentro del container Ubuntu: valida vim y tmux con la config del usuario.
# Corre como usuario no-root. Imprime PASS/FAIL por check y retorna != 0 si algo falla.

set -u

declare -i gi_fail=0
VIMRC="$HOME/.vimrc"
TMUXCONF="$HOME/.tmux.conf"
SOCK="ubtest"

pass() { echo -e "  \e[32m[PASS]\e[0m $1"; }
fail() { echo -e "  \e[31m[FAIL]\e[0m $1"; (( gi_fail++ )); }

echo "==================================================="
echo " Test de vimfiles en Ubuntu (vim + tmux)"
echo "==================================================="
echo "[*] vim : $(vim --version 2>/dev/null | head -1)"
echo "[*] tmux: $(tmux -V 2>/dev/null)"
echo "[*] HOME=$HOME  vimrc=$VIMRC  tmux=$TMUXCONF"

# --- Check 0: los symlinks existen ---
echo; echo "--> Check 0: symlinks de install.sh"
if [ -e "$VIMRC" ]; then pass "~/.vimrc existe"; else fail "~/.vimrc NO existe"; fi
if [ -e "$TMUXCONF" ]; then pass "~/.tmux.conf existe"; else fail "~/.tmux.conf NO existe"; fi

# --- Check A: vim carga el vimrc sin errores ---
echo; echo "--> Check A: vim -Es -u ~/.vimrc +qall!"
vlog=$(mktemp)
# -Es: modo ex silencioso; TERM para que no reclame terminal.
TERM=xterm vim -N -Es -u "$VIMRC" \
  -c 'redir! > /tmp/vim_messages.log' -c 'silent messages' -c 'redir END' \
  -c 'qall!' >"$vlog" 2>&1
vrc=$?
echo "    exit code = $vrc"
if [ "$vrc" -eq 0 ]; then pass "vim salio con 0"; else fail "vim salio con $vrc"; fi
# Buscamos errores tipicos (E123:, 'Error detected') en la salida y en messages.
if grep -qE 'E[0-9]+:|Error detected|Traceback' "$vlog" /tmp/vim_messages.log 2>/dev/null; then
  fail "vim reporto errores:"
  grep -nE 'E[0-9]+:|Error detected|Traceback' "$vlog" /tmp/vim_messages.log 2>/dev/null | sed 's/^/      /' | head -20
else
  pass "vim no reporto errores (E.../Error detected)"
fi
rm -f "$vlog"

# --- Check B: tmux arranca y sourcea el tmux.conf sin errores ---
echo; echo "--> Check B: tmux new -d + source-file"
tmux -L "$SOCK" kill-server >/dev/null 2>&1
terr=$(mktemp)
tmux -L "$SOCK" -f "$TMUXCONF" new-session -d -s t 2>"$terr"
brc=$?
if [ "$brc" -eq 0 ]; then pass "tmux new-session -d arranco (con -f ~/.tmux.conf)"; else fail "tmux new-session fallo ($brc)"; fi
# Re-sourceamos explicitamente y capturamos stderr + show-messages
tmux -L "$SOCK" source-file "$TMUXCONF" 2>>"$terr"
src=$?
if [ "$src" -eq 0 ]; then pass "source-file ~/.tmux.conf retorno 0"; else fail "source-file retorno $src"; fi
# show-messages muestra errores de config acumulados
msgs=$(tmux -L "$SOCK" show-messages 2>/dev/null)
# Errores reales: lineas con 'error', 'not found', 'unknown', 'usage:', 'invalid', 'no such'
if grep -qiE 'error|not found|command not found|unknown|invalid|no such|failed' "$terr"; then
  fail "tmux escribio en stderr:"
  sed 's/^/      /' "$terr" | head -20
else
  pass "tmux sin errores en stderr"
fi
if echo "$msgs" | grep -qiE 'error|unknown command|invalid|no such|can.t'; then
  fail "tmux show-messages con errores:"
  echo "$msgs" | grep -iE 'error|unknown command|invalid|no such|can.t' | sed 's/^/      /' | head -20
else
  pass "tmux show-messages sin errores"
fi
tmux -L "$SOCK" kill-server >/dev/null 2>&1
rm -f "$terr"

# Patrones de error "reales" que buscamos en stderr de bash/git/inputrc.
ERRPAT='command not found|No such file|syntax error|unbound variable|permission denied|not found|cannot execute'
# Ruido benigno por falta de TTY (no es error de config): lo ignoramos.
NOISE='cannot set terminal process group|no job control|Inappropriate ioctl'

# Corre un shell interactivo bajo un PTY (con `script`) para evitar el ruido de
# job-control. TMUX=fake evita que bashrc.sh haga `exec env tmux` (linea 37)
# y reemplace el shell del test.
run_pty() { # $1 = comando bash a correr; deja stderr en $2
  local cmd="$1" errf="$2"
  TMUX=fake script -qec "$cmd" /dev/null >/dev/null 2>"$errf"
  return $?
}

# --- Check C: ~/.bashrc (dotfile/bashrc.sh) en crudo ---
echo; echo "--> Check C: bash -ic / bash -lic con ~/.bashrc"
cerr=$(mktemp)
run_pty "bash -ic true" "$cerr"; crc=$?
if [ "$crc" -eq 0 ]; then pass "bash -ic 'true' salio 0"; else fail "bash -ic 'true' salio $crc"; fi
lerr=$(mktemp)
run_pty "bash -lic true" "$lerr"; lrc=$?
if [ "$lrc" -eq 0 ]; then pass "bash -lic 'true' salio 0 (con ~/.bash_profile)"; else fail "bash -lic 'true' salio $lrc"; fi
# Filtramos el ruido de TTY y buscamos errores reales
cbad=$( { cat "$cerr" "$lerr"; } | grep -viE "$NOISE" | grep -iE "$ERRPAT" )
if [ -n "$cbad" ]; then
  fail "bashrc/bash_profile imprimio errores en stderr:"
  echo "$cbad" | sed 's/^/      /' | head -20
  # Origen exacto con bash -x
  echo "      (origen con bash -x:)"
  TMUX=fake bash -xic true 2>&1 | grep -iE "$ERRPAT" | grep -viE "$NOISE" | sed 's/^/        /' | head -10
else
  pass "bashrc/bash_profile sin errores en stderr (fuera del ruido de TTY)"
fi
rm -f "$cerr" "$lerr"

# --- Check D: git (~/.gitconfig = dotfile/gitconfig) ---
echo; echo "--> Check D: git config + commit"
gerr=$(mktemp)
git config --global --list >/dev/null 2>"$gerr"; grc=$?
if [ "$grc" -eq 0 ]; then pass "git config --global --list salio 0"; else fail "git config --global --list salio $grc"; fi
if [ -s "$gerr" ]; then fail "git config escribio en stderr:"; sed 's/^/      /' "$gerr" | head; fi
# Commit de prueba en repo temporal (user.name/email vienen del gitconfig)
rm -rf /tmp/gittest
if git init -q /tmp/gittest 2>"$gerr" && ( cd /tmp/gittest && git commit --allow-empty -m x >/dev/null 2>>"$gerr" ); then
  pass "git init + commit --allow-empty funciona (user.name/email definidos)"
else
  fail "git commit fallo (revisar user.name/user.email):"; sed 's/^/      /' "$gerr" | head
fi
rm -rf /tmp/gittest; rm -f "$gerr"

# --- Check E: ~/.inputrc (dotfile/inputrc) ---
echo; echo "--> Check E: bind -f ~/.inputrc"
ierr=$(mktemp)
run_pty "bash -ic 'bind -f ~/.inputrc'" "$ierr"; irc=$?
ibad=$( grep -viE "$NOISE" "$ierr" | grep -iE "$ERRPAT|warning|invalid" )
if [ "$irc" -eq 0 ] && [ -z "$ibad" ]; then
  pass "bind -f ~/.inputrc sin errores"
else
  fail "bind -f ~/.inputrc con problemas (exit=$irc):"; echo "$ibad" | sed 's/^/      /' | head
fi
rm -f "$ierr"

# --- Check F: core.excludesfile global apunta a un archivo existente ---
echo; echo "--> Check F: git core.excludesfile"
excl=$(git config --global core.excludesfile 2>/dev/null)
if [ -z "$excl" ]; then
  pass "core.excludesfile no definido (nada que validar)"
else
  # Expandimos ~ manualmente
  excl_exp="${excl/#\~/$HOME}"
  if [ -e "$excl_exp" ]; then
    pass "core.excludesfile ($excl) existe"
  else
    fail "core.excludesfile ($excl) NO existe -> $excl_exp"
  fi
fi

# --- Resumen ---
echo; echo "==================================================="
if [ "$gi_fail" -eq 0 ]; then
  echo -e " RESULTADO: \e[32mTODOS LOS CHECKS PASARON\e[0m"
else
  echo -e " RESULTADO: \e[31m$gi_fail CHECK(S) FALLARON\e[0m"
fi
echo "==================================================="
exit "$gi_fail"
