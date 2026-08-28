---
description: "Alias for /resume — thaw the background child processes that /pause stopped in THIS session"
allowed-tools: Bash(*)
---
`/restart` is an alias for `/resume`. Thaw the background child processes that `/pause` stopped in THIS session only. Other Claude sessions and the main agent are never affected.

Run:

```
bash ~/.claude/skills/hunt-hunter/bin/claude-pause-session.sh restart
```

Report how many child processes were thawed, then ask me whether to continue the previous loop or stay at the prompt — do not auto-restart a loop.
