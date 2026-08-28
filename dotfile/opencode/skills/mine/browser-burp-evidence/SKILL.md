---
name: browser-burp-evidence
source: own-tooling
license: MIT
metadata:
  audience: opencode-agents
description: "Produce CyScope-style browser+Burp reproduction evidence for a `## Prueba de concepto` step — drive a browser proxied through Burp, capture the page, overlay a BLUE rectangle (and arrows/labels) on the button/URL that matters via bin/annotate.py, pull the matching HTTP request/response from Burp, and emit the step as the Spanish narration + a ```ruby snippet + the annotated PNG. Use when the operator says 'arma la evidencia con navegador', 'screenshot con recuadro azul', 'captura el paso con Burp', 'annotated screenshot', 'blue box on the button', 'genera el Paso N de la PoC', or right before vuln-reporter writes `## Prueba de concepto`."
---

# browser-burp-evidence — annotated browser+Burp steps for CyScope

Turn one reproducible browser action into one CyScope `### Paso N`: the Spanish narration, a ` ```ruby ` HTTP request/response block, and a screenshot with a **blue recuadro** over the relevant button/URL (plus optional arrows and a label). This is the "se realizó un clic … en Burp Suite se capturó la solicitud" evidence, built to drop straight into `vuln-reporter`'s `## Prueba de concepto`.

> Reality note (2026-08-25): earlier CyScope reports shipped *plain* captures — the blue you saw was native UI chrome, not drawn annotation. This skill ADDS the recuadro/flecha overlay the operator wants going forward. The ruby snippet and the narration are the parts that already matched the house style exactly; keep those verbatim even when the browser capture is not possible.

`ANNOTATE` = `python3 ~/.claude/skills/browser-burp-evidence/bin/annotate.py`.

## Preconditions
- Burp is running with its proxy up; the browser is launched **through** that proxy so every action is captured. Confirm the Burp MCP is reachable (`127.0.0.1:9876`) per `burp-history-reader` / `burp-repeater-capture`.
- Every request carries the attribution header `X-Bug-Bounty-CyScope: tinmarino burp-mcp` (grep-verify — never assume).
- Scope + read/write rules of the engagement `AGENTS.md` still bind; money moves stay under the 5 USD / 5000 CLP daily cap.

## Per-step procedure
1. **Act in the browser.** Navigate and perform the one action the step describes. Drive it with the `claude-in-chrome` MCP (preferred: it clicks/fills and screenshots your real proxied Chrome) or Playwright if installed (`pip install playwright` — only the browsers are cached here, the Python package is not). Keep the URL bar visible in the capture.
2. **Get the element box.** From the driver, read the target element's bounding box in screenshot-pixel space (`claude-in-chrome` returns element geometry; Playwright: `el.bounding_box()`). This gives `x,y,w,h` for the recuadro. If you cannot get exact geometry, measure it from the PNG.
3. **Capture the PNG.** Full-window screenshot to `Findings/<ID>/shots/` (never `/tmp`). For the Burp side of the step, capture the Burp window with `burp-repeater-capture` (X11 `import -window`, no focus steal).
4. **Annotate.** Draw the blue box (+ arrow/label) onto the capture:
   ```
   ANNOTATE Findings/<ID>/shots/raw-01.png \
     --rect <x>,<y>,<w>,<h> --arrow <x1>,<y1>,<x2>,<y2> --label <lx>,<ly>,"Botón Pagar" \
     --out Report/<ID>/res/<client>-<consultant>-<NNN>-<MM>.png
   ```
   Or pass a `--spec step.json` with `{"rects":[[..]],"arrows":[[..]],"labels":[[x,y,"text"]]}` when a driver emits geometry as JSON. Coordinates are pixels in the source image; out-of-bounds values are clamped, so a partly-off-screen element still annotates. Filename follows the submitted-report convention `<client>-<consultant>-<NNN>-<MM>.png` under `res/` (the actually-shipped path; the older skill text says `img/…jpeg` — prefer `res/…png` to match donotgit).
5. **Pull the HTTP pair.** From Burp (MCP `get_active_editor_contents` / history) copy the raw request and its response for this exact action.
6. **Emit the step** in the canonical shape below.

## Step output shape (drop into `## Prueba de concepto`)

First step carries the fixed proxy boilerplate; later steps use the capture sentence.

```markdown
### Paso 1

Para reportar el presente hallazgo, se realizaron los siguientes pasos en un navegador configurado con la herramienta Burp Suite en modo *proxy*.

Se realizó un clic en el botón `Pagar`. En el proxy de Burp Suite se capturó la solicitud HTTP y su respuesta, detalladas a continuación.

https://target.example.com/checkout

```ruby
POST /api/checkout HTTP/2
Host: target.example.com
Content-Type: application/json
X-Bug-Bounty-CyScope: tinmarino burp-mcp

{"couponId":"<test-coupon>","amount":1}
```

```ruby
HTTP/2 200 OK
Content-Type: application/json

{"status":"applied","balance":0}
```

![target-tin-072-01.png](res/target-tin-072-01.png)
```

Rules: ` ```ruby ` is ONLY for the HTTP request/response transcription (the `## Carga` curl reproducer stays ` ```bash `). Exactly the screenshots that exist on disk are cited — never reference a PNG you did not write (this is `vuln-reporter` §2b). One primary annotated capture per step; a Burp-window capture may follow it in the same step.

## Hard rules
- Never fabricate a request/response or a screenshot; every cited artifact exists under `Findings/<ID>/` or `Report/<ID>/res/`.
- Nothing in `/tmp`; annotated PNGs live in the report's `res/`. Public-repo hygiene: in any skill/example use `target.example.com`, `<test-coupon>`, `<token>` — never a real host, cookie or RUT.
- If the browser capture cannot be produced (no display, target unreachable), still emit the narration + ` ```ruby ` blocks and note the missing screenshot under Bloqueados for the triage pass — do not stall the report.
