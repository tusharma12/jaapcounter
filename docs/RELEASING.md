# Releasing

Store releases run through [fastlane](https://fastlane.tools), one setup per
platform, and the store screenshots are generated from the app itself.

| What | Where |
| --- | --- |
| iOS lanes | `ios/fastlane/Fastfile` |
| App Store text (en-US, hi) | `ios/fastlane/metadata/` |
| App Store screenshots (1320×2868) | `ios/fastlane/screenshots/en-US/` |
| Android lanes | `android/fastlane/Fastfile` |
| Play listing text (en-US, hi-IN) | `android/fastlane/metadata/android/` |
| Play screenshots (1080×1920), feature graphic, icon | `android/fastlane/metadata/android/en-US/images/` |
| Screenshot generator | `screenshots/store_screenshots_test.dart`, run by `tool/screenshots.sh` |

The version shown in the stores comes from `version:` in `pubspec.yaml`.
Build numbers are handled by the lanes: each upload is one above the highest
build the store already has.

## One-time setup

### Both

```sh
cd ios && bundle install      # and the same in android/
```

`bundle exec fastlane …` then uses the pinned fastlane from each `Gemfile`.

### iOS: App Store Connect API key

1. Create the app record in App Store Connect with bundle id
   `com.japmala.japmala` (the name is `Naam Jap Counter – Smaran`).
2. Users and Access → Integrations → App Store Connect API → generate a key
   with the **App Manager** role. Download the `.p8` (only offered once).
3. Export, e.g. in your shell profile:

   ```sh
   export ASC_KEY_ID=XXXXXXXXXX
   export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   export ASC_KEY_PATH=~/keys/AuthKey_XXXXXXXXXX.p8
   ```

Signing stays **Automatic** (team `H47Y3CY9CT`). The key lets `xcodebuild`
create or refresh the distribution profiles for the app and the widget
extension without an Apple ID login.

In App Store Connect, before the first submission, fill in what fastlane
cannot: the privacy questionnaire (the app collects no data), the age rating,
pricing, and App Review contact name and phone.

### Android: upload key and Play access

1. Create an upload keystore (keep it and its passwords safe; losing it
   means asking Google to reset the key):

   ```sh
   keytool -genkey -v -keystore ~/keys/smaran-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` (git-ignored):

   ```properties
   storeFile=/Users/you/keys/smaran-upload.jks
   storePassword=…
   keyAlias=upload
   keyPassword=…
   ```

   Without this file, release builds fall back to debug signing so
   `flutter run --release` keeps working, but the lanes refuse to upload.

3. In Play Console, create the app `com.japmala.japmala`, enrol in Play App
   Signing, and **upload the first `.aab` by hand** (Google requires it).
4. Google Cloud → create a service account and a JSON key. In Play Console →
   Users and permissions, invite that account with release permissions. Save
   the key as `android/fastlane/play-store-key.json` (git-ignored) or point
   `PLAY_JSON_KEY_PATH` at it.

This Mac's Android toolchain also needs its command-line tools before release
builds can strip native symbols (otherwise the `.aab` is ~60 MB):
Android Studio → Settings → Android SDK → SDK Tools → **Android SDK
Command-line Tools**, then `flutter doctor --android-licenses`.

## Lanes

Run from `ios/` or `android/`:

| Command | Does |
| --- | --- |
| `bundle exec fastlane beta` (iOS) | build, upload to TestFlight |
| `bundle exec fastlane release` (iOS) | build, upload binary + text + screenshots; **not** submitted for review |
| `bundle exec fastlane metadata` (iOS) | store text only |
| `bundle exec fastlane screenshots` (iOS) | screenshots only |
| `bundle exec fastlane internal` (Android) | build, upload to the internal testing track |
| `bundle exec fastlane release` (Android) | build, upload to production as a **draft**, with listing and screenshots |
| `bundle exec fastlane metadata` (Android) | listing text and images only |

Submitting for review (iOS) and rolling out the draft (Android) stay manual,
so nothing reaches users without a last look.

## Screenshots

```sh
./tool/screenshots.sh
```

Renders six shots through the real router and screens, seeded with a
23-day practice and a 40-day Sankalp, and frames each under a headline. It
writes both store sizes plus the Play feature graphic. Headlines and the
seeded data live at the top of `screenshots/store_screenshots_test.dart`.
Regenerate after any visible UI change, then run the `screenshots` /
`metadata` lane.

## Before the first release

- `https://japmala.app/privacy` and `https://japmala.app` are the privacy
  and support URLs in both listings and in the app. Both must be live pages
  before review.
- Release notes: `ios/fastlane/metadata/*/release_notes.txt` and
  `android/fastlane/metadata/android/*/changelogs/default.txt`.
