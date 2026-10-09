#!/usr/bin/env python3
"""Renders the five JaapMitra promo motion graphics (1080x1920, 30fps, MP4).

Usage:
  python3 marketing/motion_videos/render.py            # all videos
  python3 marketing/motion_videos/render.py 1 3        # selected videos
  python3 marketing/motion_videos/render.py --sheet 1  # contact sheet PNG for review

Everything is drawn procedurally with Pillow and piped to ffmpeg. Brand
assets (fonts, app icon, hand-with-mala photo from the App Store art) are
read from the repo. Audio is synthesized sound design (no music bed).
"""
import functools
import math
import os
import subprocess
import sys
import wave
from multiprocessing import Pool

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(HERE, 'out')
W, H, FPS = 1080, 1920, 30

FONT_DIR = os.path.join(ROOT, 'assets', 'fonts')
EMOJI_FONT = '/System/Library/Fonts/Apple Color Emoji.ttc'
ICON_PATH = os.path.join(ROOT, 'appstore_assets', 'appicon-transparent.png')
PHOTO_PATH = os.path.join(ROOT, 'ios', 'fastlane', 'screenshots', 'en-US', '01_counter.png')

# Brand palette (lib/app/theme tokens).
SAFFRON = (245, 166, 35)
SAFFRON_DEEP = (222, 142, 12)
ACCENT_ON_LIGHT = (212, 122, 6)
INK = (43, 38, 35)
CREAM_TEXT = (250, 246, 240)
GOLD = (255, 196, 92)
LIGHT = dict(bg=(248, 247, 244), card=(255, 255, 255), primary=(23, 23, 23),
             secondary=(112, 112, 112), tertiary=(163, 163, 163),
             track=(226, 222, 214), track_hi=(250, 249, 246), track_lo=(196, 191, 182),
             soft=(255, 241, 214), divider=(230, 227, 220))
DARK = dict(bg=(15, 15, 14), card=(30, 30, 29), primary=(245, 244, 241),
            secondary=(156, 154, 148), tertiary=(110, 108, 103),
            track=(54, 52, 49), track_hi=(92, 90, 86), track_lo=(30, 29, 27),
            soft=(51, 38, 15), divider=(48, 48, 46))
RUDRAKSHA = ((128, 62, 30), (206, 136, 86), (66, 30, 12))


# ---------------------------------------------------------------- easing

def clamp(x, a=0.0, b=1.0):
    return a if x < a else b if x > b else x


def prog(t, a, b):
    return clamp((t - a) / (b - a)) if b > a else float(t >= a)


def ease_out(x):
    return 1 - (1 - x) ** 3


def ease_in(x):
    return x * x


def ease_in_out(x):
    return 4 * x ** 3 if x < 0.5 else 1 - (-2 * x + 2) ** 3 / 2


def ease_back(x, s=1.5):
    return 1 + (s + 1) * (x - 1) ** 3 + s * (x - 1) ** 2


EASE = dict(lin=lambda x: x, inout=ease_in_out, out=ease_out, inn=ease_in)


def lerp(a, b, x):
    return a + (b - a) * x


def lerp_c(c1, c2, x):
    return tuple(int(round(lerp(a, b, x))) for a, b in zip(c1, c2))


def window(t, a, b, fi=0.4, fo=0.4):
    if t < a or t > b:
        return 0.0
    v = 1.0
    if fi:
        v = min(v, (t - a) / fi)
    if fo:
        v = min(v, (b - t) / fo)
    return clamp(v)


# ---------------------------------------------------------------- compositing

def with_alpha(img, a):
    if a >= 0.999:
        return img
    out = img.copy()
    out.putalpha(img.getchannel('A').point(lambda v: int(v * a)))
    return out


def comp(canvas, img, x, y, a=1.0):
    if a <= 0.004:
        return
    x, y = int(round(x)), int(round(y))
    w, h = img.size
    cw, ch = canvas.size
    l, t = max(0, -x), max(0, -y)
    r, b = min(w, cw - x), min(h, ch - y)
    if r <= l or b <= t:
        return
    if (l, t, r, b) != (0, 0, w, h):
        img = img.crop((l, t, r, b))
    canvas.alpha_composite(with_alpha(img, a), (x + l, y + t))


def comp_c(canvas, img, cx, cy, a=1.0):
    comp(canvas, img, cx - img.width / 2, cy - img.height / 2, a)


def scaled(img, s):
    if abs(s - 1) < 0.002:
        return img
    return img.resize((max(1, int(img.width * s)), max(1, int(img.height * s))), Image.BICUBIC)


def rrect(size, radius, fill, ss=3, outline=None, width=0):
    w, h = size
    im = Image.new('RGBA', (w * ss, h * ss), fill[:3] + (0,))
    ImageDraw.Draw(im).rounded_rectangle((0, 0, w * ss - 1, h * ss - 1), radius * ss, fill=fill,
                                         outline=outline, width=width * ss)
    return im.resize((w, h), Image.LANCZOS)


@functools.lru_cache(None)
def soft_shadow(w, h, radius, blur, alpha):
    pad = blur * 3
    im = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle((pad, pad, pad + w, pad + h), radius, fill=(40, 22, 8, alpha))
    return im.filter(ImageFilter.GaussianBlur(blur))


# ---------------------------------------------------------------- sprites

@functools.lru_cache(None)
def ball(d, base, light, dark, texture=False):
    ss = 4
    n = d * ss
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
    r = n / 2
    dx, dy = (xx - r) / r, (yy - r) / r
    dist = np.sqrt(dx * dx + dy * dy)
    alpha = np.clip(r - dist * r, 0, 1)
    hl = np.sqrt((dx + 0.35) ** 2 + (dy + 0.4) ** 2)
    lf = np.clip(1 - hl / 0.85, 0, 1) ** 1.6
    rim = np.clip((dist - 0.5) / 0.5, 0, 1) ** 2
    base, light, dark = (np.array(c, np.float32) for c in (base, light, dark))
    col = base[None, None] * (1 - rim[..., None] * 0.7) + dark[None, None] * (rim[..., None] * 0.7)
    if texture:
        bumps = 0.5 + 0.5 * np.sin(dx * 22) * np.sin(dy * 22 + dx * 9)
        col *= (1 - 0.22 * bumps * (dist < 0.95))[..., None]
    col = col * (1 - lf[..., None]) + light[None, None] * lf[..., None]
    rgba = np.dstack([np.clip(col, 0, 255), alpha * 255]).astype(np.uint8)
    return Image.fromarray(rgba, 'RGBA').resize((d, d), Image.BOX)


@functools.lru_cache(None)
def glow(r, color, strength=1.0):
    n = max(2, int(r * 2))
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
    d = np.sqrt((xx - r) ** 2 + (yy - r) ** 2) / r
    a = np.exp(-d * d * 3.2) * np.clip((1 - d) * 3, 0, 1) * 255 * strength
    rgba = np.zeros((n, n, 4), np.uint8)
    rgba[..., :3] = color
    rgba[..., 3] = np.clip(a, 0, 255).astype(np.uint8)
    return Image.fromarray(rgba, 'RGBA')


def bead_sprite(d, mix, theme=LIGHT):
    """mix 0 = rudraksha, 1 = unfilled digital bead."""
    q = round(mix * 10) / 10
    base = lerp_c(RUDRAKSHA[0], theme['track'], q)
    light = lerp_c(RUDRAKSHA[1], theme['track_hi'], q)
    dark = lerp_c(RUDRAKSHA[2], theme['track_lo'], q)
    return ball(max(3, int(round(d))), base, light, dark, q < 0.5)


def bead_on(d=11):
    return ball(d, SAFFRON, (255, 228, 165), (198, 112, 0))


def bead_off(theme, d=11):
    return ball(d, theme['track'], theme['track_hi'], theme['track_lo'])


