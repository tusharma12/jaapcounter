# Product Page Optimization test: screenshots A vs B

- **A (original):** `ios/fastlane/screenshots/<locale>/` — maroon pages, mantra-led first shot, callout cards.
- **B (treatment):** `appstore_assets/ab_test/B/<locale>/` — bright cream and saffron pages, big two-line headlines, larger phone, Sankalp moved to third. Regenerate with `python3 tool/make_ab_screenshots.py` after `tool/screenshots.sh`.
- **Localizations in the treatment:** en-US, en-GB, en-AU, hi (what India sees most). Other languages keep A.

## Setup (App Store Connect → the app → Product Page Optimization → Create Test)

1. Start it only after 1.0.3 is live, so the release does not interrupt it.
2. One treatment (B), traffic 50%: with about 8 downloads a day, more treatments or a smaller share would take months to read.
3. Upload B's iPhone 6.9" screenshots for each localization above, then submit the treatment for review (no app version needed).
4. Leave it at least 3–4 weeks; act only when App Store Connect reports B ahead with at least 90% confidence, then use "Apply treatment".

Don't change the screenshots or icon of A while the test runs, or the result means nothing.
