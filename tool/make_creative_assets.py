"""Builds the App Store creative assets (product page header + search results).

  appstore_assets/creative/<locale>/universal_16x9.png   5244×2950, fits both
  appstore_assets/creative/<locale>/search_3x2.mp4       1920×1280, 8 s loop

The PNG is the one size App Store Connect accepts in both slots. It is cropped
to 21:9 for the header and to 3:2 in search, so everything that matters sits
inside the area both crops keep (SAFE below).

Run tool/screenshots.sh first: the phones show its bare captures from
build/store_raw/. Run from the repo root:  python3 tool/make_creative_assets.py
"""
import math
import os
import subprocess

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = f'{ROOT}/build/store_raw'
OUT = f'{ROOT}/appstore_assets/creative'
ICON = f'{ROOT}/appstore_assets/appicon.png'

W, H = 5244, 2950
# What survives both the 21:9 crop (full width, middle 2247 rows) and the
# 3:2 crop (full height, middle 4425 columns).
SAFE = (410, 352, 4834, 2598)
# What an iPhone product page header shows: only the middle ~56% of the
# width, from the top down to about y 1900, with the status bar and the
# back/share buttons over the top ~760 rows. Measured on a 402 pt iPhone;
# narrower phones show a little less width, hence the margin.
IPHONE = (1300, 780, 3944, 1860)

CREAM = (255, 244, 226)
SAFFRON = (255, 178, 63)
INK = (36, 22, 8)
RUST = (217, 96, 15)

FONTS = f'{ROOT}/assets/fonts'
SHOT_FONTS = f'{ROOT}/screenshots/fonts'
DEVANAGARI = (f'{FONTS}/NotoSansDevanagari-Bold.ttf', f'{FONTS}/NotoSansDevanagari-Medium.ttf')
FONT = {
    'en': (f'{FONTS}/Inter-Bold.ttf', f'{FONTS}/Inter-Medium.ttf'),
    'hi': DEVANAGARI,
    'mr': DEVANAGARI,
    'gu': (f'{SHOT_FONTS}/NotoSansGujarati-Bold.ttf', f'{SHOT_FONTS}/NotoSansGujarati-Regular.ttf'),
    'pa': (f'{SHOT_FONTS}/NotoSansGurmukhi-Bold.ttf', f'{SHOT_FONTS}/NotoSansGurmukhi-Regular.ttf'),
    'ta': (f'{SHOT_FONTS}/NotoSansTamil-Bold.ttf', f'{SHOT_FONTS}/NotoSansTamil-Regular.ttf'),
    'te': (f'{SHOT_FONTS}/NotoSansTelugu-Bold.ttf', f'{SHOT_FONTS}/NotoSansTelugu-Regular.ttf'),
}

