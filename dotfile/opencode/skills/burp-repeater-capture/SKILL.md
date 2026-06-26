---
name: burp-repeater-capture
description: Use when the user asks to reenviar/enviar una request de Burp Repeater, capturar screenshots/pantallazos de Burp, or operate Burp without bringing the window to the foreground. Uses Burp MCP on localhost:9876 plus X11 window capture.
---

# Burp Repeater Capture

Use this skill when the user asks to send or resend a Burp Repeater request, capture a Burp screenshot, or do it without moving their screen/focus.

## Constraints

- Do not use `xdotool windowactivate` unless the user explicitly allows moving Burp to the foreground.
- Prefer Burp MCP on `127.0.0.1:9876` for request operations because Java/Swing often ignores `xdotool key --window` while inactive.
- Use `import -window <burp-window-id>` for screenshots because it captures the Burp window without focusing it.
- Save screenshots under `img/` in the current project unless the user provides another path.
- Use timestamp format `date '+%Y-%m-%dT%H:%M:%S.%3N'` for millisecond filenames.
- Never print full Authorization tokens or sensitive request bodies back to the user. Summarize status and file path only.

## Window Discovery

Find the main Burp window without focusing it:

```bash
xdotool search --name "Burp" | while read -r wid; do printf '%s %s\n' "$wid" "$(xdotool getwindowname "$wid")"; done
```

Use the window whose title starts with `Burp Suite`, not `install4j-burp-StartBurp`.

## Screenshot Only

```bash
mkdir -p "img"
wid="$(xdotool search --name "Burp Suite" | head -n 1)"
ts="$(date '+%Y-%m-%dT%H:%M:%S.%3N')"
import -window "$wid" "img/capture-${ts}.png"
file "img/capture-${ts}.png"
```

## Re-send Active Editor Without Focus

Use this when the active Repeater editor already contains the request the user wants to resend. It reads the active editor via Burp MCP, parses HTTP/1.1 or HTTP/2, sends it via MCP, and captures a screenshot without focusing Burp.

```bash
mkdir -p "img" "/tmp/opencode"
wid="$(xdotool search --name "Burp Suite" | head -n 1)"
ts="$(date '+%Y-%m-%dT%H:%M:%S.%3N')"
raw="/tmp/opencode/burp-active-${ts}.txt"
resp="/tmp/opencode/burp-send-${ts}.json"

curl -sS -N http://127.0.0.1:9876/ > "/tmp/opencode/burp-sse-${ts}.log" 2>&1 &
pid="$!"
sleep 0.5
session="$(perl -ne 'print $1 if /data: \?(sessionId=[0-9a-f-]+)/' "/tmp/opencode/burp-sse-${ts}.log")"

post() {
  curl -sS -X POST "http://127.0.0.1:9876/?${session}" \
    -H 'Content-Type: application/json' \
    -d "$1" >/dev/null
}

post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"opencode-burp-repeater-capture","version":"1.0"}}}'
sleep 0.2
post '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
post '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_active_editor_contents","arguments":{}}}'
sleep 0.7
kill "$pid" 2>/dev/null || true

perl -0777 -ne 'print $1 if /"text":"((?:[^"\\]|\\.)*)","type":"text"/' "/tmp/opencode/burp-sse-${ts}.log" \
  | python3 -c 'import json,sys; print(json.loads("\"" + sys.stdin.read() + "\""), end="")' > "$raw"

python3 - "$raw" "$resp" <<'PY'
from json import dumps
from pathlib import Path
from subprocess import check_call
from sys import argv

raw = Path(argv[1]).read_text()
out = Path(argv[2])
head, _, body = raw.partition("\r\n\r\n")
lines = head.split("\r\n")
request_line = lines[0]
headers = {}
for line in lines[1:]:
    if not line or ":" not in line:
        continue
    key, value = line.split(":", 1)
    headers[key.strip()] = value.strip()

host = headers.get("Host") or headers.get("host")
if not host:
    raise SystemExit("active request has no Host header")

target = host.split(":", 1)[0]
port = int(host.split(":", 1)[1]) if ":" in host else 443
uses_https = port == 443

if request_line.endswith(" HTTP/2"):
    method, path, _ = request_line.split(" ", 2)
    pseudo = {":method": method, ":path": path, ":authority": host, ":scheme": "https" if uses_https else "http"}
    headers = {k: v for k, v in headers.items() if k.lower() not in {"host", "content-length", "connection"}}
    tool = "send_http2_request"
    arguments = {"pseudoHeaders": pseudo, "headers": headers, "requestBody": body, "targetHostname": target, "targetPort": port, "usesHttps": uses_https}
else:
    tool = "send_http1_request"
    arguments = {"content": raw, "targetHostname": target, "targetPort": port, "usesHttps": uses_https}

message = {"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": tool, "arguments": arguments}}
out.write_text(dumps(message))
PY

curl -sS -N http://127.0.0.1:9876/ > "/tmp/opencode/burp-send-sse-${ts}.log" 2>&1 &
pid="$!"
sleep 0.5
session="$(perl -ne 'print $1 if /data: \?(sessionId=[0-9a-f-]+)/' "/tmp/opencode/burp-send-sse-${ts}.log")"
curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"opencode-burp-repeater-capture","version":"1.0"}}}' >/dev/null
sleep 0.2
curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' >/dev/null
curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' --data-binary "@$resp" >/dev/null
sleep 1
kill "$pid" 2>/dev/null || true

import -window "$wid" "img/capture-${ts}.png"
file "img/capture-${ts}.png"
```

