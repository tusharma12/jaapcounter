# Platform setup

Everything in the app runs after `flutter pub get` on both platforms. Two
things need a human: the iOS widget extension (Xcode cannot be scripted
reliably) and release signing.

---

## Android

Already configured in this repository:

- **Label and icon** - `@string/app_name`, adaptive launcher icon made
  from `appstore_assets/appicon.png`. The artwork is a full-colour
  illustration, so there is no monochrome layer for themed icons.
- **Notifications** - `POST_NOTIFICATIONS`, plus `RECEIVE_BOOT_COMPLETED` and
  the `flutter_local_notifications` boot receiver, so reminders survive a
  reboot or an app update.
- **Desugaring** - `isCoreLibraryDesugaringEnabled` and `desugar_jdk_libs`,
  required by `flutter_local_notifications`.
- **Widget** - `JapMalaWidgetProvider` (Kotlin), `layout/japmala_widget.xml`,
  `xml/japmala_widget_info.xml`, registered as a receiver in the manifest.
- **R8** - `proguard-rules.pro` keeps the notification plugin's Gson models
  and the widget provider, which is only referenced from the manifest.
- **Launch window** - the app's own background colour in both light and dark,
  so there is no white flash.

Nothing further is needed to run or to build a widget-capable APK:

```bash
flutter build apk --release
flutter build appbundle --release   # for Play
```

**Before publishing:** replace `signingConfig = signingConfigs.getByName("debug")`
in `android/app/build.gradle.kts` with a real keystore.

---

## iOS

Configured already: display name, portrait-only orientation, `en` + `hi`
bundle localisations, `ITSAppUsesNonExemptEncryption`, the app icon set, a
launch screen in the app's background colour, `platform :ios, '14.0'` (the
minimum `file_picker` and `home_widget` support), and
`Runner/Runner.entitlements` declaring the app group the widget shares.

```bash
cd ios && pod install && cd ..
flutter build ios --release          # add --no-codesign to check it compiles
```

### The home screen widget

The `JapMalaWidget` extension (source in `ios/JapMalaWidget/`) is part of the
Xcode project and is embedded in the app by every `flutter build ios`:

- **App Group** `group.com.naamjapcounter.smaran` is declared in both
  `Runner/Runner.entitlements` and `JapMalaWidget/JapMalaWidget.entitlements`,
  and must match `WidgetService.iOSAppGroupId` in
  `lib/core/services/widget_service.dart`. Automatic signing registers it the
  first time the app is built for a device.
- **Version and build number** come from Flutter through
  `ios/Flutter/Widget.xcconfig`, because an extension must carry the same
  version as the app it ships in.
- **Deployment target** is iOS 17, for `containerBackground`.
- **Theme:** the app writes the chosen theme's colours with the counts; with
  the Auto theme it writes none and the widget follows the system.

The target was added with the `xcodeproj` Ruby gem (bundled with CocoaPods).
If it ever has to be recreated, the embed phase must sit before Flutter's
*Thin Binary* script phase, or Xcode reports a build cycle.

---

## Where the keys come from

The widget reads these from the shared app group, all written by
`WidgetService.publish`:

| Key | Meaning |
| --- | --- |
| `mantra` | The mantra, exactly as the user wrote it |
| `beads` | Beads in the mala currently in progress |
| `malaSize` | Beads in one mala for that mantra |
| `todayTotal` | Jaap counted today for that mantra |
| `todayMalas` | Malas completed today |
| `streak` | Current streak in days |
| `updatedAt` | Epoch milliseconds of the last write |
| `colorBackground`, `colorText`, `colorSecondaryText`, `colorAccent`, `colorTrack`, `colorStreak` | The chosen theme's colours as ARGB integers; absent on the Auto theme |

---

## Permissions, and when they are asked for

| Permission | When | Why |
| --- | --- | --- |
| Notifications | The moment a reminder is switched on - never at first launch | Daily reminders, streak and goal nudges |
| Microphone (`RECORD_AUDIO`, `NSMicrophoneUsageDescription`) | The first time the user records their own meditation sound or dictates a mantra | Recording a chant for the Music list in Meditation; dictating the mantra text |
| Speech recognition (iOS, `NSSpeechRecognitionUsageDescription`) | The first time the user dictates a mantra | Dictation, which runs **on-device only** (`onDevice: true`); where no offline model exists the app says so instead of going online |
| Live Activities (iOS 17+, `NSSupportsLiveActivities`) | When the user turns on Lock screen counter | A +1 button on the lock screen; see [IOS_LIVE_ACTIVITY.md](IOS_LIVE_ACTIVITY.md) |
| Nothing else | - | No camera, contacts, location, storage or network permission is requested |

Exact alarms are deliberately *not* requested: reminders use
`AndroidScheduleMode.inexactAllowWhileIdle`, which a gentle daily nudge does
not need special permission for.

## Home screen shortcut

Long-pressing the app icon offers **Blackout mode** (`quick_actions`,
registered from `lib/app/app.dart`). Its icon is
`ios/Runner/Assets.xcassets/shortcut_blackout.imageset` on iOS and
`android/app/src/main/res/drawable/shortcut_blackout.xml` on Android; both
names must match the `icon` in `ShortcutService`.
