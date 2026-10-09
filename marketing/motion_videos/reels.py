#!/usr/bin/env python3
"""Data-driven renderer for the 3-month content calendar (content_plan.py).

Each motion post is a list of beats: hook -> emotional/spiritual value ->
tiny insight -> the app appears naturally -> a quiet close. Sound design
uses a per-post devotional palette (temple bell, ghanti, singing bowl,
tanpura, Om, shankh, chimes, night crickets).

Usage:
  python3 marketing/motion_videos/reels.py              # every motion post
  python3 marketing/motion_videos/reels.py D01 D02      # selected posts
  python3 marketing/motion_videos/reels.py --sheet D01  # review contact sheet
  python3 marketing/motion_videos/reels.py --export     # calendar CSV/JSON
"""
import csv
import functools
import json
import math
import os
import subprocess
import sys
import unicodedata
import wave
from multiprocessing import Pool

import numpy as np
from PIL import Image, ImageDraw

import render as R
from render import (ACCENT_ON_LIGHT, BZ, CREAM_TEXT, DARK, FPS, GOLD, H, INK, LIGHT, NIGHT, PH, PHONE_CY, PW,
                    RCY, SAFFRON, SAFFRON_DEEP, SH, SR, SW, W, Track, add_mantra_screen, ball, base, bg,
                    blackout_screen, burst, caption_img, clamp, comp, comp_c, counter_screen, draw_diya,
                    draw_guru, draw_icon, draw_phone, draw_photo, draw_sage, draw_tabs, ease_back, ease_in,
                    ease_in_out, ease_out, env, flame_img, fit_size, font_for, glow, icon_img, is_indic, lerp,
                    list_screen, lowpass, mix_in, moon_img, noise, particles, phone_shake, progress_screen, prog,
                    rays_img, rrect, sadhana_screen, sankalp_chooser, scaled, slide, snd_key, snd_pop, snd_shimmer,
                    snd_tap, snd_tick, snd_whoosh, sound_rings, stars, status_bar, teardrop_pts, text_glow,
                    text_img, bead_sprite, soft_shadow, ALL_MANTRAS, L10N, CARD_Y0, CARD_H, CARD_GAP, _t)
from content_plan import POSTS

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'out', 'calendar')
BY_ID = {p['id']: p for p in POSTS}

# post bg -> (render bg kind, text on dark?)
THEMES = {'dawn': ('light', False), 'temple': ('temple', True), 'night': ('night', True), 'navy': ('navy', True),
          'dark': ('dark', True), 'lotus': ('lotus', False), 'sage': ('sagebg', False)}

ROSE = dict(bg=(255, 214, 224), card=(255, 236, 241), primary=(64, 22, 38), secondary=(140, 90, 110),
            tertiary=(180, 140, 155), track=(240, 192, 206), track_hi=(255, 226, 234), track_lo=(214, 160, 178),
            soft=(255, 236, 241), divider=(238, 196, 208))
OCEAN = dict(bg=(15, 59, 58), card=(24, 76, 74), primary=(236, 246, 244), secondary=(160, 204, 200),
             tertiary=(110, 154, 150), track=(40, 92, 90), track_hi=(70, 124, 120), track_lo=(24, 66, 64),
             soft=(30, 80, 70), divider=(36, 84, 82))
SAFF_T = dict(bg=(255, 153, 51), card=(255, 176, 92), primary=(60, 18, 0), secondary=(122, 31, 0),
              tertiary=(150, 60, 10), track=(255, 196, 130), track_hi=(255, 220, 170), track_lo=(232, 150, 70),
              soft=(255, 196, 130), divider=(240, 160, 80))

DEFAULT_DUR = dict(hook=2.8, line=3.2, big=3.0, list=4.6, mantra=5.2, quote=5.0, grid=4.6, app=5.6, close=3.2)


def clusters(s):
    """Split text into typed units (Devanagari matras and conjuncts stay with their base)."""
    out = []
    for ch in s:
        if out and out[-1] != ' ' and ch != ' ' and (unicodedata.category(ch) in ('Mn', 'Mc') or out[-1].endswith('्')):
            out[-1] += ch
        else:
            out.append(ch)
    return out


# ---------------------------------------------------------------- build

@functools.lru_cache(None)
def built(pid):
    p = BY_ID[pid]
    bgk, dark = THEMES[p.get('bg', 'dawn')]
    beats, t = [], 0.0
    tracks, bells, events = [], [], []
    raw = p['beats']
    for i, (kind, text, o) in enumerate(raw):
        o = dict(o)
        d = o.get('dur', DEFAULT_DUR[kind])
        s = t
        prev_app = i > 0 and raw[i - 1][0] == 'app'
        next_app = i + 1 < len(raw) and raw[i + 1][0] == 'app'
        o['enter'] = kind == 'app' and not prev_app
        o['exit'] = kind == 'app' and not next_app
        if kind == 'app':
            scr = o.get('screen', 'counter')
            to = o.get('to', 108)
            if scr in ('counter', 'music', 'blackout', 'themes', 'falling'):
                o['track'] = Track([(s + 0.5, o.get('from', 0), 'lin'), (s + 1.7, o.get('from', 0) + 3, 'lin'),
                                    (s + d - 1.0, to, 'inout')])
                tracks.append((o['track'], 'buzz' if scr == 'blackout' else 'tap'))
                if to >= 108:
                    bells.append(o['track'].done)
            elif scr == 'auto':
                o['track'] = Track([(s + 0.6, 40, 'lin'), (s + d - 0.4, 40 + int((d - 1.0) / 0.5), 'lin')])
                tracks.append((o['track'], 'tick'))
            elif scr in ('sankalp', 'sadhana'):
                st = s + (1.9 if scr == 'sankalp' else 0.5)
                o['track'] = Track([(st, o.get('day_from', 1), 'lin'), (s + d - 0.8, o.get('day_to', 23), 'inout')])
                tracks.append((o['track'], 'tick'))
                if o.get('day_to', 23) >= 40:
                    bells.append(o['track'].done)
                if scr == 'sankalp':
                    events.append((s + 1.3, 'tap', 0.7))
            elif scr == 'add':
                cl = clusters(o.get('typed', 'राधे राधे'))
                o['clusters'] = cl
                o['t0'] = s + 0.7
                o['save'] = s + 0.7 + 0.4 * len(cl) + 0.5
                for k in range(len(cl)):
                    events.append((o['t0'] + 0.4 * k, 'key', 0.5))
                events.append((o['save'], 'tap', 0.7))
            elif scr == 'list':
                events.append((s + 0.6, 'scroll', 0.3))
        elif kind == 'grid':
            n = o.get('n', 21)
            o['track'] = Track([(s + 0.6, o.get('from', 0), 'lin'), (s + d - 0.7, o.get('upto', n), 'inout')])
            tracks.append((o['track'], 'tick'))
            if o.get('upto', n) >= n:
                bells.append(o['track'].done)
        elif kind == 'list':
            for k in range(len(o['items'])):
                events.append((s + 0.7 + k * 0.9, 'pop', 0.45))
        elif kind == 'mantra':
            events.append((s + 0.2, 'accent', 0.6))
        beats.append(dict(kind=kind, text=text, o=o, start=s, end=s + d, dur=d, first=i == 0,
                          last=i == len(raw) - 1))
        t += d
    return dict(post=p, bgk=bgk, dark=dark, dur=t, beats=beats, tracks=tracks, bells=bells, events=events,
                lang=p.get('lang', 'en'))


