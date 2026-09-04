Keep generated prompt dashboards out of `~/.vim`: they aggregate local AI prompt history and may include sensitive working context, so the command should write the rendered HTML under `~/.cache/ai-dashboard/` instead of inside the public dotfiles repository.

Claude session recovery is split across two local stores: `~/.claude/history.jsonl` is the cheap prompt index, while `~/.claude/projects/*/*.jsonl` provides end times, model names, and subagent transcripts. Merging both gives a much more useful restore dashboard than using either source alone.

OpenCode session recovery is easier to keep structured from `~/.local/share/opencode/opencode.db`: root sessions, child sessions, and user prompt parts can all be reconstructed locally without parsing logs, and the sibling `storage/session_diff/<id>.json` path is a good file reference to surface in the UI.

A terminal dashboard that only prints tables wastes space and forces too much scroll for long titles and prompt history. A better shape is a full-screen split view: a fixed-height left session navigator and a right detail pane with lazy prompt/subagent expansion, so the empty area becomes working context instead of blank padding.

Rich alone does not ship click widgets, but a practical local TUI can still offer mouse-friendly behavior by pairing Rich `Live(screen=True)` rendering with raw terminal input and SGR mouse events. That keeps the command dependency-light while still allowing row selection, copy buttons, and expand/collapse actions in a real terminal.