## Create New Repeater Tab (HTTP/2) — Preferred for Fresh Requests

Use `create_repeater_tab_http2` when you have a raw request and want it to appear as a named tab in Burp Repeater. This is the correct approach when the user asks to "send a request to Repeater" — do NOT use `send_http2_request` alone for this purpose (it fires the request but does NOT update the Repeater UI).

**Important behaviour difference:**
- `create_repeater_tab_http2` — creates a visible named tab with the request pre-loaded; the response panel stays empty until the user (or you) clicks Send.
- `send_http2_request` — fires the request to the server and returns the response text in the MCP SSE stream, but does NOT update any Repeater tab UI. Use only when you need the raw response text in your script, not for screenshot evidence.

**Full recipe — create tab, send it, screenshot:**

```bash
mkdir -p "img" "/tmp/opencode"
wid="$(xdotool search --name "Burp Suite" | head -n 1)"
ts="$(date '+%Y-%m-%dT%H:%M:%S.%3N')"

# ── Step 1: create the named tab ────────────────────────────────────────────
curl -sS -N http://127.0.0.1:9876/ > "/tmp/opencode/burp-create-${ts}.log" 2>&1 &
pid="$!"
sleep 0.8
session="$(perl -ne 'print $1 if /data: \?(sessionId=[0-9a-f-]+)/' "/tmp/opencode/burp-create-${ts}.log")"

post() { curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' -d "$1" >/dev/null; }

post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"opencode","version":"1.0"}}}'
sleep 0.2
post '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
sleep 0.2

# Adjust tabName, pseudoHeaders, headers, requestBody, targetHostname, targetPort for your request.
post '{
  "jsonrpc":"2.0","id":3,"method":"tools/call",
  "params":{
    "name":"create_repeater_tab_http2",
    "arguments":{
      "tabName":"payment_simulate_demo",
      "pseudoHeaders":{
        ":method":"POST",
        ":path":"/api/v1/payments/simulate",
        ":authority":"api.example.com",
        ":scheme":"https"
      },
      "headers":{
        "user-agent":"Dart/3.11 (dart:io)",
        "accept-encoding":"gzip, deflate, br",
        "access_token":"<ACCESS_TOKEN>",
        "firma":"<FIRMA_HEX>",
        "content-type":"application/json"
      },
      "requestBody":"{\"tipoTransaccion\":\"simulate_post\",\"body\":{\"field_a\":\"AAA\",\"field_b\":\"BBB\",\"mode\":\"DEMO\",\"amount\":7,\"version_api\":\"V2\"}}",
      "targetHostname":"api.example.com",
      "targetPort":443,
      "usesHttps":true
    }
  }
}'
sleep 1.5
kill "$pid" 2>/dev/null || true

# Screenshot after tab creation (response panel will be empty — that is expected)
import -window "$wid" "img/tab-created-${ts}.png"
file "img/tab-created-${ts}.png"

# ── Step 2: fire the request and capture the response in the SSE stream ─────
ts2="$(date '+%Y-%m-%dT%H:%M:%S.%3N')"
curl -sS -N http://127.0.0.1:9876/ > "/tmp/opencode/burp-send-${ts2}.log" 2>&1 &
pid="$!"
sleep 0.8
session="$(perl -ne 'print $1 if /data: \?(sessionId=[0-9a-f-]+)/' "/tmp/opencode/burp-send-${ts2}.log")"

post() { curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' -d "$1" >/dev/null; }

post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"opencode","version":"1.0"}}}'
sleep 0.2
post '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
sleep 0.2

# Same request as above — send_http2_request returns the live server response
post '{
  "jsonrpc":"2.0","id":4,"method":"tools/call",
  "params":{
    "name":"send_http2_request",
    "arguments":{
      "pseudoHeaders":{":method":"POST",":path":"/api/v1/payments/simulate",":authority":"api.example.com",":scheme":"https"},
      "headers":{"user-agent":"Dart/3.11 (dart:io)","accept-encoding":"gzip, deflate, br","access_token":"<ACCESS_TOKEN>","firma":"<FIRMA_HEX>","content-type":"application/json"},
      "requestBody":"{\"tipoTransaccion\":\"simulate_post\",\"body\":{\"field_a\":\"AAA\",\"field_b\":\"BBB\",\"mode\":\"DEMO\",\"amount\":7,\"version_api\":\"V2\"}}",
      "targetHostname":"api.example.com","targetPort":443,"usesHttps":true
    }
  }
}'
sleep 3
kill "$pid" 2>/dev/null || true

# The response body is in the SSE log as a long "text":"..." field
grep -o '"text":"HttpRequestResponse[^"]*"' "/tmp/opencode/burp-send-${ts2}.log" | head -1

# Screenshot — NOTE: send_http2_request does NOT update the Repeater UI panel.
# The screenshot will still show the tab with an empty response. This is expected.
# The actual response is in the SSE log above.
import -window "$wid" "img/sent-${ts2}.png"
file "img/sent-${ts2}.png"
```

**Known limitation:** `send_http2_request` returns the server response via the MCP SSE stream but does NOT paint it into the Burp Repeater response panel. The tab will show an empty right-hand pane even after a successful send. This is a Burp MCP constraint — the tab creation (`create_repeater_tab_http2`) and the live send are intentionally decoupled. To get a screenshot that shows request + response together, the user must press Send manually in the Burp UI.

**For HTTP/1.1 requests** use `create_repeater_tab` (not `create_repeater_tab_http2`) and `send_http1_request`. The `content` argument for HTTP/1.1 is the raw request string including headers and body separated by `\r\n\r\n`.

## If User Names A Tab Number

The current Burp MCP bridge does not expose selecting or resending a Repeater tab by index. If the user says `tab 8` or `task 08` and also requires no focus changes, explain that the no-focus method can only resend the active editor or a raw request found in Proxy History/Organizer. Then either:

- Ask them to make that Repeater tab active once, after which this skill can resend it repeatedly without focus changes.
- Search Proxy History/Organizer by task name or endpoint and send the matching raw request via MCP.

## Verification

After sending and capturing, report only:

- Whether the MCP request send completed without shell/MCP transport errors.
- The screenshot path.
- Any limitation, such as not being able to confirm the GUI selected the requested tab.
