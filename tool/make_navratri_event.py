"""Builds the Sharad Navratri In-App Event images: nine diyas for nine nights.

  appstore_assets/events/navratri/<locale>/card_16x9.png      3840×2160
  appstore_assets/events/navratri/<locale>/details_9x16.png   2160×3840

App Store Connect lays the event name over the bottom of the card and covers
roughly the lower quarter of the details image, so the art keeps its words
and diyas high and centred. Run from the repo root:
  python3 tool/make_navratri_event.py
"""
import math
import os

import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_creative_assets import DOODLES, PATTERN  # noqa: E402  the header's line art

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = f'{ROOT}/appstore_assets/events/navratri'
ICON = f'{ROOT}/appstore_assets/appicon.png'
FONTS = f'{ROOT}/assets/fonts'

# Drawn at 2× and scaled down, so curves come out smooth.
SS = 2

SAFFRON = (255, 178, 63)

COPY = {
    'en-US': ('Navratri', '9-Day Jaap Sankalp', 'Set your daily malas. Finish all nine days.',
              f'{FONTS}/Inter-Bold.ttf', f'{FONTS}/Inter-Medium.ttf'),
    'hi': ('नवरात्रि', '9 दिन का जप संकल्प', 'रोज़ की माला तय करें, नौ दिन पूरे करें।',
           f'{FONTS}/NotoSansDevanagari-Bold.ttf', f'{FONTS}/NotoSansDevanagari-Medium.ttf'),
}


def font(path, size):
    return ImageFont.truetype(path, round(size * SS), layout_engine=ImageFont.Layout.RAQM)


def fit(text, path, max_w, start):
    size = start
    while size > 20:
        f = font(path, size)
        if f.getlength(text) <= max_w * SS:
            return f
        size -= 4
    return f


def background(w, h):
    """The header creatives' maroon gradient: dark at the top, warming to a
    saffron glow along the bottom edge."""
    img = Image.new('RGB', (w, h))
    d = ImageDraw.Draw(img)
    stops = [(42, 10, 4), (90, 26, 7), (138, 58, 12)]
    for y in range(h):
        t = y / (h - 1) * 2
        a, b = (stops[0], stops[1]) if t < 1 else (stops[1], stops[2])
        t = t if t < 1 else t - 1
        d.line([(0, y), (w, y)], fill=tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3)))
    glow = Image.new('L', (w, h), 0)
    ImageDraw.Draw(glow).ellipse((w * 0.1, h * 0.98, w * 0.9, h * 1.8), fill=90)
    glow = glow.filter(ImageFilter.GaussianBlur(w * 0.08))
    img.paste((255, 178, 63), (0, 0), glow)
    return img.convert('RGBA')


# The details image is portrait, so it gets its own spread: art in the
# corners and gaps, clear of the title, the diyas and the bottom quarter.
DETAILS_PATTERN = [
    ('bell', 0.14, 0.06, 420, 8), ('om', 0.86, 0.06, 420, -8), ('sparkle', 0.30, 0.04, 140, 0),
    ('sparkle', 0.72, 0.15, 150, 0), ('trishul', 0.09, 0.38, 420, -8), ('om', 0.91, 0.38, 380, 6),
    ('sun', 0.10, 0.55, 420, 0), ('flame', 0.90, 0.56, 330, 8), ('mala', 0.17, 0.84, 480, -12),
    ('bell', 0.84, 0.83, 420, 6), ('lotus', 0.50, 0.85, 500, 0),
]


# Hindu art only on the event images, for now: the Sikh symbols in the
# header's pattern are swapped for Hindu ones.
HINDU_ONLY = {'ek_onkar': 'flame', 'khanda': 'om'}


def doodles(img, pattern, scale, alpha=0.30):
    """Faint line art, as on the header creatives. `scale` maps the header's
    5244-px sizes onto this canvas."""
    for kind, fx, fy, size, angle in pattern:
        kind = HINDU_ONLY.get(kind, kind)
        size = round(size * scale)
        tile = Image.new('RGBA', (size * 2, size * 2), (0, 0, 0, 0))
        DOODLES[kind](ImageDraw.Draw(tile), size, size, max(4, round(11 * scale)))
        if angle:
            tile = tile.rotate(angle, resample=Image.BICUBIC)
        tile.putalpha(tile.getchannel('A').point(lambda v: round(v * alpha)))
        img.alpha_composite(tile, (round(fx * img.width - size), round(fy * img.height - size)))


