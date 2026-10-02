# Naam Jap Counter – Smaran

**Your peaceful digital mala for daily Naam Jap.**

A Flutter app for Android and iOS. Open it and you are counting within a
second: the whole counter area is the tap target, the bead is felt through
haptics, and every Jaap is stored only on the device.

---

## What is in the app

| Area | What it does |
| --- | --- |
| **Jaap** | The mala ring, current bead over mala size, today's total and malas, undo, timed sessions, manual entry, mala reset, an optional marker knock every 27 or 54 beads, counting with volume buttons, a headset button or a Bluetooth clicker, and on iOS 17+ a lock-screen +1 button (Live Activity) |
| **Mantras** | Built-in mantras in Devanagari plus custom ones, each with its own mala size (27 / 54 / 108 / custom), an optional voice note in the user's own voice, and on-device dictation |
| **Sadhana** | A daily goal, and a Sankalp - a vow of *n* Jaap a day for *n* days - with day-by-day progress; upcoming Ekadashis and festivals, each offering a Sankalp that fits it |
| **Progress** | Streak and best streak (with grace days), today against the goal, a daily/weekly/monthly/yearly chart, lifetime totals, a habit grid, a per-mantra breakdown, lifetime milestones (1,008 Jaap to 1 crore) and a shareable year in review |
| **Meditation** | Distraction-free counting, a session timer, and a blackout mode for chanting with eyes closed |
| **Stories** | Seven short original retellings, in English and Hindi, with favourites, adjustable text and read-aloud |
| **Reminders** | Local daily reminders, a streak nudge, a goal nudge, and a 6 am note on Ekadashi and festival days |
| **Backup** | Readable JSON export and restore of everything, validated before it replaces anything |
| **Widgets** | A home screen widget showing the mantra, the mala in progress and today's total |
| **Languages** | English, हिन्दी, मराठी, ગુજરાતી, ਪੰਜਾਬੀ, தமிழ் and తెలుగు, including notification copy. Stories are in English and Hindi (Marathi reads the Hindi) |
| **Diagnostics** | A report of versions, settings and the error log - never mantras or counts - shown in full and sent only by the user's own mail or share sheet |

Nothing leaves the device. There is no account, no analytics and no network
call in the app. Dictation runs on-device only; where a phone has no offline
model for the language, the app says so rather than going online.

---

## Running it

```bash
flutter pub get
flutter run                 # a connected device or simulator
flutter test                # the whole suite, including accessibility
flutter analyze             # clean
```

Requires Flutter 3.44 or newer (Dart 3.12). Android and iOS are the supported
platforms; the iOS home screen widget needs one manual Xcode step, described
in [docs/PLATFORM_SETUP.md](docs/PLATFORM_SETUP.md). Store releases and
screenshots are covered in [docs/RELEASING.md](docs/RELEASING.md).

---

## How the counting works

This is the part worth understanding before changing anything.

**The ledger is the source of truth.** There is no stored "current count".
Every bead is appended to `jaap_entries`, and every figure the app shows -
the bead on the ring, today's total, lifetime malas, the streak, the chart -
is derived from those rows by `MalaMath`. That is what makes undo, statistics,
history and restore safe rather than approximate.

**A tap never waits for the disk.** `JaapController.count()` updates the
on-screen state synchronously and appends the write to a serialised queue.
Writes drain in order, are flushed when the app is backgrounded, and are
awaited before anything reads back. A hundred rapid taps produce exactly a
hundred recorded beads - there are tests for both the sequential and the
concurrent case.

**Consecutive taps share a row.** Taps within two minutes increment one
ledger row instead of inserting thousands, so a year of chanting stays small.
Undo decrements that row and deletes it when it reaches zero. Manual and
imported entries are never merged into a tap row, so they stay auditable.

**A mala reset destroys nothing.** Resetting the mala in progress raises
`mantras.mala_base`, the count of beads that no longer count toward malas.
Totals, days and streaks are untouched; only the bead position moves.

**Streaks are derived too, grace days included.** Every 7 qualifying days in
a row earn a grace day (2 at most), and a missed day spends one instead of
breaking the run. `StreakCalculator` replays the history to work this out, so
there is no stored grace-day balance to drift out of step with the ledger.

**Days are local calendar days.** Everything aggregates on a `yyyy-MM-dd` key
taken in local time, so a bead counted at 23:59 belongs to that evening.

---

## Layout

```
lib/
├── app/                    theme, router, four-tab shell, lifecycle
├── core/
│   ├── constants/          mala sizes, goal presets, built-in mantras
│   ├── database/           SQLite schema and migrations
│   ├── services/           settings, notifications, haptics, speech, widgets, logging
│   ├── utils/              day keys, formatting, ids
│   ├── widgets/            the shared design-system widgets
│   └── providers.dart      repository wiring
├── features/
│   ├── jaap/               counting engine, controller, counter screen
│   ├── mantras/            library, editor, quick picker
│   ├── sadhana/            goals, Sankalp, streaks
│   ├── progress/           statistics, chart, heatmap
│   ├── meditation/         distraction-free and blackout modes
│   ├── stories/            bundled content, reader, text-to-speech
│   ├── reminders/          local notification scheduling
│   ├── backup/             JSON export and restore
│   ├── settings/           preferences
│   └── onboarding/
└── l10n/                   app_en.arb, app_hi.arb
```

Each feature is `data / domain / presentation`. Domain classes hold no Flutter
imports and no storage; business logic lives there and in the controllers,
never in widgets. State is Riverpod.

---

## Design

The palette is a warm off-white ground with near-black text and **saffron as an
accent only** - progress, the streak, calls to action, selected state, a
completed mala. The classic light and dark palettes are defined as tokens in
`lib/app/theme/app_colors.dart`; the other colour themes in the theme picker
(Saffron, Lavender, Ocean…) are derived from a background and an accent in
`lib/app/theme/app_themes.dart`. Everything is reached through
`context.palette`; the widget is the only place colours are repeated, in
`colors.xml`.

UI text is Inter, Devanagari is Noto Sans Devanagari (both bundled as static
instances, SIL Open Font License), and mantras are rendered in Devanagari
wherever there is room for them. Gujarati, Gurmukhi, Tamil and Telugu text
falls back to the phone's own fonts for those scripts, which every supported
Android and iOS version ships.

---

## Tests

```
test/
├── support/test_harness.dart          in-memory database, controllable clock
├── features/jaap/                     mala maths, ledger, controller, screen
├── features/sadhana/                  streaks across months, years, leap days
├── features/mantras/                  library rules, screen, picker
├── features/progress/                 statistics and the Progress screen
├── features/backup/                   round trips and rejected files
├── accessibility_test.dart            every screen at 200% text in en and hi,
│                                      and the tap-target, label and contrast
│                                      guidelines
└── l10n_test.dart                     every language complete
```

The unit tests run the shipping SQL against an in-memory SQLite database, so
ledger behaviour is tested rather than mocked.

---

## Before publishing

- Follow [docs/RELEASING.md](docs/RELEASING.md): App Store Connect API key,
  Android upload key (`android/key.properties`) and Play service account.
- Point `AppConstants` at real privacy, terms, support and store URLs; the
  store listings use the same privacy and support URLs.
- The privacy policy must mention the microphone (voice notes and dictation,
  both on-device) and that a diagnostics report is sent only when the user
  chooses to.
- The Ekadashi and festival table ends on the last date in
  `tool/observances.json`. Extend it a year ahead (Drik Panchang, New Delhi,
  `geoname-id=1261481`), then run `dart run tool/generate_observances.dart`.
