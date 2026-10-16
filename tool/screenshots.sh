#!/usr/bin/env bash
# Regenerates the store screenshots from the real app.
#   ios/fastlane/screenshots/en-US/                               1320×2868
#   android/fastlane/metadata/android/en-US/images/phoneScreenshots/  1080×1920
#   appstore_assets/iphone-duo/en-US/{outer,inner}/  iPhone Duo, upload by hand
set -euo pipefail
cd "$(dirname "$0")/.."
FLUTTER_ROOT="$(dirname "$(dirname "$(readlink -f "$(command -v flutter)")")")"
export FLUTTER_ROOT
# One run per language: each draws its script font under the app's fallback
# family, and a font family can only be registered once per run.
for code in en hi mr gu pa ta te; do
  SHOT_LOCALE="$code" flutter test screenshots/store_screenshots_test.dart "$@"
done
# en-GB and en-AU show the same English set.
for loc in en-GB en-AU; do
  cp ios/fastlane/screenshots/en-US/*.png "ios/fastlane/screenshots/$loc/"
  cp android/fastlane/metadata/android/en-US/images/phoneScreenshots/*.png \
    "android/fastlane/metadata/android/$loc/images/phoneScreenshots/"
  mkdir -p "appstore_assets/iphone-duo/$loc"
  cp -R appstore_assets/iphone-duo/en-US/. "appstore_assets/iphone-duo/$loc/"
done
