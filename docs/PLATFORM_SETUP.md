# Platform setup

Everything in the app runs after `flutter pub get` on both platforms. Two
things need a human: the iOS widget extension (Xcode cannot be scripted
reliably) and release signing.

---

## Android

Already configured in this repository:

- **Label and icon** — `@string/app_name`, adaptive launcher icon made
  from `appstore_assets/appicon.png`. The artwork is a full-colour
  illustration, so there is no monochrome layer for themed icons.
- **Notifications** — `POST_NOTIFICATIONS`, plus `RECEIVE_BOOT_COMPLETED` and
  the `flutter_local_notifications` boot receiver, so reminders survive a
  reboot or an app update.
- **Desugaring** — `isCoreLibraryDesugaringEnabled` and `desugar_jdk_libs`,
  required by `flutter_local_notifications`.
- **Widget** — `JapMalaWidgetProvider` (Kotlin), `layout/japmala_widget.xml`,
  `xml/japmala_widget_info.xml`, registered as a receiver in the manifest.
- **R8** — `proguard-rules.pro` keeps the notification plugin's Gson models
  and the widget provider, which is only referenced from the manifest.
- **Launch window** — the app's own background colour in both light and dark,
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

### Adding the home screen widget

The widget's source is written and ready at `ios/JapMalaWidget/`. It is not in
the Xcode project, because adding a target rewrites `project.pbxproj` and that
is not safe to do by script. In Xcode, once:

1. **File → New → Target… → Widget Extension.** Name it `JapMalaWidget`,
   uncheck *Include Live Activity* and *Include Configuration App Intent*,
   and set the embedding target to `Runner`.
2. Delete the placeholder files Xcode generates in the new group, then drag in
   `ios/JapMalaWidget/JapMalaWidget.swift` (target: `JapMalaWidget` only).
   Use `ios/JapMalaWidget/Info.plist` for the extension's Info.plist.
3. **Signing & Capabilities** for *both* `Runner` and `JapMalaWidget`:
   add **App Groups** and tick `group.com.japmala.japmala`. This must match
   `WidgetService.iOSAppGroupId` in
   `lib/core/services/widget_service.dart`; if you change the identifier,
   change it in three places — both targets and that constant.
4. Set the extension's deployment target to iOS 17 (the widget uses
   `containerBackground`), or lower it and remove that modifier.

The Dart side needs no changes: `WidgetService` already writes the values and
calls `HomeWidget.updateWidget(iOSName: 'JapMalaWidget')`. Until the target
exists, widget updates fail silently and are logged — counting is never
affected.

---

## Where the keys come from

The widget reads these from the shared app group, all written by
`WidgetService.publish`:

| Key | Meaning |
| --- | --- |
| `mantra` | What to chant, as displayed (Devanagari where available) |
| `beads` | Beads in the mala currently in progress |
| `malaSize` | Beads in one mala for that mantra |
| `todayTotal` | Jaap counted today for that mantra |
| `todayMalas` | Malas completed today |
| `streak` | Current streak in days |
| `updatedAt` | Epoch milliseconds of the last write |

---

## Permissions, and when they are asked for

| Permission | When | Why |
| --- | --- | --- |
| Notifications | The moment a reminder is switched on — never at first launch | Daily reminders, streak and goal nudges |
| Nothing else | — | No camera, contacts, location, storage or network permission is requested |

Exact alarms are deliberately *not* requested: reminders use
`AndroidScheduleMode.inexactAllowWhileIdle`, which a gentle daily nudge does
not need special permission for.