@functools.lru_cache(None)
def guru_sprite(px):
    """Guru (sumeru) bead with tassel. px ~ bead diameter. Bead centre at (w/2, px/2)."""
    ss = 4
    w, h = int(px * 1.6), int(px * 3.6)
    im = Image.new('RGBA', (w * ss, h * ss), SAFFRON + (0,))
    d = ImageDraw.Draw(im)
    cx = w * ss / 2
    top, bot = px * 0.85 * ss, h * ss - 1
    d.polygon([(cx - px * 0.22 * ss, top), (cx + px * 0.22 * ss, top),
               (cx + px * 0.75 * ss, bot), (cx - px * 0.75 * ss, bot)], fill=SAFFRON)
    for k in range(-3, 4):
        x = cx + k * px * 0.18 * ss
        d.line((cx + k * px * 0.05 * ss, top + px * 0.6 * ss, x, bot), fill=SAFFRON_DEEP, width=max(1, int(px * 0.06 * ss)))
    d.rectangle((cx - px * 0.3 * ss, top, cx + px * 0.3 * ss, top + px * 0.35 * ss), fill=(196, 104, 0))
    im = im.resize((w, h), Image.LANCZOS)
    b = ball(px, SAFFRON_DEEP, (255, 214, 140), (170, 90, 0))
    im.alpha_composite(b, ((w - px) // 2, 0))
    return im


def draw_guru(canvas, x, y, px, a=1.0):
    g = guru_sprite(max(4, int(round(px))))
    comp(canvas, g, x - g.width / 2, y - px / 2, a)


# ---------------------------------------------------------------- text

@functools.lru_cache(None)
def font(weight, size):
    return ImageFont.truetype(os.path.join(FONT_DIR, f'Inter-{weight}.ttf'), size)


SUPP = '/System/Library/Fonts/Supplemental'
SCRIPTS = (((0x0900, 0x097F), None),
           ((0x0A80, 0x0AFF), os.path.join(SUPP, 'Gujarati Sangam MN.ttc')),
           ((0x0A00, 0x0A7F), os.path.join(SUPP, 'Gurmukhi Sangam MN.ttc')),
           ((0x0B80, 0x0BFF), os.path.join(SUPP, 'Tamil Sangam MN.ttc')),
           ((0x0C00, 0x0C7F), os.path.join(SUPP, 'Telugu Sangam MN.ttc')))


def script_of(text):
    for k, ((lo, hi), _) in enumerate(SCRIPTS):
        if any(lo <= ord(c) <= hi for c in text):
            return k
    return -1


def is_indic(text):
    return script_of(text) >= 0


@functools.lru_cache(None)
def _script_font(k, weight, size):
    if k == 0:
        return ImageFont.truetype(os.path.join(FONT_DIR, f'NotoSansDevanagari-{weight}.ttf'), size)
    bold = weight in ('Bold', 'SemiBold')
    try:
        return ImageFont.truetype(SCRIPTS[k][1], size, index=1 if bold else 0)
    except OSError:
        return ImageFont.truetype(SCRIPTS[k][1], size)


def font_for(text, weight, size):
    k = script_of(text)
    return font(weight, size) if k < 0 else _script_font(k, weight, size)


@functools.lru_cache(maxsize=4096)
def text_img(text, size, weight='Bold', color=INK):
    f = font_for(text, weight, size)
    asc, desc = f.getmetrics()
    pad = max(4, size // 10)
    w = int(math.ceil(f.getlength(text))) + 2 * pad
    im = Image.new('RGBA', (w, asc + desc + 2 * pad), color + (0,))
    ImageDraw.Draw(im).text((pad, pad), text, font=f, fill=color + (255,), anchor='la')
    return im


@functools.lru_cache(None)
def text_glow(text, size, color, blur):
    t = text_img(text, size, 'Bold', color)
    pad = blur * 3
    im = Image.new('RGBA', (t.width + 2 * pad, t.height + 2 * pad), color + (0,))
    im.alpha_composite(t, (pad, pad))
    g = im.filter(ImageFilter.GaussianBlur(blur))
    g.alpha_composite(g)  # strengthen the halo
    g.alpha_composite(im)
    return g


def fit_size(text, size, max_w, weight='Bold'):
    while size > 20 and font_for(text, weight, size).getlength(text) > max_w:
        size -= 2
    return size


@functools.lru_cache(None)
def emoji_img(ch, size):
    f = ImageFont.truetype(EMOJI_FONT, 160)
    im = Image.new('RGBA', (190, 190), (0, 0, 0, 0))
    ImageDraw.Draw(im).text((10, 10), ch, font=f, embedded_color=True)
    im = im.crop(im.getbbox())
    return im.resize((size, int(size * im.height / im.width)), Image.LANCZOS)


@functools.lru_cache(None)
def caption_img(text, size, dark):
    imgs = []
    for ln in text.split('\n'):
        accent = ln.startswith('*') and ln.endswith('*')
        ln = ln.strip('*')
        if accent:
            col = SAFFRON if dark else ACCENT_ON_LIGHT
        else:
            col = CREAM_TEXT if dark else INK
        imgs.append(text_img(ln, size, 'Bold', col))
    widest = max(i.width for i in imgs)
    if widest > 1000:
        return caption_img(text, int(size * 1000 / widest), dark)
    lh = int(size * (1.42 if is_indic(text) else 1.18))
    w = max(i.width for i in imgs)
    h = lh * (len(imgs) - 1) + imgs[-1].height
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for k, i in enumerate(imgs):
        out.alpha_composite(i, ((w - i.width) // 2, k * lh))
    return out


def draw_caption(canvas, t, a, b, text, y=330, size=76, dark=False, fi=0.45, fo=0.35):
    al = window(t, a, b, fi, fo)
    if al <= 0:
        return
    rise = (1 - ease_out(prog(t, a, a + fi * 1.6))) * 40
    comp_c(canvas, caption_img(text, size, dark), W / 2, y + rise, al)


# ---------------------------------------------------------------- backgrounds

@functools.lru_cache(None)
def bg(kind):
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    v = (yy / H)[..., None]
    pal = {
        'light': ((255, 246, 236), (252, 214, 192), (255, 251, 243), 0.55),
        'dark': ((10, 8, 7), (26, 16, 9), (70, 40, 12), 0.35),
        'busy': ((236, 237, 241), (210, 214, 222), (246, 247, 250), 0.4),
        'black': ((0, 0, 0), (0, 0, 0), (0, 0, 0), 0.0),
        'night': ((5, 7, 18), (16, 13, 26), (34, 36, 70), 0.5),
        'navy': ((20, 21, 40), (36, 30, 58), (78, 64, 118), 0.45),
        'temple': ((52, 12, 8), (112, 36, 8), (190, 110, 30), 0.45),
        'lotus': ((255, 240, 243), (250, 208, 216), (255, 250, 246), 0.5),
        'sagebg': ((242, 246, 236), (206, 224, 200), (252, 252, 244), 0.5),
    }[kind]
    top, bot, glow_c, gs = (np.array(c, np.float32) if isinstance(c, tuple) else c for c in pal)
    col = top * (1 - v) + bot * v
    d = np.sqrt(((xx - 540) / 900) ** 2 + ((yy - 820) / 1000) ** 2)[..., None]
    g = np.clip(1 - d, 0, 1) ** 2 * gs
    col = col * (1 - g) + glow_c * g
    rgba = np.dstack([np.clip(col, 0, 255), np.full((H, W), 255, np.float32)]).astype(np.uint8)
    return Image.fromarray(rgba, 'RGBA')


def base(kind='light', other=None, x=0.0):
    if other is None or x <= 0:
        return bg(kind).copy()
    if x >= 1:
        return bg(other).copy()
    return Image.blend(bg(kind), bg(other), x)


_rng = np.random.default_rng(108)
PARTS = [(float(_rng.uniform(0, W)), float(_rng.uniform(0, H + 200)), float(_rng.uniform(25, 70)),
          int(_rng.integers(6, 17)), float(_rng.uniform(0, 6.28))) for _ in range(34)]


def particles(canvas, t, intensity=1.0, color=GOLD):
    if intensity <= 0:
        return
    for x0, y0, sp, r, ph in PARTS:
        y = (y0 - sp * t) % (H + 200) - 100
        x = x0 + 26 * math.sin(t * 0.6 + ph)
        a = intensity * (0.3 + 0.7 * math.sin(t * 1.3 + ph) ** 2)
        comp_c(canvas, glow(r, color), x, y, a)


def burst(canvas, age, cx, cy, s=1.0, dur=1.6):
    if age < 0 or age > dur:
        return
    p = age / dur
    for j in range(32):
        ang = j * 2.39996
        dist = (200 + (j % 5) * 45) * ease_out(p) * s
        comp_c(canvas, glow(8 + (j % 3) * 5, GOLD), cx + math.cos(ang) * dist,
               cy + math.sin(ang) * dist, (1 - p) ** 1.4)


@functools.lru_cache(None)
def rays_img():
    n = 1500
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) - n / 2
    ang = np.arctan2(yy, xx)
    d = np.sqrt(xx * xx + yy * yy) / (n / 2)
    a = (0.5 + 0.5 * np.cos(ang * 14)) ** 3 * np.clip(1 - d, 0, 1) ** 1.5 * 120
    rgba = np.zeros((n, n, 4), np.uint8)
    rgba[..., :3] = (255, 200, 110)
    rgba[..., 3] = a.astype(np.uint8)
    return Image.fromarray(rgba, 'RGBA').filter(ImageFilter.GaussianBlur(6))


# ---------------------------------------------------------------- photo + icon

@functools.lru_cache(None)
def hand_photo():
    im = Image.open(PHOTO_PATH).convert('RGB').crop((0, 1540, 1320, 2640))
    im = im.resize((W, int(im.height * W / im.width)), Image.LANCZOS)
    w, h = im.size
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    m = (np.clip(yy / 200, 0, 1) * np.clip((h - yy) / 160, 0, 1)
         * np.clip((w - xx) / 180, 0, 1) * np.clip(xx / 30, 0, 1))
    m = m * m * (3 - 2 * m)
    im.putalpha(Image.fromarray((m * 255).astype(np.uint8), 'L'))
    return im


@functools.lru_cache(None)
def hand_photo_desat():
    im = hand_photo()
    g = im.convert('L').convert('RGB')
    out = Image.blend(im.convert('RGB'), g, 0.45)
    out.putalpha(im.getchannel('A'))
    return out


def draw_photo(canvas, zoom, a, cy=1150, desat=0.0):
    im = hand_photo() if desat <= 0 else Image.blend(hand_photo(), hand_photo_desat(), desat)
    comp_c(canvas, scaled(im, zoom), W / 2, cy, a)


@functools.lru_cache(None)
def icon_img(size):
    return Image.open(ICON_PATH).convert('RGBA').resize((size, size), Image.LANCZOS)


def draw_icon(canvas, cx, cy, size, a=1.0):
    size = max(8, int(size))
    sh = soft_shadow(size, size, int(size * 0.22), max(4, size // 14), 110)
    comp_c(canvas, sh, cx, cy + size * 0.06, a)
    comp_c(canvas, icon_img(size), cx, cy, a)


def draw_sage(canvas, t, cx, cy, size, a, light=1.0):
    """The app's sage-with-mala character as a devotional 'person chanting' plate."""
    if a <= 0:
        return
    breathe = 1 + 0.012 * math.sin(t * 1.6)
    comp_c(canvas, glow(int(size * 0.95), (255, 190, 90)), cx, cy, a * 0.55 * light)
    draw_icon(canvas, cx, cy, size * breathe, a)


# ---------------------------------------------------------------- phone

PW, PH, BZ = 580, 1196, 16
SW, SH = PW - 2 * BZ, PH - 2 * BZ
RCX, RCY, RR = SW / 2, 548, 168
GAP = math.radians(7)
PHONE_CY = 1160


@functools.lru_cache(None)
def phone_frame():
    im = rrect((PW, PH), 86, (22, 22, 24), outline=(92, 90, 96), width=3)
    return im


@functools.lru_cache(None)
def screen_mask():
    ss = 3
    m = Image.new('L', (SW * ss, SH * ss), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, SW * ss - 1, SH * ss - 1), 70 * ss, fill=255)
    return m.resize((SW, SH), Image.LANCZOS)


@functools.lru_cache(None)
def island():
    im = Image.new('RGBA', (PW, PH), (0, 0, 0, 0))
    pill = rrect((150, 44), 22, (6, 6, 6))
    im.alpha_composite(pill, (PW // 2 - 75, BZ + 18))
    return im


def draw_phone(canvas, screen, cx, cy, s=1.0, a=1.0):
    ph = phone_frame().copy()
    ph.paste(screen.convert('RGB'), (BZ, BZ), screen_mask())
    ph.alpha_composite(island())
    sh = soft_shadow(PW, PH, 86, 34, 120)
    comp_c(canvas, scaled(sh, s), cx, cy + 34 * s, a * 0.9)
    comp_c(canvas, scaled(ph, s), cx, cy, a)


def phone_to_global(lx, ly, cx, cy, s):
    return cx + (lx - PW / 2) * s, cy + (ly - PH / 2) * s


def bead_angle(i):
    return math.pi / 2 + GAP + i * (2 * math.pi - 2 * GAP) / 107


def ring_pos(i):
    a = bead_angle(i)
    return RCX + RR * math.cos(a), RCY + RR * math.sin(a)


def ring_global(i, cx, cy, s):
    x, y = ring_pos(i)
    return phone_to_global(BZ + x, BZ + y, cx, cy, s)


def guru_global(cx, cy, s):
    return phone_to_global(BZ + RCX, BZ + RCY + RR + 8, cx, cy, s)


class Track:
    """Count over time: keys are (time, count, easing of the segment ending here)."""

    def __init__(self, keys):
        self.keys = keys

    def val(self, t):
        k = self.keys
        if t <= k[0][0]:
            return k[0][1]
        for (t0, n0, _), (t1, n1, e) in zip(k, k[1:]):
            if t < t1:
                return int(math.floor(lerp(n0, n1, EASE[e]((t - t0) / (t1 - t0))) + 1e-9))
        return k[-1][1]

    @property
    def start(self):
        return self.keys[0][0]

    @property
    def done(self):
        return self.keys[-1][0]

    def taps(self, t, horizon=0.6):
        out, step = [], 1 / 240
        prev = self.val(t - horizon)
        tt = t - horizon
        while tt < t:
            tt = min(t, tt + step)
            v = self.val(tt)
            if v > prev:
                out.append((t - tt, v))
                prev = v
        return out[-4:]


def tap_pos(k):
    return SW / 2 + 120 * math.sin(k * 2.1), 960 + 36 * math.cos(k * 1.3)


def status_bar(img, th, light_text=False):
    d = ImageDraw.Draw(img)
    col = (255, 255, 255) if light_text else th['primary']
    comp_c(img, text_img('9:41', 26, 'SemiBold', col), 86, 46)
    for k in range(4):
        d.rounded_rectangle((398 + k * 9, 52 - k * 4, 404 + k * 9, 58), 1, fill=col)
    d.rounded_rectangle((448, 36, 492, 58), 6, outline=col, width=2)
    d.rounded_rectangle((452, 40, 482, 54), 3, fill=col)


def counter_screen(theme, mantra, track, t, hide_ring=False, total_base=504, lang='en',
                   falling=False, toolbar=False, active_tool=-1):
    th = theme
    L = L10N[lang]
    img = Image.new('RGBA', (SW, SH), th['bg'] + (255,))
    d = ImageDraw.Draw(img)
    status_bar(img, th)
    short = mantra if len(mantra) <= 9 else (mantra.split()[0] if is_indic(mantra) else mantra[:7]) + '…'
    comp(img, text_img(short, 24, 'SemiBold', th['primary']), 30, 104)
    sw = font_for(short, 'SemiBold', 24).getlength(short)
    d.line((44 + sw, 116, 50 + sw, 122, 56 + sw, 116), fill=th['secondary'], width=3)
    d.rounded_rectangle((196, 98, 270, 136), 19, fill=th['soft'])
    comp_c(img, glow(9, SAFFRON, 1.6), 216, 117)
    comp_c(img, text_img('22', 22, 'SemiBold', th['primary']), 246, 117)
    for k in range(3):
        d.line((480, 106 + k * 9, 508, 106 + k * 9), fill=th['primary'], width=3)

    size = fit_size(mantra, 78, SW - 70)
    comp_c(img, text_img(mantra, size, 'Bold', th['primary']), SW / 2, 258)

    n = track.val(t)
    taps = track.taps(t)
    done_age = t - track.done if t >= track.done else None

    if falling:
        for age, k in track.taps(t, 1.8):
            fx = 110 + (k * 137) % 330
            comp_c(img, text_img(mantra, 30, 'SemiBold', SAFFRON), fx, 320 + age * 420, (1 - age / 1.8) * 0.55)

    if done_age is not None:
        pulse = ease_out(prog(done_age, 0, 0.5)) * (0.72 + 0.28 * math.cos(done_age * 3.2))
        comp_c(img, glow(210, SAFFRON), RCX, RCY - 8, pulse * 0.6)

    if not hide_ring:
        on, off = bead_on(), bead_off(th)
        for i in range(108):
            x, y = ring_pos(i)
            comp_c(img, on if i < n else off, x, y)
        if taps and n > 0:
            age = taps[-1][0]
            comp_c(img, glow(22, SAFFRON), *ring_pos(n - 1), (1 - age / 0.6) * 0.95)
        if done_age is not None and done_age < 1.6:
            ph = done_age / 1.1
            for i in range(108):
                boost = math.exp(-((ph - i / 108) * 9) ** 2)
                if boost > 0.05:
                    comp_c(img, glow(17, (255, 214, 130)), *ring_pos(i), boost)
        draw_guru(img, RCX, RCY + RR + 8, 20)

    comp_c(img, text_img(str(n), 120, 'Bold', th['primary']), RCX, RCY - 24)
    d.line((RCX - 34, RCY + 46, RCX + 34, RCY + 46), fill=th['divider'], width=3)
    comp_c(img, text_img('108', 30, 'Medium', th['tertiary']), RCX, RCY + 78)
    if done_age is not None:
        a = prog(done_age, 0.25, 0.65)
        chip = rrect((132, 36), 18, th['soft'])
        comp_c(img, chip, RCX, RCY + 124, a)
        comp_c(img, text_img(L['complete'], 20, 'SemiBold', SAFFRON_DEEP), RCX, RCY + 124, a)

    comp_c(img, text_img(L['todays_jaap'], 22, 'Medium', th['secondary']), SW / 2, 812)
    malas = 4 + (1 if n >= 108 else 0)
    comp_c(img, text_img(L['count'].format(total_base + n) + '   |   ' + L['malas'].format(malas), 27, 'SemiBold',
                         th['primary']), SW / 2, 850)

    draw_tabs(img, th, lang, toolbar, active_tool if toolbar else 0)

    for age, k in taps:
        p = age / 0.6
        x, y = tap_pos(k)
        comp_c(img, glow(46, SAFFRON), x, y, (1 - p) * 0.55)
        if age < 0.22:
            comp_c(img, glow(36, (60, 50, 40)), x, y, 0.22 * (1 - age / 0.22))
        rr = 18 + 80 * ease_out(p)
        ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
        ImageDraw.Draw(ov).ellipse((x - rr, y - rr, x + rr, y + rr), outline=SAFFRON + (int(170 * (1 - p)),), width=4)
        img.alpha_composite(ov)
    return img


MANTRAS = ['Ram Ram', 'Radha Radha', 'Om Namah Shivaya', 'Om Hanumate Namah', 'Hare Krishna',
           'Waheguru', 'Satnam Waheguru', 'Om Namo Narayanaya', 'Jai Shri Ram', 'Jai Mata Di', 'Om Shanti']
DEVA = ['राम राम', 'राधा राधा', 'ॐ नमः शिवाय', 'ॐ हनुमते नमः', 'हरे कृष्ण', 'वाहेगुरु', 'सतनाम वाहेगुरु',
        'ॐ नमो नारायणाय', 'जय श्री राम', 'जय माता दी', 'ॐ शान्ति']
CARD_W, CARD_H, CARD_GAP, CARD_Y0 = 500, 112, 16, 176


@functools.lru_cache(None)
def deva_font(size):
    return ImageFont.truetype(os.path.join(FONT_DIR, 'NotoSansDevanagari-Medium.ttf'), size)


@functools.lru_cache(None)
def deva_img(text, size, color):
    f = deva_font(size)
    bb = f.getbbox(text)
    im = Image.new('RGBA', (bb[2] - bb[0] + 8, bb[3] - bb[1] + 8), color + (0,))
    ImageDraw.Draw(im).text((4 - bb[0], 4 - bb[1]), text, font=f, fill=color + (255,))
    return im


@functools.lru_cache(None)
def card_img(selected, theme_name='light', h=CARD_H, w=CARD_W):
    th = LIGHT if theme_name == 'light' else DARK
    pad = 30
    im = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    comp(im, soft_shadow(w, h, 22, 10, 40), pad - 30, pad - 26)
    fill = th['soft'] if selected else th['card']
    outline = SAFFRON if selected else None
    im.alpha_composite(rrect((w, h), 22, fill, outline=outline, width=3 if selected else 0), (pad, pad))
    return im


def list_screen(scroll, active, pressed, press_amt, theme=LIGHT, lang='en', items=None):
    th = theme
    L = L10N[lang]
    if items is None:
        items = list(zip(MANTRAS, DEVA)) if lang == 'en' else [(dv, None) for dv in DEVA]
    img = Image.new('RGBA', (SW, SH), th['bg'] + (255,))
    d = ImageDraw.Draw(img)
    for i, (name, right) in enumerate(items):
        y = CARD_Y0 + i * (CARD_H + CARD_GAP) - scroll
        if y > SH or y + CARD_H < 120:
            continue
        sel = i == pressed and press_amt > 0.5
        card = card_img(sel)
        s = 1 - 0.03 * (press_amt if i == pressed else 0)
        cx = 24 + CARD_W / 2
        comp_c(img, scaled(card, s), cx, y + CARD_H / 2)
        nm = text_img(name, fit_size(name, 31, 300 if right else 400, 'SemiBold'), 'SemiBold', th['primary'])
        comp(img, nm, 46, y + 40 - nm.height / 2)
        sub = text_img(L['beads'], 20, 'Regular', th['secondary'])
        comp(img, sub, 46, y + 80 - sub.height / 2)
        if i == active:
            comp_c(img, glow(9, SAFFRON, 1.6), 46 + sub.width + 10, y + 80)
            act = text_img(L['active'], 20, 'SemiBold', th['primary'])
            comp(img, act, 46 + sub.width + 20, y + 80 - act.height / 2)
        if right:
            dv = deva_img(right, 22, th['tertiary'])
            comp(img, dv, min(490 - dv.width, 360), y + 74 - dv.height / 2)
        comp_c(img, text_img('···', 26, 'Bold', th['tertiary']), 482, y + 34)
    # header drawn last so cards scroll beneath it
    d.rectangle((0, 0, SW, 160), fill=th['bg'])
    status_bar(img, th)
    d.line((32, 120, 56, 120), fill=th['primary'], width=3)
    d.line((32, 120, 42, 110), fill=th['primary'], width=3)
    d.line((32, 120, 42, 130), fill=th['primary'], width=3)
    comp_c(img, text_img(L['my_mantras'], 30, 'SemiBold', th['primary']), SW / 2, 120)
    d.line((498, 120, 520, 120), fill=th['primary'], width=3)
    d.line((509, 109, 509, 131), fill=th['primary'], width=3)
    return img


def select_flow(t, t0, target, theme=LIGHT, lang='en'):
    """Mantra pick: scroll, tap a card, it becomes Active. Returns list screen image."""
    max_scroll = max(0, CARD_Y0 + target * (CARD_H + CARD_GAP) - 420)
    scroll = max_scroll * ease_in_out(prog(t, t0 + 0.4, t0 + 1.6))
    tp = t0 + 2.0
    press = window(t, tp, tp + 0.5, 0.12, 0.3) if t < tp + 0.5 else (1.0 if t >= tp + 0.1 else 0)
    press_amt = 1.0 if t >= tp + 0.1 else press
    active = target if t >= tp + 0.15 else 0
    img = list_screen(scroll, active, target, press_amt, theme, lang)
    age = t - tp
    if 0 <= age < 0.6:
        y = CARD_Y0 + target * (CARD_H + CARD_GAP) - scroll + CARD_H / 2
        comp_c(img, glow(50, SAFFRON), 230, y, (1 - age / 0.6) * 0.6)
        if age < 0.25:
            comp_c(img, glow(36, (60, 50, 40)), 230, y, 0.25 * (1 - age / 0.25))
    return img


def slide(a_img, b_img, p):
    """iOS-style push from a to b."""
    if p <= 0:
        return a_img
    if p >= 1:
        return b_img
    p = ease_in_out(p)
    out = a_img.copy()
    out.paste(a_img, (int(-SW * 0.3 * p), 0))
    shade = Image.new('RGBA', out.size, (0, 0, 0, int(40 * p)))
    out.alpha_composite(shade)
    out.alpha_composite(b_img, (int(SW * (1 - p)), 0))
    return out


@functools.lru_cache(None)
def lock_screen():
    yy = np.linspace(0, 1, SH, dtype=np.float32)[:, None, None]
    top, bot = np.array((28, 20, 15), np.float32), np.array((96, 58, 26), np.float32)
    col = np.broadcast_to(top * (1 - yy) + bot * yy, (SH, SW, 3))
    img = Image.fromarray(np.dstack([col, np.full((SH, SW), 255, np.float32)]).astype(np.uint8), 'RGBA')
    status_bar(img, LIGHT, light_text=True)
    comp_c(img, text_img('Thursday, October 8', 28, 'Medium', (240, 228, 214)), SW / 2, 196)
    comp_c(img, text_img('6:12', 150, 'SemiBold', (252, 246, 238)), SW / 2, 300)
    card = rrect((500, 110), 26, (255, 255, 255, 52))
    comp(img, card, 24, 830)
    comp_c(img, icon_img(60), 76, 885)
    comp(img, text_img('JaapMitra', 23, 'SemiBold', (255, 255, 255)), 116, 846)
    comp(img, text_img('Time for your morning Jaap', 23, 'Regular', (245, 235, 225)), 116, 880)
    return img


# ---------------------------------------------------------------- drawn mala

@functools.lru_cache(None)
def teardrop_pts(n=108, gap=0.035):
    ths = np.linspace(math.pi, 3 * math.pi, 6001)
    xs = np.sin(ths) * np.abs(np.sin(ths / 2))
    ys = -np.cos(ths)
    seg = np.hypot(np.diff(xs), np.diff(ys))
    cum = np.concatenate([[0], np.cumsum(seg)])
    L = cum[-1]
    tg = gap * L + np.arange(n) * (L * (1 - 2 * gap)) / (n - 1)
    idx = np.clip(np.searchsorted(cum, tg), 0, len(xs) - 1)
    return tuple(zip(xs[idx].tolist(), ys[idx].tolist()))


def draw_mala_morph(canvas, t, t0, t1, mala, phone, a=1.0, theme=LIGHT):
    """Rudraksha mala (teardrop) -> the phone's bead ring.

    mala = (cx, cy, half_width, half_height, bead_d); phone = (cx, cy, scale).
    """
    mx, my, ma, mb, md = mala
    pcx, pcy, ps = phone
    pts = teardrop_pts()
    for i in range(108):
        st = (i % 108) / 108 * 0.35
        p = ease_in_out(prog(t, t0 + st * (t1 - t0), t1 - (0.35 - st) * (t1 - t0)))
        sx, sy = mx + pts[i][0] * ma, my + pts[i][1] * mb
        ex, ey = ring_global(i, pcx, pcy, ps)
        x, y = lerp(sx, ex, p), lerp(sy, ey, p)
        # slight arc so beads swirl in
        lift = math.sin(p * math.pi) * 40
        comp_c(canvas, bead_sprite(lerp(md, 11 * ps, p), p, theme), x + lift * 0.4, y - lift, a)
    p = ease_in_out(prog(t, t0 + 0.2 * (t1 - t0), t1))
    gx, gy = guru_global(pcx, pcy, ps)
    draw_guru(canvas, lerp(mx, gx, p), lerp(my + mb + md * 0.7, gy, p), lerp(md * 1.6, 20 * ps, p), a)


# ---------------------------------------------------------------- cards / bubbles

@functools.lru_cache(None)
def bubble_img(text):
    t = text_img(text, 50, 'Bold', INK)
    w, h = max(120, t.width + 50), 96
    im = Image.new('RGBA', (w + 60, h + 60), (0, 0, 0, 0))
    comp(im, soft_shadow(w, h, 48, 10, 60), 0, 6)
    im.alpha_composite(rrect((w, h), 48, (255, 255, 255)), (30, 30))
    comp_c(im, t, 30 + w / 2, 30 + h / 2)
    return im


@functools.lru_cache(None)
def notif_card(emoji, title, sub, rot):
    w, h = 660, 150
    pad = 50
    im = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    comp(im, soft_shadow(w, h, 36, 14, 70), pad - 42, pad - 34)
    im.alpha_composite(rrect((w, h), 36, (255, 255, 255)), (pad, pad))
    comp_c(im, emoji_img(emoji, 84), pad + 80, pad + h / 2)
    comp(im, text_img(title, 40, 'SemiBold', INK), pad + 146, pad + 28)
    comp(im, text_img(sub, 28, 'Regular', (120, 116, 112)), pad + 146, pad + 82)
    return im.rotate(rot, resample=Image.BICUBIC, expand=True)


def end_card(cv, t, tagline, dark=False, lang='en'):
    primary = CREAM_TEXT if dark else INK
    secondary = (170, 160, 148) if dark else (120, 106, 96)
    p = prog(t, 0.15, 0.95)
    s = ease_back(p) if p < 1 else 1.0
    comp_c(cv, glow(400, SAFFRON), 540, 900, 0.42 * prog(t, 0, 0.8) * (0.85 + 0.15 * math.sin(t * 2)))
    draw_icon(cv, 540, 900, 340 * max(0.05, s), prog(t, 0.15, 0.45))
    a = prog(t, 0.55, 1.05)
    rise = (1 - ease_out(prog(t, 0.55, 1.2))) * 30
    comp_c(cv, text_img(L10N[lang]['brand'], 132, 'Bold', primary), 540, 1196 + rise, a)
    sub = text_img(L10N[lang]['brand_sub'], 44, 'Medium', secondary)
    a2 = prog(t, 0.85, 1.35)
    comp_c(cv, sub, 540, 1306, a2)
    line = Image.new('RGBA', (80, 3), secondary + (150,))
    comp_c(cv, line, 540 - sub.width / 2 - 60, 1306, a2)
    comp_c(cv, line, 540 + sub.width / 2 + 60, 1306, a2)
    draw_caption(cv, t, 0.25, 99, tagline, y=440, size=80, dark=dark)


def finish(cv, t, dur, fade, to='light'):
    x = prog(t, dur - fade, dur)
    if x > 0:
        cv = Image.blend(cv, bg(to), ease_in_out(x))
    return cv


def phone_shake(track, t):
    off = 0.0
    for age, _ in track.taps(t, 0.15):
        off += 4 * math.sin(age * 95) * (1 - age / 0.15)
    return off


# ---------------------------------------------------------------- video 1

V1T = Track([(5.0, 0, 'lin'), (7.0, 5, 'lin'), (12.7, 108, 'inout')])


def v1(t):
    D = 22.0
    cv = base('light')
    particles(cv, t, 1.0 if t < 3.5 else 0.55)
    if t < 3.8:
        z = 1 + 0.08 * ease_in_out(prog(t, 0, 3.6))
        draw_photo(cv, z, 1 - prog(t, 3.0, 3.6))
        seq = ['41', '42', '43', '4…', '?']
        k = min(4, int(max(0, t - 0.5) / 0.42))
        wob = math.sin(t * 9) * 6 * (k == 4)
        comp_c(cv, bubble_img(seq[k]), 760 + wob, 840, window(t, 0.5, 3.2, 0.25, 0.3))
    draw_caption(cv, t, 0.15, 3.3, 'Stop Counting.\n*Start Chanting.*', size=86)

    if 3.0 <= t < 17.6:
        s = lerp(0.9, 1.0, ease_out(prog(t, 3.5, 4.8)))
        pa = prog(t, 3.5, 4.3) * (1 - prog(t, 16.9, 17.5))
        s *= lerp(1, 0.9, ease_in_out(prog(t, 16.9, 17.5)))
        cx, cy = 540 + phone_shake(V1T, t), PHONE_CY
        scr = counter_screen(LIGHT, 'Ram Ram', V1T, t, hide_ring=t < 5.0)
        draw_phone(cv, scr, cx, cy, s, pa)
        if t < 5.0:
            draw_mala_morph(cv, t, 3.7, 5.0, (540, 1080, 240, 330, 18), (cx, cy, s), prog(t, 3.0, 3.6))
        burst(cv, t - V1T.done, cx, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 3.5, 7.0, 'Just tap.\n*JaapMitra counts for you.*')
    draw_caption(cv, t, 7.0, 12.0, 'You focus on\n*the mantra.*')
    draw_caption(cv, t, 12.0, 17.0, 'We handle\n*the count.*')
    if t >= 17.2:
        particles(cv, t, 0.5)
        end_card(cv, t - 17.2, 'Your daily Sadhana,\n*made simple.*')
    return finish(cv, t, D, 1.5)


# ---------------------------------------------------------------- video 2

V2T = Track([(10.0, 0, 'lin'), (11.6, 4, 'lin'), (15.6, 108, 'inout')])


def v2(t):
    D = 23.0
    cv = base('light')
    particles(cv, t, 0.6)
    if t < 6.9:
        z = 1.06 - 0.05 * ease_in_out(prog(t, 0, 6))
        des = 0.8 * ease_in_out(prog(t, 3.0, 3.8))
        draw_photo(cv, z, 1 - prog(t, 6.0, 6.8), desat=des)
        # one bead slips through the fingers
        for g in range(4):
            p = prog(t - g * 0.04, 1.0, 2.3)
            if 0 < p < 1:
                x, y = lerp(770, 690, p), 1050 + 520 * ease_in(p)
                comp_c(cv, bead_sprite(42, 0), x, y, (1 - p) * (1 if g == 0 else 0.25))
        seq = ['54?', '55?', '56?', '?']
        k = min(3, int(max(0, t - 3.2) / 0.45))
        wob = math.sin(t * 8) * 7 if k == 3 else 0
        comp_c(cv, bubble_img(seq[k]), 760 + wob, 830, window(t, 3.2, 5.9, 0.25, 0.3))
    draw_caption(cv, t, 0.15, 3.0, 'Lose Count\n*While Chanting?*', size=86)
    draw_caption(cv, t, 3.2, 6.0, 'It happens.', size=86)

    if 6.0 <= t < 19.5:
        enter = ease_out(prog(t, 6.0, 7.1))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        s = lerp(1.0, 0.9, ease_in_out(prog(t, 18.9, 19.5)))
        pa = 1 - prog(t, 18.9, 19.5)
        cx = 540 + phone_shake(V2T, t)
        draw_phone(cv, counter_screen(LIGHT, 'Radha Radha', V2T, t), cx, cy, s, pa)
        burst(cv, t - V2T.done, cx, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 6.2, 10.0, 'Let JaapMitra\n*count for you.*')
    draw_caption(cv, t, 10.0, 15.0, 'Just tap\n*and chant.*')
    draw_caption(cv, t, 15.0, 19.0, '*108 / 108*', size=120)
    if t >= 19.3:
        particles(cv, t, 0.4)
        end_card(cv, t - 19.3, 'Never lose\n*count again.*')
    return finish(cv, t, D, 1.0)


# ---------------------------------------------------------------- video 3

V3T = Track([(13.0, 0, 'lin'), (14.6, 4, 'lin'), (18.0, 108, 'inout')])


def v3(t):
    D = 25.0
    cv = base('light')
    # soft morning light
    ml = prog(t, 0, 4)
    comp_c(cv, glow(760, (255, 214, 150)), 900, 260, 0.35 + 0.4 * ml)
    if t < 8.5:
        r = rays_img()
        comp_c(cv, r.rotate(t * 3, resample=Image.BILINEAR), 900, 260, (0.25 + 0.45 * ml) * (1 - prog(t, 6, 8)))
    particles(cv, t, 0.7)

    mala = (300, 1150, 190, 290, 15)
    if t < 22.6:
        mv = ease_in_out(prog(t, 4.0, 5.4))
        cx = lerp(790, 540, mv) + phone_shake(V3T, t)
        cy = lerp(1180, PHONE_CY, mv)
        s = lerp(0.56, 1.0, mv)
        s *= lerp(1, 0.9, ease_in_out(prog(t, 21.9, 22.5)))
        pa = prog(t, 0.0, 0.6) * (1 - prog(t, 21.9, 22.5))
        if t < 8.0:
            cnt = counter_screen(LIGHT, 'Ram Ram', V3T, t, hide_ring=t < 6.4)
            scr = Image.blend(lock_screen(), cnt, ease_in_out(prog(t, 4.2, 5.0)))
        elif t < 11.6:
            cnt = counter_screen(LIGHT, 'Ram Ram', V3T, t)
            scr = slide(cnt, select_flow(t, 8.4, 2), prog(t, 8.0, 8.45))
            if t >= 11.0:
                nxt = counter_screen(LIGHT, 'Om Namah Shivaya', V3T, t)
                scr = slide(select_flow(t, 8.4, 2), nxt, prog(t, 11.0, 11.45))
        else:
            scr = counter_screen(LIGHT, 'Om Namah Shivaya', V3T, t)
        if pa > 0:
            draw_phone(cv, scr, cx, cy, s, pa)
        if t < 6.4:
            draw_mala_morph(cv, t, 4.4, 6.4, mala, (cx, cy, s), prog(t, 0.0, 0.6))
        burst(cv, t - V3T.done, cx, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 0.2, 4.0, 'What if your Mala\n*was always with you?*', size=78)
    draw_caption(cv, t, 4.2, 8.0, 'Your digital\n*Jap Mala.*')
    draw_caption(cv, t, 8.2, 13.0, 'Choose\n*your mantra.*')
    draw_caption(cv, t, 13.0, 18.0, 'Tap. Chant.\n*Count.*')
    draw_caption(cv, t, 18.0, 22.0, '108 chants.\n*No counting stress.*')
    if t >= 22.3:
        particles(cv, t, 0.4)
        end_card(cv, t - 22.3, 'Your Mala.\n*Anywhere.*')
    return finish(cv, t, D, 1.0)


# ---------------------------------------------------------------- video 4

V4T = Track([(10.0, 0, 'lin'), (11.4, 4, 'lin'), (14.4, 108, 'inout')])


def v4(t):
    D = 23.0
    cv = base('black', 'dark', ease_in_out(prog(t, 3.0, 4.5)))
    if t < 3.4:
        p = prog(t, 0.2, 2.4)
        s = lerp(0.94, 1.0, ease_out(p))
        a = ease_in_out(p) * (1 - prog(t, 2.7, 3.3))
        g = text_glow('108.', 360, SAFFRON, 28)
        comp_c(cv, scaled(g, s), W / 2, 920, a)
    light = ease_in_out(prog(t, 6.0, 8.0))
    sage_a = prog(t, 3.2, 4.2) * (1 - prog(t, 8.8, 9.4))
    if sage_a > 0:
        if light > 0:
            comp_c(cv, rays_img().rotate(t * 4, resample=Image.BILINEAR), 540, 1080, light * sage_a * 0.9)
            comp_c(cv, glow(640, (255, 176, 70)), 540, 1080, light * sage_a * 0.5)
        draw_sage(cv, t, 540, 1080, 540, sage_a, 0.6 + light)
    particles(cv, t, 0.25 + 0.5 * light * (1 - prog(t, 9, 10)))
    draw_caption(cv, t, 3.4, 6.0, 'One mantra.', size=86, dark=True)
    draw_caption(cv, t, 6.1, 9.0, 'One moment\n*of peace.*', size=86, dark=True)

    if 9.0 <= t < 18.7:
        enter = ease_out(prog(t, 9.3, 10.2))
        cy = lerp(PHONE_CY + 160, PHONE_CY, enter)
        pa = enter * (1 - prog(t, 18.0, 18.6))
        s = lerp(1.0, 0.9, ease_in_out(prog(t, 18.0, 18.6)))
        cx = 540 + phone_shake(V4T, t)
        draw_phone(cv, counter_screen(DARK, 'Hare Krishna', V4T, t), cx, cy, s, pa)
        burst(cv, t - V4T.done, cx, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 9.2, 14.0, 'Track\n*every Jaap.*', dark=True)
    draw_caption(cv, t, 14.0, 18.0, '*108 complete.*', size=88, dark=True)
    if t >= 18.3:
        particles(cv, t, 0.4)
        end_card(cv, t - 18.3, 'Make Jaap part\n*of every day.*', dark=True)
    return finish(cv, t, D, 1.0, to='black')


# ---------------------------------------------------------------- video 5

V5T = Track([(10.0, 0, 'lin'), (11.6, 4, 'lin'), (15.4, 108, 'inout')])
BUSY = [('⏰', '6:45 AM', 'Alarm · snoozed twice', 470, 640, -3),
        ('💬', '12 new messages', 'Family group, Work', 600, 860, 2.5),
        ('💼', 'Standup in 5 min', 'Join call', 470, 1080, -2),
        ('☕', 'Coffee, quick!', 'Running late', 610, 1300, 3),
        ('🚗', 'Traffic +25 min', 'Leave now', 480, 1520, -2.5)]


def v5(t):
    D = 25.0
    cv = base('busy', 'light', ease_in_out(prog(t, 3.0, 4.2)))
    if t < 4.2:
        jitter = 1 - prog(t, 2.9, 3.2)
        for k, (em, title, sub, x, y, rot) in enumerate(BUSY):
            t0 = 0.1 + k * 0.45
            p = prog(t, t0, t0 + 0.35)
            if p <= 0:
                continue
            s = ease_back(p, 2.2)
            out = ease_in(prog(t, 3.0 + k * 0.06, 3.7 + k * 0.06))
            dx = (x - 540) * 2.2 * out + math.sin(t * 40 + k) * 5 * jitter
            dy = (y - 1080) * 0.6 * out + math.cos(t * 37 + k) * 4 * jitter
            card = scaled(notif_card(em, title, sub, rot), max(0.05, s * (1 - 0.3 * out)))
            comp_c(cv, card, x + dx, y + dy, min(1, p * 2) * (1 - out))
    draw_caption(cv, t, 0.1, 3.0, 'Life gets busy.', size=88, fo=0.25)

    sage_a = prog(t, 3.6, 4.4) * (1 - prog(t, 5.7, 6.2))
    particles(cv, t, prog(t, 3.2, 4.2) * 0.8)
    if sage_a > 0:
        draw_sage(cv, t, 540, 1100, 560, sage_a)
    draw_caption(cv, t, 3.4, 6.0, 'Make a moment\n*for yourself.*')

    if 6.0 <= t < 19.7:
        enter = ease_out(prog(t, 6.0, 7.0))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        pa = 1 - prog(t, 19.0, 19.6)
        s = lerp(1.0, 0.9, ease_in_out(prog(t, 19.0, 19.6)))
        cx = 540 + phone_shake(V5T, t)
        if t < 9.6:
            scr = select_flow(t, 6.8, 4)
            if t >= 9.2:
                scr = slide(scr, counter_screen(LIGHT, 'Hare Krishna', V5T, t), prog(t, 9.2, 9.6))
        else:
            scr = counter_screen(LIGHT, 'Hare Krishna', V5T, t)
        draw_phone(cv, scr, cx, cy, s, pa)
        burst(cv, t - V5T.done, cx, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 6.2, 10.0, 'Choose\n*your mantra.*')
    draw_caption(cv, t, 10.0, 15.0, 'Just tap\n*and chant.*')
    draw_caption(cv, t, 15.0, 19.0, 'Your Jaap\n*is complete.*')
    if t >= 19.4:
        end_card(cv, t - 19.4, 'Your daily Sadhana,\n*made simple.*')
    return finish(cv, t, D, 1.2)


# ================================================================ feature videos (06-10, EN + HI)

L10N = {
    'en': dict(
        brand='JaapMitra', brand_sub='Naam Jap Counter',
        todays_jaap="Today's Jaap", count='Count: {:,}', malas='Malas: {}', complete='Complete',
        mala_complete='Mala complete', tabs=('Jaap', 'Progress', 'Stories', 'Settings'),
        tools=('Music', 'Timer', 'Auto Jaap', 'Blackout'), my_mantras='My Mantras', beads='108 beads',
        active='Active', take_sankalp='Take a Sankalp', sankalp_sub='A daily vow you keep', days='{} days',
        malas_day='10 malas a day', my_sadhana='My Sadhana', todays_goal="Today's Goal",
        streak_chip='{} Day Streak', sankalp_title='40 DAY SANKALP', day_x='Day {} / 40',
        days_done='{} days completed', sankalp_meta='10 malas a day · 1,080 Jaap',
        sankalp_complete='Sankalp complete', progress='Progress', grace='2 grace days held',
        goal_of='/ 1,080 Goal', malas_done='5 Malas completed',
        periods=('Daily', 'Weekly', 'Monthly', 'Yearly'), weekly_jaap='Weekly Jaap',
        week=('M', 'T', 'W', 'T', 'F', 'S', 'S'), streak_label='STREAK', in_a_row='{} days in a row',
        day_streak='Day Streak', add_mantra='Add Mantra', mantra_label='Mantra', mala_size='Mala size',
        custom='Custom', save='Save', now_playing='NOW PLAYING', your_recording='Your recording',
        recording='Recording…'),
    'hi': dict(
        brand='जापमित्र', brand_sub='नाम जप काउंटर',
        todays_jaap='आज का जाप', count='गिनती: {:,}', malas='मालाएँ: {}', complete='पूर्ण',
        mala_complete='माला पूर्ण', tabs=('जाप', 'प्रगति', 'कथाएँ', 'सेटिंग'),
        tools=('संगीत', 'समय', 'स्वतः जाप', 'अंधकार'), my_mantras='मेरे मंत्र', beads='108 मनके',
        active='सक्रिय', take_sankalp='संकल्प लें', sankalp_sub='प्रतिदिन निभाया जाने वाला वचन', days='{} दिन',
        malas_day='प्रतिदिन 10 माला', my_sadhana='मेरी साधना', todays_goal='आज का लक्ष्य',
        streak_chip='{} दिन की लय', sankalp_title='40 दिन का संकल्प', day_x='दिन {} / 40',
        days_done='{} दिन पूर्ण', sankalp_meta='प्रतिदिन 10 माला · 1,080 जाप',
        sankalp_complete='संकल्प पूर्ण', progress='प्रगति', grace='2 छूट के दिन शेष',
        goal_of='/ 1,080 लक्ष्य', malas_done='5 मालाएँ पूर्ण',
        periods=('दैनिक', 'साप्ताहिक', 'मासिक', 'वार्षिक'), weekly_jaap='साप्ताहिक जाप',
        week=('सो', 'मं', 'बु', 'गु', 'शु', 'श', 'र'), streak_label='लय', in_a_row='लगातार {} दिन',
        day_streak='दिन की लय', add_mantra='मंत्र जोड़ें', mantra_label='मंत्र', mala_size='माला का आकार',
        custom='अपना', save='सहेजें', now_playing='अभी चल रहा है', your_recording='आपकी रिकॉर्डिंग',
        recording='रिकॉर्ड हो रहा है…'),
}

NIGHT = dict(bg=(26, 27, 46), card=(38, 40, 66), primary=(245, 244, 241), secondary=(176, 176, 196),
             tertiary=(122, 122, 146), track=(62, 64, 94), track_hi=(100, 102, 136), track_lo=(40, 41, 64),
             soft=(60, 48, 40), divider=(52, 54, 82))

ALL_MANTRAS = [('Ram Ram', 'राम राम'), ('Radha Radha', 'राधा राधा'), ('Sita Ram', 'सीता राम'),
               ('Om Namah Shivaya', 'ॐ नमः शिवाय'), ('Om Hanumate Namah', 'ॐ हनुमते नमः'),
               ('Hare Krishna', 'हरे कृष्ण'), ('Maha Mantra', 'हरे कृष्ण महामंत्र'),
               ('Om Namo Bhagavate Vasudevaya', 'ॐ नमो भगवते वासुदेवाय'), ('Gayatri Mantra', 'गायत्री मंत्र'),
               ('Mahamrityunjaya', 'महामृत्युंजय मंत्र'), ('Om Gam Ganapataye Namah', 'ॐ गं गणपतये नमः'),
               ('Om Shri Mahalakshmyai Namah', 'ॐ श्री महालक्ष्म्यै नमः'),
               ('Om Aim Saraswatyai Namah', 'ॐ ऐं सरस्वत्यै नमः'), ('Shri Ram Jai Ram', 'श्री राम जय राम'),
               ('Radhe Krishna', 'राधे कृष्ण'), ('Om Namo Narayanaya', 'ॐ नमो नारायणाय'),
               ('Om Sai Ram', 'ॐ साईं राम'), ('Om', 'ॐ'), ('Waheguru', 'वाहेगुरु वाहेगुरु'),
               ('Satnam Waheguru', 'सतनाम वाहेगुरु'), ('Hare Rama', 'हरे राम हरे राम')]

# Mantras in the scripts the app ships (lib/core/constants/mantra_scripts.dart).
FLOATING = ['राम राम', 'ॐ नमः शिवाय', 'ਵਾਹਿਗੁਰੂ ਵਾਹਿਗੁਰੂ', 'રાધે કૃષ્ણ', 'ஓம் நமஃ சிவாய', 'ఓం నమః శివాయ',
            'Hare Krishna', 'ॐ', 'ਰਾਮ ਰਾਮ', 'రామ రామ', 'Om Namah Shivaya', 'राधे कृष्ण', 'ராம ராம',
            'ૐ નમઃ શિવાય', 'हरे कृष्ण', 'Radhe Radhe']


def glyph(d, kind, x, y, col, bg=None):
    if kind == 'note':
        d.ellipse((x - 11, y + 2, x + 1, y + 12), fill=col)
        d.line((x, y + 7, x, y - 13), fill=col, width=3)
        d.line((x, y - 13, x + 10, y - 8), fill=col, width=3)
    elif kind == 'timer':
        d.ellipse((x - 11, y - 10, x + 11, y + 12), outline=col, width=3)
        d.line((x, y + 1, x, y - 5), fill=col, width=3)
        d.line((x - 4, y - 14, x + 4, y - 14), fill=col, width=3)
    elif kind == 'play':
        d.ellipse((x - 12, y - 12, x + 12, y + 12), outline=col, width=3)
        d.polygon([(x - 4, y - 6), (x - 4, y + 6), (x + 6, y)], fill=col)
    elif kind == 'moon':
        d.ellipse((x - 11, y - 11, x + 11, y + 11), fill=col)
        d.ellipse((x - 5, y - 15, x + 15, y + 5), fill=bg)
    else:
        d.ellipse((x - 11, y - 11, x + 11, y + 11), outline=col, width=3)


def tool_pos(k):
    return 78 + k * 130, SH - 81


def draw_tabs(img, th, lang, toolbar=False, active=0):
    d = ImageDraw.Draw(img)
    labels = L10N[lang]['tools' if toolbar else 'tabs']
    d.line((0, SH - 112, SW, SH - 112), fill=th['divider'], width=2)
    for k, lab in enumerate(labels):
        col = SAFFRON_DEEP if k == active else th['tertiary']
        x, y = tool_pos(k)
        glyph(d, ('note', 'timer', 'play', 'moon')[k] if toolbar else 'circle', x, y, col, th['bg'])
        comp_c(img, text_img(lab, 18, 'Medium', col), x, SH - 48)


def screen_tap(img, x, y, age, dur=0.6):
    if not 0 <= age < dur:
        return
    p = age / dur
    comp_c(img, glow(50, SAFFRON), x, y, (1 - p) * 0.6)
    if age < 0.22:
        comp_c(img, glow(36, (60, 50, 40)), x, y, 0.25 * (1 - age / 0.22))
    rr = 18 + 70 * ease_out(p)
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ov).ellipse((x - rr, y - rr, x + rr, y + rr), outline=SAFFRON + (int(170 * (1 - p)),), width=4)
    img.alpha_composite(ov)


def header(img, th, title, back=True, plus=False):
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, SW, 160), fill=th['bg'])
    status_bar(img, th)
    if back:
        d.line((32, 120, 56, 120), fill=th['primary'], width=3)
        d.line((32, 120, 42, 110), fill=th['primary'], width=3)
        d.line((32, 120, 42, 130), fill=th['primary'], width=3)
    comp_c(img, text_img(title, 30, 'SemiBold', th['primary']), SW / 2, 120)
    if plus:
        d.line((498, 120, 520, 120), fill=th['primary'], width=3)
        d.line((509, 109, 509, 131), fill=th['primary'], width=3)


@functools.lru_cache(None)
def check_ball(dm):
    b = ball(dm, SAFFRON, (255, 228, 165), (198, 112, 0)).copy()
    ss = 4
    ov = Image.new('RGBA', (dm * ss, dm * ss), (255, 255, 255, 0))
    c = dm * ss / 2
    ImageDraw.Draw(ov).line((c - dm * 0.2 * ss, c + 0.02 * dm * ss, c - 0.05 * dm * ss, c + 0.17 * dm * ss,
                             c + 0.23 * dm * ss, c - 0.14 * dm * ss), fill=(255, 255, 255, 255),
                            width=int(dm * 0.1 * ss), joint='curve')
    b.alpha_composite(ov.resize((dm, dm), Image.LANCZOS))
    return b


@functools.lru_cache(None)
def flame_img(h):
    """Teardrop flame: yellow core, saffron edge. Point at top, round base."""
    ss = 3
    n_h, w = h * ss, int(h * 0.62) * ss
    R = w / 2
    yy, xx = np.mgrid[0:n_h, 0:w].astype(np.float32) + 0.5
    xc = xx - w / 2
    cy = n_h - R
    r = np.where(yy >= cy, np.sqrt(np.clip(R * R - (yy - cy) ** 2, 0, None)), R * np.clip(yy / cy, 0, 1) ** 1.5)
    q = np.abs(xc) / np.maximum(r, 1e-3)
    alpha = np.clip((r - np.abs(xc)) / ss, 0, 1)
    core, edge = np.array((255, 244, 190), np.float32), np.array((246, 132, 18), np.float32)
    m = np.clip(q ** 1.4 * 0.8 + (1 - yy / n_h) * 0.45, 0, 1)[..., None]
    col = core * (1 - m) + edge * m
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    return im.resize((w // ss, h), Image.LANCZOS)


def draw_flame(cv, cx, base_y, h, t, a=1.0):
    fl = 1 + 0.05 * math.sin(t * 13) + 0.03 * math.sin(t * 7.3 + 1)
    hh = max(8, int(h * fl / 4) * 4)
    comp_c(cv, glow(int(h * 1.3), (255, 170, 60)), cx, base_y - h * 0.45, a * 0.6)
    f = flame_img(hh)
    comp(cv, f, cx - f.width / 2 + math.sin(t * 5) * h * 0.02, base_y - hh, a)


@functools.lru_cache(None)
def diya_img(w):
    ss = 4
    h = int(w * 0.42)
    im = Image.new('RGBA', (w * ss, h * ss), (184, 86, 36, 0))
    d = ImageDraw.Draw(im)
    d.pieslice((0, -h * ss * 0.9, w * ss, h * ss), 0, 180, fill=(176, 80, 32))
    d.ellipse((0, -h * ss * 0.16 + h * ss * 0.04, w * ss, h * ss * 0.26), fill=(212, 116, 56))
    d.ellipse((w * ss * 0.08, h * ss * 0.0, w * ss * 0.92, h * ss * 0.2), fill=(120, 52, 18))
    d.ellipse((w * ss * 0.12, h * ss * 0.5, w * ss * 0.88, h * ss * 0.62), fill=(150, 64, 24))
    return im.resize((w, h), Image.LANCZOS)


def draw_diya(cv, cx, cy, w, t, a=1.0):
    comp_c(cv, glow(int(w * 1.1), (255, 186, 90)), cx, cy - w * 0.25, a * 0.55)
    dy = diya_img(w)
    draw_flame(cv, cx, cy - dy.height * 0.08, int(w * 0.62), t, a)
    comp(cv, dy, cx - w / 2, cy - dy.height * 0.12, a)


@functools.lru_cache(None)
def moon_img(r):
    ss = 3
    n = r * 2 * ss
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
    c = n / 2
    d1 = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
    d2 = np.sqrt((xx - c - r * ss * 0.48) ** 2 + (yy - c + r * ss * 0.22) ** 2)
    a = np.clip(r * ss - d1, 0, 1) * np.clip(d2 - r * ss * 0.86, 0, 1)
    rgba = np.zeros((n, n, 4), np.uint8)
    rgba[..., :3] = (250, 238, 206)
    rgba[..., 3] = (a * 255).astype(np.uint8)
    return Image.fromarray(rgba, 'RGBA').resize((r * 2, r * 2), Image.LANCZOS)


_srng = np.random.default_rng(42)
STARS = [(float(_srng.uniform(0, W)), float(_srng.uniform(0, H * 0.75)), int(_srng.integers(3, 9)),
          float(_srng.uniform(0, 6.28))) for _ in range(80)]


def stars(cv, t, a=1.0):
    for x, y, r, ph in STARS:
        comp_c(cv, glow(r, (225, 230, 255)), x, y, a * (0.25 + 0.75 * math.sin(t * 1.1 + ph) ** 2))


@functools.lru_cache(None)
def note_img(size, color=SAFFRON):
    ss = 4
    s = size * ss
    im = Image.new('RGBA', (s, s), color + (0,))
    d = ImageDraw.Draw(im)
    d.ellipse((s * 0.12, s * 0.62, s * 0.5, s * 0.92), fill=color)
    d.line((s * 0.47, s * 0.78, s * 0.47, s * 0.1), fill=color, width=int(s * 0.08))
    d.line((s * 0.47, s * 0.12, s * 0.8, s * 0.3), fill=color, width=int(s * 0.08))
    return im.resize((size, size), Image.LANCZOS)


def mic_glyph(d, x, y, s, col):
    d.rounded_rectangle((x - 12 * s, y - 26 * s, x + 12 * s, y + 6 * s), 12 * s, fill=col)
    d.arc((x - 20 * s, y - 14 * s, x + 20 * s, y + 18 * s), 0, 180, fill=col, width=int(4 * s))
    d.line((x, y + 18 * s, x, y + 28 * s), fill=col, width=int(4 * s))


def phone_buzz(cv, cx, cy, s, age, strong=False, dur=0.55):
    if not 0 <= age < dur:
        return
    p = age / dur
    pad = int(12 + 80 * ease_out(p))
    w, h = int(PW * s) + 2 * pad, int(PH * s) + 2 * pad
    ov = Image.new('RGBA', (w + 8, h + 8), (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle((4, 4, w + 4, h + 4), int(86 * s) + pad, outline=SAFFRON + (
        int((200 if strong else 120) * (1 - p)),), width=5 if strong else 3)
    comp_c(cv, ov, cx, cy)


# ---------------------------------------------------------------- new screens

def blackout_screen(mantra, track, t, lang):
    img = Image.new('RGBA', (SW, SH), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    comp_c(img, text_img('9:41', 26, 'SemiBold', (120, 120, 120)), 86, 46)
    for k, kind in enumerate(('eye', 'play', 'x')):
        x, y = SW / 2 + (k - 1) * 90, 156
        d.ellipse((x - 32, y - 32, x + 32, y + 32), fill=(26, 26, 26))
        col = (140, 140, 140)
        if kind == 'eye':
            d.ellipse((x - 14, y - 8, x + 14, y + 8), outline=col, width=3)
            d.line((x - 14, y + 12, x + 14, y - 12), fill=col, width=3)
        elif kind == 'play':
            d.ellipse((x - 14, y - 14, x + 14, y + 14), outline=col, width=3)
            d.polygon([(x - 4, y - 7), (x - 4, y + 7), (x + 7, y)], fill=col)
        else:
            d.line((x - 10, y - 10, x + 10, y + 10), fill=col, width=3)
            d.line((x - 10, y + 10, x + 10, y - 10), fill=col, width=3)
    n = track.val(t)
    comp_c(img, text_img(mantra, 52, "Medium", (128, 128, 128)), SW / 2, 540)
    comp_c(img, text_img(f"{n} / 108", 38, "Medium", (100, 100, 100)), SW / 2, 615)
    if t >= track.done:
        a = prog(t - track.done, 0.2, 0.6)
        comp_c(img, glow(150, (90, 70, 40)), SW / 2, 580, a * 0.5)
        comp_c(img, text_img(L10N[lang]['mala_complete'], 26, 'Medium', (150, 120, 70)), SW / 2, 670, a)
    return img


def sankalp_chooser(t, tap_t, lang):
    th, L = LIGHT, L10N[lang]
    img = Image.new('RGBA', (SW, SH), th['bg'] + (255,))
    for k, days in enumerate((11, 21, 40)):
        y = 230 + k * 160
        sel = days == 40 and t >= tap_t + 0.1
        s = 1 - 0.03 * window(t, tap_t, tap_t + 0.3, 0.1, 0.2) * (days == 40)
        comp_c(img, scaled(card_img(sel, 'light', 136), s), 24 + CARD_W / 2, y + 68)
        dt = text_img(L['days'].format(days), 46, 'Bold', th['primary'])
        comp(img, dt, 52, y + 50 - dt.height / 2)
        md = text_img(L['malas_day'], 22, 'Regular', th['secondary'])
        comp(img, md, 52, y + 100 - md.height / 2)
        if sel:
            comp_c(img, check_ball(40), 478, y + 68)
        else:
            ImageDraw.Draw(img).ellipse((458, y + 48, 498, y + 88), outline=th['track_lo'], width=3)
    screen_tap(img, 260, 230 + 2 * 160 + 68, t - tap_t)
    header(img, th, L['take_sankalp'])
    comp_c(img, text_img(L['sankalp_sub'], 22, 'Regular', th['secondary']), SW / 2, 180)
    draw_tabs(img, th, lang)
    return img


def sadhana_screen(day_track, t, lang):
    th, L = LIGHT, L10N[lang]
    img = Image.new('RGBA', (SW, SH), th['bg'] + (255,))
    d = ImageDraw.Draw(img)
    header(img, th, L['my_sadhana'])
    day = day_track.val(t)
    done = t >= day_track.done
    comp_c(img, text_img('राम राम' if lang == 'hi' else 'Ram Ram', 30, 'Medium', th['secondary']), SW / 2, 196)
    big = text_img('612', 84, 'Bold', th['primary'])
    of = text_img('/ 1,080', 36, 'Medium', th['tertiary'])
    x0 = SW / 2 - (big.width + of.width) / 2
    comp(img, big, x0, 270 - big.height / 2)
    comp(img, of, x0 + big.width, 286 - of.height / 2)
    comp_c(img, text_img(L['todays_goal'], 22, 'Regular', th['secondary']), SW / 2, 336)
    chip = rrect((270, 54), 27, (240, 235, 226))
    comp_c(img, chip, SW / 2, 398)
    comp_c(img, glow(9, SAFFRON, 1.6), SW / 2 - 104, 398)
    comp_c(img, text_img(L['streak_chip'].format(max(1, day - 1 + done)), 24, 'SemiBold', th['primary']), SW / 2 + 12, 398)

    card = rrect((500, 420), 26, (255, 241, 214), outline=SAFFRON if done else None, width=3 if done else 0)
    comp(img, card, 24, 450)
    comp_c(img, text_img(L['sankalp_title'], 21, 'SemiBold', SAFFRON_DEEP), SW / 2, 492)
    comp_c(img, text_img(L['day_x'].format(day), 48, 'Bold', th['primary']), SW / 2, 548)
    kept = day if done else day - 1
    d.rounded_rectangle((64, 604, 484, 616), 6, fill=(240, 222, 186))
    if kept > 0:
        d.rounded_rectangle((64, 604, 64 + 420 * kept / 40, 616), 6, fill=SAFFRON)
    comp_c(img, text_img(L['days_done'].format(kept), 22, 'Regular', th['secondary']), SW / 2, 650)
    on, off = ball(16, SAFFRON, (255, 228, 165), (198, 112, 0)), ball(16, (232, 214, 182), (250, 240, 222), (210, 190, 156))
    for i in range(40):
        x = SW / 2 + ((i % 20) - 9.5) * 21
        y = 700 + (i // 20) * 28
        comp_c(img, on if i < kept else off, x, y)
        if i == kept and not done:
            d.ellipse((x - 11, y - 11, x + 11, y + 11), outline=SAFFRON_DEEP, width=3)
    comp_c(img, text_img(L['sankalp_meta'], 20, 'Regular', th['tertiary']), SW / 2, 776)
    if done:
        a = prog(t - day_track.done, 0.15, 0.5)
        comp_c(img, rrect((280, 50), 25, SAFFRON), SW / 2, 830, a)
        comp_c(img, text_img(L['sankalp_complete'], 22, 'SemiBold', (255, 255, 255)), SW / 2, 830, a)
    draw_tabs(img, th, lang)
    return img


WEEK_VALUES = (7.2, 9.0, 6.1, 10.8, 8.4, 12.0, 9.6)


def progress_screen(t, t0, lang):
    th, L = LIGHT, L10N[lang]
    img = Image.new('RGBA', (SW, SH), th['bg'] + (255,))
    d = ImageDraw.Draw(img)
    header(img, th, L['progress'], back=False)
    comp_c(img, rrect((270, 54), 27, (240, 235, 226)), SW / 2, 200)
    comp_c(img, glow(9, SAFFRON, 1.6), SW / 2 - 104, 200)
    comp_c(img, text_img(L['streak_chip'].format(22), 24, 'SemiBold', th['primary']), SW / 2 + 12, 200)
    comp_c(img, text_img(L['grace'], 20, 'Regular', th['tertiary']), SW / 2, 250)

    comp(img, card_img(False, 'light', 220), -6, 260)
    lab = text_img(L['todays_jaap'], 22, 'Regular', th['secondary'])
    comp(img, lab, 52, 318 - lab.height / 2)
    frac = ease_out(prog(t, t0 + 0.3, t0 + 1.6))
    n = int(612 * frac)
    big = text_img(f'{n}', 72, 'Bold', th['primary'])
    comp(img, big, 50, 370 - big.height / 2)
    g = text_img(L['goal_of'], 26, 'Medium', th['tertiary'])
    comp(img, g, 50 + big.width + 4, 384 - g.height / 2)
    d.rounded_rectangle((52, 430, 496, 442), 6, fill=th['track'])
    if n:
        d.rounded_rectangle((52, 430, 52 + 444 * n / 1080, 442), 6, fill=SAFFRON)
    md = text_img(L['malas_done'], 22, 'Regular', th['secondary'])
    comp(img, md, 52, 470 - md.height / 2)

    for k, lab in enumerate(L['periods']):
        x = 24 + k * 125 + 62
        if k == 1:
            comp_c(img, rrect((118, 52), 26, (23, 23, 23)), x, 548)
        comp_c(img, text_img(lab, 21, 'Medium', (255, 255, 255) if k == 1 else th['secondary']), x, 548)

    comp(img, card_img(False, 'light', 400), -6, 580)
    wl = text_img(L['weekly_jaap'], 24, 'SemiBold', th['primary'])
    comp(img, wl, 52, 640 - wl.height / 2)
    total = int(8064 * ease_out(prog(t, t0 + 0.5, t0 + 2.2)))
    tv = text_img(f'{total:,}', 24, 'SemiBold', th['primary'])
    comp(img, tv, 496 - tv.width, 640 - tv.height / 2)
    for i, v in enumerate(WEEK_VALUES):
        h = 230 * v / 12 * ease_out(prog(t, t0 + 0.5 + i * 0.1, t0 + 1.3 + i * 0.1))
        x = 84 + i * 63
        if h > 2:
            d.rounded_rectangle((x - 17, 930 - h, x + 17, 930), 8, fill=SAFFRON if i == 6 else (247, 200, 120))
        comp_c(img, text_img(L['week'][i], 20, 'Medium', th['tertiary']), x, 956)
    draw_tabs(img, th, lang, active=1)
    return img


TYPED = ['रा', 'धे', ' ', 'रा', 'धे']
KEYS = ['क ख ग घ च छ ज झ ट ठ', 'ड ढ त थ द ध न प फ', 'ब भ म य र ल व स ह']
TYPED_KEYS = ['र', 'ध', ' ', 'र', 'ध']


def add_mantra_screen(t, t0, save_t, lang, typed_clusters=None, size_sel=0):
    """Type a mantra from t0 (one cluster every 0.4s; default 'राधे राधे'), Save tapped at save_t."""
    clusters = typed_clusters or TYPED
    th, L = LIGHT, L10N[lang]
    img = Image.new('RGBA', (SW, SH), th['bg'] + (255,))
    d = ImageDraw.Draw(img)
    header(img, th, L['add_mantra'])
    ml = text_img(L['mantra_label'], 22, 'Medium', th['secondary'])
    comp(img, ml, 36, 196 - ml.height / 2)
    comp(img, rrect((500, 110), 22, (255, 255, 255), outline=SAFFRON, width=3), 24, 220)
    k = clamp(int((t - t0) / 0.4) + 1 if t >= t0 else 0, 0, len(clusters))
    typed = ''.join(clusters[:k])
    x_end = 52
    if typed.strip():
        ti = text_img(typed, 46, 'Bold', th['primary'])
        comp(img, ti, 48, 275 - ti.height / 2)
        x_end = 48 + ti.width - 6
    if int(t * 2.2) % 2 == 0 and t < save_t:
        d.rectangle((x_end, 252, x_end + 3, 298), fill=SAFFRON_DEEP)
    sl = text_img(L['mala_size'], 22, 'Medium', th['secondary'])
    comp(img, sl, 36, 376 - sl.height / 2)
    x = 24
    for j, lab in enumerate(('108', '54', '27', L['custom'])):
        on = j == size_sel
        tw = text_img(lab, 24, 'SemiBold', SAFFRON_DEEP if on else th['secondary'])
        w = max(96, tw.width + 36)
        chip = rrect((w, 56), 28, th['soft'] if on else (255, 255, 255),
                     outline=SAFFRON if on else th['divider'], width=2)
        comp(img, chip, x, 404)
        comp_c(img, tw, x + w / 2, 432)
        x += w + 14
    s = 1 - 0.04 * window(t, save_t, save_t + 0.3, 0.08, 0.2)
    comp_c(img, scaled(rrect((500, 86), 24, SAFFRON), s), SW / 2, 540)
    comp_c(img, text_img(L['save'], 30, 'SemiBold', (255, 255, 255)), SW / 2, 540)
    screen_tap(img, SW / 2 + 40, 540, t - save_t)

    ky = SH - 440
    d.rectangle((0, ky, SW, SH), fill=(212, 215, 222))
    press = None
    if t0 <= t < t0 + 0.4 * len(clusters) and (t - t0) % 0.4 < 0.16:
        c0 = clusters[int((t - t0) / 0.4)][0]
        allkeys = ' '.join(KEYS).split()
        press = c0 if (c0 in allkeys or c0 == ' ') else allkeys[ord(c0) % len(allkeys)]
    for r, row in enumerate(KEYS):
        keys = row.split()
        x0 = (SW - len(keys) * 51 + 5) / 2
        for c, ch in enumerate(keys):
            kx, kyy = x0 + c * 51, ky + 20 + r * 86
            fill = (170, 175, 186) if ch == press else (255, 255, 255)
            d.rounded_rectangle((kx, kyy, kx + 46, kyy + 74), 9, fill=fill)
            comp_c(img, text_img(ch, 28, 'Medium', th['primary']), kx + 23, kyy + 37)
    sp_fill = (170, 175, 186) if press == ' ' else (255, 255, 255)
    d.rounded_rectangle((120, ky + 280, SW - 120, ky + 354), 9, fill=sp_fill)
    d.rounded_rectangle((SW / 2 - 70, SH - 26, SW / 2 + 70, SH - 18), 4, fill=(30, 30, 30))
    return img


def now_playing_card(t, lang, rec_sel=False):
    L = L10N[lang]
    w, h = 920, 400
    pad = 50
    im = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    comp(im, soft_shadow(w, h, 44, 20, 140), pad - 60, pad - 46)
    im.alpha_composite(rrect((w, h), 44, (255, 248, 238)), (pad, pad))
    d = ImageDraw.Draw(im)
    ox, oy = pad, pad
    comp_c(im, ball(96, SAFFRON, (255, 214, 140), (210, 120, 0)), ox + 92, oy + 92)
    comp_c(im, note_img(48, (255, 255, 255)), ox + 92, oy + 92)
    npl = text_img(L['now_playing'], 24, 'SemiBold', SAFFRON_DEEP)
    comp(im, npl, ox + 166, oy + 66 - npl.height / 2)
    tt = text_img('Morning on the High Plateau', 40, 'Bold', INK)
    comp(im, tt, ox + 166, oy + 110 - tt.height / 2)
    comp_c(im, ball(84, SAFFRON, (255, 214, 140), (210, 120, 0)), ox + 830, oy + 92)
    d.rounded_rectangle((ox + 818, oy + 76, ox + 826, oy + 108), 3, fill=(255, 255, 255))
    d.rounded_rectangle((ox + 834, oy + 76, ox + 842, oy + 108), 3, fill=(255, 255, 255))
    frac = (t * 0.035) % 1
    for i in range(40):
        hh = 8 + 46 * abs(math.sin(i * 0.7 + t * 3.1) * math.sin(i * 0.31 + t * 1.7))
        x = ox + 58 + i * 20.6
        col = SAFFRON if i / 40 < frac + 0.25 else (236, 216, 190)
        d.rounded_rectangle((x - 4, oy + 222 - hh / 2, x + 4, oy + 222 + hh / 2), 4, fill=col)
    x = ox + 40
    for j, lab in enumerate(('Still Waters', 'Inner Peace', L['your_recording'])):
        sel = rec_sel and j == 2
        tw = text_img(lab, 24, 'SemiBold', (255, 255, 255) if sel else INK)
        cw = tw.width + (76 if j == 2 else 44)
        comp(im, rrect((cw, 58), 29, SAFFRON if sel else (255, 234, 204)), x, oy + 300)
        if j == 2:
            mic_glyph(d, x + 30, oy + 334, 0.6, (255, 255, 255) if sel else SAFFRON_DEEP)
            comp(im, tw, x + 52, oy + 329 - tw.height / 2)
        else:
            comp_c(im, tw, x + cw / 2, oy + 329)
        x += cw + 16
    return im


def recording_panel(cv, t, t0, cx, cy, lang, a):
    if a <= 0:
        return
    L = L10N[lang]
    for k in range(3):
        p = ((t - t0) * 0.7 + k / 3) % 1
        rr = 90 + 120 * p
        ov = Image.new('RGBA', (int(rr * 2 + 8),) * 2, (0, 0, 0, 0))
        ImageDraw.Draw(ov).ellipse((4, 4, rr * 2 + 4, rr * 2 + 4), outline=SAFFRON + (int(160 * (1 - p)),), width=4)
        comp_c(cv, ov, cx, cy, a)
    comp_c(cv, glow(160, SAFFRON), cx, cy, a * 0.5)
    comp_c(cv, ball(170, SAFFRON, (255, 214, 140), (210, 110, 0)), cx, cy, a)
    ov = Image.new('RGBA', (120, 120), (0, 0, 0, 0))
    mic_glyph(ImageDraw.Draw(ov), 60, 62, 1.5, (255, 255, 255))
    comp_c(cv, ov, cx, cy, a)
    secs = int(max(0, t - t0)) + 1
    comp_c(cv, text_img(f'0:{secs:02d}', 46, 'Bold', CREAM_TEXT), cx, cy + 170, a)
    comp_c(cv, text_img(L['recording'], 30, 'Medium', (210, 200, 220)), cx, cy + 230, a)


def sound_rings(cv, t, cx, cy, a):
    for k in range(4):
        p = (t * 0.45 + k / 4) % 1
        rr = 60 + 460 * p
        ov = Image.new('RGBA', (int(rr * 2 + 8),) * 2, (0, 0, 0, 0))
        ImageDraw.Draw(ov).ellipse((4, 4, rr * 2 + 4, rr * 2 + 4), outline=SAFFRON + (int(130 * (1 - p) ** 1.5),), width=3)
        comp_c(cv, ov, cx, cy, a)


_nrng = np.random.default_rng(5)
NOTES = [(float(_nrng.uniform(80, W - 80)), float(_nrng.uniform(0, H)), int(_nrng.integers(40, 90)),
          float(_nrng.uniform(40, 90)), float(_nrng.uniform(0, 6.28))) for _ in range(12)]


def caption_clear(y):
    """Fade decorative elements out of the caption band so text stays legible."""
    return 0.12 + 0.88 * clamp((abs(y - 335) - 150) / 90)


def floating_notes(cv, t, a):
    for x, y0, sz, sp, ph in NOTES:
        y = (y0 - sp * t) % (H + 200) - 100
        comp_c(cv, note_img(sz), x + 30 * math.sin(t * 0.8 + ph), y,
               a * caption_clear(y) * (0.35 + 0.4 * math.sin(t + ph) ** 2))


_frng = np.random.default_rng(9)
FLOAT_POS = [(float(_frng.uniform(140, W - 140)), float(_frng.uniform(0, H + 300)), int(_frng.integers(46, 104)),
              float(_frng.uniform(28, 60)), float(_frng.uniform(0, 6.28))) for _ in FLOATING]


def floating_mantras(cv, t, a):
    for (x, y0, sz, sp, ph), txt in zip(FLOAT_POS, FLOATING):
        y = (y0 + sp * t) % (H + 300) - 150
        col = SAFFRON_DEEP if (sz % 3 == 0) else (120, 86, 60)
        comp_c(cv, text_img(txt, sz, 'SemiBold', col), x + 20 * math.sin(t * 0.5 + ph), y,
               a * caption_clear(y) * (0.25 + 0.35 * math.sin(t * 0.7 + ph) ** 2))


def week_card(n, taps, lang):
    L = L10N[lang]
    w, h = 920, 370
    pad = 50
    im = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    comp(im, soft_shadow(w, h, 40, 18, 80), pad - 54, pad - 44)
    im.alpha_composite(rrect((w, h), 40, (255, 255, 255)), (pad, pad))
    ox, oy = pad, pad
    comp_c(im, ball(92, SAFFRON, (255, 214, 140), (210, 120, 0)), ox + 90, oy + 86)
    f = flame_img(50)
    comp(im, f, ox + 90 - f.width / 2, oy + 60)
    sl = text_img(L['streak_label'], 24, 'SemiBold', SAFFRON_DEEP)
    comp(im, sl, ox + 160, oy + 62 - sl.height / 2)
    phrase = 'Day 1 of your streak' if (lang == 'en' and n <= 1) else L['in_a_row'].format(max(n, 1))
    tt = text_img(phrase, 44, 'Bold', INK)
    comp(im, tt, ox + 160, oy + 106 - tt.height / 2)
    ages = {k: age for age, k in taps}
    d = ImageDraw.Draw(im)
    for i in range(7):
        x, y = ox + 100 + i * 120, oy + 236
        if i < n:
            age = ages.get(i + 1)
            sc = 1.0 if age is None else 0.6 + 0.4 * ease_back(clamp(age / 0.3), 2.5)
            comp_c(im, scaled(check_ball(86), sc), x, y)
        else:
            d.ellipse((x - 41, y - 41, x + 41, y + 41), outline=(226, 222, 214), width=4)
        comp_c(im, text_img(L['week'][i], 26, 'Medium', (128, 120, 112)), x, oy + 318)
    return im


# ---------------------------------------------------------------- 06 chant in the dark

TX6 = {'en': dict(a='Chanting at night?', b='Bright screens\n*break the calm.*', c='Blackout mode.\n*Pure black screen.*',
                  d='Eyes closed.\n*Every tap still counts.*', e='A gentle buzz\n*on every bead.*',
                  end='Chant in the dark.\n*Never lose count.*'),
       'hi': dict(a='रात में जाप?', b='तेज़ रोशनी\n*ध्यान भंग करती है।*', c='अंधकार मोड।\n*पूरी काली स्क्रीन।*',
                  d='आँखें बंद।\n*हर टैप गिना जाता है।*', e='हर मनके पर\n*हल्का कंपन।*',
                  end='अंधेरे में जाप।\n*गिनती कभी न भूलें।*')}
V6T = Track([(11.8, 0, 'lin'), (13.4, 4, 'lin'), (16.6, 108, 'inout')])


def v6(t, lang):
    X = TX6[lang]
    mantra = 'राम राम' if lang == 'hi' else 'Ram Ram'
    cv = base('night')
    dark_room = ease_in_out(prog(t, 8.2, 9.2))
    glare = ease_out(prog(t, 3.4, 4.6)) * (1 - dark_room)
    stars(cv, t, 1 - 0.7 * glare)
    comp_c(cv, glow(200, (200, 200, 255)), 950, 500, 0.25 * (1 - glare))
    comp_c(cv, moon_img(64), 950, 500, 1 - 0.6 * glare)
    if glare > 0:
        comp_c(cv, glow(900, (235, 240, 255)), 540, PHONE_CY, 0.55 * glare)
    draw_caption(cv, t, 0.2, 3.2, X['a'], size=86, dark=True)

    if 3.0 <= t < 17.6:
        enter = ease_out(prog(t, 3.0, 4.0))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        out = ease_in_out(prog(t, 16.9, 17.5))
        s, pa = lerp(1, 0.9, out), 1 - out
        cnt = counter_screen(LIGHT, mantra, V6T, t, lang=lang, toolbar=True)
        bx, by = tool_pos(3)
        screen_tap(cnt, bx, by, t - 7.9)
        scr = Image.blend(cnt, blackout_screen(mantra, V6T, t, lang), dark_room) if dark_room > 0 else cnt
        if dark_room >= 1:
            scr = blackout_screen(mantra, V6T, t, lang)
        draw_phone(cv, scr, 540, cy, s, pa)
        for age, k in V6T.taps(t, 0.55):
            phone_buzz(cv, 540, cy, s, age)
        phone_buzz(cv, 540, cy, s, t - V6T.done, strong=True, dur=0.9)
        phone_buzz(cv, 540, cy, s, t - V6T.done - 0.25, strong=True, dur=0.9)
    draw_caption(cv, t, 3.4, 7.7, X['b'], dark=True)
    draw_caption(cv, t, 8.0, 11.5, X['c'], dark=True)
    draw_caption(cv, t, 11.6, 14.6, X['d'], dark=True)
    draw_caption(cv, t, 14.6, 17.0, X['e'], dark=True)
    if t >= 17.3:
        end_card(cv, t - 17.3, X['end'], dark=True, lang=lang)
    return finish(cv, t, 22.0, 1.0, to='night')


# ---------------------------------------------------------------- 07 sankalp

TX7 = {'en': dict(a='A promise\n*to yourself.*', b='Take a Sankalp.\n*11, 21 or 40 days.*', c='Show up\n*every day.*',
                  d='Day by day,\n*bead by bead.*', e='*Sankalp complete.*', end='Take a Sankalp.\n*Keep it.*'),
       'hi': dict(a='स्वयं से\n*एक वचन।*', b='संकल्प लें।\n*11, 21 या 40 दिन।*', c='हर दिन\n*साधना करें।*',
                  d='दिन-ब-दिन,\n*मनका-दर-मनका।*', e='*संकल्प पूर्ण।*', end='संकल्प लें।\n*निभाएँ।*')}
V7D = Track([(6.0, 1, 'lin'), (8.0, 4, 'lin'), (13.0, 23, 'inout'), (15.8, 40, 'inout')])


def v7(t, lang):
    X = TX7[lang]
    cv = base('light')
    particles(cv, t, 0.7)
    da = window(t, 0.0, 3.6, 0.5, 0.6)
    if da > 0:
        draw_diya(cv, 540, 1180, 420, t, da)
    draw_caption(cv, t, 0.2, 3.2, X['a'], size=86)
    if 3.0 <= t < 18.5:
        enter = ease_out(prog(t, 3.0, 4.0))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        out = ease_in_out(prog(t, 17.8, 18.4))
        s, pa = lerp(1, 0.9, out), 1 - out
        if t < 5.5:
            scr = sankalp_chooser(t, 5.0, lang)
        elif t < 5.9:
            scr = slide(sankalp_chooser(t, 5.0, lang), sadhana_screen(V7D, t, lang), prog(t, 5.5, 5.9))
        else:
            scr = sadhana_screen(V7D, t, lang)
        draw_phone(cv, scr, 540, cy, s, pa)
        burst(cv, t - V7D.done, 540, cy - PH / 2 + BZ + 600)
    draw_caption(cv, t, 3.2, 7.8, X['b'])
    draw_caption(cv, t, 7.8, 12.8, X['c'])
    draw_caption(cv, t, 12.8, 15.8, X['d'])
    draw_caption(cv, t, 15.8, 18.0, X['e'], size=88)
    if t >= 18.3:
        particles(cv, t, 0.4)
        end_card(cv, t - 18.3, X['end'], lang=lang)
    return finish(cv, t, 22.5, 1.0)


# ---------------------------------------------------------------- 08 daily habit

TX8 = {'en': dict(a='Day 1.', b='One mala\n*a day.*', c='Becomes\n*a habit.*', d='Watch your\n*Sadhana grow.*',
                  end='Every day.\n*Every bead counts.*'),
       'hi': dict(a='पहला दिन।', b='रोज़\n*एक माला।*', c='बन जाती है\n*आदत।*', d='अपनी साधना को\n*बढ़ते देखें।*',
                  end='हर दिन।\n*हर मनका मायने रखता है।*')}
W8 = Track([(3.6, 0, 'lin'), (7.2, 7, 'lin')])
S8 = Track([(8.6, 7, 'lin'), (12.0, 22, 'inout')])


def v8(t, lang):
    X = TX8[lang]
    L = L10N[lang]
    cv = base('light')
    particles(cv, t, 0.6)
    ha = window(t, 0.1, 3.0, 0.4, 0.4)
    if ha > 0:
        draw_flame(cv, 540, 840, 200, t, ha)
        rise = (1 - ease_out(prog(t, 0.1, 0.8))) * 40
        comp_c(cv, text_img(X['a'], 190, 'Bold', INK), 540, 1060 + rise, ha)
    wa = prog(t, 3.0, 3.5) * (1 - prog(t, 8.0, 8.5))
    if wa > 0:
        s = ease_back(prog(t, 3.0, 3.5)) if t < 3.5 else 1.0
        card = week_card(W8.val(t), W8.taps(t, 0.35), lang)
        comp_c(cv, scaled(card, max(0.05, s)), 540, 1150 - 120 * ease_in(prog(t, 8.0, 8.5)), wa)
    sa = prog(t, 8.3, 8.8) * (1 - prog(t, 12.8, 13.3))
    if sa > 0:
        n = S8.val(t)
        pop = 1.0
        tp = S8.taps(t, 0.2)
        if tp:
            pop = 1 + 0.06 * (1 - tp[-1][0] / 0.2)
        if t >= S8.done:
            pop = 1 + 0.12 * math.exp(-(t - S8.done) * 4) * math.sin((t - S8.done) * 18 + 1.57)
        draw_flame(cv, 540, 930, int(260 * (1 + 0.15 * (n - 7) / 15)), t, sa)
        comp_c(cv, scaled(text_img(str(n), 260, 'Bold', INK), pop), 540, 1170, sa)
        comp_c(cv, text_img(L['day_streak'], 60, 'SemiBold', ACCENT_ON_LIGHT), 540, 1360, sa)
        burst(cv, t - S8.done, 540, 1100)
    if 12.8 <= t < 18.5:
        enter = ease_out(prog(t, 12.8, 13.8))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        out = ease_in_out(prog(t, 17.8, 18.4))
        draw_phone(cv, progress_screen(t, 13.3, lang), 540, cy, lerp(1, 0.9, out), 1 - out)
    draw_caption(cv, t, 3.2, 8.0, X['b'])
    draw_caption(cv, t, 8.2, 12.8, X['c'])
    draw_caption(cv, t, 13.0, 18.0, X['d'])
    if t >= 18.3:
        particles(cv, t, 0.4)
        end_card(cv, t - 18.3, X['end'], lang=lang)
    return finish(cv, t, 22.5, 1.0)


# ---------------------------------------------------------------- 09 mantras

TX9 = {'en': dict(a='Every devotee\n*has a mantra.*', b='21 sacred\n*mantras.*', c='Or add your own,\n*in any script.*',
                  d='You chant.\n*We count.*', end='Your mantra.\n*Your way.*'),
       'hi': dict(a='हर भक्त का\n*अपना मंत्र।*', b='21 पवित्र\n*मंत्र।*', c='या अपना मंत्र जोड़ें,\n*किसी भी लिपि में।*',
                  d='आप जाप करें,\n*गिनती हम करेंगे।*', end='आपका मंत्र,\n*आपका तरीका।*')}
V9T = Track([(13.0, 0, 'lin'), (14.4, 4, 'lin'), (17.4, 108, 'inout')])


def v9(t, lang):
    X = TX9[lang]
    cv = base('light')
    floating_mantras(cv, t, 1.0 - 0.75 * ease_in_out(prog(t, 3.0, 4.0)))
    particles(cv, t, 0.4)
    draw_caption(cv, t, 0.2, 3.3, X['a'], size=86)
    items = ALL_MANTRAS if lang == 'en' else [(dv, None) for _, dv in ALL_MANTRAS]
    if 3.0 <= t < 18.6:
        enter = ease_out(prog(t, 3.0, 4.0))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        out = ease_in_out(prog(t, 17.9, 18.5))
        s, pa = lerp(1, 0.9, out), 1 - out
        max_scroll = CARD_Y0 + len(items) * (CARD_H + CARD_GAP) - SH + 40
        scroll = max_scroll * ease_in_out(prog(t, 4.2, 7.6))
        lst = list_screen(scroll, 0, -1, 0, LIGHT, lang, items)
        if t < 8.0:
            scr = lst
        elif t < 12.3:
            scr = slide(lst, add_mantra_screen(t, 8.7, 11.8, lang), prog(t, 8.0, 8.4))
        else:
            cnt = counter_screen(LIGHT, 'राधे राधे', V9T, t, lang=lang, falling=True)
            scr = slide(add_mantra_screen(t, 8.7, 11.8, lang), cnt, prog(t, 12.3, 12.7))
        draw_phone(cv, scr, 540, cy, s, pa)
        burst(cv, t - V9T.done, 540, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 3.3, 8.0, X['b'])
    draw_caption(cv, t, 8.0, 13.0, X['c'])
    draw_caption(cv, t, 13.0, 18.0, X['d'])
    if t >= 18.3:
        particles(cv, t, 0.4)
        end_card(cv, t - 18.3, X['end'], lang=lang)
    return finish(cv, t, 22.5, 1.0)


# ---------------------------------------------------------------- 10 music

TX10 = {'en': dict(a='Find your calm.', b='Chant with\n*calming music.*', c='Or record\n*your own voice.*',
                   d='Chant. Breathe.\n*Be at peace.*', end='Peace in\n*every bead.*'),
        'hi': dict(a='अपनी शांति पाएँ।', b='शांत संगीत के\n*साथ जाप करें।*', c='या अपनी आवाज़\n*रिकॉर्ड करें।*',
                   d='जाप करें, साँस लें,\n*शांत रहें।*', end='हर मनके में\n*शांति।*')}
V10T = Track([(13.8, 0, 'lin'), (15.0, 3, 'lin'), (17.4, 108, 'inout')])


def v10(t, lang):
    X = TX10[lang]
    mantra = 'राम राम' if lang == 'hi' else 'Ram Ram'
    cv = base('navy')
    stars(cv, t, 0.35)
    ra = window(t, 0.0, 3.6, 0.6, 0.6)
    if ra > 0:
        sound_rings(cv, t, 540, 1080, ra)
    floating_notes(cv, t, 1 - 0.6 * prog(t, 12.8, 13.6))
    draw_caption(cv, t, 0.2, 3.2, X['a'], size=86, dark=True)
    ca = prog(t, 3.0, 3.5) * (1 - prog(t, 12.6, 13.2))
    if ca > 0:
        s = ease_back(prog(t, 3.0, 3.5)) if t < 3.5 else 1.0
        y = lerp(1060, 780, ease_in_out(prog(t, 8.0, 8.6)))
        card = now_playing_card(t, lang, rec_sel=t >= 8.7)
        comp_c(cv, scaled(card, max(0.05, s)), 540, y, ca)
        if 8.6 <= t < 9.3:
            # tap on the "Your recording" chip
            comp_c(cv, glow(60, SAFFRON), 540 + 100, y + 129, (1 - (t - 8.6) / 0.7) * 0.7)
        recording_panel(cv, t, 9.0, 540, 1300, lang, prog(t, 9.0, 9.5) * (1 - prog(t, 12.6, 13.2)))
    if 12.8 <= t < 18.6:
        enter = ease_out(prog(t, 12.8, 13.8))
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        out = ease_in_out(prog(t, 17.9, 18.5))
        s, pa = lerp(1, 0.9, out), 1 - out
        scr = counter_screen(NIGHT, mantra, V10T, t, lang=lang, toolbar=True, active_tool=0)
        draw_phone(cv, scr, 540 + phone_shake(V10T, t), cy, s, pa)
        burst(cv, t - V10T.done, 540, RCY + BZ - PH / 2 + cy)
    draw_caption(cv, t, 3.3, 8.0, X['b'], dark=True)
    draw_caption(cv, t, 8.0, 12.8, X['c'], dark=True)
    draw_caption(cv, t, 13.0, 18.0, X['d'], dark=True)
    if t >= 18.3:
        end_card(cv, t - 18.3, X['end'], dark=True, lang=lang)
    return finish(cv, t, 22.5, 1.0, to='navy')


FEATURE_VIDEOS = [
    (6, 'chant_in_the_dark', 22.0, v6, [(V6T, 'buzz')], [(V6T.done, 392.0, 0.6)]),
    (7, 'take_a_sankalp', 22.5, v7, [(V7D, 'tick')], [(V7D.done, 523.25, 0.85)]),
    (8, 'build_a_daily_habit', 22.5, v8, [(W8, 'pop'), (S8, 'tick')], [(7.2, 784.0, 0.4), (S8.done, 523.25, 0.8)]),
    (9, 'your_mantra_your_way', 22.5, v9, [(V9T, 'tap')], [(V9T.done, 523.25, 0.85)]),
    (10, 'chant_with_calming_music', 22.5, v10, [(V10T, 'tap')], [(V10T.done, 523.25, 0.85)]),
]

FEATURE_CUES = {
    6: [(0.1, 'whoosh', 0.45, 0, {}), (0.3, 'shimmer', 0.5, 0, dict(dur=2.6, density=7, seed=41)),
        (3.0, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)), (3.4, 'whoosh', 0.35, 0, dict(dur=1.4, peak=0.8, seed=42)),
        (7.9, 'tap', 0.75, 0, dict(seed=3)), (8.2, 'whoosh', 0.55, 0, dict(dur=1.1, peak=0.2, seed=43)),
        (8.4, 'bell', 0.3, 0, dict(f=196.0)), (11.55, 'whoosh', 0.3, 0, dict(dur=0.5, seed=4)),
        (14.55, 'whoosh', 0.3, 0, dict(dur=0.5, seed=3)), (16.9, 'whoosh', 0.6, 0, dict(dur=0.8, seed=6)),
        (17.4, 'chime', 0.6, 0, {})],
    7: [(0.1, 'whoosh', 0.5, 0, {}), (0.25, 'whoosh', 0.3, 0, dict(dur=0.5, peak=0.2, seed=44)),
        (0.3, 'shimmer', 0.6, 0, dict(dur=2.2, density=9, seed=45)),
        (3.0, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)), (5.0, 'tap', 0.75, 0, dict(seed=2)),
        (5.5, 'swipe', 0.7, 0.2, {}), (7.75, 'whoosh', 0.3, 0, dict(dur=0.5, seed=4)),
        (12.75, 'whoosh', 0.3, 0, dict(dur=0.5, seed=3)), (17.8, 'whoosh', 0.6, 0, dict(dur=0.8, seed=6)),
        (18.4, 'chime', 0.7, 0, {})],
    8: [(0.1, 'pop', 0.6, 0, {}), (0.15, 'bell', 0.3, 0, dict(f=392.0)),
        (3.0, 'whoosh', 0.7, 0, dict(dur=0.8, seed=2)), (8.0, 'whoosh', 0.6, 0, dict(dur=0.8, seed=46)),
        (12.8, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)), (13.8, 'shimmer', 0.6, 0, dict(dur=1.6, density=14, seed=47)),
        (17.8, 'whoosh', 0.6, 0, dict(dur=0.8, seed=6)), (18.4, 'chime', 0.7, 0, {})],
    9: [(0.1, 'shimmer', 0.6, 0, dict(dur=3.0, density=8, seed=48)), (0.2, 'whoosh', 0.4, 0, {}),
        (3.0, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)), (4.2, 'whoosh', 0.25, 0, dict(dur=3.2, peak=0.5, seed=49)),
        (8.0, 'swipe', 0.7, 0.2, {}), *[(8.7 + k * 0.4, 'key', 0.55, 0, dict(seed=k)) for k in range(5)],
        (11.8, 'tap', 0.75, 0, dict(seed=5)), (12.3, 'swipe', 0.7, 0.2, dict(seed=12)),
        (17.9, 'whoosh', 0.6, 0, dict(dur=0.8, seed=6)), (18.4, 'chime', 0.7, 0, {})],
    10: [(0.1, 'bell', 0.35, 0, dict(f=261.6)), (0.3, 'shimmer', 0.6, 0, dict(dur=2.6, density=8, seed=50)),
         (3.0, 'whoosh', 0.6, 0, dict(dur=0.8, seed=2)), (3.1, 'pop', 0.5, 0, {}),
         (8.0, 'whoosh', 0.3, 0, dict(dur=0.6, seed=4)), (8.6, 'tap', 0.75, 0.3, dict(seed=1)),
         (9.0, 'ping', 0.5, 0, {}), (12.8, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)),
         (17.9, 'whoosh', 0.6, 0, dict(dur=0.8, seed=6)), (18.4, 'chime', 0.7, 0, {})],
}


VIDEOS = {
    1: dict(name='01_stop_counting_start_chanting', dur=22.0, render=v1, track=V1T),
    2: dict(name='02_lose_count_while_chanting', dur=23.0, render=v2, track=V2T),
    3: dict(name='03_your_mala_always_with_you', dur=25.0, render=v3, track=V3T),
    4: dict(name='04_108_every_day', dur=23.0, render=v4, track=V4T),
    5: dict(name='05_daily_jaap_made_simple', dur=25.0, render=v5, track=V5T),
}


for _vid, _slug, _dur, _fn, _tracks, _bells in FEATURE_VIDEOS:
    for _off, _lang in ((0, 'en'), (5, 'hi')):
        VIDEOS[_vid + _off] = dict(name=f'{_vid + _off:02d}_{_slug}' + ('_hi' if _lang == 'hi' else ''), dur=_dur,
                                   render=functools.partial(_fn, lang=_lang), tracks=_tracks, bells=_bells)


# ---------------------------------------------------------------- audio
# Sound design only (no music bed): taps, whooshes, pops, sparkles, bells.

SR = 48000
PENTA = (2093.0, 2349.3, 2637.0, 3136.0, 3520.0, 4186.0)


def _t(dur):
    return np.arange(int(SR * dur)) / SR


def env(t, attack, decay):
    return np.clip(t / attack, 0, 1) * np.exp(-t * decay)


def lowpass(x, cutoff):
    """One-pole lowpass; cutoff may vary per sample."""
    a = 1 - np.exp(-2 * np.pi * np.broadcast_to(np.asarray(cutoff, float), x.shape) / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a[i] * (x[i] - acc)
        y[i] = acc
    return y


def noise(n, seed):
    return np.random.default_rng(seed).standard_normal(n)


def glide(f0, f1, dur, decay, attack=0.002):
    t = _t(dur)
    f = f0 * (f1 / f0) ** (t / dur)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * env(t, attack, decay)


def marimba(f, dur=0.6, decay=9.0):
    t = _t(dur)
    return (np.sin(2 * np.pi * f * t) + 0.25 * np.sin(2 * np.pi * 4 * f * t) * np.exp(-t * 40)) * env(t, 0.002, decay)


def snd_tap(seed):
    """Soft 'haptic' tok: low thump + wooden knock + tiny click."""
    t = _t(0.1)
    thump = np.sin(2 * np.pi * np.cumsum(150 + 90 * np.exp(-t * 60)) / SR) * env(t, 0.001, 45)
    knock = np.sin(2 * np.pi * 1150 * t) * env(t, 0.001, 70)
    n = noise(len(t), seed)
    click = (n - lowpass(n, 2500)) * env(t, 0.0003, 400)
    return 0.9 * thump + 0.35 * knock + 0.25 * click


def snd_whoosh(dur=0.7, peak=0.45, seed=1):
    t = _t(dur)
    ph = t / dur
    cut = 250 + 5200 * np.sin(np.pi * ph) ** 2
    n = noise(len(t), seed)
    y = lowpass(lowpass(n, cut), cut)
    y -= lowpass(y, 120)
    y /= np.sqrt(np.mean(y ** 2)) + 1e-9
    e = np.where(ph < peak, (ph / peak) ** 2, ((1 - ph) / (1 - peak)) ** 1.6)
    return 0.35 * y * e


def snd_shimmer(dur, density=22, seed=3):
    """Stereo sparkle: scattered high pentatonic bell pings."""
    rng = np.random.default_rng(seed)
    out = np.zeros((int(SR * (dur + 0.5)), 2))
    t = _t(0.45)
    for _ in range(int(dur * density)):
        f = rng.choice(PENTA) * rng.choice((1, 1, 0.5))
        s = np.sin(2 * np.pi * f * t) * env(t, 0.002, 11) * rng.uniform(0.3, 1)
        i = int(rng.uniform(0, dur) * SR)
        pan = rng.uniform(-0.8, 0.8)
        out[i:i + len(s), 0] += s * math.cos((pan + 1) * math.pi / 4)
        out[i:i + len(s), 1] += s * math.sin((pan + 1) * math.pi / 4)
    fade = np.minimum(1, np.minimum(np.arange(len(out)) / (0.3 * SR), 1))
    return 0.12 * out * fade[:, None]


def snd_bell(f=523.25, dur=4.5):
    t = _t(dur)
    out = np.zeros_like(t)
    for m, a, dk in ((1.0, 1.0, 0.9), (1.003, 0.6, 0.9), (2.0, 0.5, 1.4), (3.0, 0.28, 2.2), (5.04, 0.12, 3.4)):
        out += a * np.sin(2 * np.pi * f * m * t) * np.exp(-t * dk)
    return out * np.clip(t / 0.003, 0, 1) / 2.4


def snd_boom():
    t = _t(3.2)
    body = np.sin(2 * np.pi * np.cumsum(46 + 50 * np.exp(-t * 7)) / SR) * env(t, 0.01, 1.3)
    n = noise(len(t), 9)
    rumble = lowpass(lowpass(n, 180), 180) * env(t, 0.004, 5) * 4
    return 0.8 * body + 0.3 * rumble


def snd_chime():
    out = np.zeros(int(SR * 4.5))
    for k, f in enumerate((1046.5, 1318.5, 1568.0, 2093.0)):
        s = marimba(f, 1.4, 4.5) * 0.45
        i = int(k * 0.09 * SR)
        out[i:i + len(s)] += s
    b = snd_bell(523.25) * 0.6
    out[:len(b)] += b
    return out


def snd_pop(up=True):
    return glide(480, 1100, 0.1, 38) if up else glide(1100, 480, 0.1, 38)


def snd_tick():
    return glide(1500, 1750, 0.06, 70) * 0.7


def snd_huh():
    """Two descending soft notes: 'hmm?'"""
    out = np.zeros(int(SR * 0.9))
    a, b = marimba(784, 0.5, 10), marimba(587, 0.7, 7)
    out[:len(a)] += a
    i = int(0.14 * SR)
    out[i:i + len(b)] += b
    return out * 0.7


def snd_ping():
    out = np.zeros(int(SR * 0.8))
    a, b = marimba(1318.5, 0.5, 12), marimba(1760, 0.6, 10)
    out[:len(a)] += a
    i = int(0.08 * SR)
    out[i:i + len(b)] += b
    return out * 0.55


def snd_slip():
    out = np.zeros(int(SR * 0.9))
    c = snd_tick()
    out[:len(c)] += c
    g = glide(1300, 280, 0.8, 4.5, attack=0.03) * 0.35
    out[:len(g)] += g
    return out


def snd_key(seed=0):
    t = _t(0.05)
    n = noise(len(t), 40 + seed)
    return 0.5 * glide(2100, 1800, 0.05, 110) + 0.4 * (n - lowpass(n, 3000)) * env(t, 0.0003, 260)


def snd_buzz():
    """Phone haptic: a short low rattle."""
    t = _t(0.09)
    sq = np.sign(np.sin(2 * np.pi * 165 * t))
    return lowpass(sq, 900) * env(t, 0.004, 32) * 0.9


SOUNDS = {
    'whoosh': lambda kw: snd_whoosh(kw.get('dur', 0.7), kw.get('peak', 0.45), kw.get('seed', 1)),
    'swipe': lambda kw: snd_whoosh(0.32, 0.35, kw.get('seed', 5)) * 0.8,
    'shimmer': lambda kw: snd_shimmer(kw.get('dur', 1.5), kw.get('density', 22), kw.get('seed', 3)),
    'bell': lambda kw: snd_bell(kw.get('f', 523.25)),
    'boom': lambda kw: snd_boom(),
    'chime': lambda kw: snd_chime(),
    'pop': lambda kw: snd_pop(kw.get('up', True)),
    'tick': lambda kw: snd_tick(),
    'huh': lambda kw: snd_huh(),
    'ping': lambda kw: snd_ping(),
    'slip': lambda kw: snd_slip(),
    'tap': lambda kw: snd_tap(kw.get('seed', 0)),
    'key': lambda kw: snd_key(kw.get('seed', 0)),
    'buzz': lambda kw: snd_buzz(),
}

# (time, sound, gain, pan, options). Taps and the 108 bell come from each video's Track.
CUES = {
    1: [(0.1, 'whoosh', 0.6, 0, {}), (0.5, 'pop', 0.5, 0.3, {}), (0.92, 'tick', 0.45, 0.3, {}),
        (1.34, 'tick', 0.45, 0.3, {}), (1.76, 'tick', 0.45, 0.3, {}), (2.18, 'huh', 0.55, 0.3, {}),
        (3.0, 'whoosh', 0.8, 0, dict(dur=0.9, seed=2)), (3.6, 'shimmer', 1.0, 0, dict(dur=1.5)),
        (6.95, 'whoosh', 0.35, 0, dict(dur=0.5, seed=3)), (11.95, 'whoosh', 0.35, 0, dict(dur=0.5, seed=4)),
        (16.85, 'whoosh', 0.7, 0, dict(dur=0.8, seed=6)), (17.35, 'chime', 0.7, 0, {})],
    2: [(0.1, 'whoosh', 0.6, 0, {}), (1.0, 'slip', 0.6, 0.25, {}), (3.15, 'whoosh', 0.35, 0, dict(dur=0.5, seed=7)),
        (3.2, 'pop', 0.5, 0.3, {}), (3.65, 'tick', 0.45, 0.3, {}), (4.1, 'tick', 0.45, 0.3, {}),
        (4.55, 'huh', 0.55, 0.3, {}), (6.0, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)),
        (9.95, 'whoosh', 0.35, 0, dict(dur=0.5, seed=3)), (14.95, 'whoosh', 0.35, 0, dict(dur=0.5, seed=4)),
        (18.85, 'whoosh', 0.7, 0, dict(dur=0.8, seed=6)), (19.35, 'chime', 0.7, 0, {})],
    3: [(0.2, 'shimmer', 0.6, 0, dict(dur=3.0, density=8, seed=11)), (4.0, 'whoosh', 0.8, 0, dict(dur=0.9, seed=2)),
        (4.4, 'shimmer', 1.0, 0, dict(dur=2.0)), (8.0, 'swipe', 0.7, 0.2, {}), (10.4, 'tap', 0.7, 0, dict(seed=21)),
        (11.0, 'swipe', 0.7, 0.2, dict(seed=12)), (12.95, 'whoosh', 0.35, 0, dict(dur=0.5, seed=3)),
        (21.85, 'whoosh', 0.7, 0, dict(dur=0.8, seed=6)), (22.35, 'chime', 0.7, 0, {})],
    4: [(0.2, 'boom', 0.9, 0, {}), (0.3, 'shimmer', 0.7, 0, dict(dur=2.2, density=12, seed=13)),
        (2.7, 'whoosh', 0.45, 0, dict(dur=0.7, seed=14)), (3.3, 'bell', 0.35, 0, dict(f=392.0)),
        (6.0, 'whoosh', 0.4, 0, dict(dur=1.4, peak=0.7, seed=15)), (6.1, 'shimmer', 0.8, 0, dict(dur=2.5, density=14, seed=16)),
        (9.2, 'whoosh', 0.7, 0, dict(dur=0.9, seed=8)), (13.95, 'whoosh', 0.3, 0, dict(dur=0.5, seed=4)),
        (17.95, 'whoosh', 0.7, 0, dict(dur=0.8, seed=6)), (18.35, 'chime', 0.7, 0, {})],
    5: [*[(0.1 + k * 0.45, 'ping', 0.55, (-0.4, 0.4)[k % 2], {}) for k in range(5)],
        (3.0, 'whoosh', 0.9, 0, dict(dur=0.9, peak=0.3, seed=17)), (3.6, 'bell', 0.4, 0, dict(f=392.0)),
        (3.7, 'shimmer', 0.6, 0, dict(dur=2.0, density=8, seed=18)), (5.7, 'whoosh', 0.35, 0, dict(dur=0.6, seed=3)),
        (6.0, 'whoosh', 0.8, 0, dict(dur=1.0, peak=0.6, seed=8)), (7.2, 'whoosh', 0.25, 0, dict(dur=1.0, peak=0.5, seed=19)),
        (8.8, 'tap', 0.7, 0, dict(seed=22)), (9.2, 'swipe', 0.7, 0.2, {}),
        (14.95, 'whoosh', 0.35, 0, dict(dur=0.5, seed=4)),
        (18.95, 'whoosh', 0.7, 0, dict(dur=0.8, seed=6)), (19.45, 'chime', 0.7, 0, {})],
}

for _vid, _cues in FEATURE_CUES.items():
    CUES[_vid] = CUES[_vid + 5] = _cues


def mix_in(buf, t0, snd, gain=1.0, pan=0.0):
    i = int(t0 * SR)
    if i >= len(buf):
        return
    if snd.ndim == 1:
        snd = np.stack([snd * math.cos((pan + 1) * math.pi / 4), snd * math.sin((pan + 1) * math.pi / 4)], 1) * math.sqrt(2)
    m = min(len(snd), len(buf) - i)
    buf[i:i + m] += snd[:m] * gain


def write_sfx(vid, spec, path):
    buf = np.zeros((int(SR * spec['dur']), 2))
    for t0, kind, gain, pan, kw in CUES[vid]:
        mix_in(buf, t0, SOUNDS[kind](kw), gain, pan)
    tap_cache = [snd_tap(s) for s in range(6)]
    for tr, kind in spec.get('tracks') or [(spec['track'], 'tap')]:
        last, prev, tt, k = -1.0, tr.val(tr.start - 0.01), tr.start - 0.01, 0
        one = None if kind == 'tap' else SOUNDS[kind]({})
        while tt <= tr.done + 0.01:
            v = tr.val(tt)
            if v > prev and tt - last >= 0.07:
                gain = (0.75 if tt - last > 0.2 else 0.32) * (1 if kind == 'tap' else 0.8)
                mix_in(buf, tt, tap_cache[k % 6] if one is None else one, gain, 0.12 * math.sin(k * 2.1))
                last, k = tt, k + 1
            prev = v
            tt += 1 / 600
    for bt, f, amp in spec.get('bells') or [(spec['track'].done, 523.25, 0.85)]:
        mix_in(buf, bt, snd_bell(f), amp)
        mix_in(buf, bt + 0.05, snd_shimmer(1.6, 26, seed=31), amp * 1.15)
    peak = np.max(np.abs(buf)) or 1
    pcm = (buf / peak * 0.89 * 32767).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


# ---------------------------------------------------------------- driver

def frame_job(args):
    vid, i = args
    return VIDEOS[vid]['render'](i / FPS).convert('RGB').tobytes()


def render_video(vid):
    spec = VIDEOS[vid]
    D = spec['dur']
    n = int(round(D * FPS))
    os.makedirs(OUT, exist_ok=True)
    sfx = os.path.join(OUT, f".{spec['name']}_sfx.wav")
    write_sfx(vid, spec, sfx)
    out = os.path.join(OUT, spec['name'] + '.mp4')
    fc = "[1:a]aecho=0.85:0.8:45|100|180:0.2|0.12|0.07,volume=6dB,alimiter=limit=0.8:attack=2:release=60:level=0[a]"
    cmd = ['ffmpeg', '-y', '-loglevel', 'error',
           '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-',
           '-i', sfx, '-filter_complex', fc, '-map', '0:v', '-map', '[a]',
           '-c:v', 'libx264', '-preset', 'slow', '-crf', '18', '-pix_fmt', 'yuv420p',
           '-c:a', 'aac', '-b:a', '192k', '-t', str(D), '-movflags', '+faststart', out]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    with Pool(os.cpu_count()) as pool:
        for k, buf in enumerate(pool.imap(frame_job, [(vid, i) for i in range(n)], chunksize=3)):
            proc.stdin.write(buf)
            if k % 90 == 0:
                print(f"  {spec['name']}: {k}/{n}", flush=True)
    proc.stdin.close()
    proc.wait()
    os.remove(sfx)
    print('wrote', out)


def contact_sheet(vid, step=1.0, cols=6):
    spec = VIDEOS[vid]
    times = np.arange(0.2, spec['dur'], step)
    tw, th = W // 4, H // 4
    rows = math.ceil(len(times) / cols)
    sheet = Image.new('RGB', (cols * tw, rows * (th + 24)), (255, 255, 255))
    d = ImageDraw.Draw(sheet)
    for k, t in enumerate(times):
        im = spec['render'](float(t)).convert('RGB').resize((tw, th), Image.LANCZOS)
        x, y = (k % cols) * tw, (k // cols) * (th + 24)
        sheet.paste(im, (x, y + 24))
        d.text((x + 6, y + 4), f'{t:.1f}s', fill=(0, 0, 0))
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, f'sheet_{vid}.png')
    sheet.save(path)
    print('wrote', path)


if __name__ == '__main__':
    argv = sys.argv[1:]
    if argv and argv[0] == '--sheet':
        for v in argv[1:] or VIDEOS:
            contact_sheet(int(v))
    elif argv and argv[0] == '--still':
        vid, t = int(argv[1]), float(argv[2])
        os.makedirs(OUT, exist_ok=True)
        VIDEOS[vid]['render'](t).convert('RGB').save(os.path.join(OUT, f'still_{vid}_{t}.png'))
    else:
        for v in [int(a) for a in argv] or sorted(VIDEOS):
            render_video(v)
