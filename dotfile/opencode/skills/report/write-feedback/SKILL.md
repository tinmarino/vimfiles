---
name: write-feedback
description: Persist findings to the target repo MEMORY.md and a doc/ref/feedback-<NNN>-<title>.md file — the legacy variant, not the pentest-engagement doc/feedback/ series (the counterpart is `pentest-memory-feedback`) — dispatched to a BACKGROUND subagent so the main session keeps working. Trigger on "write feedback", "write memory", "record findings", "save this to memory", "document this", "feedback file en master", or a request to checkpoint progress to disk. "master" means the AI master repo at ~/Software/Python/AI/OpenCodeMaster (the user's `master` shell alias), NOT a git branch — see "Resolving the target repo". Use for any project whose notes must outlive the chat.
source: mine
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
  writes: MEMORY.md, doc/ref/feedback-<NNN>-<title>.md
  master_repo: ~/Software/Python/AI/OpenCodeMaster
---

# write-feedback

Persists the current findings to disk in TWO places, as a fire-and-forget
background task so the user can keep driving the main prompt.

## Goal

When triggered, hand the documentation off to a **background subagent** and
immediately return control. Do NOT write the files inline on the main thread —
spawn a subagent (the `task` tool) so the main conversation is not blocked. Tell
the user one line: "feedback dispatched to background (NNN: <title>)" and
continue whatever they were doing.

## Resolving the target repo

"master" is **not** a git branch. The user has a shell alias

```bash
alias master='cd ~/Software/Python/AI/OpenCodeMaster/'
```

so "write the feedback file in master", "feedback en master", or plain "master"
all mean **the AI master repo at `~/Software/Python/AI/OpenCodeMaster`**. That repo
is the cross-project journal: it holds `MEMORY.md` and `doc/ref/`, and it records
work done in *other* repos (`~/Software/Html/Page`, `~/.vim`, pentest engagements).
Its own git branch happens to be `main`.

Pick the target like this:

- The user says **master** (or the work spanned several repos, or the repo being
  worked on is not the place for team notes) -> write to
  `~/Software/Python/AI/OpenCodeMaster`.
- The user says nothing and the cwd is a project with its own `MEMORY.md` and
  `doc/ref/` (e.g. a pentest engagement under `~/Pentest/<engagement>`) -> write
  there.
- Never write to the repo the work was performed *on* unless it already has a
  `MEMORY.md` + `doc/ref/` pair. Source repos stay free of session journals.

## What the subagent must do

1. **Resolve the target repo** per "Resolving the target repo" above: the master
   repo when the user said master, otherwise the cwd's project (where `MEMORY.md`
   and `doc/ref/` live).
2. **Pick the id**: scan `doc/ref/feedback-*.md`, take the highest zero-padded
   `NNN` actually present, add 1. In the master repo the convention is
   `feedback-<NNN>-<title>.md` (three digits, no `step-` infix); some older files
   there have no number at all, so ignore those when computing the maximum.
   Pick a short kebab-case `<title>` from the finding.
3. **Write the full record** to `doc/ref/feedback-<NNN>-<title>.md`:
   - One-line summary, what was tested, what is verified vs open, exact
     addresses/keys/formulas, the concrete next experiment, and the files touched.
   - Plain technical English. This is team documentation — do NOT attribute it to
     Claude or any LLM, do not write in the first person, no "I" / "the assistant".
4. **Append a concise pointer** to the project `MEMORY.md` under the most relevant
   existing `##` section (or a new dated `## Wave<NNN> — <title> (YYYY-MM-DD)`
   section): 1–4 lines, key facts only, link the feedback file. Match the file's
   existing terse style; never paraphrase or delete prior entries.
5. **Continue, don't duplicate**: if `MEMORY.md` already has a `##` section for
   this topic (say `## Python classroom app`), extend that section and reference
   the new feedback file from it, rather than opening a near-duplicate section.
6. **Reconcile, don't contradict silently**: if the new finding overturns an
   earlier MEMORY.md claim (e.g. a "CRACKED" that turned out wrong), add a short
   "UPDATE (feedback-NNN): ..." note next to the old claim rather than leaving both.

## Rules

- Team-visible, not Claude-private: always write to the target repo's `MEMORY.md`
  and `doc/ref/`, never to `~/.claude*/.../memory/`.
- Security hygiene: a feedback file is committed and may be pushed to a public
  remote. Never write a credential, token, password, bucket ARN with an account
  id, or the contents of a gitignored secrets file into it. Naming *which*
  credential leaked and what was done about it is right; reproducing its value
  is not.
- No LLM self-reference anywhere in the text.
- Markdown: one line per paragraph/list-item, no hard-wrapping (matches the repo
  convention).
- Never `git push`. A commit is fine only if the user already asked for commits.
- If `$ARGUMENTS` is empty, summarize the findings from the current session
  context; otherwise use `$ARGUMENTS` as the title/notes seed.

## Invocation shape

The user typically types `/write-feedback <short title or notes>`. Treat the rest
of the line as the seed; derive the full content from the recent conversation.
