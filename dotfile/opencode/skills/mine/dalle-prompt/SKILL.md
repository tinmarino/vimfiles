---
name: dalle-prompt
description: Write image-generation prompts (DALL-E / gpt-image) in Tinmarino's house style — moody gloomy cyberpunk, one action frozen at a moment, faces never visible, near-monochromatic blue #00233e, Ghost-in-the-Shell impressionist cartoon — where each visual element maps to the concept taught. Use for an image prompt, a portada / title-page image, a DALLE prompt, a `\classimage`, a `classimage`, a ChatGPT image, or a class/CTF/talk illustration. Corpus in ~/Software/Python/AI/Openai/Dalle.
source: mine
license: MIT
metadata:
  audience: opencode-agents
  corpus: ~/Software/Python/AI/Openai/Dalle
---

# dalle-prompt

Write image prompts in Tinmarino's current visual style. The point of a good prompt here is not decoration: it teaches one idea by turning it into a single, legible scene where each object stands for a concept.

## When To Use

Use when the user asks to create, design, rewrite, or improve an image prompt — for a class portada / title page (`\classimage`), a slide illustration, a CTF/talk hook, a blog header, or any DALL-E / ChatGPT / gpt-image generation. Also when they paste an old prompt and want it brought into this style.

Do not use for non-image text, normal slides (that is `slide-writer`), or photographic / brand-logo work.

## First Steps

1. Identify the ONE concept the image must convey (an attack, a bug class, an antipattern, an algorithm step). If there are several, pick the single most cinematic one — one image, one idea.
2. Skim the corpus for tone and for prompts of adjacent concepts: `~/Software/Python/AI/Openai/Dalle/prompts.txt` (full history), `first.py` (named prompts in the top docstring, including the newest `bounty-hounter` and Pepe ones), `old.md` (curated `# NICE` / `# Best`).
3. Decide the metaphor: subject + one action + the setting, then the concept→visual mapping (see below). Write the mapping first, in your head or on paper; the prose comes from it.

## The House Style (always)

- Open with: **"Create a moody, gloomy cyberpunk image of …"** (newest decks) or "Create an image of …" (classic). Prefer the moody-gloomy opener.
- **One subject, one action, one moment.** End the body with: "The image should focus on a single action at a specific moment: the instant <X>."
- **Subject is anonymous:** a hooded silhouette, a sleek featureless mask, or seen from behind. Faces are never visible. "Faces are not visible; the design is impersonal, minimalist and simple."
- **Atmosphere:** deep volumetric haze, pooled shadows, tense and quiet; a faint sickly CRT glow off-screen as the only warm accent.
- **Style footer (verbatim, almost always):**
  > Use a clean, impressionist cartoon style with a cyberpunk influence reminiscent of Ghost in the Shell. The color palette should be almost monochromatic, primarily black and white or blue with the HTML code #00233e.
- Older prompts append "Set the temperature to 0.5 for a balanced creative result." — optional, keep only if matching that era.

## Structure Of A Prompt

1. `# <kebab-name> — <short subtitle>` (the subtitle says what the scene means).
2. Optional literal line `Create image` on top (handy when pasting into the ChatGPT image UI).
3. **The body**, one rich paragraph: subject doing the action, then weave in the concept→visual mapping, then the single-moment sentence.
4. The style footer.

## The Core Trick — Map Each Visual To A Concept

Every notable object in the scene should *be* a concept. Build a 1:1 mapping, then describe it. Examples actually used:

- async fan-out → a swarm of identical glowing packets on hundreds of thin threads at once (not one by one).
- source-IP rotation → a row of small relay nodes, each glowing a slightly different hue, so every stream seems to start somewhere else.
- enumeration over a range → numeric data motes drifting along the threads in order.
- a rare hit among many → a few of the target's windows lighting up among thousands of identical pulses.
- a swallowed exception (`except: pass`) → a bare black gap that silently eats falling sparks.
- a hardcoded secret → an exposed glowing key/wire embedded in the wall.
- "code that runs but is rotten" → a tower lit and working on the surface, cracked and leaking underneath.
- Python the language → a luminous serpent of code threading the scene; smooth where idiomatic, knotted where it is an antipattern.

If you cannot name the concept a given object represents, cut the object.

## Text In The Image

- Default: **no readable text** — add "Do NOT include any written text!".
- For a **title-page background** (the deck overlays its own `\classtitle`): keep only "faint illegible code glyphs", no large words.
- When the user explicitly wants labels (like `bounty-hounter`: IPs, a `LAUNCH SWARM` terminal, 攻殻機動隊 kanji) — drop the no-text line and **spell out the exact strings** to render, since models mangle unspecified text.

## Palette & Variations

- Core: almost monochromatic, blue `#00233e`, black and white.
- Business / clean-abstract variant (e.g. dashboards): darker `#050a1e`, "super clean and abstract, no text".
- A single warm accent (sickly CRT green, one lit rose, a key) is allowed and makes the frame read.

## Output

- Present the finished prompt ready to copy, in a fenced block, with its `# name — subtitle` header.
- Offer to save it: a named prompt can be appended to `~/Software/Python/AI/Openai/Dalle/prompts.txt` or added under the docstring of `first.py`; a class portada prompt belongs next to its deck (e.g. `doc/ref/dalle-prompt-<topic>.md`).
- If useful, include the concept→visual mapping as a short list after the prompt so the user can tweak it.

## Checklist Before Returning

1. One subject, one action, one specific moment?
2. Face hidden / anonymous subject?
3. Every notable object maps to a named concept?
4. Moody-gloomy opener + volumetric haze + the GitS `#00233e` style footer present?
5. Text handled deliberately (none, faint glyphs, or exact specified strings) — no accidental readable words?
6. Subtitle states the meaning, not just the subject.

## Gold-Standard Example (`bounty-hounter`)

> Create a moody, gloomy cyberpunk image of a single hooded hacker silhouette seen from behind, standing at the left edge, calmly unleashing a massive parallel swarm of identical glowing request packets that fan out toward a single tall server tower on the right. The packets travel along hundreds of thin luminous threads at once — a dense bundle of simultaneous streams, not one by one — conveying continuous high-concurrency async fan-out. Between the hacker and the target, the threads pass through a row of small floating relay nodes, each glowing a slightly different hue, so every stream appears to originate from a different source — symbolizing source-IP rotation through scattered gateways. … The image should focus on a single action at a specific moment: the instant the parallel swarm is launched. Use a clean, impressionist cartoon style with a cyberpunk influence reminiscent of Ghost in the Shell. The color palette should be almost monochromatic, primarily black and white or blue with the HTML code #00233e.
