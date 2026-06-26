---
description: "Async: persist current findings to project MEMORY.md + doc/ref/feedback-step-<NNN>-<title>.md via a background subagent (uses the write-feedback skill)"
allowed-tools: Bash(*)
---
Use the `write-feedback` skill to persist the current findings.

Dispatch the documentation to a BACKGROUND subagent (the `task` tool) and return
immediately — do not write the files inline, do not block this session. Reply
with a single line: `feedback dispatched to background (step-NNN: <title>)`.

Seed title / notes (may be empty — if so, summarize from the current session): $ARGUMENTS

The subagent writes, per the skill: the full record to
`doc/ref/feedback-step-<NNN>-<title>.md` and a concise pointer into the project
`MEMORY.md`. Team-visible technical English, no LLM self-reference, no `git push`.