# locale -> (language, app name, slogan, headline, highlighted line, badge).
# The Gujarati fonts have no '.' or ',', so its lines go without them.
COPY = {
    'en-US': ('en', 'Naam Jaap Counter', 'Bhakti Ka Sathi, Har Din!', 'Tap Anywhere.', 'Never Lose Count.',
              'No ads  •  Private  •  Works offline'),
    'hi': ('hi', 'नाम जप काउंटर', 'भक्ति का साथी, हर दिन', 'कहीं भी टैप करें।', 'गिनती कभी न भूलें।',
           'विज्ञापन नहीं  •  निजी  •  बिना इंटरनेट'),
    'mr-IN': ('mr', 'नाम जप काउंटर', 'भक्तीचा सोबती, दररोज', 'कुठेही टॅप करा.', 'मोजणी चुकणार नाही.',
              'जाहिराती नाहीत  •  खाजगी  •  इंटरनेटशिवाय'),
    'gu-IN': ('gu', 'નામ જપ કાઉન્ટર', 'ભક્તિનો સાથી દરરોજ', 'ગમે ત્યાં ટૅપ કરો', 'ગણતરી ક્યારેય ન ભૂલો',
              'જાહેરાત નહીં  •  ખાનગી  •  ઇન્ટરનેટ વગર'),
    'pa-IN': ('pa', 'ਨਾਮ ਜਪ ਕਾਊਂਟਰ', 'ਭਗਤੀ ਦਾ ਸਾਥੀ, ਹਰ ਦਿਨ', 'ਕਿਤੇ ਵੀ ਟੈਪ ਕਰੋ।', 'ਗਿਣਤੀ ਕਦੇ ਨਾ ਭੁੱਲੋ।',
              'ਕੋਈ ਇਸ਼ਤਿਹਾਰ ਨਹੀਂ  •  ਨਿੱਜੀ  •  ਬਿਨਾਂ ਇੰਟਰਨੈੱਟ'),
    'ta-IN': ('ta', 'நாம ஜப கவுண்டர்', 'பக்தியின் துணை, ஒவ்வொரு நாளும்', 'எங்கும் தட்டி', 'எண்ணுங்கள்',
              'விளம்பரமில்லை  •  ஆஃப்லைன்'),
    'te-IN': ('te', 'నామ జప కౌంటర్', 'భక్తికి తోడు, ప్రతిరోజూ', 'ఎక్కడైనా ట్యాప్ చేయండి', 'లెక్క తప్పదు',
              'ప్రకటనలు లేవు  •  ప్రైవేట్  •  ఆఫ్‌లైన్'),
}

# "No paywall • No ads", per language.
PILL = {
    'en-US': ('No paywall', 'No ads'),
    'hi': ('कोई पेवॉल नहीं', 'कोई विज्ञापन नहीं'),
    'mr-IN': ('पेवॉल नाही', 'जाहिराती नाहीत'),
    'gu-IN': ('પેવૉલ નહીં', 'જાહેરાત નહીં'),
    'pa-IN': ('ਕੋਈ ਪੇਵਾਲ ਨਹੀਂ', 'ਕੋਈ ਇਸ਼ਤਿਹਾਰ ਨਹੀਂ'),
    'ta-IN': ('கட்டணமில்லை', 'விளம்பரமில்லை'),
    'te-IN': ('పేవాల్ లేదు', 'ప్రకటనలు లేవు'),
}



def font(path, size):
    return ImageFont.truetype(path, size, layout_engine=ImageFont.Layout.RAQM)


def fit(text, path, max_w, start):
    size = start
    while size > 40:
        f = font(path, size)
        if f.getlength(text) <= max_w:
            return f
        size -= 6
    return f