def diya(img, cx, cy, size):
    """A clay lamp: glow, flame, bowl. cy is the bowl's rim."""
    glow = Image.new('L', img.size, 0)
    gr = size * 1.1
    ImageDraw.Draw(glow).ellipse((cx - gr, cy - size * 1.6 - gr, cx + gr, cy - size * 1.6 + gr), fill=150)
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.6))
    img.paste((255, 190, 80, 255), (0, 0), glow)

    d = ImageDraw.Draw(img)
    # Flame: a teardrop, pointed at the top.
    def flame(scale, colour):
        a, b = size * 0.32 * scale, size * 0.62 * scale
        fy = cy - size * 0.18 - b
        pts = [(cx + a * math.sin(t) * math.sin(t / 2), fy - b * math.cos(t))
               for t in [i * 2 * math.pi / 80 for i in range(81)]]
        d.polygon(pts, fill=colour)
    flame(1.0, (255, 150, 30))
    flame(0.62, (255, 230, 120))

    bw, bh = size * 1.0, size * 0.55
    d.pieslice((cx - bw, cy - bh, cx + bw, cy + bh), 0, 180, fill=(176, 72, 22))
    d.ellipse((cx - bw, cy - bh * 0.28, cx + bw, cy + bh * 0.28), fill=(214, 110, 40))
    d.ellipse((cx - bw * 0.82, cy - bh * 0.18, cx + bw * 0.82, cy + bh * 0.18), fill=(120, 40, 10))


def icon(img, x, y, size):
    ic = Image.open(ICON).convert('RGB').resize((size, size), Image.LANCZOS)
    mask = Image.new('L', ic.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size, size), size * 0.225, fill=255)
    img.paste(ic, (round(x - size / 2), round(y)), mask)


def card(locale):
    title, sub, _, bold, regular = COPY[locale]
    W, H = 3840 * SS, 2160 * SS
    img = background(W, H)
    doodles(img, PATTERN, W / 5244)
    icon(img, W / 2, H * 0.14, round(H * 0.14))
    d = ImageDraw.Draw(img)
    f_title = fit(title, bold, 2600, 300)
    f_sub = fit(sub, regular, 2400, 130)
    d.text((W / 2, H * 0.31), title, font=f_title, fill='white', anchor='mt')
    d.text((W / 2, H * 0.31 + f_title.size * 1.2), sub, font=f_sub, fill=(255, 200, 120), anchor='mt')
    # Nine diyas, one for each night.
    gap = W * 0.075
    for i in range(9):
        diya(img, W / 2 + (i - 4) * gap, H * 0.70, W * 0.03)
    return img


def details(locale):
    title, sub, line, bold, regular = COPY[locale]
    W, H = 2160 * SS, 3840 * SS
    img = background(W, H)
    doodles(img, DETAILS_PATTERN, SS)
    icon(img, W / 2, H * 0.09, round(W * 0.2))
    d = ImageDraw.Draw(img)
    f_title = fit(title, bold, 1800, 260)
    f_sub = fit(sub, regular, 1800, 120)
    d.text((W / 2, H * 0.225), title, font=f_title, fill='white', anchor='mt')
    d.text((W / 2, H * 0.225 + f_title.size * 1.2), sub, font=f_sub, fill=(255, 200, 120), anchor='mt')
    # Nine diyas in three rows of three.
    for r in range(3):
        for c in range(3):
            diya(img, W / 2 + (c - 1) * W * 0.27, H * (0.44 + r * 0.085), W * 0.07)
    f_line = fit(line, regular, 1800, 92)
    d.text((W / 2, H * 0.69), line, font=f_line, fill='white', anchor='mt')
    return img


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    w, h = img.size
    img.convert('RGB').resize((w // SS, h // SS), Image.LANCZOS).save(path, optimize=True)
    print(path)


if __name__ == '__main__':
    for locale in COPY:
        save(card(locale), f'{OUT}/{locale}/card_16x9.png')
        save(details(locale), f'{OUT}/{locale}/details_9x16.png')
