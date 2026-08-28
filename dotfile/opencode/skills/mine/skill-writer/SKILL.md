---
name: skill-writer
description: "Author, review and package an OpenCode/Claude skill the optimal way — the SKILL.md frontmatter and body, a description written to trigger reliably (bilingual EN/ES triggers, third person, a little pushy), progressive disclosure into references/ and scripts/, the public-repo leak discipline (no client name, host, token or national ID, verified with check-leaks.sh), and the .skill bundle for delivery. Use when the operator says 'escribe un skill', 'crea un skill para X', 'mejora este skill', 'optimiza la descripción', 'por qué no se activa mi skill', 'empaqueta el skill', 'convierte este workflow en skill', 'write a skill', 'create a skill for X', 'improve this skill', 'optimize the trigger description', 'why won't my skill fire', 'package this skill', 'turn this workflow into a skill', or whenever a repeatable workflow is worth capturing so it outlives the chat."
---

# skill-writer

A skill is a folder OpenCode loads on demand. It exists so a workflow you would otherwise re-explain every session becomes a capability the model reaches for on its own. Your job here is to turn a workflow into that folder — correctly triggered, cheap in context, and safe to publish.

> **This folder is published publicly.** Every skill under `~/.vim/dotfile/opencode/skills/` (symlinked from `~/.claude/skills` and `~/.config/opencode/skills`) ships to a public repo. No client name, real hostname, credential, token, national ID, employee name or engagement path may appear in any file — ever, including examples. Use `target.example.com` / ACME / `AI###` / `<PFX>` placeholders. Run `./check-leaks.sh` before any push; exit 1 means do not push. See §6.

## 1. How triggering actually works

OpenCode keeps every skill's **name + description** always in context and nothing else. The model reads the descriptions and, for a task it cannot trivially do itself, loads the one whose description matches. Two consequences drive every decision below:

- **The description is the product.** It is the only always-loaded text and the sole trigger mechanism. Spend your effort here. A perfect body behind a vague description never fires.
- **Descriptions are a shared, always-on budget.** N skills each with a 150-word description is N×150 words of permanent context across every session. Tight descriptions are not a nicety; they are why the suite scales. Write the shortest description that still triggers reliably.

Claude only consults a skill for tasks it can't easily handle alone — "read this file" won't trigger anything regardless of wording. Design for substantive, multi-step tasks.

## 2. Anatomy

```
skill-name/
├── SKILL.md              (required — frontmatter + body)
├── references/           (optional — docs loaded only when the body points to them)
│   ├── variant-a.md
│   └── variant-b.md
├── scripts/              (optional — code the skill runs; executes without loading into context)
└── assets/               (optional — templates, icons, fonts used in output)
```

`name`: kebab-case, matches the directory. `description`: see §3. Those two are the only required frontmatter fields.

## 3. Writing the description

Pack in **what it does AND when to fire it**, in third person, a little pushy (the failure mode is *under*-triggering, not over). Then cut every word that does not earn its place in an always-on budget.

- **Lead with the capability**, one clause: what the skill produces or decides.
- **Then the triggers**: the concrete phrases a user actually types. Include both English and Spanish — this operator works in both, and a Spanish request must fire an English-named skill. Prefer real phrasings (`"por qué me da 401 de repente"`, `"turn this Burp request into a script"`) over abstract categories.
- **Third person, imperative-free**: "Writes the report…", never "I can help you…" or "You can use this…". Inconsistent point of view hurts matching.
- **Disambiguate against siblings** when two skills are adjacent — one clause on the boundary ("for the Spanish CyScope format; the English counterpart is `bugbounty-report-en`") saves a wrong load.
- **Length**: aim for one dense sentence of capability plus one of triggers. If it runs past ~120 words, you are probably listing triggers that paraphrase each other — keep the distinct ones, drop the echoes.

Quote the description in YAML (`description: "…"`) whenever it contains a colon, and it usually will.

**Before / after** (same skill, trimmed to what triggers):

```
BAD   description: This is a very useful and comprehensive skill that helps you when
      you need to write reports and it does many things including formatting and more.
GOOD  description: Writes the HackerOne/Bugcrowd bug-bounty report that maximizes payout
      — impact-first body, CVSS vector, reproducible curl. Use on "write the H1 report",
      "argue severity", "subir a Bugcrowd", "me lo cerraron como duplicado".
```

## 4. Writing the body

Keep it under ~500 lines. The body loads in full whenever the skill fires, so it competes for the working context — every line must be load-bearing at run time.