def rounded(im, radius):
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *im.size), radius, fill=255)
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def phone(screen_path, height):
    """A plain modern phone around a bare capture, with its shadow margin."""
    screen = Image.open(screen_path).convert('RGB')
    sw = round(height * screen.width / screen.height)
    bezel = round(sw * 0.03)
    w, h = sw + 2 * bezel, height + 2 * bezel
    pad = round(w * 0.12)
    canvas = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))

    shadow = Image.new('L', canvas.size, 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        (pad, pad + round(h * 0.02), pad + w, pad + h), round(w * 0.15), fill=150)
    shadow = shadow.filter(ImageFilter.GaussianBlur(w * 0.04))
    canvas.paste((0, 0, 0, 255), (0, 0), shadow)

    body = ImageDraw.Draw(canvas)
    body.rounded_rectangle((pad, pad, pad + w, pad + h), round(w * 0.15),
                           fill=(10, 10, 10), outline=(70, 70, 74), width=max(3, w // 300))
    shot = rounded(screen.resize((sw, height), Image.LANCZOS), round(sw * 0.13))
    canvas.alpha_composite(shot, (pad + bezel, pad + bezel))
    # Dynamic Island.
    iw, ih = round(sw * 0.31), round(sw * 0.092)
    ix, iy = pad + bezel + (sw - iw) // 2, pad + bezel + round(sw * 0.03)
    body.rounded_rectangle((ix, iy, ix + iw, iy + ih), ih // 2, fill=(0, 0, 0))
    return canvas


def gradient_text(layer, xy, text, f, anchor, top, bottom):
    """Text filled with a top-to-bottom colour gradient."""
    mask = Image.new('L', layer.size, 0)
    ImageDraw.Draw(mask).text(xy, text, font=f, fill=255, anchor=anchor)
    box = mask.getbbox()
    fill = Image.new('RGBA', (1, box[3] - box[1]))
    for y in range(fill.height):
        t = y / max(1, fill.height - 1)
        fill.putpixel((0, y), (*(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)), 255))
    sheet = Image.new('RGBA', layer.size, (0, 0, 0, 0))
    sheet.paste(fill.resize((box[2] - box[0], fill.height)), box[:2])
    layer.paste(sheet, (0, 0), mask)


# Line-art doodles for the header pattern. Each draws in white on its own
# transparent tile, centred, about `s` across, with stroke width `w`.

def _mala(d, c, s, w):
    r = s * 0.36
    for k in range(24):
        a = math.pi / 2 + 2 * math.pi * k / 25 + math.pi / 25
        x, y = c + r * math.cos(a), c - s * 0.06 + r * math.sin(a)
        b = s * 0.035
        d.ellipse((x - b, y - b, x + b, y + b), outline='white', width=w)
    gy = c - s * 0.06 + r
    d.ellipse((c - s * 0.05, gy - s * 0.02, c + s * 0.05, gy + s * 0.08), outline='white', width=w)
    for dx in (-0.07, -0.035, 0, 0.035, 0.07):
        d.line((c, gy + s * 0.08, c + s * dx, gy + s * 0.3), fill='white', width=w)


def _diya(d, c, s, w):
    d.arc((c - s * 0.4, c - s * 0.15, c + s * 0.4, c + s * 0.35), 0, 180, fill='white', width=w)
    d.line((c - s * 0.4, c + s * 0.1, c + s * 0.4, c + s * 0.1), fill='white', width=w)
    pts = [(c + s * 0.11 * math.sin(t) * math.sin(t / 2), c + s * 0.07 - s * 0.22 * (1 + math.cos(t)) / 2 * 1.4)
           for t in [i * 2 * math.pi / 40 for i in range(41)]]
    d.line(pts, fill='white', width=w, joint='curve')
    for a in (-60, -30, 30, 60):
        ra = math.radians(a - 90)
        d.line((c + s * 0.28 * math.cos(ra), c - s * 0.1 + s * 0.28 * math.sin(ra),
                c + s * 0.4 * math.cos(ra), c - s * 0.1 + s * 0.4 * math.sin(ra)), fill='white', width=w)


def _lotus(d, c, s, w):
    def petal(cx, cy, hw, hh, tilt):
        pts = []
        for i in range(31):
            t = i / 30
            y = cy - hh * t
            x = hw * math.sin(math.pi * t)
            pts.append((cx + tilt * hh * t + x, y))
        for i in range(30, -1, -1):
            t = i / 30
            pts.append((cx + tilt * hh * t - hw * math.sin(math.pi * t), cy - hh * t))
        d.line(pts + [pts[0]], fill='white', width=w, joint='curve')
    base = c + s * 0.22
    petal(c, base, s * 0.11, s * 0.5, 0)
    petal(c - s * 0.12, base, s * 0.1, s * 0.4, -0.55)
    petal(c + s * 0.12, base, s * 0.1, s * 0.4, 0.55)
    petal(c - s * 0.2, base, s * 0.08, s * 0.28, -1.3)
    petal(c + s * 0.2, base, s * 0.08, s * 0.28, 1.3)
    d.arc((c - s * 0.45, base - s * 0.08, c + s * 0.45, base + s * 0.18), 0, 180, fill='white', width=w)


def _bell(d, c, s, w):
    d.line((c, c - s * 0.45, c, c - s * 0.3), fill='white', width=w)
    d.ellipse((c - s * 0.05, c - s * 0.32, c + s * 0.05, c - s * 0.24), outline='white', width=w)
    pts = [(c - s * 0.28, c + s * 0.22), (c - s * 0.22, c - s * 0.05), (c - s * 0.12, c - s * 0.2),
           (c, c - s * 0.25), (c + s * 0.12, c - s * 0.2), (c + s * 0.22, c - s * 0.05), (c + s * 0.28, c + s * 0.22)]
    d.line(pts, fill='white', width=w, joint='curve')
    d.line((c - s * 0.34, c + s * 0.22, c + s * 0.34, c + s * 0.22), fill='white', width=w)
    d.ellipse((c - s * 0.06, c + s * 0.25, c + s * 0.06, c + s * 0.37), outline='white', width=w)


def _sun(d, c, s, w):
    r = s * 0.2
    d.ellipse((c - r, c - r, c + r, c + r), outline='white', width=w)
    for k in range(12):
        a = 2 * math.pi * k / 12
        r1, r2 = s * 0.28, s * (0.42 if k % 2 else 0.36)
        d.line((c + r1 * math.cos(a), c + r1 * math.sin(a), c + r2 * math.cos(a), c + r2 * math.sin(a)),
               fill='white', width=w)


def _flame(d, c, s, w):
    pts = [(c + s * 0.25 * math.sin(t) * math.sin(t / 2), c + s * 0.25 - s * 0.6 * (1 + math.cos(t)) / 2)
           for t in [i * 2 * math.pi / 50 for i in range(51)]]
    d.line(pts, fill='white', width=w, joint='curve')
    pts = [(c + s * 0.11 * math.sin(t) * math.sin(t / 2), c + s * 0.22 - s * 0.28 * (1 + math.cos(t)) / 2)
           for t in [i * 2 * math.pi / 40 for i in range(41)]]
    d.line(pts, fill='white', width=w, joint='curve')


def _sparkle(d, cx, s, w, cy=None):
    cy = cx if cy is None else cy
    r, q = s * 0.4, s * 0.09
    pts = [(cx, cy - r), (cx + q, cy - q), (cx + r, cy), (cx + q, cy + q), (cx, cy + r), (cx - q, cy + q),
           (cx - r, cy), (cx - q, cy - q), (cx, cy - r)]
    d.line(pts, fill='white', width=w, joint='curve')


def _glyph(path, ch, scale):
    def draw(d, c, s, w):
        f = font(path, round(s * scale))
        d.text((c, c), ch, font=f, anchor='mm', fill=(0, 0, 0, 0), stroke_width=w, stroke_fill='white')
    return draw


_om = _glyph(f'{FONTS}/NotoSansDevanagari-Medium.ttf', 'ॐ', 0.75)
_ek_onkar = _glyph(f'{SHOT_FONTS}/NotoSansGurmukhi-Regular.ttf', 'ੴ', 0.7)
_khanda = _glyph(f'{SHOT_FONTS}/NotoSansGurmukhi-Regular.ttf', '☬', 0.75)


def _trishul(d, c, s, w):
    top, fork = c - s * 0.42, c - s * 0.08
    d.line((c, top, c, c + s * 0.45), fill='white', width=w)
    d.line((c - s * 0.05, top + s * 0.1, c, top, c + s * 0.05, top + s * 0.1), fill='white', width=w, joint='curve')
    for side in (-1, 1):
        pts = [(c, fork)] + [(c + side * s * 0.22 * (1 - (1 - t) ** 2), fork + s * 0.02 - s * 0.3 * t ** 2)
                             for t in [i / 20 for i in range(21)]]
        d.line(pts, fill='white', width=w, joint='curve')
    d.ellipse((c - s * 0.05, fork + s * 0.08, c + s * 0.05, fork + s * 0.18), outline='white', width=w)


DOODLES = {'mala': _mala, 'diya': _diya, 'lotus': _lotus, 'bell': _bell, 'sun': _sun, 'trishul': _trishul,
           'khanda': _khanda, 'ek_onkar': _ek_onkar, 'flame': _flame, 'om': _om,
           'sparkle': lambda d, c, s, w: _sparkle(d, c, s, w)}

# (doodle, x, y as fractions of the canvas, size in px, rotation in degrees).
# The middle is left clear for the name.
PATTERN = [
    ('mala', 0.06, 0.25, 760, -12), ('sun', 0.80, 0.16, 640, 0), ('diya', 0.25, 0.83, 700, 6),
    ('lotus', 0.88, 0.78, 760, -8), ('bell', 0.33, 0.13, 520, 10), ('khanda', 0.64, 0.86, 600, -8),
    ('trishul', 0.95, 0.40, 560, 10), ('ek_onkar', 0.10, 0.68, 600, -6), ('om', 0.58, 0.12, 520, -8),
    ('flame', 0.40, 0.88, 420, 8), ('sparkle', 0.74, 0.20, 170, 0),
    ('sparkle', 0.50, 0.95, 150, 0), ('sparkle', 0.93, 0.08, 180, 0), ('sparkle', 0.14, 0.08, 150, 0),
    ('sparkle', 0.87, 0.60, 150, 0), ('sparkle', 0.31, 0.74, 140, 0),
]


def doodle_header(locale, line_alpha, out):
    """A WhatsApp-style header: the maroon gradient, a sparse pattern of thin
    Hindu and Sikh line art, and the name and slogan in the middle."""
    lang, name, slogan = COPY[locale][:3]
    bold, medium = FONT[lang]
    img = maroon((W * 0.1, H * 0.98, W * 0.9, H * 1.8))
    for kind, fx, fy, size, angle in PATTERN:
        tile = Image.new('RGBA', (size * 2, size * 2), (0, 0, 0, 0))
        DOODLES[kind](ImageDraw.Draw(tile), size, size, 11)
        if angle:
            tile = tile.rotate(angle, resample=Image.BICUBIC)
        tile.putalpha(tile.getchannel('A').point(lambda v: round(v * line_alpha)))
        img.alpha_composite(tile, (round(fx * W - size), round(fy * H - size)))

    # Name, slogan and "No paywall • No ads", stacked and centred.
    words = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(words)
    # Everything sits in the iPhone window, the tightest crop.
    max_w = IPHONE[2] - IPHONE[0]
    f_name = fit(name, bold, max_w, 540)
    f_slogan = fit(slogan, medium, max_w - 200, 185)
    left, right = PILL[locale]
    f_pill = fit(f'{left}      {right}', medium, max_w - 400, 140)
    gap = round(f_name.size * 0.3) + 50  # clears the name's descenders
    pill_gap = round(f_slogan.size * 0.75)
    y = (IPHONE[1] + IPHONE[3]) / 2 - (f_name.size + gap + f_slogan.size + pill_gap + f_pill.size) / 2
    d.text((W / 2, y + f_name.size), name, font=f_name, fill='white', anchor='ms')
    d.text((W / 2, y + f_name.size + gap), slogan, font=f_slogan, fill=(255, 255, 255, 215), anchor='mt')
    # Script fonts often lack '•', so the dot is drawn.
    py = y + f_name.size + gap + f_slogan.size + pill_gap
    dot = f_pill.size * 0.12
    space = f_pill.size * 0.7
    wl, wr = f_pill.getlength(left), f_pill.getlength(right)
    x0 = W / 2 - (wl + 2 * space + wr) / 2
    pill = (255, 200, 120, 235)
    d.text((x0, py), left, font=f_pill, fill=pill, anchor='lt')
    cy = py + f_pill.getbbox(left, anchor='lt')[3] / 2
    d.ellipse((x0 + wl + space - dot, cy - dot, x0 + wl + space + dot, cy + dot), fill=pill)
    d.text((x0 + wl + 2 * space, py), right, font=f_pill, fill=pill, anchor='lt')
    img.alpha_composite(words)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.convert('RGB').save(out, optimize=True)
    return out


def maroon(glow_box):
    """The screenshots' maroon gradient, dark at the top, with a saffron glow
    inside glow_box."""
    img = Image.new('RGB', (W, H))
    grad = ImageDraw.Draw(img)
    stops = [(42, 10, 4), (90, 26, 7), (138, 58, 12)]
    for y in range(H):
        t = y / (H - 1) * 2
        a, b = (stops[0], stops[1]) if t < 1 else (stops[1], stops[2])
        t = t if t < 1 else t - 1
        grad.line([(0, y), (W, y)], fill=tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3)))
    glow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(glow).ellipse(glow_box, fill=90)
    img.paste(SAFFRON, (0, 0), glow.filter(ImageFilter.GaussianBlur(420)))
    return img.convert('RGBA')


