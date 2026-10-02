# iOS: the lock-screen counter (Live Activity)

A Live Activity on the lock screen and in the Dynamic Island, with a **+1**
button that counts a bead without unlocking the phone or opening the app.
It is off by default (Settings > Counter > Lock screen counter) and only shown
on iOS 17 or later, with Live Activities allowed in system Settings. Older iOS
simply does not offer the setting.

## How it works

The ledger has one writer: the Flutter app. The lock screen never touches it.

1. The +1 button runs `AddBeadIntent` (`ios/LiveActivity/CounterActivityShared.swift`).
   It is a `LiveActivityIntent`, so the system runs it **in the app's process**
   (starting the app in the background if needed, without launching Flutter).
2. The intent only bumps a pending count in the shared app group
   (`PendingBeads`) and updates the Live Activity's numbers so the tap shows at
   once.
3. When the app next resumes, `JaapController.refreshForResume` calls
   `drainPending` over the `japmala/lockscreen` channel, which returns and
   clears the count in one step, and writes the beads to the ledger with
   `addBeads`. Then it republishes the true numbers to the activity.

A bug here can show the wrong number on the lock screen for a moment; it cannot
damage the user's history.

## Files

| File | Target | Role |
| --- | --- | --- |
| `ios/LiveActivity/CounterActivityShared.swift` | app + widget extension | Attributes, `PendingBeads`, `AddBeadIntent` |
| `ios/LiveActivity/LiveActivityBridge.swift` | app | The `japmala/lockscreen` method channel |
| `ios/JapMalaWidget/JapMalaLiveActivity.swift` | widget extension | The lock screen and Dynamic Island UI |
| `lib/core/services/lock_screen_counter_service.dart` | Dart | Channel wrapper, safe where unsupported |

`NSSupportsLiveActivities` is set in `Runner/Info.plist`. The intent file must
stay in **both** targets: the extension draws the button, the app runs it.

## Limits worth knowing

- iOS ends a Live Activity after about 8 hours (it can stay on the lock screen
  a few hours longer). The app starts it again the next time it is opened or
  counts, so a long-running chant may need the app brought forward once.
- Beads tapped on the lock screen are recorded with the time of the last tap,
  and appear in Progress only after the app has been opened.
- The +1 does not play the app's haptics, and does not celebrate a finished
  mala or a milestone; those need the app in front.

## Checking it on a device or simulator

1. Build and run, turn the switch on, and put the app in the background.
2. The activity appears on the lock screen and in the Dynamic Island.
3. Tap +1 several times, open the app: Today's total went up by exactly that
   many, once. Open it again: no change.
4. Turn the switch off: the activity disappears.

> The code compiles for the simulator and the Dart side is covered by tests
> (`test/core/services/lock_screen_counter_test.dart`), but the lock screen
> itself has not been exercised on a simulator or device yet. Do step 1 to 4
> above before releasing.
