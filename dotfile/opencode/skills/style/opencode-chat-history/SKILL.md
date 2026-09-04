---
name: opencode-chat-history
description: Use when the user asks where OpenCode or Claude Code stores chats, wants to inspect/browse a past session and its subsessions, or says to restart/resume/read from a ses_*.json or ses_* session id. Prefer the `ai-dashboard --ui txt` command over hand-writing SQL.
source: mine
license: MIT
metadata:
  audience: opencode-agents
---

# OpenCode Chat History

Use this skill when the user asks about OpenCode or Claude Code chat/session storage, wants to inspect or explore a past conversation, or references a session id such as `ses_1768108a6ffeCR6D36E2XrEZB5` or a diff file such as `ses_1768108a6ffeCR6D36E2XrEZB5.json`.

## Fast path: the `ai-dashboard` command

`ai-dashboard` is on `PATH`. Its default `--ui txt` mode prints a plain-text, greppable index of every Claude and OpenCode root session (and, per session, its prompts and nested subsessions). Reach for it FIRST: it is faster and safer than reimplementing the SQL below, and it already merges both agents' stores.

List sessions, newest first, filtered to one project by a case-insensitive path substring:

```bash
ai-dashboard --dir <substring>          # e.g. a client or project folder name
ai-dashboard --dir <substring> --source opencode   # one source only: claude | opencode | all
ai-dashboard --dir <substring> --limit 20          # cap the list (0 = all)
```

Each list entry prints the source, session id, start/end time, folder, cwd, title and the exact resume command.

Drill into ONE root session to read its prompts and every nested subsession (subagent):

```bash
ai-dashboard --session <session-id>          # prompts capped for skimming
ai-dashboard --session <session-id> --full   # untruncated prompt text
```

This is how to understand "what has already been done in this project": filter by `--dir` to find the sessions, then `--session` each id to read the prompt-by-prompt story and the subagents it spawned. All output is plain text, so pipe it through `grep`/`sed` freely.

The other modes are for humans: `ai-dashboard --ui term` (interactive Rich table) and `ai-dashboard --ui web` (localhost UI with copy buttons and lazy loading).

## Storage Layout

OpenCode keeps persistent data under:

```text
~/.local/share/opencode/
```

Important paths:

```text
~/.local/share/opencode/opencode.db
~/.local/share/opencode/storage/session_diff/<session-id>.json
~/.local/share/opencode/tool-output/
~/.local/share/opencode/log/
```

Chat messages are not primarily stored as one JSON file per session. The authoritative OpenCode chat history is in the SQLite database `opencode.db`. Claude Code stores its transcripts under `~/.claude/projects/<project>/<session-id>.jsonl` with subagent transcripts beside them under `<session-id>/subagents/`.

Session diff JSON files live under `storage/session_diff/` and are useful for reconstructing file changes made during a session.

## How To Answer

When the user asks where chat files are, say:

```text
OpenCode stores chats in ~/.local/share/opencode/opencode.db. Session diffs are in ~/.local/share/opencode/storage/session_diff/<session-id>.json. To browse them, run `ai-dashboard --ui txt`.
```

When the user gives a `ses_*.json` filename, strip the `.json` suffix to get the session id, then run `ai-dashboard --session <session-id>` to read it.

When the user says something like `restart from ses_1768108a6ffeCR6D36E2XrEZB5.json`, interpret it generically as:

```text
Restart from the session diff file ~/.local/share/opencode/storage/session_diff/<session-id>.json, then run `ai-dashboard --session <session-id>` (or query ~/.local/share/opencode/opencode.db) to read the chat messages for <session-id>.
```

Do not hardcode `ses_1768108a6ffeCR6D36E2XrEZB5`; it is only an example. Apply the same workflow to any `ses_*` id.

## Raw database fallback

Use these only when `ai-dashboard` is unavailable or you need a field it does not surface.

List relevant tables:

```bash
sqlite3 ~/.local/share/opencode/opencode.db '.tables'
```

Inspect one session's metadata:

```bash
sqlite3 ~/.local/share/opencode/opencode.db \
  "select id, title, time_created, time_updated from session where id='<session-id>';"
```

Read messages and their parts:

```bash
sqlite3 ~/.local/share/opencode/opencode.db \
  "select id, data from message where session_id='<session-id>' order by time_created;"
sqlite3 ~/.local/share/opencode/opencode.db \
  "select id, message_id, data from part where session_id='<session-id>' order by time_created;"
```

Find a session diff file:

```bash
ls ~/.local/share/opencode/storage/session_diff/<session-id>.json
```

## Safety

Prefer read-only inspection. `ai-dashboard` only reads. Do not modify `opencode.db`, WAL files, logs, tool output, or `storage/session_diff/` unless the user explicitly asks.

If OpenCode is currently running, avoid deleting or moving files in `~/.local/share/opencode/`.