# ---------------------------------------------------------------- visuals

@functools.lru_cache(None)
def petal_img(h, base_c, tip_c):
    ss = 3
    n_h, w = h * ss, int(h * 0.5) * ss
    R_ = w / 2
    yy, xx = np.mgrid[0:n_h, 0:w].astype(np.float32) + 0.5
    xc = xx - w / 2
    yf = 1 - yy / n_h  # 0 at base, 1 at tip
    r = R_ * np.sin(np.clip(yf, 0, 1) * math.pi) ** 0.8 * (1 - 0.35 * yf)
    alpha = np.clip((r - np.abs(xc)) / ss, 0, 1)
    b, tp = np.array(base_c, np.float32), np.array(tip_c, np.float32)
    m = np.clip(yf ** 1.3 + 0.25 * np.abs(xc) / max(R_, 1), 0, 1)[..., None]
    col = b * (1 - m) + tp * m
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    return im.resize((w // ss, h), Image.LANCZOS)


@functools.lru_cache(None)
def lotus_img(size):
    canvas = Image.new('RGBA', (size * 2, size * 2), (0, 0, 0, 0))
    c = size
    rows = ((int(size * 0.62), (255, 226, 232), (232, 120, 156), (-78, -52, -26, 26, 52, 78)),
            (int(size * 0.7), (255, 236, 240), (240, 96, 140), (-40, -14, 14, 40)),
            (int(size * 0.66), (255, 244, 246), (236, 84, 130), (0,)))
    for h, b, tp, angles in rows:
        pet = petal_img(h, b, tp)
        hold = Image.new('RGBA', (size * 2, size * 2), (0, 0, 0, 0))
        hold.alpha_composite(pet, (c - pet.width // 2, c - pet.height))
        for a in angles:
            canvas.alpha_composite(hold.rotate(-a, resample=Image.BICUBIC, center=(c, c)))
        if angles == (0,):
            canvas.alpha_composite(hold)
    return canvas.crop(canvas.getbbox())


@functools.lru_cache(None)
def bowl_img(w):
    ss = 4
    h = int(w * 0.62)
    im = Image.new('RGBA', (w * ss, h * ss), (170, 120, 60, 0))
    d = ImageDraw.Draw(im)
    d.ellipse((w * ss * 0.08, h * ss * 0.72, w * ss * 0.92, h * ss * 1.0), fill=(150, 36, 40))
    d.pieslice((0, -h * ss * 0.55, w * ss, h * ss * 0.86), 0, 180, fill=(176, 122, 58))
    d.pieslice((w * ss * 0.1, -h * ss * 0.48, w * ss * 0.55, h * ss * 0.78), 95, 150, fill=(214, 168, 96))
    d.ellipse((0, h * ss * 0.08, w * ss, h * ss * 0.32), fill=(226, 184, 110))
    d.ellipse((w * ss * 0.05, h * ss * 0.12, w * ss * 0.95, h * ss * 0.29), fill=(112, 74, 34))
    return im.resize((w, h), Image.LANCZOS)


def ring108(cv, cx, cy, R_, filled, a, dark, d=20, count=True):
    on = ball(d, SAFFRON, (255, 228, 165), (198, 112, 0))
    off = ball(d, (78, 64, 52), (110, 94, 80), (50, 40, 32)) if dark else ball(d, (226, 222, 214), (250, 249, 246), (196, 191, 182))
    gap = math.radians(6)
    for i in range(108):
        ang = math.pi / 2 + gap + i * (2 * math.pi - 2 * gap) / 107
        comp_c(cv, on if i < filled else off, cx + R_ * math.cos(ang), cy + R_ * math.sin(ang), a)
    if 0 < filled < 108:
        ang = math.pi / 2 + gap + (filled - 1) * (2 * math.pi - 2 * gap) / 107
        comp_c(cv, glow(34, SAFFRON), cx + R_ * math.cos(ang), cy + R_ * math.sin(ang), a)
    draw_guru(cv, cx, cy + R_ + 12, int(d * 1.8), a)
    if count:
        comp_c(cv, text_img(str(filled), 150, 'Bold', CREAM_TEXT if dark else INK), cx, cy - 10, a)


def flowing_mala(cv, cx, cy, tl, a, scale=1.0):
    pts = teardrop_pts(1080, 0.0)
    off = int(tl * 30)
    for i in range(108):
        x, y = pts[(i * 10 + off) % 1080]
        comp_c(cv, bead_sprite(int(19 * scale), 0), cx + x * 240 * scale, cy + y * 340 * scale, a)
    draw_guru(cv, cx, cy + 352 * scale, int(32 * scale), a)


def vis(cv, kind, tl, dur, cx, cy, a, dark, o):
    if a <= 0 or not kind or kind == 'none':
        return
    if kind == 'mala':
        n = int(o.get('mala_to', 108) * ease_in_out(prog(tl, 0.3, dur - 0.4)))
        ring108(cv, cx, cy, 300, n, a, dark)
    elif kind == 'hanging':
        flowing_mala(cv, cx, cy - 40, tl, a)
    elif kind == 'diya':
        draw_diya(cv, cx, cy + 120, 400, tl, a)
    elif kind == 'diyas':
        for k, dx in enumerate((-300, 0, 300)):
            draw_diya(cv, cx + dx, cy + 160 + (0 if k == 1 else 60), 240 if k != 1 else 300, tl + k, a)
    elif kind == 'lotus':
        comp_c(cv, glow(420, (255, 190, 200)), cx, cy, a * 0.55)
        comp_c(cv, lotus_img(300), cx, cy + 8 * math.sin(tl * 1.3), a)
    elif kind == 'om':
        comp_c(cv, rays_img().rotate(tl * 5, resample=Image.BILINEAR), cx, cy, a * 0.7)
        comp_c(cv, text_glow('ॐ', 420, SAFFRON, 26), cx, cy, a)
    elif kind == 'moon':
        comp_c(cv, glow(260, (210, 210, 255)), cx, cy, a * 0.4)
        comp_c(cv, moon_img(130), cx, cy, a)
    elif kind == 'fullmoon':
        comp_c(cv, glow(360, (230, 228, 255)), cx, cy, a * 0.5)
        comp_c(cv, ball(300, (250, 246, 232), (255, 255, 250), (214, 208, 196)), cx, cy, a)
    elif kind == 'sage':
        draw_sage(cv, tl, cx, cy, 520, a)
    elif kind == 'hand':
        draw_photo(cv, 1.0 + 0.05 * tl / max(dur, 0.1), a, cy)
    elif kind == 'bowl':
        sound_rings(cv, tl, cx, cy + 40, a)
        comp_c(cv, bowl_img(460), cx, cy + 80, a)
    elif kind == 'sun':
        rise = ease_out(prog(tl, 0, dur))
        y = cy + 260 - 220 * rise
        comp_c(cv, rays_img().rotate(tl * 3, resample=Image.BILINEAR), cx, y, a * 0.8)
        comp_c(cv, glow(420, (255, 190, 90)), cx, y, a * 0.7)
        comp_c(cv, ball(260, (255, 196, 80), (255, 236, 170), (246, 150, 40)), cx, y, a)
    elif kind == 'rays':
        comp_c(cv, rays_img().rotate(tl * 4, resample=Image.BILINEAR), cx, cy, a * 0.8)
    elif kind == 'flame':
        R.draw_flame(cv, cx, cy + 180, 300, tl, a)


# ---------------------------------------------------------------- beat drawing

@functools.lru_cache(None)
def hook_layout(text, size, dark):
    lines = text.split('\n')
    lh = size * (1.42 if is_indic(text) else 1.2)
    rows = []
    for ln in lines:
        acc = ln.startswith('*') and ln.endswith('*')
        ln = ln.strip('*')
        col = (SAFFRON if dark else ACCENT_ON_LIGHT) if acc else (CREAM_TEXT if dark else INK)
        f = font_for(ln, 'Bold', size)
        words = ln.split(' ')
        widths = [f.getlength(w) for w in words]
        rows.append((words, widths, f.getlength(' '), col))
    widest = max(sum(ws) + sp * (len(ws) - 1) for _, ws, sp, _ in rows)
    if widest > 960:
        return hook_layout(text, int(size * 960 / widest), dark)
    out, k = [], 0
    y0 = -lh * (len(rows) - 1) / 2
    for r, (words, widths, sp, col) in enumerate(rows):
        lw = sum(widths) + sp * (len(words) - 1)
        x = -lw / 2
        for w_, wd in zip(words, widths):
            out.append((text_img(w_, size, 'Bold', col), x + wd / 2, y0 + r * lh, k))
            x += wd + sp
            k += 1
    return tuple(out), lh * len(rows)


def draw_hook(cv, text, tl, a, dark, size=104, cy=820):
    words, block_h = hook_layout(text, size, dark)
    for img, dx, dy, k in words:
        p = prog(tl, 0.08 + 0.1 * k, 0.43 + 0.1 * k)
        if p <= 0:
            continue
        s = lerp(0.7, 1.0, ease_back(p, 2.0))
        comp_c(cv, scaled(img, s), W / 2 + dx, cy + dy + (1 - ease_out(p)) * 24, a * min(1, p * 1.6))
    return block_h


def draw_chip(cv, text, cy, a, dark):
    t = text_img(text, 34, 'SemiBold', (60, 30, 10) if not dark else (40, 20, 6))
    chip = rrect((t.width + 50, 64), 32, SAFFRON if dark else (255, 228, 186))
    comp_c(cv, chip, W / 2, cy, a)
    comp_c(cv, t, W / 2, cy, a)


def draw_caption_at(cv, text, tl, a, dark, y=360, size=78):
    rise = (1 - ease_out(prog(tl, 0, 0.7))) * 36
    comp_c(cv, caption_img(text, size, dark), W / 2, y + rise, a)


def widget_screen(t, s, lang):
    img = Image.new('RGBA', (SW, SH), (0, 0, 0, 255))
    yy = np.linspace(0, 1, SH, dtype=np.float32)[:, None, None]
    col = np.broadcast_to(np.array((232, 150, 90), np.float32) * (1 - yy) + np.array((120, 60, 110), np.float32) * yy, (SH, SW, 3))
    img = Image.fromarray(np.dstack([col, np.full((SH, SW), 255, np.float32)]).astype(np.uint8), 'RGBA')
    status_bar(img, LIGHT, light_text=True)
    pop = ease_back(prog(t, s + 0.6, s + 1.2)) if t < s + 1.2 else 1.0
    wd = rrect((480, 230), 40, (255, 250, 242))
    comp_c(img, scaled(wd, max(0.05, pop)), SW / 2, 230, prog(t, s + 0.5, s + 0.8))
    if t > s + 1.0:
        a = prog(t, s + 1.0, s + 1.4)
        d = ImageDraw.Draw(img)
        frac = 0.57 * ease_out(prog(t, s + 1.0, s + 2.2))
        d.arc((60, 150, 220, 310), -90, 270, fill=(236, 222, 200), width=16)
        d.arc((60, 150, 220, 310), -90, -90 + 360 * frac, fill=SAFFRON, width=16)
        comp_c(img, text_img(f'{int(612 * frac / 0.57)}', 44, 'Bold', INK), 140, 228, a)
        L = L10N[lang]
        comp(img, text_img(L['todays_jaap'], 24, 'Medium', (120, 106, 96)), 250, 160, a)
        comp(img, text_img('राम राम' if lang == 'hi' else 'Ram Ram', 34, 'Bold', INK), 250, 196, a)
        comp(img, text_img(L['streak_chip'].format(22), 24, 'SemiBold', SAFFRON_DEEP), 250, 252, a)
    pal = [(250, 120, 110), (110, 170, 240), (120, 200, 140), (250, 200, 90), (180, 140, 230), (240, 150, 190),
           (100, 200, 210), (250, 170, 110)]
    for k in range(16):
        x, y = 60 + (k % 4) * 142, 420 + (k // 4) * 160
        comp_c(img, rrect((104, 104), 26, pal[k % len(pal)]), x + 52, y + 52)
    dock = rrect((500, 130), 40, (255, 255, 255, 90))
    comp_c(img, dock, SW / 2, SH - 110)
    for k in range(4):
        comp_c(img, rrect((96, 96), 24, pal[(k * 3) % 8]), 92 + k * 122, SH - 110)
    return img


THEME_CYCLE = (LIGHT, NIGHT, ROSE, OCEAN, SAFF_T, DARK)


def app_screen(b, t, lang):
    o = b['o']
    scr = o.get('screen', 'counter')
    s = b['start']
    mantra = o.get('mantra', 'राम राम' if lang == 'hi' else 'Ram Ram')
    if scr in ('counter', 'falling'):
        return counter_screen(LIGHT, mantra, o['track'], t, lang=lang, falling=scr == 'falling' or o.get('falling', False))
    if scr == 'music':
        return counter_screen(NIGHT, mantra, o['track'], t, lang=lang, toolbar=True, active_tool=0)
    if scr == 'auto':
        return counter_screen(LIGHT, mantra, o['track'], t, lang=lang, toolbar=True, active_tool=2)
    if scr == 'blackout':
        return blackout_screen(mantra, o['track'], t, lang)
    if scr == 'themes':
        k = int((t - s) / 1.0)
        a_th, b_th = THEME_CYCLE[k % 6], THEME_CYCLE[(k + 1) % 6]
        x = ease_in_out(clamp(((t - s) % 1.0 - 0.7) / 0.3))
        im1 = counter_screen(a_th, mantra, o['track'], t, lang=lang, falling=True)
        if x <= 0:
            return im1
        return Image.blend(im1, counter_screen(b_th, mantra, o['track'], t, lang=lang, falling=True), x)
    if scr == 'sankalp':
        if t < s + 1.8:
            return sankalp_chooser(t, s + 1.3, lang)
        return slide(sankalp_chooser(t, s + 1.3, lang), sadhana_screen(o['track'], t, lang), prog(t, s + 1.8, s + 2.2))
    if scr == 'sadhana':
        return sadhana_screen(o['track'], t, lang)
    if scr == 'progress':
        return progress_screen(t, s, lang)
    if scr == 'list':
        items = ALL_MANTRAS if lang == 'en' else [(dv, None) for _, dv in ALL_MANTRAS]
        mx = CARD_Y0 + len(items) * (CARD_H + CARD_GAP) - SH + 40
        return list_screen(mx * ease_in_out(prog(t, s + 0.6, s + b['dur'] - 0.6)), 0, -1, 0, LIGHT, lang, items)
    if scr == 'add':
        return add_mantra_screen(t, o['t0'], o['save'], lang, o['clusters'], o.get('size_sel', 0))
    if scr == 'widget':
        return widget_screen(t, s, lang)
    raise ValueError(scr)


def draw_beat(cv, b, t, P):
    kind, text, o = b['kind'], b['text'], b['o']
    dark, lang = P['dark'], P['lang']
    tl = t - b['start']
    a_in = 1.0 if b['first'] else prog(t, b['start'], b['start'] + 0.4)
    a_out = 1.0 if b['last'] else 1 - prog(t, b['end'] - 0.3, b['end'])
    a = a_in * a_out
    if a <= 0:
        return
    if kind == 'hook':
        if o.get('vis'):
            vis(cv, o['vis'], tl, b['dur'], 540, o.get('vis_y', 1380), a, dark, o)
        cy = o.get('y', 820 if o.get('vis') else 900)
        bh = draw_hook(cv, text, tl, a, dark, o.get('size', 104), cy)
        if o.get('chip'):
            draw_chip(cv, o['chip'], cy - bh / 2 - 70, a * prog(tl, 0, 0.3), dark)
    elif kind == 'line':
        vis(cv, o.get('vis'), tl, b['dur'], 540, o.get('vis_y', 1160), a, dark, o)
        draw_caption_at(cv, text, tl, a, dark, o.get('y', 380), o.get('size', 78))
        if o.get('chip'):
            draw_chip(cv, o['chip'], 200, a, dark)
    elif kind == 'big':
        vis(cv, o.get('vis'), tl, b['dur'], 540, 900, a * 0.8, dark, o)
        p = prog(tl, 0.1, 0.8)
        g = text_glow(text, o.get('size', 300), SAFFRON, 28)
        comp_c(cv, scaled(g, lerp(0.86, 1.0, ease_out(p))), 540, 880, a * p)
        if o.get('sub'):
            draw_caption_at(cv, o['sub'], max(0, tl - 0.5), a * prog(tl, 0.5, 0.9), dark, 1180, 60)
        if o.get('top'):
            draw_caption_at(cv, o['top'], tl, a, dark, 420, 70)
    elif kind == 'list':
        draw_caption_at(cv, text, tl, a, dark, 360, o.get('size', 74))
        items = o['items']
        y0 = 1080 - (len(items) - 1) * 125
        for k, it in enumerate(items):
            p = prog(tl, 0.7 + k * 0.9, 1.1 + k * 0.9)
            if p <= 0:
                continue
            y = y0 + k * 250
            card = rrect((900, 190), 40, (255, 255, 255, 34) if dark else (255, 255, 255))
            if not dark:
                comp_c(cv, soft_shadow(900, 190, 40, 14, 50), 540, y + 12, a * p)
            comp_c(cv, card, 540 + (1 - ease_out(p)) * 80, y, a * p)
            comp_c(cv, ball(56, SAFFRON, (255, 228, 165), (198, 112, 0)), 150 + (1 - ease_out(p)) * 80, y, a * p)
            sz = fit_size(it, 50, 700, 'SemiBold')
            ti = text_img(it, sz, 'SemiBold', CREAM_TEXT if dark else INK)
            comp(cv, ti, 205 + (1 - ease_out(p)) * 80, y - ti.height / 2, a * p)
    elif kind == 'mantra':
        n = int(108 * ease_in_out(prog(tl, 0.4, b['dur'] - 0.4)))
        ring108(cv, 540, 900, 430, n, a * 0.9, dark, d=22, count=False)
        lines = text.split('\n')
        sz = min(fit_size(ln, o.get('size', 120), 720) for ln in lines)
        lh = sz * 1.45
        for k, ln in enumerate(lines):
            comp_c(cv, text_img(ln, sz, 'Bold', SAFFRON if dark else (150, 60, 0)), 540,
                   880 - lh * (len(lines) - 1) / 2 + k * lh, a * prog(tl, 0.1, 0.6))
        if o.get('translit'):
            tr = text_img(o['translit'], fit_size(o['translit'], 44, 900, 'Medium'), 'Medium',
                          (230, 214, 196) if dark else (110, 90, 74))
            comp_c(cv, tr, 540, 1500, a * prog(tl, 0.6, 1.0))
        if o.get('meaning'):
            draw_caption_at(cv, o['meaning'], max(0, tl - 1.0), a * prog(tl, 1.0, 1.4), dark, 1610, 50)
        if o.get('top'):
            draw_caption_at(cv, o['top'], tl, a, dark, 290, 64)
    elif kind == 'quote':
        comp_c(cv, rays_img().rotate(tl * 3, resample=Image.BILINEAR), 540, 900, a * 0.5)
        comp_c(cv, text_img('“', 220, 'Bold', SAFFRON), 540, 560, a * 0.8)
        lines = []
        for ln in text.split('\n'):
            if font_for(ln, 'SemiBold', o.get('size', 66)).getlength(ln) > 940 and ', ' in ln:
                head, tail = ln.split(', ', 1)
                lines += [head + ',', tail]
            else:
                lines.append(ln)
        sz = min(fit_size(ln, o.get('size', 66), 940, 'SemiBold') for ln in lines)
        lh = sz * (1.5 if is_indic(text) else 1.28)
        for k, ln in enumerate(lines):
            p = prog(tl, 0.2 + k * 0.35, 0.7 + k * 0.35)
            comp_c(cv, text_img(ln, sz, 'SemiBold', CREAM_TEXT if dark else INK), 540,
                   920 - lh * (len(lines) - 1) / 2 + k * lh + (1 - ease_out(p)) * 20, a * p)
        if o.get('by'):
            by = text_img('— ' + o['by'], 42, 'SemiBold', SAFFRON if dark else ACCENT_ON_LIGHT)
            comp_c(cv, by, 540, 920 + lh * len(lines) / 2 + 90, a * prog(tl, 1.0, 1.5))
        if o.get('meaning'):
            draw_caption_at(cv, o['meaning'], max(0, tl - 1.6), a * prog(tl, 1.6, 2.0), dark, 1500, 50)
    elif kind == 'grid':
        draw_caption_at(cv, text, tl, a, dark, 360)
        n = o.get('n', 21)
        cols = {9: 9, 11: 11, 21: 7, 40: 10, 90: 10}.get(n, 7)
        if n == 11:
            cols = 6
        rows = math.ceil(n / cols)
        step = min(900 / cols, 760 / rows)
        dm = int(step * 0.72)
        filled = o['track'].val(t)
        on = ball(dm, SAFFRON, (255, 228, 165), (198, 112, 0))
        off = ball(dm, (78, 64, 52), (110, 94, 80), (50, 40, 32)) if dark else ball(dm, (226, 222, 214), (250, 249, 246), (196, 191, 182))
        y0 = 1060 - (rows - 1) * step / 2
        for i in range(n):
            r, c = divmod(i, cols)
            inrow = min(cols, n - r * cols)
            x = 540 + (c - (inrow - 1) / 2) * step
            y = y0 + r * step
            comp_c(cv, on if i < filled else off, x, y, a)
            if i == filled - 1 and t < o['track'].done + 0.3:
                comp_c(cv, glow(int(dm * 0.9), SAFFRON), x, y, a * 0.8)
        lab = o.get('label', 'Day {}' if P['lang'] == 'en' else 'दिन {}').format(max(1, filled))
        comp_c(cv, text_img(lab, 84, 'Bold', CREAM_TEXT if dark else INK), 540, y0 + rows * step + 70, a)
        if filled >= n:
            burst(cv, t - o['track'].done, 540, 1060)
    elif kind == 'app':
        s = b['start']
        enter = ease_out(prog(t, s, s + 0.8)) if o['enter'] else 1.0
        out = ease_in_out(prog(t, b['end'] - 0.45, b['end'])) if (o['exit'] and not b['last']) else 0.0
        cy = lerp(H + PH / 2 + 40, PHONE_CY, enter)
        trk = o.get('track')
        cx = 540 + (phone_shake(trk, t) if (trk is not None and o.get('screen', 'counter') in ('counter', 'falling', 'themes', 'music')) else 0)
        if o.get('vis'):
            vis(cv, o['vis'], tl, b['dur'], 540, 1160, a * 0.5, dark, o)
        draw_phone(cv, app_screen(b, t, lang), cx, cy, lerp(1, 0.9, out), (1 - out) * (a_out if b['last'] else 1))
        if trk is not None and trk.keys[-1][1] >= 108 and o.get('screen', 'counter') != 'auto':
            burst(cv, t - trk.done, cx, RCY + BZ - PH / 2 + cy)
        if text:
            draw_caption_at(cv, text, tl, a, dark, 330, o.get('size', 76))
        if o.get('chip'):
            draw_chip(cv, o['chip'], 175, a, dark)
    elif kind == 'close':
        if o.get('vis'):
            vis(cv, o['vis'], tl, b['dur'], 540, 1500, a * 0.8, dark, o)
        p = prog(tl, 0.1, 0.8)
        comp_c(cv, caption_img(text, o.get('size', 84), dark), 540, 860 + (1 - ease_out(p)) * 30, a * p)
        if o.get('brand', True):
            pb = prog(tl, 0.7, 1.3)
            tw = text_img(L10N[lang]['brand'], 64, 'Bold', CREAM_TEXT if dark else INK)
            gw = 130 + 26 + tw.width
            x0 = 540 - gw / 2
            draw_icon(cv, x0 + 65, 1120, 130, a * pb)
            comp(cv, tw, x0 + 156, 1120 - tw.height / 2, a * pb)


def render_post(pid, t):
    P = built(pid)
    cv = base(P['bgk'])
    if P['bgk'] in ('night', 'navy'):
        stars(cv, t, 0.7)
    particles(cv, t, 0.45 if not P['dark'] else 0.35)
    for b in P['beats']:
        if b['start'] - 0.01 <= t <= b['end'] + 0.01:
            draw_beat(cv, b, t, P)
    return R.finish(cv, t, P['dur'], 0.8, to=P['bgk'])


# ---------------------------------------------------------------- devotional sound palette

def temple_bell(f0=440.0, dur=6.0, bright=1.0):
    t = _t(dur)
    out = np.zeros_like(t)
    for r, a, dk in ((0.5, 0.5, 0.35), (1.0, 1.0, 0.6), (1.19, 0.45, 0.9), (1.5, 0.35, 1.1), (2.0, 0.4, 1.3),
                     (2.51, 0.25, 1.9), (2.66, 0.2, 2.1), (3.01, 0.15, 2.6), (4.17, 0.1 * bright, 3.5)):
        out += a * np.sin(2 * np.pi * f0 * r * t + r) * np.exp(-t * dk) * (1 + 0.15 * np.sin(2 * np.pi * (1.3 + r) * t))
    n = noise(2400, 77)
    strike = (n - lowpass(n, 1500)) * env(_t(0.05), 0.0005, 120) * 0.4
    out = out / 2.6 * np.clip(t / 0.002, 0, 1)
    out[:len(strike)] += strike
    return out


def ghanti(dur=2.6, f0=1480.0, seed=3):
    """Puja hand bell: the clapper strikes quickly and irregularly."""
    rng = np.random.default_rng(seed)
    out = np.zeros(int(SR * dur))
    tt, k = 0.0, 0
    t = _t(1.0)
    hit = sum(a * np.sin(2 * np.pi * f0 * r * t) * np.exp(-t * dk)
              for r, a, dk in ((1, 1, 3.0), (2.32, 0.5, 4.5), (3.93, 0.3, 6.5), (5.6, 0.15, 9)))
    while tt < 1.5:
        i = int(tt * SR)
        g = (1.0 if k % 2 == 0 else 0.7) * (1 - tt / 2.2)
        m = min(len(hit), len(out) - i)
        out[i:i + m] += hit[:m] * g
        tt += rng.uniform(0.085, 0.13)
        k += 1
    return out / 3.0


def singing_bowl(f0=196.0, dur=9.0, attack=0.01):
    t = _t(dur)
    out = np.zeros_like(t)
    for r, a, dk in ((1, 1.0, 0.28), (2.76, 0.5, 0.45), (5.4, 0.25, 0.8), (8.9, 0.1, 1.2)):
        bt = 1.6 * r
        out += a * 0.5 * (np.sin(2 * np.pi * (f0 * r - bt / 2) * t) + np.sin(2 * np.pi * (f0 * r + bt / 2) * t)) * np.exp(-t * dk)
    return out * np.clip(t / attack, 0, 1) / 1.9


def tanpura(dur, root=130.81):
    """Pa-Sa-Sa-Sa drone, plucked every ~0.95s, with jawari shimmer."""
    out = np.zeros((int(SR * dur), 2))
    notes = (root * 1.5, root * 2, root * 2, root)
    t = _t(3.8)
    plucks = {}
    for f in set(notes):
        y = np.zeros_like(t)
        for k in range(1, 19):
            if f * k > 9000:
                break
            amp = k ** -0.75 * np.exp(-t * (0.5 + 0.07 * k)) * (0.6 + 0.4 * np.sin(2 * np.pi * (0.4 + 0.03 * k) * t + k))
            y += amp * np.sin(2 * np.pi * f * k * t)
        plucks[f] = y * np.clip(t / 0.01, 0, 1) / 4.0
    tt, k = 0.0, 0
    while tt < dur:
        pan = (-0.3, 0.2, -0.1, 0.3)[k % 4]
        mix_in(out, tt, plucks[notes[k % 4]], 1.0, pan)
        tt += 0.95
        k += 1
    return out


def drone(dur, root=130.81):
    t = _t(dur)
    y = (np.sin(2 * np.pi * root * t) + 0.5 * np.sin(2 * np.pi * root * 1.5 * t) + 0.3 * np.sin(2 * np.pi * root * 2 * t))
    y *= 0.7 + 0.3 * np.sin(2 * np.pi * 0.15 * t)
    return y / 2.0


def om_chant(dur=5.0, f0=98.0):
    """Additive 'AUM': A -> O/U -> M by moving the formants and closing the mouth."""
    t = _t(dur)
    x = t / dur
    phase = 2 * np.pi * np.cumsum(f0 * (1 + 0.004 * np.sin(2 * np.pi * 5.2 * t))) / SR
    F1 = np.interp(x, (0, 0.25, 0.4, 0.55, 0.65, 1), (700, 700, 450, 350, 250, 250))
    F2 = np.interp(x, (0, 0.25, 0.4, 0.55, 0.65, 1), (1150, 1150, 800, 700, 900, 900))
    G = np.interp(x, (0, 0.55, 0.7, 1), (1, 0.8, 0.08, 0.05))
    out = np.zeros_like(t)
    for k in range(1, 40):
        fk = k * f0
        a = (np.exp(-((fk - F1) / 110) ** 2) + G * 0.6 * np.exp(-((fk - F2) / 140) ** 2)
             + G * 0.25 * np.exp(-((fk - 2600) / 220) ** 2) + 0.03 / k)
        out += a * np.sin(k * phase)
    out += 0.6 * np.sin(phase / 2)
    e = np.clip(t / 0.35, 0, 1) * np.clip((dur - t) / 0.9, 0, 1)
    return out * e / (np.max(np.abs(out)) + 1e-9)


def shankh(dur=3.2, f0=311.0):
    """Conch: breathy horn with a slight upward bend."""
    t = _t(dur)
    f = f0 * (1 + 0.06 * np.clip(t / 0.4, 0, 1)) * (1 + 0.006 * np.sin(2 * np.pi * 5 * t) * np.clip(t - 0.5, 0, 1))
    phase = 2 * np.pi * np.cumsum(f) / SR
    out = np.zeros_like(t)
    for k in range(1, 15):
        fk = k * f0
        a = np.exp(-((fk - 900) / 400) ** 2) + 0.5 * np.exp(-((fk - 1800) / 500) ** 2) + 0.1 / k
        out += a * np.sin(k * phase)
    n = noise(len(t), 12)
    out += lowpass(n, 2000) * 0.25
    e = np.clip(t / 0.25, 0, 1) * np.clip((dur - t) / 0.7, 0, 1)
    return out * e / (np.max(np.abs(out)) + 1e-9)


def crickets(dur):
    out = np.zeros((int(SR * dur), 2))
    for c, (fc, pan, per) in enumerate(((4400, -0.6, 0.83), (4900, 0.6, 0.71))):
        tt = c * 0.3
        t = _t(0.03)
        pulse = np.sin(2 * np.pi * fc * t) * np.sin(np.pi * t / 0.03)
        while tt < dur:
            for p in range(3):
                mix_in(out, tt + p * 0.045, pulse, 0.25, pan)
            tt += per
    return out


def chimes(dur, density=1.2, seed=8):
    rng = np.random.default_rng(seed)
    out = np.zeros((int(SR * (dur + 2)), 2))
    t = _t(2.2)
    for _ in range(int(dur * density)):
        f = rng.choice((1046.5, 1174.7, 1318.5, 1568.0, 1760.0, 2093.0))
        y = sum(a * np.sin(2 * np.pi * f * r * t) * np.exp(-t * dk) for r, a, dk in ((1, 1, 1.8), (2.76, 0.4, 3.5), (5.4, 0.15, 6)))
        mix_in(out, rng.uniform(0, dur), y * rng.uniform(0.3, 0.8), 0.5, rng.uniform(-0.7, 0.7))
    return out[:int(SR * dur)]


PALETTES = {
    'temple': dict(bed=[('tanpura', 0.22)], hook=[('temple_bell', 0.8, 0)], accent=('ghanti', 0.3),
                   close=[('temple_bell', 0.7, 0), ('ghanti', 0.45, 0.4)]),
    'bowl': dict(bed=[('drone', 0.06), ('bowl_soft', 0.0)], hook=[('bowl', 0.9, 0)], accent=('chime', 0.35),
                 close=[('bowl', 0.8, 0)]),
    'om': dict(bed=[('tanpura', 0.16)], hook=[('om', 0.75, 0)], accent=('chime', 0.3),
               close=[('om', 0.55, 0), ('temple_bell', 0.35, 0.6)]),
    'night': dict(bed=[('crickets', 0.12), ('drone', 0.05)], hook=[('low_bell', 0.6, 0)], accent=('chime', 0.3),
                  close=[('bowl', 0.6, 0)]),
    'conch': dict(bed=[('tanpura', 0.2)], hook=[('shankh', 0.6, 0), ('temple_bell', 0.6, 2.4)],
                  accent=('ghanti', 0.3), close=[('temple_bell', 0.7, 0), ('ghanti', 0.45, 0.4)]),
    'chimes': dict(bed=[('chimes_bed', 0.5), ('drone', 0.05)], hook=[('chime', 0.6, 0), ('bowl', 0.5, 0.2)],
                   accent=('chime', 0.35), close=[('bowl', 0.6, 0)]),
}


def one_shot(name):
    if name == 'temple_bell':
        return temple_bell(440)
    if name == 'low_bell':
        return temple_bell(262, 6, 0.4)
    if name == 'ghanti':
        return ghanti()
    if name == 'bowl':
        return singing_bowl(196)
    if name == 'om':
        return om_chant()
    if name == 'shankh':
        return shankh()
    if name == 'chime':
        return chimes(2.5, 2.0, seed=11)
    if name == 'tap':
        return snd_tap(1)
    if name == 'key':
        return snd_key(2)
    if name == 'pop':
        return snd_pop(True)
    if name == 'tick':
        return snd_tick()
    if name == 'buzz':
        return R.snd_buzz()
    if name == 'scroll':
        return snd_whoosh(2.0, 0.5, 49) * 0.6
    raise ValueError(name)


def bed(name, dur):
    if name == 'tanpura':
        return tanpura(dur)
    if name == 'drone':
        return drone(dur)
    if name == 'crickets':
        return crickets(dur)
    if name == 'chimes_bed':
        return chimes(dur, 0.8)
    if name == 'bowl_soft':
        out = np.zeros((int(SR * dur), 2))
        for tt in np.arange(3.0, dur, 6.0):
            mix_in(out, tt, singing_bowl(147, 8, 0.6) * 0.35, 1.0)
        return out
    raise ValueError(name)


def write_audio(pid, path):
    P = built(pid)
    pal = PALETTES[P['post'].get('sound', 'temple')]
    D = P['dur']
    buf = np.zeros((int(SR * D), 2))
    fade = np.clip(np.arange(len(buf)) / (1.2 * SR), 0, 1) * np.clip((len(buf) - np.arange(len(buf))) / (1.2 * SR), 0, 1)
    for name, gain in pal['bed']:
        b = bed(name, D)
        if b.ndim == 1:
            b = np.stack([b, b], 1)
        bmax = np.max(np.abs(b)) or 1
        g = gain if name != 'bowl_soft' else 0.25
        buf += b[:len(buf)] / bmax * g * fade[:, None]
    for name, gain, dt in pal['hook']:
        mix_in(buf, 0.05 + dt, one_shot(name), gain)
    for k, b in enumerate(P['beats'][1:], 1):
        mix_in(buf, b['start'] - 0.15, snd_whoosh(0.6, 0.5, 60 + k), 0.22)
        if b['kind'] not in ('app', 'close'):
            nm, g = pal['accent']
            mix_in(buf, b['start'] + 0.05, one_shot(nm), g * 0.7)
    last = P['beats'][-1]
    if last['kind'] == 'close':
        for name, gain, dt in pal['close']:
            mix_in(buf, last['start'] + 0.2 + dt, one_shot(name), gain)
    tap_cache = [snd_tap(s) for s in range(6)]
    for tr, kind in P['tracks']:
        lastt, prev, tt, k = -1.0, tr.val(tr.start - 0.01), tr.start - 0.01, 0
        snd1 = None if kind == 'tap' else one_shot(kind)
        while tt <= tr.done + 0.01:
            v = tr.val(tt)
            if v > prev and tt - lastt >= 0.07:
                g = (0.7 if tt - lastt > 0.2 else 0.3) * (1 if kind == 'tap' else 0.75)
                mix_in(buf, tt, tap_cache[k % 6] if snd1 is None else snd1, g, 0.12 * math.sin(k * 2.1))
                lastt, k = tt, k + 1
            prev = v
            tt += 1 / 600
    for bt in P['bells']:
        mix_in(buf, bt, temple_bell(523.25, 5, 0.8), 0.55)
        mix_in(buf, bt + 0.05, snd_shimmer(1.6, 24, seed=31), 0.9)
    for tt, name, gain in P['events']:
        mix_in(buf, tt, one_shot(pal['accent'][0] if name == 'accent' else name), gain)
    peak = np.max(np.abs(buf)) or 1
    pcm = (buf / peak * 0.89 * 32767).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


# ---------------------------------------------------------------- driver

def frame_job(args):
    pid, i = args
    return render_post(pid, i / FPS).convert('RGB').tobytes()


def out_name(p):
    return f"{p['id']}_{p['date']}_{p['slug']}.mp4"


def render_one(pid, pool):
    P = built(pid)
    D = P['dur']
    n = int(round(D * FPS))
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, f'.{pid}.wav')
    write_audio(pid, wav)
    out = os.path.join(OUT, out_name(P['post']))
    fc = "[1:a]aecho=0.85:0.8:45|100|180:0.18|0.1|0.06,volume=5dB,alimiter=limit=0.8:attack=2:release=60:level=0[a]"
    cmd = ['ffmpeg', '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}',
           '-r', str(FPS), '-i', '-', '-i', wav, '-filter_complex', fc, '-map', '0:v', '-map', '[a]',
           '-c:v', 'libx264', '-preset', 'medium', '-crf', '19', '-pix_fmt', 'yuv420p', '-c:a', 'aac',
           '-b:a', '160k', '-t', f'{D:.3f}', '-movflags', '+faststart', out]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    for buf in pool.imap(frame_job, [(pid, i) for i in range(n)], chunksize=4):
        proc.stdin.write(buf)
    proc.stdin.close()
    proc.wait()
    os.remove(wav)
    print('wrote', out, flush=True)


def sheet(pid, step=0.8, cols=7):
    P = built(pid)
    times = np.arange(0.3, P['dur'], step)
    tw, th = W // 5, H // 5
    rows = math.ceil(len(times) / cols)
    sh = Image.new('RGB', (cols * tw, rows * (th + 20)), (255, 255, 255))
    d = ImageDraw.Draw(sh)
    for k, t in enumerate(times):
        im = render_post(pid, float(t)).convert('RGB').resize((tw, th), Image.LANCZOS)
        x, y = (k % cols) * tw, (k // cols) * (th + 20)
        sh.paste(im, (x, y + 20))
        d.text((x + 4, y + 3), f'{pid} {t:.1f}s', fill=(0, 0, 0))
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, f'sheet_{pid}.png')
    sh.save(path)
    print('wrote', path)


def export():
    rows = []
    for p in POSTS:
        motion = p['format'] == 'motion'
        rows.append(dict(
            id=p['id'], date=p['date'], day=p['day'], week=p['week'], pillar=p['pillar'], format=p['format'],
            lang=p['lang'], title=p['title'], hook=p['hook'], occasion=p.get('occasion', ''),
            sound=p.get('sound', ''), video=('out/calendar/' + out_name(p)) if motion else '',
            duration=round(built(p['id'])['dur'], 1) if motion else p.get('ugc', {}).get('length', ''),
            on_screen=' / '.join(b[1].replace('*', '').replace('\n', ' ') for b in p.get('beats', []) if b[1]),
            caption=p['caption'], hashtags=p['tags'], ugc=p.get('ugc'), notes=p.get('notes', '')))
    base_dir = os.path.join(HERE, 'out')
    with open(os.path.join(base_dir, 'content_calendar.json'), 'w') as f:
        json.dump(rows, f, ensure_ascii=False, indent=1)
    with open(os.path.join(base_dir, 'content_calendar.csv'), 'w', newline='') as f:
        w = csv.writer(f)
        cols = ['id', 'date', 'day', 'week', 'pillar', 'format', 'lang', 'title', 'hook', 'occasion', 'sound',
                'video', 'duration', 'on_screen', 'caption', 'hashtags', 'ugc_creator', 'ugc_shots', 'ugc_voiceover',
                'ugc_app_moment', 'notes']
        w.writerow(cols)
        for r in rows:
            u = r['ugc'] or {}
            w.writerow([r[c] for c in cols[:16]] + [u.get('creator', ''), ' | '.join(u.get('shots', [])),
                                                     u.get('vo', ''), u.get('app_moment', ''), r['notes']])
    print('wrote content_calendar.json / .csv')


if __name__ == '__main__':
    argv = sys.argv[1:]
    if argv[:1] == ['--sheet']:
        for pid in argv[1:]:
            sheet(pid)
    elif argv[:1] == ['--export']:
        export()
    else:
        ids = argv or [p['id'] for p in POSTS if p['format'] == 'motion'
                       and not os.path.exists(os.path.join(OUT, out_name(p)))]
        with Pool(os.cpu_count()) as pool:
            for pid in ids:
                render_one(pid, pool)