def hero(locale):
    """The header: brand and promise on the left, three real screens fanned
    out on the right, over the maroon backdrop."""
    lang, name, slogan, line1, line2, _ = COPY[locale]
    bold, medium = FONT[lang]

    # Maroon night, lit from behind the phones.
    img = maroon((2500, 0, 5300, H))
    x_mid, y_mid = 3740, (SAFE[1] + SAFE[3]) // 2

    # Phones: music and mantras tilted behind, the counter in front.
    for shot, cx, ph, angle in [('03_music', 4380, 1900, -7), ('02_mantras', 3100, 1900, 7),
                                ('01_counter', x_mid, 2160, 0)]:
        p = phone(f'{RAW}/{locale}/{shot}.png', ph)
        if angle:
            p = p.rotate(angle, resample=Image.BICUBIC, expand=True)
        img.alpha_composite(p, (round(cx - p.width / 2), round(y_mid - p.height / 2)))

    words = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(words)
    left, col = 600, 1780
    f_head = fit(max(line1, line2, key=lambda t: font(bold, 200).getlength(t)), bold, col, 320)
    parts = PILL[locale]
    f_pill = fit(parts[0] + '      ' + parts[1], bold, col - 260, 104)
    ph = f_pill.size * 1.9
    # Indic scripts stack taller than Latin, so their lines need more room.
    lh = 1.1 if lang == 'en' else 1.3
    head_h = f_head.size * (2 * lh + 0.3)
    # The whole block (lockup, promise, pill) centred on the image's middle.
    block = 380 + 130 + head_h + ph
    top = H / 2 - block / 2

    # Brand lockup: icon, then name over slogan.
    y = top
    icon = rounded(Image.open(ICON).convert('RGB').resize((380, 380), Image.LANCZOS), 86)
    words.alpha_composite(icon, (left, round(y)))
    f_name = fit(name, bold, col - 440, 140)
    f_slogan = fit(slogan, medium, col - 440, 100)
    d.text((left + 440, y + 190 - 14), name, font=f_name, fill=CREAM, anchor='ls')
    d.text((left + 440, y + 190 + 36), slogan, font=f_slogan, fill=SAFFRON, anchor='lt')

    # The promise, large.
    y = top + 380 + 130
    d.text((left - 10, y), line1, font=f_head, fill=CREAM, anchor='lt')
    gradient_text(words, (left - 10, y + f_head.size * lh), line2, f_head, 'lt',
                  (255, 204, 96), (245, 146, 38))

    # Free means free: a pill under the promise.
    y += head_h
    sep = f_pill.size * 1.3
    pw = sum(f_pill.getlength(t) for t in parts) + sep + f_pill.size * 1.8
    d.rounded_rectangle((left, y, left + pw, y + ph), ph / 2,
                        fill=(*SAFFRON, 40), outline=(*SAFFRON, 160), width=6)
    x, cy = left + f_pill.size * 0.9, y + ph / 2
    d.text((x, cy), parts[0], font=f_pill, fill=SAFFRON, anchor='lm')
    x += f_pill.getlength(parts[0]) + sep / 2
    r = f_pill.size * 0.1
    d.ellipse((x - r, cy - r, x + r, cy + r), fill=CREAM)
    d.text((x + sep / 2, cy), parts[1], font=f_pill, fill=SAFFRON, anchor='lm')
    img.alpha_composite(words)

    out = f'{OUT}/{locale}/universal_16x9.png'
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.convert('RGB').save(out, optimize=True)
    return out


