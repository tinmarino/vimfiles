---
description: "Work through every [ ] task in doc/ai-todo.md § # AI, treating the file as a live stream"
allowed-tools: Bash(*)
---
Work through every `[ ]` item in `@doc/ai-todo.md`, one at a time, following `@AGENTS.md` or `@~/.config/opencode/AGENTS.md` in case the first one do not exits (which overrides this prompt on any conflict).

For each task, do the following steps.

1. Re-read `@doc/ai-todo.md` FIRST — the file is a live stream, not a snapshot: I may append new tasks while you work. Any new `[ ]` after the last one you did is fair game and must be processed before stopping.
2. Execute the task, run the test suite when code changes.
3. **Remove** the line from `@doc/ai-todo.md` entirely (do NOT leave a `[X]` behind — the todo file should only contain pending items). Then prepend it as `* [X]` to `@doc/ai-done.md` (most recent first). Prefix with a timestamp like `2026-04-27T00:16:21:` (strftime("%Y-%m-%dT%H:%M:%S")) and add a suffix with the solution used, for example: `=> solved replacing ncurses by rich`
4. Commit with a message prefixed by your assistant name, e.g.  `Claude: <one-line summary>`. Never `git push`.
5. If the task is blocked by a question only I can answer, write it as `[ ] <question>` in `@doc/ai-pending.md` and move on.

Append any generic product / process insight to `@doc/ai-feedback.md` or as in file in `@doc/ref/feedback-<question>.md` where question is a placeholder to a short title of the question. If I say report in `shooter`, report in file @doc/ref/feedback-shooter.md. Commit messages and code comments in English. Also write all output to markdown file for each task. For example in `@doc/ref/feedback-task-001-<taskshortname>.md` where taskshortname is a placeholder for a short description of the task.

In Short, write everything to files and read form input files so that I do not have to interact with the TUI.
