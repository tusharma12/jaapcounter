#!/usr/bin/env bash
# Regenerates the store screenshots from the real app.
#   ios/fastlane/screenshots/en-US/                               1320×2868
#   android/fastlane/metadata/android/en-US/images/phoneScreenshots/  1080×1920
set -euo pipefail
cd "$(dirname "$0")/.."
FLUTTER_ROOT="$(dirname "$(dirname "$(readlink -f "$(command -v flutter)")")")"
export FLUTTER_ROOT
flutter test screenshots/store_screenshots_test.dart "$@"
