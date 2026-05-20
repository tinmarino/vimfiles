---
description: "Work through every [ ] task in doc/ai-todo.md § # AI, treating the file as a live stream"
allowed-tools: Bash(*)
---
Work through every `[ ]` item in `@doc/ai-todo.md`, one at a time, following `@AGENTS.md` (which overrides this prompt on any conflict). For each task:

1. Re-read `@doc/ai-todo.md` FIRST — the file is a live stream, not a snapshot: I may append new tasks while you work. Any new `[ ]` after the last one you did is fair game and must be processed before stopping.
2. Execute the task, run the test suite when code changes.
3. Mark it `* [X]`, cut the line and move it to `@doc/ai-done.md` in the first line as I want to see most recent log first in ai-done.md. Also prefixe the line with a timestamp like `2026-04-27T00:16:21:` like strftime("%Y-%m-%dT%H:%M:%S") and add a suffix with the solution used, for example: `=> solved replading ncurses by rich`
4. Commit with a message prefixed by your assistant name, e.g.  `Claude: <one-line summary>`. Never `git push`.
5. If the task is blocked by a question only I can answer, write it as `[ ] <question>` in `@doc/ai-pending.md` and move on.
6. After committing, go back to step 1. When the `# AI` section has no pending `[ ]` items, do NOT stop — block on the file with:

   ```bash
   inotifywait -qq -e modify -e close_write -e move_self -t 540 doc/ai-todo.md
   ```

   (9-minute timeout keeps us under the Bash tool ceiling; if it exits with status 2 = timeout, just re-issue the wait.) As soon as the file is modified, re-read it and resume from step 1. Only stop the loop when the user adds an explicit `* [ ] STOP` task — mark it `[X]`, log it, then exit cleanly.

Append any generic product / process insight to `@doc/ai-feedback.md` or as in file in `@doc/ref/feedback-<question>.md` where question is a placeholder to a short title of the question. If I say report in `shooter`, report in file @doc/ref/feedback-shooter.md. Commit messages and code comments in English.
