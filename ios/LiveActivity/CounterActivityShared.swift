import ActivityKit
import AppIntents
import Foundation

// Shared by the app and the widget extension: the Live Activity's data, the
// +1 button's intent, and the small store the two sides use to talk.
//
// The counting ledger lives in the app's SQLite database and has exactly one
// writer: the Flutter app. This file never touches it. The +1 button only
// bumps a pending counter in the shared app group; the app adds those beads to
// the ledger the next time it comes forward (see LiveActivityBridge and
// JaapController.addPendingBeads). A bug here can therefore miscount the
// lock screen for a moment, but it cannot damage the user's history.

let counterAppGroupId = "group.com.naamjapcounter.smaran"

/// What the lock screen shows. Static facts live in the attributes; the
/// numbers that change live in [ContentState].
@available(iOS 16.2, *)
struct CounterActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var beads: Int
        var malaSize: Int
        var todayTotal: Int
    }

    var mantra: String
}

/// Beads tapped on the lock screen that the app has not yet written to the
/// ledger. Every access is serialised on one queue, so a tap and the app's
/// drain can never interleave.
enum PendingBeads {
    private static let queue = DispatchQueue(label: "japmala.pending-beads")
    private static var store: UserDefaults? { UserDefaults(suiteName: counterAppGroupId) }

    private static let countKey = "lockPendingCount"
    private static let atKey = "lockPendingAt"

    /// Records one tap and returns the pending total.
    @discardableResult
    static func add(_ n: Int = 1) -> Int {
        queue.sync {
            guard let store else { return 0 }
            let total = store.integer(forKey: countKey) + n
            store.set(total, forKey: countKey)
            store.set(Date().timeIntervalSince1970, forKey: atKey)
            return total
        }
    }

    /// Takes everything pending and resets it, in one step.
    static func drain() -> (count: Int, at: Date?) {
        queue.sync {
            guard let store else { return (0, nil) }
            let count = store.integer(forKey: countKey)
            let at = store.object(forKey: atKey) as? Double
            store.set(0, forKey: countKey)
            store.removeObject(forKey: atKey)
            return (count, at.map { Date(timeIntervalSince1970: $0) })
        }
    }
}

/// The +1 on the lock screen and in the Dynamic Island. A LiveActivityIntent
/// runs in the app's process (the system starts the app in the background if
/// needed), which is why this file is compiled into the app target too.
@available(iOS 17.0, *)
struct AddBeadIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Count a bead"
    static var openAppWhenRun = false
    static var isDiscoverable = false

    func perform() async throws -> some IntentResult {
        PendingBeads.add()
        for activity in Activity<CounterActivityAttributes>.activities {
            var state = activity.content.state
            // Mirror what the app will do on its next write: the ring wraps
            // when a mala completes, and today's total only goes up.
            state.beads = state.malaSize > 0 ? (state.beads + 1) % state.malaSize : state.beads + 1
            state.todayTotal += 1
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
        return .result()
    }
}
