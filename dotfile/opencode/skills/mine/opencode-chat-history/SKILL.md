---
name: opencode-chat-history
description: Use when the user asks where OpenCode stores chats, how to inspect an opencode session, or says to restart/resume/read from a ses_*.json or ses_* session id.
---

# OpenCode Chat History

Use this skill when the user asks about OpenCode chat/session storage, wants to inspect a past conversation, or references a session id such as `ses_1768108a6ffeCR6D36E2XrEZB5` or a diff file such as `ses_1768108a6ffeCR6D36E2XrEZB5.json`.

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

Chat messages are not primarily stored as one JSON file per session. The authoritative chat history is in the SQLite database `opencode.db`.

Session diff JSON files live under `storage/session_diff/` and are useful for reconstructing file changes made during a session.

## How To Answer

When the user asks where chat files are, say:

```text
OpenCode stores chats in ~/.local/share/opencode/opencode.db. Session diffs are in ~/.local/share/opencode/storage/session_diff/<session-id>.json.
```

When the user gives a `ses_*.json` filename, strip the `.json` suffix to get the session id for database queries.

When the user says something like `restart from ses_1768108a6ffeCR6D36E2XrEZB5.json`, interpret it generically as:

```text
Restart from the session diff file ~/.local/share/opencode/storage/session_diff/<session-id>.json, then use ~/.local/share/opencode/opencode.db to read the chat messages for <session-id>.
```

Do not hardcode `ses_1768108a6ffeCR6D36E2XrEZB5`; it is only an example. Apply the same workflow to any `ses_*` id.

## Commands

List relevant tables:

```bash
sqlite3 ~/.local/share/opencode/opencode.db '.tables'
```

Inspect one session's metadata:

```bash
sqlite3 ~/.local/share/opencode/opencode.db \
  "select id, title, time_created, time_updated from session where id='<session-id>';"
```

Read messages:

```bash
sqlite3 ~/.local/share/opencode/opencode.db \
  "select id, data from message where session_id='<session-id>' order by time_created;"
```

Read message parts:

```bash
sqlite3 ~/.local/share/opencode/opencode.db \
  "select id, message_id, data from part where session_id='<session-id>' order by time_created;"
```

Find a session diff file:

```bash
ls ~/.local/share/opencode/storage/session_diff/<session-id>.json
```

## Safety

Prefer read-only inspection. Do not modify `opencode.db`, WAL files, logs, tool output, or `storage/session_diff/` unless the user explicitly asks.

If OpenCode is currently running, avoid deleting or moving files in `~/.local/share/opencode/`.
