# Android: lock-screen counter and Wear OS - what is left to do

The iOS lock-screen counter is built (see `docs/IOS_LIVE_ACTIVITY.md`). Android
has none of it yet. This is the plan, written so it can be picked up on a
machine with a working Android toolchain.

## Why it was not built yet

The machine it was planned on had no Android cmdline-tools or accepted
licences (`flutter doctor` showed both missing), so Kotlin could not be
compiled or run. Native code that writes a person's Jaap counts should not be
shipped untested.

## Setup before starting

1. Install the Android cmdline-tools (Android Studio > SDK Manager > SDK Tools).
2. `flutter doctor --android-licenses`, then `flutter doctor` must show the
   Android toolchain with no ✗.
3. A real phone for testing. Notification actions and the lock screen behave
   differently on emulators, and OEM skins (Samsung, Xiaomi) differ again.

## Design: one writer to the ledger

The counting ledger is the source of truth, and only the Flutter app writes it.
The notification must never open SQLite itself, or two processes would write
one file.

1. An ongoing notification shows the mantra, `beads / malaSize` and today's
   total, with a **+1** action.
2. The action fires a `BroadcastReceiver` in Kotlin. It only increments a
   `pendingBeads` counter (and records the time of the last tap) in
   `SharedPreferences`, then re-posts the notification with the new numbers.
3. When the app is next in the foreground, Dart reads and clears the pending
   count and adds it to the ledger in one write. The same drain step already
   exists for iOS (`JaapController.addPendingBeads`); only the native source of
   the number differs.

The home-screen widget is display-only and keeps working as it does now.

## Work items

| # | Item | Notes |
| --- | --- | --- |
| 1 | `CounterNotification.kt` | Builds the ongoing notification; channel `japmala.counter`, importance LOW, no sound or vibration. `setOnlyAlertOnce(true)`, `setOngoing(true)`, visibility PUBLIC so it shows on the lock screen. |
| 2 | `CounterActionReceiver.kt` | Handles `ACTION_ADD_BEAD` and `ACTION_STOP`. Increments `pendingBeads` with `apply()`; no coroutines, no I/O beyond `SharedPreferences`. Must be `exported="false"` in the manifest. |
| 3 | Manifest | `POST_NOTIFICATIONS` (already requested for reminders), the receiver, and on Android 14 `FOREGROUND_SERVICE_SPECIAL_USE` only if a foreground service is added (it should not be needed for an ongoing notification). |
| 4 | Method channel `japmala/lockscreen` | `start`, `update`, `end`, `drainPending`, `isSupported` - the same names as iOS, so `LiveActivityService` in Dart needs no change. Register it in `MainActivity.kt`. |
| 5 | Settings | The "Lock screen counter" switch (`lockScreenCounter`) already exists and is shared; just allow it on Android once the channel exists. |
| 6 | Notification permission | Android 13+: ask when the switch is turned on (reuse `NotificationService.requestPermission`). |
| 7 | Tests | Dart side is covered by the fake channel tests. Add an instrumented test for the receiver's counter arithmetic if possible. |
| 8 | Device checks | See the list below. |

## Device checks

- Tapping +1 ten times quickly adds exactly ten beads after the app opens.
- The pending count survives the app being killed, and is cleared once only
  (open the app twice; the second drain adds nothing).
- Turning the switch off removes the notification and clears pending beads
  after draining them (beads already counted must not be lost).
- The notification shows on the lock screen, and not with sensitive content
  hidden if the user chose "hide sensitive content" (mantra text is not
  sensitive, but respect `VISIBILITY_PRIVATE` if they ask).
- Battery: no foreground service, no wakelocks, no polling.

## Wear OS (later, separate project)

A Wear OS app is its own Gradle module and needs a Wear device or emulator. The
same rule applies: the watch sends taps to the phone with the Data Layer API
(`MessageClient`), and the phone's Flutter app writes the ledger. Do not give the
watch its own database.

## watchOS (later, separate project)

Same shape: a watch app target with a +1 button sending `WCSession` messages to
the phone app, which owns the ledger. Needs a paired watch simulator and a
watchOS deployment target decision (10+ is a sensible floor).
