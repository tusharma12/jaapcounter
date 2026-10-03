"""Builds every app-icon asset from appstore_assets/appicon.png.

That master is the rounded icon on a white backdrop. From it this makes:
  - a transparent rounded version (in-app, widgets, Android legacy icon)
  - a full-bleed square (store icons, iOS app icon, adaptive foreground art)
"""
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, glob, os

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = Image.open(f'{R}/appstore_assets/appicon.png').convert('RGB')
N = src.size[0]

# Backdrop = near-white pixels connected to a corner.
bg = src.copy()
for c in [(0, 0), (N - 1, 0), (0, N - 1), (N - 1, N - 1)]:
    ImageDraw.floodfill(bg, c, (255, 0, 255), thresh=40)
a = np.asarray(bg).astype(int)
back = (a[..., 0] == 255) & (a[..., 1] == 0) & (a[..., 2] == 255)
back_img = Image.fromarray((back * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))
back = np.asarray(back_img) > 0

alpha = Image.fromarray(((~back) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
rgba = src.convert('RGBA')
rgba.putalpha(alpha)
rgba.save(f'{R}/appstore_assets/appicon-transparent.png')

# Full bleed: fill the backdrop from the nearest icon pixels.
arr = np.asarray(src).astype(float)
known = (~back).astype(float)
num = arr * known[..., None]
out = arr.copy(); done = ~back
for radius in (4, 10, 24, 56, 120, 250):
    n = np.stack([np.asarray(Image.fromarray(num[..., c].clip(0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(radius))).astype(float) for c in range(3)], -1)
    k = np.asarray(Image.fromarray((known * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(radius))).astype(float) / 255
    take = (~done) & (k > 0.04)
    out[take] = (n / np.maximum(k[..., None], 1e-3))[take]
    done |= take
full = Image.fromarray(out.clip(0, 255).astype(np.uint8))
full.save(f'{R}/appstore_assets/appicon-fullbleed.png')

def put(img, path, size):
    Image.fromarray(np.asarray(img)).resize((size, size), Image.LANCZOS).save(path) if False else img.resize((size, size), Image.LANCZOS).save(path)

# iOS app icon set: same names/sizes as already there.
for p in glob.glob(f'{R}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png'):
    s = Image.open(p).size[0]
    put(full, p, s)
# Store icons (512, opaque).
for p in glob.glob(f'{R}/android/fastlane/metadata/android/*/images/icon.png'):
    put(full, p, 512)
# In-app logo + iOS widget icons (transparent, rounded).
put(rgba, f'{R}/assets/branding/app_icon.png', 384)
for p in glob.glob(f'{R}/ios/JapMalaWidget/Assets.xcassets/AppIcon.imageset/icon_widget_*.png'):
    put(rgba, p, Image.open(p).size[0])
# Android legacy launcher + adaptive foreground.
dens = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
for d, s in dens.items():
    base = f'{R}/android/app/src/main/res/mipmap-{d}'
    put(rgba, f'{base}/ic_launcher.png', s)
    fg = int(s * 108 / 48)
    canvas = Image.new('RGBA', (fg, fg), (0, 0, 0, 0))
    inner = int(fg * 320 / 432)
    canvas.paste(rgba.resize((inner, inner), Image.LANCZOS), ((fg - inner) // 2,) * 2)
    canvas.save(f'{base}/ic_launcher_foreground.png')
# iOS launch image: the icon, 120pt.
for name, s in {'LaunchImage.png': 120, 'LaunchImage@2x.png': 240, 'LaunchImage@3x.png': 360}.items():
    put(rgba, f'{R}/ios/Runner/Assets.xcassets/LaunchImage.imageset/{name}', s)
print('ok')
