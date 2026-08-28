#!/usr/bin/env python3
"""Draw CyScope-style annotations (blue rectangles + arrows) onto a screenshot.

The browser/Burp capture produces a plain PNG; this overlays a highlight box on
the button/field/URL that matters and, optionally, arrows pointing at it — the
"recuadro azul + flecha" look for a `## Prueba de concepto` step. It is decoupled
from whichever driver captured the image: coordinates come in on the CLI or a
`--spec` JSON, so it works with claude-in-chrome, Playwright, or hand-measured
boxes alike.

Coordinates are pixels in the source image's own space (origin top-left). A
rectangle is `x,y,w,h`; an arrow is `x1,y1,x2,y2` (tail -> head). Out-of-bounds
values are clamped, never fatal, so a driver that reports a box partly off-screen
still yields a usable image.

Examples:
  annotate.py shot.png --rect 120,340,210,44 --out step1.png
  annotate.py shot.png --rect 120,340,210,44 --arrow 40,300,120,352 \
              --label 30,290,"Botón Pagar" --out step1.png
  annotate.py shot.png --spec step1.json --out step1.png
"""

from argparse import ArgumentParser
from pathlib import Path
import json
import sys

from PIL import Image, ImageDraw, ImageFont


CYSCOPE_BLUE = (20, 100, 255)   # bright annotation blue, high contrast on light UI
HALO = (255, 255, 255)          # thin white halo so the box reads on any background


def clamp(v, lo, hi):
    """Clamp v into [lo, hi]."""
    return max(lo, min(hi, v))


def parse_ints(s, n, name):
    """Parse a comma-separated list of exactly n ints, or exit with a message."""
    parts = s.split(',')
    if len(parts) < n:
        sys.exit('bad --%s %r: need %d comma-separated numbers' % (name, s, n))
    try:
        return [int(round(float(p))) for p in parts[:n]]
    except ValueError:
        sys.exit('bad --%s %r: non-numeric' % (name, s))


def scaled(img, base):
    """Return a stroke width that scales gently with image size (min `base`)."""
    return max(base, round(min(img.size) / 300))


def draw_rect(draw, img, x, y, w, h, width):
    """Draw a blue rectangle with a white halo, clamped to the image."""
    x2, y2 = x + w, y + h
    W, H = img.size
    x, y = clamp(x, 0, W - 1), clamp(y, 0, H - 1)
    x2, y2 = clamp(x2, 0, W - 1), clamp(y2, 0, H - 1)
    if x2 < x:
        x, x2 = x2, x
    if y2 < y:
        y, y2 = y2, y
    # white halo underneath, then the blue on top
    draw.rectangle([x - 1, y - 1, x2 + 1, y2 + 1], outline=HALO, width=width + 2)
    draw.rectangle([x, y, x2, y2], outline=CYSCOPE_BLUE, width=width)


def draw_arrow(draw, img, x1, y1, x2, y2, width):
    """Draw a blue arrow from (x1,y1) tail to (x2,y2) head with a filled head."""
    import math
    W, H = img.size
    x1, y1 = clamp(x1, 0, W - 1), clamp(y1, 0, H - 1)
    x2, y2 = clamp(x2, 0, W - 1), clamp(y2, 0, H - 1)
    draw.line([x1, y1, x2, y2], fill=HALO, width=width + 2)
    draw.line([x1, y1, x2, y2], fill=CYSCOPE_BLUE, width=width)
    ang = math.atan2(y2 - y1, x2 - x1)
    size = max(10, width * 4)
    for da in (math.radians(150), math.radians(-150)):
        hx = x2 + size * math.cos(ang + da)
        hy = y2 + size * math.sin(ang + da)
        draw.line([x2, y2, hx, hy], fill=CYSCOPE_BLUE, width=width)
    # solid arrowhead
    p1 = (x2 + size * math.cos(ang + math.radians(150)),
          y2 + size * math.sin(ang + math.radians(150)))
    p2 = (x2 + size * math.cos(ang - math.radians(150)),
          y2 + size * math.sin(ang - math.radians(150)))
    draw.polygon([(x2, y2), p1, p2], fill=CYSCOPE_BLUE)


def draw_label(draw, img, x, y, text, width):
    """Draw a blue text label on a white plate at (x,y)."""
    try:
        font = ImageFont.truetype('DejaVuSans-Bold.ttf', max(14, width * 5))
    except OSError:
        font = ImageFont.load_default()
    box = draw.textbbox((x, y), text, font=font)
    pad = 4
    draw.rectangle([box[0] - pad, box[1] - pad, box[2] + pad, box[3] + pad],
                   fill=HALO, outline=CYSCOPE_BLUE, width=2)
    draw.text((x, y), text, fill=CYSCOPE_BLUE, font=font)


def load_spec(path):
    """Load a JSON spec: {rects:[[x,y,w,h]], arrows:[[..]], labels:[[x,y,text]]}."""
    d = json.loads(Path(path).read_text())
    return d.get('rects', []), d.get('arrows', []), d.get('labels', [])


def build_parser():
    """Return the argument parser."""
    p = ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument('image')
    p.add_argument('--rect', action='append', default=[], help='x,y,w,h (repeatable)')
    p.add_argument('--arrow', action='append', default=[], help='x1,y1,x2,y2 (repeatable)')
    p.add_argument('--label', action='append', default=[], help='x,y,text (repeatable)')
    p.add_argument('--spec', help='JSON file with rects/arrows/labels')
    p.add_argument('--width', type=int, default=0, help='stroke px (0 = auto by image size)')
    p.add_argument('--out', required=True)
    return p


def main():
    """Parse args, draw every annotation, save the result."""
    args = build_parser().parse_args()
    src = Path(args.image)
    if not src.exists():
        sys.exit('no such image: %s' % src)
    img = Image.open(src).convert('RGB')
    draw = ImageDraw.Draw(img)
    width = args.width or scaled(img, 4)

    rects = [parse_ints(r, 4, 'rect') for r in args.rect]
    arrows = [parse_ints(a, 4, 'arrow') for a in args.arrow]
    labels = []
    for l in args.label:
        xy = l.split(',', 2)
        if len(xy) == 3:
            labels.append([int(float(xy[0])), int(float(xy[1])), xy[2]])
    if args.spec:
        sr, sa, sl = load_spec(args.spec)
        rects += sr
        arrows += sa
        labels += sl

    if not (rects or arrows or labels):
        sys.exit('nothing to draw: give --rect/--arrow/--label or --spec')

    for x, y, w, h in rects:
        draw_rect(draw, img, x, y, w, h, width)
    for x1, y1, x2, y2 in arrows:
        draw_arrow(draw, img, x1, y1, x2, y2, width)
    for x, y, text in labels:
        draw_label(draw, img, x, y, text, width)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print('wrote %s (%dx%d, %d rect / %d arrow / %d label)'
          % (out, img.size[0], img.size[1], len(rects), len(arrows), len(labels)))


if __name__ == '__main__':
    main()
