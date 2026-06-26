---
name: burp-history-reader
description: Use when reading, searching, or analyzing Burp Suite HTTP proxy history. Triggers on phrases like "look at Burp history", "what did Burp capture", "show me the requests", "search Burp for X", "read the traffic". Uses Burp MCP on localhost:9876.
---

# Burp History Reader

Use this skill to read and search the Burp Suite HTTP proxy history via the MCP server on `127.0.0.1:9876`.

## Prerequisites

- Burp MCP server must be **running and enabled** (Burp → MCP tab → Start server).
- Port `9876` must be reachable on localhost.
- If MCP is not running, tell the user to enable it in Burp before proceeding.

## Check MCP is alive

```bash
curl -sS --max-time 3 http://127.0.0.1:9876/ 2>&1 | head -2
```

If that times out or errors, MCP is not running — stop and tell the user.

## Session bootstrap (reuse this block in every MCP call)

Every interaction with Burp MCP requires an SSE session. Always follow this pattern:

```bash
TS=$(date '+%Y-%m-%dT%H-%M-%S')
curl -sS -N http://127.0.0.1:9876/ > /tmp/burp-sse-${TS}.log 2>&1 &
pid="$!"
sleep 0.5
session="$(perl -ne 'print $1 if /data: \?(sessionId=[0-9a-f-]+)/' /tmp/burp-sse-${TS}.log)"

post() {
  curl -sS -X POST "http://127.0.0.1:9876/?${session}" \
    -H 'Content-Type: application/json' -d "$1" >/dev/null
}

post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"oc","version":"1.0"}}}'
sleep 0.2
post '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'

# --- your tool call here ---

sleep 3
kill "$pid" 2>/dev/null; true
```

## Available tools

| Tool | Purpose |
|------|---------|
| `get_proxy_http_history` | All HTTP history, paginated |
| `get_proxy_http_history_regex` | Filter history by regex on URL/body |
| `get_proxy_websocket_history` | WebSocket frames |
| `get_proxy_websocket_history_regex` | Filter WebSocket by regex |
| `get_organizer_items` | Saved Organizer items |
| `get_organizer_items_regex` | Filter Organizer by regex |

## get_proxy_http_history_regex (most useful)

Required arguments: `regex`, `count`, `offset`.

```bash
post '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_proxy_http_history_regex","arguments":{"regex":"YOUR_PATTERN","count":30,"offset":0}}}'
```

Common regex patterns:
- API domain: `"api\\.dalecoopeuch\\.cl"`
- Transmit Security: `"transmitsecurity|transmit"`
- Biometric/FIDO: `"webauthn|fido|credential|attestation|enroll|facet|challenge"`
- Auth endpoints: `"auth|token|login|session"`
- Specific path: `"passwordless|2fa|biometric"`

## Parse the response

```python
grep '"id":2' /tmp/burp-sse-${TS}.log | python3 -c "
import sys, json
line = sys.stdin.read()
data = line.split('data: ',1)[-1].strip()
j = json.loads(data)
txt = j['result']['content'][0]['text']
entries = [e for e in txt.strip().split('\n\n') if e.strip()]
for e in entries[:20]:
    try:
        item = json.loads(e)
        req = item.get('request','')
        first_line = req.split('\r\n')[0]
        host = next((l.split(':',1)[1].strip() for l in req.split('\r\n') if l.lower().startswith('host:')), '')
        resp = item.get('response','')
        status = resp.split('\r\n')[0] if resp else ''
        print(f'{first_line}  [{host}]  ->  {status}')
    except: pass
"
```

## Print full request+response for a specific entry

```python
grep '"id":2' /tmp/burp-sse-${TS}.log | python3 -c "
import sys, json
line = sys.stdin.read()
data = line.split('data: ',1)[-1].strip()
j = json.loads(data)
txt = j['result']['content'][0]['text']
entries = [e for e in txt.strip().split('\n\n') if e.strip()]
idx = 0  # change to desired index
item = json.loads(entries[idx])
print('=== REQUEST ===')
print(item['request'][:3000])
print('=== RESPONSE ===')
print(item['response'][:3000])
"
```

## Pagination

If there are more results, increment `offset` by `count`:

```bash
# Page 1: offset=0
# Page 2: offset=30
# Page 3: offset=60
```

## Common errors

| Error | Fix |
|-------|-----|
| `Field 'offset' is required` | Add `"offset":0` to arguments |
| `sessionId` empty | Wait longer after starting SSE (`sleep 1`) |
| Empty result | Regex matched nothing — broaden the pattern |
| MCP timeout | Burp MCP not started — enable in Burp → MCP tab |

## Full example: find all Transmit Security requests

```bash
TS=$(date '+%Y-%m-%dT%H-%M-%S')
curl -sS -N http://127.0.0.1:9876/ > /tmp/burp-sse-${TS}.log 2>&1 &
pid="$!"
sleep 0.5
session="$(perl -ne 'print $1 if /data: \?(sessionId=[0-9a-f-]+)/' /tmp/burp-sse-${TS}.log)"

curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"oc","version":"1.0"}}}' >/dev/null
sleep 0.2
curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' >/dev/null
curl -sS -X POST "http://127.0.0.1:9876/?${session}" -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_proxy_http_history_regex","arguments":{"regex":"transmitsecurity","count":30,"offset":0}}}' >/dev/null
sleep 4
kill "$pid" 2>/dev/null; true

grep '"id":2' /tmp/burp-sse-${TS}.log | python3 -c "
import sys, json
line = sys.stdin.read()
data = line.split('data: ',1)[-1].strip()
j = json.loads(data)
txt = j['result']['content'][0]['text']
entries = [e for e in txt.strip().split('\n\n') if e.strip()]
for i, e in enumerate(entries):
    try:
        item = json.loads(e)
        req = item['request']
        first_line = req.split('\r\n')[0]
        host = next((l.split(':',1)[1].strip() for l in req.split('\r\n') if l.lower().startswith('host:')), '')
        resp = item.get('response','')
        status = resp.split('\r\n')[0]
        print(f'[{i}] {first_line}  [{host}]  ->  {status}')
    except: pass
"
```
