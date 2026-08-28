---
name: persistent-terminal-control
description: Use when the user wants OpenCode to drive a local or remote shell interactively with lower latency than repeated SSH or tmux capture-pane polling, especially for "persistent shell", "capture only command output", "tmux pane automation", "PTY", or command-by-command troubleshooting loops.
---

# Persistent Terminal Control

Use this skill when the user wants a persistent interactive shell that returns only the output of the current command, rather than the whole visible pane buffer.

## Goal

Prefer a persistent PTY-backed shell session with explicit start and end markers over repeated one-shot shell or SSH invocations.

Use the helper at:

```text
~/.config/opencode/skills/persistent-terminal-control/driver.py
```

## Why

Repeated `ssh host command` or repeated `bash -lc ...` pay the startup cost of a new command context every time.

`tmux send-keys` plus `capture-pane` keeps a persistent shell but still pays extra overhead for pane capture, visible-buffer polling, and parsing text that does not belong to the current command.

The PTY driver keeps one shell alive and returns only the output between explicit markers for the current command.

## Session Lifecycle

Start a local session:

```bash
python3 ~/.config/opencode/skills/persistent-terminal-control/driver.py start --name local-bash -- bash --noprofile --norc -i
```

Start a remote SSH-backed session:

```bash
python3 ~/.config/opencode/skills/persistent-terminal-control/driver.py start --name win11 -- ssh win11-thoma
```

Run one command and get structured output:

```bash
python3 ~/.config/opencode/skills/persistent-terminal-control/driver.py run --name local-bash "pwd && hostname"
```

Check status:

```bash
python3 ~/.config/opencode/skills/persistent-terminal-control/driver.py status --name local-bash
```

Stop the session:

```bash
python3 ~/.config/opencode/skills/persistent-terminal-control/driver.py stop --name local-bash
```

## Output Contract

The helper prints JSON with these fields:

```json
{
  "ok": true,
  "marker": "AB12CD34EF56",
  "stdout": "...",
  "exit_code": 0,
  "duration_ms": 42.7
}
```

Treat `stdout` as the command output for the current command only.

Do not parse prompt text or visible pane history when this helper is available.

## When To Prefer Tmux Anyway

Prefer `tmux` when the user explicitly wants a visible, human-shared terminal surface or wants to keep manual control in parallel.

Prefer the PTY driver when the user prioritizes speed, structured output, or repeated short command/result loops.

## Rules

- Keep one session per target and reuse it.
- Do not close a user-owned shell unless the user asks, or unless it was created solely for the current benchmark or experiment.
- Use `status` before assuming a saved session is alive.
- For benchmarks, compare fresh shell, reused shell, `tmux`, and PTY on the same host and same command shape.
