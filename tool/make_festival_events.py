"""Builds the Kartik month and Diwali In-App Event images: the festival's
name, one line and a row of diyas beside the app's counter on the event's
mantra, over the Navratri event's maroon background. Kept short on purpose.

  appstore_assets/events/<event>/<locale>/card_16x9.png      3840×2160
  appstore_assets/events/<event>/<locale>/details_9x16.png   2160×3840

  kartik  Kartik month, 27 Oct – 24 Nov 2026, with Hare Krishna.
  diwali  11 Days to Diwali, 29 Oct – 8 Nov 2026, with Om Shri Mahalakshmyai
          Namah.

The phones are real captures. Make them first, then run from the repo root:
  for code in en hi; do SHOT_EVENTS=1 SHOT_LOCALE=$code flutter test \\
    screenshots/store_screenshots_test.dart --plain-name 'event captures'; done
  python3 tool/make_festival_events.py

App Store Connect covers the bottom of both images with the event name, so
the words sit high and the phone may run off the bottom.
"""
import os
import sys

from PIL import ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_creative_assets import PATTERN, phone  # noqa: E402
from make_navratri_event import (  # noqa: E402
    DETAILS_PATTERN, FONTS, ROOT, SS, background, diya, doodles, fit, icon, save,
)

OUT = f'{ROOT}/appstore_assets/events'
RAW = f'{ROOT}/build/store_raw'
GOLD = (255, 200, 120)
EN = (f'{FONTS}/Inter-Bold.ttf', f'{FONTS}/Inter-Medium.ttf')
HI = (f'{FONTS}/NotoSansDevanagari-Bold.ttf', f'{FONTS}/NotoSansDevanagari-Medium.ttf')

# event -> locale -> (title, sub, fonts)
COPY = {
    'kartik': {
        'en-US': ('Kartik Month', 'Daily Jaap Sankalp', EN),
        'hi': ('कार्तिक मास', 'रोज़ का जप संकल्प', HI),
    },
    'diwali': {
        'en-US': ('Diwali', '11-Day Lakshmi Jaap', EN),
        'hi': ('दिवाली', '11 दिन का लक्ष्मी जप', HI),
    },
}
RAW_DIR = {'en-US': 'en-US', 'hi': 'hi'}


def counter_phone(img, event, locale, cx, top, height):
    p = phone(f'{RAW}/{RAW_DIR[locale]}/event_{event}_counter.png', height)
    img.alpha_composite(p, (round(cx - p.width / 2), round(top)))
    return p


def card(event, locale):
    title, sub, (bold, regular) = COPY[event][locale]
    W, H = 3840 * SS, 2160 * SS
    img = background(W, H)
    doodles(img, PATTERN, W / 5244, alpha=0.18)
    counter_phone(img, event, locale, W * 0.74, H * 0.04, round(H * 1.05))

    # Just the name, one line, and the diyas, high on the left, clear of the
    # event name App Store Connect lays along the bottom.
    left, col = W * 0.08, 1700
    icon(img, left + H * 0.06, H * 0.12, round(H * 0.12))
    d = ImageDraw.Draw(img)
    f_title = fit(title, bold, col, 300)
    f_sub = fit(sub, regular, col, 140)
    y = H * 0.30
    d.text((left, y), title, font=f_title, fill='white', anchor='lt')
    y += f_title.size * 1.25
    d.text((left, y), sub, font=f_sub, fill=GOLD, anchor='lt')
    y += f_sub.size * 2.6
    for i in range(5):
        diya(img, left + W * 0.03 + i * W * 0.08, y, W * 0.026)
    return img


def details(event, locale):
    title, sub, (bold, regular) = COPY[event][locale]
    W, H = 2160 * SS, 3840 * SS
    img = background(W, H)
    doodles(img, DETAILS_PATTERN, SS, alpha=0.18)
    icon(img, W / 2, H * 0.05, round(W * 0.15))
    d = ImageDraw.Draw(img)
    f_title = fit(title, bold, 1800, 260)
    f_sub = fit(sub, regular, 1800, 120)
    y = H * 0.16
    d.text((W / 2, y), title, font=f_title, fill='white', anchor='mt')
    y += f_title.size * 1.2
    d.text((W / 2, y), sub, font=f_sub, fill=GOLD, anchor='mt')
    for i in range(5):
        diya(img, W / 2 + (i - 2) * W * 0.16, H * 0.33, W * 0.035)
    counter_phone(img, event, locale, W / 2, H * 0.37, round(H * 0.62))
    return img


if __name__ == '__main__':
    for event, locales in COPY.items():
        for locale in locales:
            save(card(event, locale), f'{OUT}/{event}/{locale}/card_16x9.png')
            save(details(event, locale), f'{OUT}/{event}/{locale}/details_9x16.png')
