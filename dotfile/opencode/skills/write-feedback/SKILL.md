---
name: write-feedback
description: Persist findings to the project MEMORY.md (team-visible) and a doc/ref/feedback-step-<NNN>-<title>.md file, dispatched to a BACKGROUND subagent so the main session keeps working uninterrupted. Trigger whenever the user says "write feedback", "write memory", "record findings", "save this to memory", "document this", or asks to checkpoint progress to disk. Use for any pentest project where notes must outlive the chat.
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
  writes: MEMORY.md, doc/ref/feedback-step-<NNN>-<title>.md
---

# write-feedback

Persists the current findings to disk in TWO places, as a fire-and-forget
background task so the user can keep driving the main prompt.

## Goal

When triggered, hand the documentation off to a **background subagent** and
immediately return control. Do NOT write the files inline on the main thread —
spawn a subagent (the `task` tool) so the main conversation is not blocked. Tell
the user one line: "feedback dispatched to background (step-NNN: <title>)" and
continue whatever they were doing.

## What the subagent must do

1. **Resolve the project root** = the current working directory's project (where
   `MEMORY.md` and `doc/ref/` live; e.g. a pentest engagement under `~/Pentest/<engagement>`).
2. **Pick the id**: scan `doc/ref/feedback-step-*.md`, take the highest `NNN`,
   add 1. Pick a short kebab-case `<title>` from the finding.
3. **Write the full record** to `doc/ref/feedback-step-<NNN>-<title>.md`:
   - One-line summary, what was tested, what is verified vs open, exact
     addresses/keys/formulas, the concrete next experiment, and the files touched.
   - Plain technical English. This is team documentation — do NOT attribute it to
     Claude or any LLM, do not write in the first person, no "I" / "the assistant".
4. **Append a concise pointer** to the project `MEMORY.md` under the most relevant
   existing `##` section (or a new dated `## Wave<NNN> — <title> (YYYY-MM-DD)`
   section): 1–4 lines, key facts only, link the feedback file. Match the file's
   existing terse style; never paraphrase or delete prior entries.
5. **Reconcile, don't contradict silently**: if the new finding overturns an
   earlier MEMORY.md claim (e.g. a "CRACKED" that turned out wrong), add a short
   "UPDATE (step-NNN): ..." note next to the old claim rather than leaving both.

## Rules

- Team-visible, not Claude-private: always write to the project `MEMORY.md` and
  `doc/ref/`, never to `~/.claude/.../memory/`.
- No LLM self-reference anywhere in the text.
- Markdown: one line per paragraph/list-item, no hard-wrapping (matches the repo
  convention).
- Never `git push`. A commit is fine only if the user already asked for commits.
- If `$ARGUMENTS` is empty, summarize the findings from the current session
  context; otherwise use `$ARGUMENTS` as the title/notes seed.

## Invocation shape

The user typically types `/write-feedback <short title or notes>`. Treat the rest
of the line as the seed; derive the full content from the recent conversation.
