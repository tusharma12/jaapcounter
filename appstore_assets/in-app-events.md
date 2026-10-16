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
- **Media:** App Store Connect asks for a 16:9 event card and a 9:16 details image; `appstore_assets/creative/<locale>/universal_16x9.png` can be scaled down for the card, but check the size it asks for. Apple overlays the event name on the card.

**English**

- Name (25/30): Kartik Month Jaap Sankalp
- Short description (43/50): Chant every day in the holy month of Kartik
- Long description (93/120): Take a Sankalp for Kartik. Set your daily malas, keep your streak, and see each day get done.

**Hindi**

- Name (21/30): कार्तिक मास जप संकल्प
- Short description (35/50): पवित्र कार्तिक मास में रोज़ जप करें
- Long description (94/120): कार्तिक मास के लिए संकल्प लें। रोज़ की माला तय करें, लगातार जप करें और हर दिन पूरा होते देखें।

## Diwali: Sun 8 Nov 2026

- **Badge:** Special Event
- **Deep link:** `jaapmitra://app/mantras`
- **Purpose:** Attract new users, and bring back lapsed ones
- **Media:** App Store Connect asks for a 16:9 event card and a 9:16 details image; `appstore_assets/creative/<locale>/universal_16x9.png` can be scaled down for the card, but check the size it asks for. Apple overlays the event name on the card.

**English**

- Name (19/30): Diwali Lakshmi Jaap
- Short description (45/50): Chant Om Shri Mahalakshmyai Namah this Diwali
- Long description (110/120): Welcome Lakshmi with jaap this Diwali. Om Shri Mahalakshmyai Namah is ready in the app. Tap anywhere to count.

**Hindi**

- Name (17/30): दिवाली लक्ष्मी जप
- Short description (44/50): इस दिवाली ॐ श्री महालक्ष्म्यै नमः का जप करें
- Long description (107/120): इस दिवाली जप से लक्ष्मी जी का स्वागत करें। ॐ श्री महालक्ष्म्यै नमः ऐप में तैयार है। कहीं भी टैप करके गिनें।
