---
name: slide-writer
description: Use when creating, editing, extending, or reviewing Markdown slide decks in Tinmarino style, especially files listed in doc/all-prez.md or decks compiled with ~/Software/Latex/AcademyBook/book.py.
---

# slide-writer

Write Markdown slide decks in Tinmarino's current presentation style and compile them through AcademyBook.

## When To Use

Use this skill when the user asks to create, add, rewrite, polish, or review slides, a charla, a clase, a deck, a presentation, or a `.md` file that will compile as slides with `~/Software/Latex/AcademyBook`.

Use it especially for decks related to `doc/all-prez.md`, `md/*.md`, or any class/talk deck directory in the corpus, or when the user mentions SEK, Tinmarino, AcademyBook, `book.py`, `book compile`, `slide`, or `-t sek`.

Do not use for normal Markdown documents, reports, pentest findings, or application code unless the requested output is a slide deck.

## First Steps

1. Inspect the target file and nearby resources before writing.
2. Read `doc/all-prez.md` when available to identify the presentation corpus and prefer the newest examples over old ones.
3. Prefer recent style references: pick the newest decks in the corpus (check `doc/all-prez.md` for the most recent dated files), and fall back to older decks only for patterns the newest ones do not cover.
4. If creating a new deck, choose whether it belongs in the user's project `md/` directory or another existing deck directory. Ask only if the destination is ambiguous.
5. Preserve existing frontmatter, header includes, resources, and theme choices unless the user explicitly asks for a new deck or style migration.

## Compile Workflow

Compile through AcademyBook, not directly with `pandoc` or `xelatex`.

Use this command shape from the deck's project context:

```bash
./book.py compile -c slide -t sek -i /absolute/path/to/deck.md
```

Run it with `workdir=~/Software/Latex/AcademyBook`.

If the deck uses a different known theme, keep the same shape and replace `-t sek` with the existing target only when the file or user indicates it. Current newest style usually targets `sek`.

After compiling, verify the generated PDF path reported by AcademyBook, usually `~/Software/Latex/AcademyBook/out/<name>_slide_<theme>.pdf`.

For visual verification, render pages to images with `pdftoppm -png -r 120 <pdf> /tmp/opencode/<deck>/page` and inspect all new or modified slides, plus title/table/code-heavy slides. Do not claim visual verification unless rendered pages were inspected.

Common non-fatal warnings: small overfull boxes, missing Inkscape for SVG, and rerun labels. Fatal LaTeX errors, missing images, broken tables, or clipped content must be fixed.

## Current Style Principles

Favor the newest style: concise, dark, technical, concrete, and opinionated. Slides should feel like a live security class by Tinmarino: practical attacks, defensive lessons, small jokes, and one clear thing to remember.

Write mostly in Spanish unless the existing deck is in another language. Spanish should be natural Chilean-neutral technical Spanish, with occasional Tinmarino phrasing when it fits. Avoid generic AI-generated prose.

Keep each slide sparse. One slide should carry one idea, one artifact, or one turn in the story. Split rather than cram.

Prefer concrete examples over abstract advice: a command, a request, a snippet, a tiny table, a screenshot, a number, a payload, a failure mode.

Use progressive disclosure with `\pause`, `\only`, `\visible`, or repeated slide titles when the reveal matters. Do not overuse overlays for ordinary lists.

Do not over-explain on the slide. Put richer speaker notes in HTML comments when useful.

## Narrative Shape

Most good decks follow this rhythm:

1. Context: what the talk is about, for whom, and why it matters.
2. Table of contents: short linked agenda, often with `\hyperlink{anchor}{...}`.
3. Hook: image, contradiction, exploit, surprising number, or uncomfortable question.
4. Source: where the bug/risk appears.
5. Mechanism: the smallest runnable example that explains it.
6. Exploitation or failure: attacker/bug path with concrete input/output.
7. Mitigation: primitive, pattern, or design rule.
8. Remember: short checklist or lesson learned.
9. Conclusion: 3-8 takeaways and references/challenges if the deck is a class.

For training decks, keep exercise slides and solution slides separate. For talks, keep the story tighter and less encyclopedic.

## Markdown Structure

Use Pandoc/Beamer Markdown:

```markdown
# Section {#anchor}

## Subsection

#### Slide Title

Slide body.
```

Use `###` or `####` slide headings according to the target deck's existing convention. Newer full classes often use `####`; some recent secure-dev talks use `###`. Preserve local convention.

Use anchors on major sections when referenced from a TOC: `# Introducción {#intro}`, `# Conclusión {#conc}`.

For title/frontmatter, imitate the nearest newest deck. A SEK-style deck commonly includes:

```yaml
---
title: "..."
place: ...
date: ...
author: Tinmarino
institute: SEK
keywords: ...
header-includes: |
  \def\classtitle{...}
  \def\classimage{res/...}
  \def\classfooter{...}
  \def\classfootnote{}
  \subtitle{}
  \AtBeginPart{ }
  \AtBeginSection{ }
  \AtBeginSubsection{ }
---
```

When copying a footer from a recent SEK deck, preserve the exact TikZ/logo block unless changing branding is requested.

## Visual Patterns

Use dark-theme-friendly content. Tables should be compact and should not rely on light backgrounds.

