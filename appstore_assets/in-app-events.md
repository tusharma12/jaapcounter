# In-App Events

Create these in App Store Connect under In-App Events. From 1.0.2 (7) the app opens `jaapmitra://app/<screen>` links (`sadhana`, `mantras`, `jaap`, …); older versions just open the app. An event can be shown on the App Store up to 14 days before it starts, so publish each one as soon as it is approved.

## Sharad Navratri: Sun 11 Oct – Mon 19 Oct 2026

- **Badge:** Challenge
- **Purpose:** Attract new users, and bring back lapsed ones
- **Media:** `appstore_assets/events/navratri/<locale>/card_16x9.png` (event card, 3840×2160) and `details_9x16.png` (event details page, 2160×3840), English and Hindi. Regenerate with `python3 tool/make_navratri_event.py`.
- **Timing:** starts 11 Oct. Submit it today: events need App Review (often about a day) and can show while they are running, so an approved event still covers most of the nine days.
- **Deep link:** `jaapmitra://app/sadhana` once 1.0.2 (7) is live; leave it empty if you submit the event before then.
- **In the app:** Sadhana screen → upcoming festivals → Sharad Navratri → Take a Sankalp sets a 9-day Sankalp for the festival dates. Do not mention a Durga mantra: the built-in one was removed (users can add their own).

**English**

- Name (27/30): Navratri 9-Day Jaap Sankalp
- Short description (47/50): Chant every day for all nine nights of Navratri
- Long description (92/120): Take a 9-day Sankalp for Navratri in one tap. Set your daily malas and finish all nine days.

**Hindi**

- Name (24/30): नवरात्रि 9 दिन जप संकल्प
- Short description (37/50): नवरात्रि की नौ रातों में रोज़ जप करें
- Long description (85/120): एक टैप में नवरात्रि का 9 दिन का संकल्प लें। रोज़ की माला तय करें और नौ दिन पूरे करें।

## Kartik month: Tue 27 Oct – Tue 24 Nov 2026

- **Badge:** Challenge
- **Deep link:** `jaapmitra://app/sadhana`
- **Purpose:** Attract new users, and bring back lapsed ones
- **Media:** `appstore_assets/events/kartik/<locale>/card_16x9.png` and `details_9x16.png`, English and Hindi. They show only the festival name, one line, diyas, and the app's counter on the event's mantra. Regenerate: `for code in en hi; do SHOT_EVENTS=1 SHOT_LOCALE=$code flutter test screenshots/store_screenshots_test.dart --plain-name 'event captures'; done`, then `python3 tool/make_festival_events.py`.
- **Timing:** starts 27 Oct and runs four weeks, the longest stretch of search exposure this season. Submit it first.

**English**

- Name (25/30): Kartik Month Jaap Sankalp
- Short description (43/50): Chant every day in the holy month of Kartik
- Long description (93/120): Take a Sankalp for Kartik. Set your daily malas, keep your streak, and see each day get done.

**Hindi**

- Name (21/30): कार्तिक मास जप संकल्प
- Short description (35/50): पवित्र कार्तिक मास में रोज़ जप करें
- Long description (94/120): कार्तिक मास के लिए संकल्प लें। रोज़ की माला तय करें, लगातार जप करें और हर दिन पूरा होते देखें।

## 11 Days to Diwali: Thu 29 Oct – Sun 8 Nov 2026

- **Badge:** Challenge
- **Deep link:** `jaapmitra://app/sadhana`
- **Purpose:** Attract new users, and bring back lapsed ones
- **Media:** `appstore_assets/events/diwali/<locale>/card_16x9.png` and `details_9x16.png`, English and Hindi. They show only the festival name, one line, diyas, and the app's counter on the event's mantra. Regenerate: `for code in en hi; do SHOT_EVENTS=1 SHOT_LOCALE=$code flutter test screenshots/store_screenshots_test.dart --plain-name 'event captures'; done`, then `python3 tool/make_festival_events.py`.
- **Why 11 days, not just Diwali day:** an event card only shows while the event is upcoming or running, so a one-day event barely appears. An 11-day Sankalp (a built-in length) ends on Lakshmi Puja night and brings people back daily; after two active days the rating prompt can fire on a finished mala, in the most devotional week of the year.
- **Timing:** submit by 28 Oct so it is live on the 29th. Approved late, it still runs to Diwali.
- **Check first:** in the app, an 11-day Sankalp can be started from any day with Om Shri Mahalakshmyai Namah.
- **Promotional text** (no review needed, change any time; 143/170): This Diwali, chant Om Shri Mahalakshmyai Namah for 11 days. Take a Sankalp, keep your streak, and chant in the dark with Blackout mode. No ads.

**English**

- Name (26/30): Diwali 11-Day Lakshmi Jaap
- Short description (40/50): Chant for Lakshmi every day until Diwali
- Long description (106/120): Take an 11-day Sankalp with Om Shri Mahalakshmyai Namah and finish on Diwali night. Tap anywhere to count.

**Hindi**

- Name (27/30): दिवाली तक 11 दिन लक्ष्मी जप
- Short description (36/50): दिवाली तक रोज़ लक्ष्मी जी का जप करें
- Long description (103/120): ॐ श्री महालक्ष्म्यै नमः के साथ 11 दिन का संकल्प लें और दिवाली की रात पूरा करें। कहीं भी टैप करके गिनें।