- **Imperative and explanatory.** Tell the model what to do, and *why* it matters — modern models generalize from the reason and overfit to bare rules. Reserve ALL-CAPS MUST/NEVER for the two or three genuine invariants (a header that must be byte-exact, a file that must never be deleted); explain the rest.
- **Show the exact output format** when the skill produces a structured artifact — a template block, a table schema, a filename convention. Ambiguity here is the main cause of inconsistent output across invocations.
- **Push detail down a level.** When the skill spans variants (per cloud, per platform, per language), put the shared workflow in SKILL.md and one file per variant in `references/`, with a clear pointer ("for the GCP path, read `references/gcp.md`"). The model reads only the relevant one. A reference over ~300 lines gets its own table of contents.
- **Bundle repeated code.** If every invocation would independently write the same helper, write it once into `scripts/` and have the skill call it. Deterministic, faster, and it never drifts.
- **Never hard-wrap prose** (house rule): one line per paragraph, one per bullet or table cell. Code fences, tables and YAML keep their natural breaks.
- **Cross-link siblings** in a closing `## Composes with` line so the suite stays navigable.

## 5. Where it lives, and no client data

Author directly in `~/.vim/dotfile/opencode/skills/<name>/` — that path is what OpenCode indexes, via the symlinks. There is no separate "draft" location.

The public-repo rule is absolute and applies to *every* file including throwaway examples: no real client name, hostname, IP, token, cookie, national ID, employee name, or internal engagement path. This is not only OPSEC — a leaked client identifier in a published skill is a contract breach. When a skill genuinely needs an example of client-shaped data, use the placeholders the suite already standardizes on: `target.example.com`, ACME, `AI###`, `<PFX><NNN>`, `<token>`, synthetic IDs like `11111111-1`.

## 6. Verify, then package for delivery

**Leak gate — before every push:**

```bash
cd ~/.vim/dotfile/opencode/skills && ./check-leaks.sh
# exit 0 -> "OK -- N skills clean"; exit 1 -> a LEAK line per hit, do not push
```

It derives the forbidden-word list at runtime from the engagement directories on this machine, so it stays current on its own. A hit means placeholder the value and re-run — never edit `check-leaks.sh` to pass.

**Delivering a skill to someone else** — the efficient unit is a `.skill` bundle (a zip of the folder), not pasted Markdown:

```bash
cd ~/.vim/dotfile/opencode/skills
zip -r /tmp/<name>.skill <name> -x '*/.*'      # ship the folder as one file
```

The recipient drops it into their own `skills/` directory. For a whole suite, ship the suite as one zip and keep a `pentest-router`-style entry-point skill so the recipient loads one dispatcher instead of memorizing every name. Prefer a bundle over emailing prose: it preserves `references/`, `scripts/` and the exact frontmatter that makes triggering work.

## 7. Reviewing or improving an existing skill

- **Preserve the name and directory** — installed skills are addressed by them; a rename orphans references and muscle memory.
- **Trim first.** Read the body and cut what isn't pulling its weight before adding anything; bloat in a skill is paid on every invocation.
- **Fix triggering at the description**, never by padding the body. If it under-fires, add the missing real-world phrasing (in both languages) to the description.
- **Test with realistic prompts.** Write 2–3 things a real user would actually type — some casual, some Spanish, some near-misses that should *not* fire it — and check the skill loads (or doesn't) as intended. If two sibling skills both fire on the same prompt, sharpen the boundary clause in both descriptions.

## Anti-patterns

| Anti-pattern | Cost |
| --- | --- |
| Vague or capability-only description ("helps with reports") | Never triggers; the body is dead weight. |
| First-person or "you can use this" phrasing | Degrades matching. |
| Triggers that paraphrase each other | Wastes the always-on budget every session. |
| A 900-line body with everything inline | Floods context on every fire; split into `references/`. |
| Any client name / host / token / national ID, even in an example | Contract breach on a public repo; blocked by `check-leaks.sh`. |
| Hard-wrapped prose | Violates the house rule; noisy diffs. |
| Editing `check-leaks.sh` to make it pass | Defeats the guard; placeholder the real value instead. |
| Shipping a skill as pasted Markdown | Loses `references/`/`scripts/` and the frontmatter; send the `.skill` zip. |

## Composes with

`pentest-router` (entry-point dispatcher pattern for a multi-skill suite) · `write-feedback` and `pentest-memory-feedback` (persist what a new skill should encode) · `python-writer` (house style for any bundled `scripts/`).