Images are preferred for emotional hooks, metaphors, screenshots, and exercises. Typical sizing:

```markdown
![](res/path/image.jpg){height=70%}
![](res/path/image.jpg){height=80%}
[![](res/path/screenshot.png){height=70%}](https://example.com)
```

Use `\vspace{-3mm}` to tighten after images or before captions, but only after rendering confirms it helps.

Use centered one-liners for the key memory phrase:

```latex
\begin{center}
Validar todas las entradas.
\end{center}
```

Use `\framesubtitle{\textcolor{my-link}{...}}` sparingly for recap slides.

Use `\relscale{0.8}` or `\slide{\DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,commandchars=\\\{\},fontsize=...}}` when code or tables need to fit. Prefer shortening content first.

Use columns for real comparisons, not decoration:

```markdown
::: columns
:::: {.column width=50%}
Left side.
::::
:::: {.column width=50%}
Right side.
::::
:::
```

## Text Style

Prefer direct verbs and short claims:

- `Validar las entradas.`
- `Separar el código de los datos.`
- `Adoptar primitivas seguras por defecto.`
- `No implementar su propia criptografía.`
- `Lo que el defensor menosprecia, el atacante lo explota.`

Use bold/underline for the one operative word, not whole sentences: `\underline{Validar}`, `**Separar**`, `__Diseñar__`.

Do not write corporate filler such as “en el panorama actual”, “robusto”, “integral”, “aprovechar sinergias”, or long abstract paragraphs.

Humor is allowed but should be anchored to a technical point. Keep jokes short and slightly dry. Do not add memes unless the existing deck already uses that visual language.

Avoid too-perfect Spanish if the local deck has Tinmarino's voice. It is acceptable to keep idioms like “ciberatacante legal”, “computador como arma”, “game over”, “newbye”, “dar es recibir”, “no equivocarse solo” when they fit.

## Technical Content Patterns

For vulnerability or secure coding slides, use this microstructure:

1. Vulnerable source or sink.
2. Expected input.
3. Malicious input.
4. Observable result.
5. Mitigation with the safe primitive.
6. One-line lesson.

Prefer runnable snippets over pseudocode. Keep code small and idiomatic enough to teach the concept.

For code slides, include language tags and outputs as comments:

```python
0.1 + 0.2 - 0.3
# Out: 5.55[...]e-17
```

For attack examples, stay safe and training-oriented. Use local/lab domains or fictional domains unless the existing deck already references a real training system.

For references, use tables with source, type, URL, and reading time when the deck is a class.

## Tables

Use Markdown tables for simple agenda, comparisons, checklists, and references.

Keep table cells short. If a cell wraps heavily, split the slide or use `\makecell[l]{...}` in an explicit LaTeX table.

For linked TOCs, use black-highlighted section cells when matching the SEK class style:

```markdown
| __N.__ | __Parte__ | __Descripción__ |
| -- | --- | --- |
| 1 | \hyperlink{intro}{\cellcolor{black}{Introducción}} | Contexto y objetivos. |
```

For very controlled layout, use raw LaTeX `tabular` with `\arrayrulecolor{black}`, `\rowcolor{black}`, and `\hline`, but only when Markdown tables do not compile correctly.

After editing tables, always compile and render the affected pages. Watch for vertical separators extending below the table, clipped text, extra empty footer rows, and columns too wide for the slide.

## Images And Assets

Before adding an image reference, verify the asset exists or create/copy it deliberately. Prefer existing `res/` subdirectories and naming conventions.

Do not invent image paths. If no asset exists, write a slide that works without the image or ask for the asset.

Use `res/pelea/`, `res/sek/`, `res/arith/`, `res/access/`, `res/injection/`, or the target deck's local resource folder consistently.

## Editing Rules

Make the smallest correct edit. Preserve local conventions even if another deck differs.

When extending a deck, add slides near the relevant section instead of reorganizing the whole file.

When creating a new deck, copy the frontmatter pattern from the nearest newest deck, then simplify only what is not needed.

When the user asks for “some slides”, produce a coherent mini-sequence, not isolated slides: hook, mechanism, mitigation, remember.

When asked to imitate the newest style, bias toward the most recent compact talk deck for density and toward the most recent full class deck for class/exercise flow (identify both from `doc/all-prez.md`).

Do not add backward-compatible LaTeX hacks unless compilation proves they are needed.

## Verification Checklist

Before final response, whenever feasible:

1. Compile with AcademyBook.
2. Render the PDF pages to PNG.
3. Inspect every changed slide and all table/code-heavy slides.
4. Fix missing assets, LaTeX errors, overfull content that visibly clips, and table artifacts.
5. Report the exact output PDF path and any remaining non-fatal warnings.

If compilation cannot be run, say why and provide the exact command to run next.

## Useful Commands

Compile a SEK deck:

```bash
./book.py compile -c slide -t sek -i /absolute/path/to/deck.md
```

Render a generated PDF:

```bash
mkdir -p /tmp/opencode/<deck>-pages
pdftoppm -png -r 120 /absolute/path/to/deck_slide_sek.pdf /tmp/opencode/<deck>-pages/page
```

Open the generated PDF if the user asks:

```bash
xdg-open /absolute/path/to/deck_slide_sek.pdf
```