def search_motion(locale):
    """The search-results video: the real counter, counting bead by bead.

    The phone rises in beside the name and promise, then a soft ripple marks
    each tap while the app's own frames (build/store_raw/<locale>/counter_seq,
    from tool/screenshots.sh) count up. Silent, 8 s, 1920×1280 at 30 fps.
    """
    lang, name, _, line1, line2, _ = COPY[locale]
    bold, medium = FONT[lang]
    vw, vh, fps = 1920, 1280, 30
    seq_dir = f'{RAW}/{locale}/counter_seq'
    frames = sorted(os.listdir(seq_dir))
    intro, hold = 30, 30  # frames before the first tap, and after the last
    per_tap = 15

    # Backdrop: the header's maroon, lit behind the phone.
    bg = Image.new('RGB', (vw, vh))
    grad = ImageDraw.Draw(bg)
    stops = [(42, 10, 4), (90, 26, 7), (138, 58, 12)]
    for y in range(vh):
        t = y / (vh - 1) * 2
        a, b = (stops[0], stops[1]) if t < 1 else (stops[1], stops[2])
        t = t if t < 1 else t - 1
        grad.line([(0, y), (vw, y)], fill=tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3)))
    px = 1400
    glow = Image.new('L', (vw, vh), 0)
    ImageDraw.Draw(glow).ellipse((px - 700, -100, px + 700, vh + 100), fill=95)
    bg.paste(SAFFRON, (0, 0), glow.filter(ImageFilter.GaussianBlur(160)))
    bg = bg.convert('RGBA')

    # The phone body, built once; each frame drops its screen into it.
    sh = 1150
    sw = round(sh * 786 / 1704)
    bezel = round(sw * 0.03)
    w, h = sw + 2 * bezel, sh + 2 * bezel
    pad = round(w * 0.12)
    body = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    shadow = Image.new('L', body.size, 0)
    ImageDraw.Draw(shadow).rounded_rectangle((pad, pad + 20, pad + w, pad + h), round(w * 0.15), fill=160)
    body.paste((0, 0, 0, 255), (0, 0), shadow.filter(ImageFilter.GaussianBlur(w * 0.05)))
    ImageDraw.Draw(body).rounded_rectangle((pad, pad, pad + w, pad + h), round(w * 0.15),
                                           fill=(10, 10, 10), outline=(70, 70, 74), width=3)
    screen_mask = Image.new('L', (sw, sh), 0)
    ImageDraw.Draw(screen_mask).rounded_rectangle((0, 0, sw, sh), round(sw * 0.13), fill=255)
    iw, ih = round(sw * 0.31), round(sw * 0.092)
    island = (pad + bezel + (sw - iw) // 2, pad + bezel + round(sw * 0.03))
    still = Image.open(f'{RAW}/{locale}/01_counter.png').convert('RGB').resize((sw, sh), Image.LANCZOS)
    shots = [Image.open(f'{seq_dir}/{f}').convert('RGB').resize((sw, sh), Image.LANCZOS) for f in frames]

    def phone_with(screen):
        p = body.copy()
        p.paste(screen, (pad + bezel, pad + bezel), screen_mask)
        ImageDraw.Draw(p).rounded_rectangle(
            (island[0], island[1], island[0] + iw, island[1] + ih), ih // 2, fill=(0, 0, 0))
        return p

    # Words: a name lockup and the two-line promise, each its own layer so
    # they can fade in one after another.
    col, cx = 820, 520
    icon = rounded(Image.open(ICON).convert('RGB').resize((132, 132), Image.LANCZOS), 30)
    f_name = fit(name, bold, col - 170, 62)
    f_head = fit(max(line1, line2, key=lambda t: font(bold, 120).getlength(t)), bold, col, 118)
    lh = 1.12 if lang == 'en' else 1.32
    block = 132 + 70 + f_head.size * (lh + 1.0)
    top = vh / 2 - block / 2

    def layer():
        im = Image.new('RGBA', (vw, vh), (0, 0, 0, 0))
        return im, ImageDraw.Draw(im)
    lock, d = layer()
    lw = 132 + 30 + f_name.getlength(name)
    lx = cx - lw / 2
    lock.alpha_composite(icon, (round(lx), round(top)))
    d.text((lx + 162, top + 66), name, font=f_name, fill=CREAM, anchor='lm')
    head1, d = layer()
    d.text((cx, top + 132 + 70), line1, font=f_head, fill=CREAM, anchor='mt')
    head2, _ = layer()
    gradient_text(head2, (cx, top + 132 + 70 + f_head.size * lh), line2, f_head, 'mt',
                  (255, 204, 96), (245, 146, 38))

    def ease(t):
        t = min(1.0, max(0.0, t))
        return 1 - (1 - t) ** 3

    def faded(im, k, dy=0):
        if k >= 1 and not dy:
            return im
        out = Image.new('RGBA', im.size, (0, 0, 0, 0))
        a = im.getchannel('A').point(lambda v: round(v * k))
        moved = im.copy()
        moved.putalpha(a)
        out.alpha_composite(moved, (0, round(dy)))
        return out

    total = intro + len(shots) + hold
    tap_x, tap_y = 0.5, 0.78  # where the finger lands, on the screen
    out = f'{OUT}/{locale}/search_3x2.mp4'
    os.makedirs(os.path.dirname(out), exist_ok=True)
    enc = subprocess.Popen([
        'ffmpeg', '-v', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
        '-s', f'{vw}x{vh}', '-r', str(fps), '-i', '-',
        '-c:v', 'libx264', '-preset', 'slow', '-crf', '18', '-pix_fmt', 'yuv420p',
        '-movflags', '+faststart', out,
    ], stdin=subprocess.PIPE)
    for i in range(total):
        t = i / fps
        frame = bg.copy()
        # Phone: rises and fades in over the first 0.8 s.
        k = ease(t / 0.8)
        screen = still if i < intro else shots[min(i - intro, len(shots) - 1)]
        p = phone_with(screen)
        px0 = round(px - p.width / 2)
        py0 = round(vh / 2 - p.height / 2 + (1 - k) * 160)
        frame.alpha_composite(faded(p, k), (px0, py0))
        # Ripple on each tap: a ring that spreads and fades over 0.4 s.
        j = i - intro
        if 0 <= j < len(shots):
            e = (j % per_tap) / 12
            if e <= 1:
                rx = px0 + pad + bezel + sw * tap_x
                ry = py0 + pad + bezel + sh * tap_y
                ring = Image.new('RGBA', (vw, vh), (0, 0, 0, 0))
                rd = ImageDraw.Draw(ring)
                r = 30 + 130 * ease(e)
                rd.ellipse((rx - r, ry - r, rx + r, ry + r), fill=(*SAFFRON, round(110 * (1 - e))),
                           outline=(*SAFFRON, round(255 * (1 - e))), width=10)
                if e < 0.4:
                    r0 = 40
                    rd.ellipse((rx - r0, ry - r0, rx + r0, ry + r0), fill=(255, 236, 200, round(210 * (1 - e / 0.4))))
                frame.alpha_composite(ring)
        # Words: lockup, then each line, 0.15 s apart, sliding up a little.
        for n, im in enumerate((lock, head1, head2)):
            kk = ease((t - 0.15 - n * 0.15) / 0.6)
            if kk > 0:
                frame.alpha_composite(faded(im, kk, (1 - kk) * 30))
        enc.stdin.write(frame.convert('RGB').tobytes())
    enc.stdin.close()
    enc.wait()
    if enc.returncode:
        raise RuntimeError(f'ffmpeg failed for {locale}')
    return out


if __name__ == '__main__':
    for locale in COPY:
        print(doodle_header(locale, 0.30, f'{OUT}/{locale}/universal_16x9.png'))
    for locale in COPY:
        print(search_motion(locale))
