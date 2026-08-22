#!/usr/bin/env bash
# Pre-push guard: this folder is published publicly (~/.vim dotfile repo).
# Fails if a skill leaks a client identifier, real host, secret or national ID.
# Usage: ./check-leaks.sh [dir]      exit 1 = leak found
#
# The client list is DERIVED AT RUNTIME from the engagement directories on this
# machine, never hard-coded -- this file itself is public and must name no client.
#
# Two blind spots were found the hard way and are handled below:
#  * a client token glued inside a longer hostname (api.<something><client>.cl) has
#    no leading word boundary, so matching is by SUBSTRING, not \b...\b;
#  * a client name that is also a dictionary word would be dropped as noise, so
#    those are matched case-SENSITIVELY (the capitalised proper-noun form only)
#    instead of being discarded.

set -uo pipefail
DIR="${1:-$(dirname "$(readlink -f "$0")")}"
PAWN="${PAWN_DIR:-$HOME/Pawn}"
MIRROR="${MIRROR_DIR:-$HOME/Software/Python/CyscopeCli/donotgit}"
DICT=$(ls /usr/share/dict/american-english /usr/share/dict/spanish 2>/dev/null)

# Training/CTF/lab/platform namespaces are not clients.
NOTCLIENT='^(CyScope|Lab|Machine|HTB|CTF|Attack|Break|Hacker|Libreria|Data|Camp|Sandbox|Test|Demo|Template|Report|Script|Program|Session|Target|Client|Findings|Release|Public|Mobile|Cloud|Reverse|Pwn|Web|Wifi|PortSwigger|Vulnlab|VulnLab|Scan)'

mapfile -t ALL < <(
  { ls "$PAWN" 2>/dev/null; ls "$MIRROR" 2>/dev/null; } \
    | grep -vE '^(du-|\.|[0-9])' | grep -vE "$NOTCLIENT" \
    | grep -E '^[A-Za-z][A-Za-z0-9]{3,}$' | sort -u)

CI=() ; CS=()
for n in "${ALL[@]}"; do
  if [ -n "$DICT" ] && grep -qixF "$n" $DICT 2>/dev/null; then
    # A dictionary word is only a client when it appears as a proper noun.
    [[ "$n" =~ ^[a-z] ]] && continue
    CS+=("$n")
  else CI+=("$n"); fi
done

rc=0
hit() { rc=1; printf '\033[31mLEAK\033[0m %-12s %s\n' "$1" "$2"; }
FILES=(--include='SKILL.md' --include='*.py' --include='*.sh' --include='*.md')
# Unescape regex-escaped dots so "api\.acme\.cl" is seen as a hostname.
scan() { grep -rIh "${FILES[@]}" -o '' "$DIR" >/dev/null 2>&1; }

ALLOW='example\.(com|org|net)|github(usercontent)?\.com|npmjs|pypi|owasp\.org|portswigger\.net|frida\.re|python\.org|mozilla\.org|w3\.org|kernel\.org|docs\.|developer\.|hackerone\.com|bugcrowd\.com|intigriti\.com|yeswehack\.com|cyscope\.io|first\.org|nvd\.nist\.gov|cve\.org|crt\.sh|certspotter\.com|tinmarino\.com|localhost|schemas\.android\.com|mitre\.org|apache\.org|json-schema\.org|graphql\.org|oast\.pro|interactsh|metadata\.google\.internal|hasura\.app|seclists|jquery|bootstrap'

# 1a. Client names that are NOT dictionary words: case-insensitive SUBSTRING.
if ((${#CI[@]})); then
  pat=$(IFS='|'; echo "${CI[*]}")
  while IFS= read -r l; do hit client-name "$l"; done < <(
    grep -rIn "${FILES[@]}" -Ei "($pat)" "$DIR" 2>/dev/null \
      | grep -v "^$DIR/check-leaks.sh:" \
      | grep -viE 'CyscopeCli')   # tool-repo name, collides by substring with a client token
fi
# 1b. Client names that ARE dictionary words: capitalised form only, substring.
if ((${#CS[@]})); then
  pat=$(IFS='|'; echo "${CS[*]}")
  while IFS= read -r l; do hit client-word "$l"; done < <(
    grep -rIn "${FILES[@]}" -E "($pat)" "$DIR" 2>/dev/null \
      | grep -v "^$DIR/check-leaks.sh:")
fi

# 2. Hostnames, whether in a URL, bare, or regex-escaped (api\.host\.cl).
while IFS= read -r l; do hit hostname "$l"; done < <(
  grep -rIh --include='SKILL.md' --include='*.py' -o \
    -E '[A-Za-z0-9-]+(\\?\.[A-Za-z0-9-]+)+\\?\.(cl|com|net|org|io|app|dev|cloud|co|br|ar|pe|mx)\b' \
    "$DIR" 2>/dev/null | sed 's/\\//g' | sort -u | grep -vEi "$ALLOW" \
    | grep -vE '^(com|org|cl|io|net|app|dev)\.')

# 3. Credential-shaped material.
while IFS= read -r l; do hit secret "$l"; done < <(
  grep -rIn --include='SKILL.md' --include='*.py' -E \
    'eyJ[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|AIza[A-Za-z0-9_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY|(Authorization|Cookie): *[A-Za-z]* *[A-Za-z0-9+/=_.-]{25,}' \
    "$DIR" 2>/dev/null)

# 4. National IDs. Only an explicit synthetic allowlist passes -- "ends in zeros"
#    was too permissive and let realistic values through.
SYNTH='^(11111111|22222222|12345678|16000000|10000000|1000000)$'
while IFS= read -r l; do
  n=$(grep -oE '[0-9.]{7,11}-[0-9kK]' <<<"$l" | head -1); n=${n%%-*}; n=${n//./}
  [[ "$n" =~ $SYNTH ]] && continue
  hit national-id "$l"
done < <(grep -rIn --include='SKILL.md' --include='*.py' -oE '[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-[0-9kK]' "$DIR" 2>/dev/null)

# 5. Public IPv4 literals (private, doc and metadata ranges are fine).
while IFS= read -r l; do hit public-ip "$l"; done < <(
  grep -rIhoE --include='SKILL.md' --include='*.py' '(^|[^/0-9])([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$DIR" 2>/dev/null \
    | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' \
    | sort -u | grep -vE '^(10\.|127\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|169\.254\.|0\.|255\.|203\.0\.113\.|198\.51\.100\.|192\.0\.2\.|224\.|1\.1\.1\.1$|8\.8\.8\.8$)')


# 6. Client-derived finding-id prefixes. Skills must only ever use the agent
#    namespace AI### or an explicit <PFX> placeholder; a two/three-letter
#    prefix plus three digits is almost always a real client's report id.
while IFS= read -r l; do hit finding-id "$l"; done < <(
  grep -rIn --include='SKILL.md' -oE '\b[A-Z]{2,3}[0-9]{3}\b' "$DIR" 2>/dev/null \
    | grep -vE ':(AI|PFX|CWE|CVE|RFC|ISO|UTF|SHA|MD5|AES|RSA|JWT|SQL|XSS|API|TLS|SSL|HTTP)[0-9]{3}$')

n=$(ls -d "$DIR"/*/SKILL.md 2>/dev/null | wc -l)
if ((rc)); then echo; echo "FAILED -- placeholder these before pushing."
else echo "OK -- $n skills clean (client names, hosts, secrets, national IDs, public IPs)."; fi
exit $rc
