# Global rules
## Markdown formatting

Do not hard-wrap Markdown prose. Write one line per paragraph and let the reader's editor soft-wrap.
Exceptions: code fences, tables, lists (one item per line), and YAML frontmatter — those keep their natural line breaks.

## Public repo safety

Treat `~/.vim/` as a public repository.
Never write secrets, tokens, credentials, private keys, or other sensitive values anywhere under `~/.vim/`, including helper scripts, comments, examples, backups, and generated files.
Do not create git commits in `~/.vim/`.
