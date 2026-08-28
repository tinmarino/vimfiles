---
description: "Tell the /hunt loop to keep the hunter pool full through the soft usage-limit warning (cannot exceed the real server-side account limit)"
allowed-tools: Bash(*)
---
FORCE MODE for the current `/hunt` loop.

Read this important truth first and relay it to me in one line before doing anything else:

> There is NO local "80% cap". The 80% you see is Anthropic's **account usage limit**, enforced
> server-side. This command does NOT and CANNOT raise it. If the account is genuinely out of usage,
> every request fails with a usage-limit error no matter what — no client flag changes that.
> To check the real number, run `/usage` or open the billing page at claude.ai.

What FORCE mode legitimately changes — the loop's *voluntary* throttling only:

1. Do **not** stop, pause, or shrink the hunter pool because Claude Code shows a soft usage-limit
   **warning** (e.g. "you are approaching your limit"). Keep `POOL = 5` and keep refilling exactly as
   the `hunt` command specifies, right up until the server returns a hard usage-limit **error**.
2. When a hard usage-limit error DOES arrive, stop spawning, log `hunt/LOOP.md` with
   `force-mode: hard usage limit hit at <timestamp>`, print the last-known findings summary, and end
   the turn. Do not retry-spam the API — that wastes nothing but adds noise. Wait for me.
3. Everything in the `hunt` command's **Hard rules** still applies in full and is NOT overridable by
   FORCE mode: the $5 / 5000 CLP daily money cap, read-only todo.md/done.md, scope gate, the
   `X-Bug-Bounty-CyScope: Tinmarino` header, no writes to real third-party data, no `git push`.

If `/hunt` is not currently running, tell me to start it first — FORCE mode is a modifier on the
running loop, not a launcher.
