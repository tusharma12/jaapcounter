"""Rewrites the title block of the hero (01_counter) (01_counter) for JaapMitra.

Wipes the old lettering by interpolating the soft backdrop across each row,
then draws the new name and slogan. English locales only.
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import glob, sys

R = '/Users/tusharsharma/Desktop/projects/jaapcounter'
# usage: make_hero.py ORIGINAL_HERO OUT.png [TITLE TITLE_FONT SUB SUB_FONT]
SRC = sys.argv[1]  # the original hero, before this script touched it
OUT = sys.argv[2]
im = Image.open(SRC).convert('RGB')
W, H = im.size
Y0, Y1 = 1085, 1385
ICON_BOX = (290, 293, 1034, 1018)  # where the old icon sits
X0, X1 = 70, 1250
import numpy as np
arr = np.asarray(im).astype(float)
reg = arr[Y0:Y1, X0:X1]
# Old lettering and its rules: anything noticeably darker than the backdrop.
mask = (reg.sum(axis=2) < 690).astype(np.uint8) * 255
mask = np.asarray(Image.fromarray(mask).filter(ImageFilter.MaxFilter(15))) > 0
known = (~mask).astype(float)
num = reg * known[..., None]
out = reg.copy()
done = known > 0
# Normalised convolution at growing radii: fill from the nearest clean pixels.
for radius in (6, 12, 24, 48, 96):
    n = np.stack([np.asarray(Image.fromarray(np.uint8(num[..., c].clip(0, 255))).filter(ImageFilter.GaussianBlur(radius))).astype(float) for c in range(3)], -1)
    k = np.asarray(Image.fromarray(np.uint8(known * 255)).filter(ImageFilter.GaussianBlur(radius))).astype(float) / 255
    fill = n / np.maximum(k[..., None], 1e-3)
    take = (~done) & (k > 0.05)
    out[take] = fill[take]
    done |= take
arr[Y0:Y1, X0:X1] = out
im = Image.fromarray(arr.astype(np.uint8))
patch = im.crop((X0, Y0, X1, Y1)).filter(ImageFilter.GaussianBlur(2))
m = Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(3))
im.paste(patch, (X0, Y0), m)

# New icon over the old one, with a soft shadow.
icon = Image.open(f'{R}/appstore_assets/appicon-transparent.png').convert('RGBA')
S = 790
icon = icon.resize((S, S), Image.LANCZOS)
cx, cy0 = (ICON_BOX[0] + ICON_BOX[2]) // 2, (ICON_BOX[1] + ICON_BOX[3]) // 2
pos = (cx - S // 2, cy0 - S // 2)
# Cover the old icon first with the backdrop's own colour above and around.
shadow = Image.new('RGBA', im.size, (0, 0, 0, 0))
sh = Image.new('RGBA', (S, S), (200, 110, 30, 110)); sh.putalpha(icon.split()[3].point(lambda v: v * 110 // 255))
shadow.paste(sh, (pos[0], pos[1] + 24), sh)
shadow = shadow.filter(ImageFilter.GaussianBlur(30))
im = im.convert('RGBA'); im.alpha_composite(shadow); im.alpha_composite(icon, pos); im = im.convert('RGB')

ink = (36, 22, 14); muted = (110, 98, 92); dash = (222, 190, 160)
d = ImageDraw.Draw(im)
def fit(path, text, maxw, start):
    size = start
    while size > 30:
        f = ImageFont.truetype(path, size)
        b = f.getbbox(text)
        if b[2] - b[0] <= maxw:
            return f
        size -= 2
    return f

TITLE = sys.argv[3] if len(sys.argv) > 3 else 'Naam Jap Counter'
TITLE_FONT = sys.argv[4] if len(sys.argv) > 4 else f'{R}/assets/fonts/Inter-Bold.ttf'
tf = fit(TITLE_FONT, TITLE, 1060, 140)
SUB = sys.argv[5] if len(sys.argv) > 5 else 'JaapMitra'
SUB_FONT = sys.argv[6] if len(sys.argv) > 6 else f'{R}/assets/fonts/Inter-Medium.ttf'
nf = ImageFont.truetype(SUB_FONT, 70)

def centred(text, font, y, fill):
    b = font.getbbox(text)
    d.text(((W - (b[2] - b[0])) / 2 - b[0], y - (b[1] + b[3]) / 2), text, font=font, fill=fill)
    return b[2] - b[0]

centred(TITLE, tf, 1150, ink)
sw = centred(SUB, nf, 1268, muted)
cy = 1268; gap = 30
d.line([(W / 2 - sw / 2 - gap - 95, cy), (W / 2 - sw / 2 - gap, cy)], fill=dash, width=3)
d.line([(W / 2 + sw / 2 + gap, cy), (W / 2 + sw / 2 + gap + 95, cy)], fill=dash, width=3)
im.save(OUT)
