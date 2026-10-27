"""Builds treatment B for the App Store product page test: the same app
captures as the store screenshots, on a bright cream and saffron page with
big two-line headlines and a larger phone running off the bottom, instead of
the maroon set (A, the original). The Sankalp shot moves up to third, since
search results show only the first three.

  appstore_assets/ab_test/B/<locale>/0N_<name>.png   1320×2868 (6.9")

English is written once for en-US, en-GB and en-AU. Run tool/screenshots.sh
first (it leaves the bare captures in build/store_raw/), then from the repo
root:  python3 tool/make_ab_screenshots.py
"""
import os
import shutil
import sys

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_creative_assets import FONT, ROOT, fit, phone  # noqa: E402

RAW = f'{ROOT}/build/store_raw'
OUT = f'{ROOT}/appstore_assets/ab_test/B'
BRAND = f'{ROOT}/ios/fastlane/screenshots/en-US/08_brand.png'
W, H = 1320, 2868
INK = (52, 22, 6)
RUST = (205, 84, 10)
SUB = (120, 70, 30)

# (output name, raw capture), in store order.
SHOTS = [
    ('01_counter', '01_counter'),
    ('02_mantras', '02_mantras'),
    ('03_sankalp', '06_sankalp'),
    ('04_music', '03_music'),
    ('05_blackout', '05_blackout'),
    ('06_habit', '04_habit'),
    ('07_themes', '07_themes'),
]

# locale -> (language, raw folder, {shot: (line 1, highlighted line 2, sub)}, ribbon)
COPY = {
    'en-US': ('en', 'en-US', {
        '01_counter': ('Tap Anywhere', 'to Chant', 'Radha · Ram · Shiv · Waheguru'),
        '02_mantras': ('21 Mantras', 'Ready to Chant', 'Or add your own'),
        '03_sankalp': ('11, 21 or 40 Day', 'Sankalp', 'Chant every day, see it done'),
        '04_music': ('Chant with', 'Calm Music', 'Or record your own'),
        '05_blackout': ('Chant in', 'the Dark', 'Black screen. Tap anywhere.'),
        '06_habit': ('Never Miss', 'a Day', 'Streaks and every day you chanted'),
        '07_themes': ('Make It', 'Your Own', '13 colour themes or your photo'),
    }, 'No ads · Private · Offline'),
    'hi': ('hi', 'hi', {
        '01_counter': ('कहीं भी टैप करें', 'जप करें', 'राधा · राम · शिव · वाहेगुरु'),
        '02_mantras': ('21 मंत्र', 'जप के लिए तैयार', 'या अपना मंत्र जोड़ें'),
        '03_sankalp': ('11, 21 या 40 दिन', 'का संकल्प', 'रोज़ जप करें, पूरा होते देखें'),
        '04_music': ('शांत संगीत', 'के साथ जप', 'या अपनी आवाज़ रिकॉर्ड करें'),
        '05_blackout': ('अंधेरे में', 'भी जप', 'काली स्क्रीन, कहीं भी टैप करें'),
        '06_habit': ('एक भी दिन', 'न छूटे', 'हर दिन का जप एक नज़र में'),
        '07_themes': ('जैसा चाहें', 'वैसा सजाएँ', '13 रंग या अपनी फ़ोटो'),
    }, 'विज्ञापन नहीं · निजी · बिना इंटरनेट'),
}
COPIES = {'en-US': ['en-GB', 'en-AU']}


def page():
    """Cream at the top warming to saffron, with a soft glow behind the phone."""
    img = Image.new('RGB', (W, H))
    d = ImageDraw.Draw(img)
    top, bottom = (255, 248, 236), (255, 206, 140)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)], fill=tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    glow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(glow).ellipse((-200, 900, W + 200, 2300), fill=150)
    img.paste((255, 178, 63), (0, 0), glow.filter(ImageFilter.GaussianBlur(160)))
    return img.convert('RGBA')


def ribbon(img, text, f):
    d = ImageDraw.Draw(img)
    w = f.getlength(text) + 80
    box = ((W - w) / 2, 150, (W + w) / 2, 150 + f.size * 1.9)
    d.rounded_rectangle(box, f.size, fill=INK)
    d.text((W / 2, (box[1] + box[3]) / 2), text, font=f, fill=(255, 228, 180), anchor='mm')


def shot(locale, name, raw):
    lang, raw_dir, lines, badge = COPY[locale]
    line1, line2, sub = lines[name]
    bold, regular = FONT[lang]
    img = page()
    first = name == '01_counter'
    if first:
        ribbon(img, badge, fit(badge, regular, W - 360, 44))
    d = ImageDraw.Draw(img)
    y = 330 if first else 210
    f1 = fit(line1, bold, W - 140, 160)
    f2 = fit(line2, bold, W - 140, f1.size)
    d.text((W / 2, y), line1, font=f1, fill=INK, anchor='mt')
    y += f1.size * 1.18
    d.text((W / 2, y), line2, font=f2, fill=RUST, anchor='mt')
    y += f2.size * 1.35
    f3 = fit(sub, regular, W - 200, 62)
    d.text((W / 2, y), sub, font=f3, fill=SUB, anchor='mt')
    # The phone is bigger than the page leaves room for: it runs off the
    # bottom, so the top of the app reads large in search results.
    p = phone(f'{RAW}/{raw_dir}/{raw}.png', 2200)
    pad = p.width * 0.12 / 1.24  # phone() leaves 12% of the body's width for the shadow
    img.alpha_composite(p, (round((W - p.width) / 2), round(y + f3.size * 1.7 - pad)))
    return img.convert('RGB')


if __name__ == '__main__':
    for locale in COPY:
        for name, raw in SHOTS:
            out = f'{OUT}/{locale}/{name}.png'
            os.makedirs(os.path.dirname(out), exist_ok=True)
            shot(locale, name, raw).save(out, optimize=True)
        brand = f'{ROOT}/ios/fastlane/screenshots/{locale}/08_brand.png'
        shutil.copy(brand, f'{OUT}/{locale}/08_brand.png')
        for copy in COPIES.get(locale, []):
            shutil.copytree(f'{OUT}/{locale}', f'{OUT}/{copy}', dirs_exist_ok=True)
        print(locale, 'done')
