import ActivityKit
import Flutter
import Foundation

// The Flutter side of the lock-screen counter (LockScreenCounterService in
// lib/core/services). It starts, updates and ends the Live Activity, and hands
// back beads tapped on the lock screen so Dart can write them to the ledger.
// Android answers the same channel from Kotlin later, so Dart does not branch.

final class LiveActivityBridge {
    static let channelName = "japmala/lockscreen"

    func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 17.0, *) else {
            // Older iOS has no interactive Live Activities.
            switch call.method {
            case "isSupported": result(false)
            case "drainPending": result(["count": 0])
            default: result(nil)
            }
            return
        }

        switch call.method {
        case "isSupported":
            result(ActivityAuthorizationInfo().areActivitiesEnabled)

        case "start", "update":
            guard let args = call.arguments as? [String: Any],
                  let mantra = args["mantra"] as? String,
                  let beads = args["beads"] as? Int,
                  let malaSize = args["malaSize"] as? Int,
                  let todayTotal = args["todayTotal"] as? Int
            else {
                result(FlutterError(code: "bad-args", message: "start/update need mantra, beads, malaSize, todayTotal", details: nil))
                return
            }
            let state = CounterActivityAttributes.ContentState(
                beads: beads, malaSize: malaSize, todayTotal: todayTotal)
            Task {
                await Self.show(mantra: mantra, state: state)
                result(nil)
            }

        case "end":
            Task {
                for activity in Activity<CounterActivityAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
                result(nil)
            }

        case "drainPending":
            let pending = PendingBeads.drain()
            var reply: [String: Any] = ["count": pending.count]
            if let at = pending.at { reply["at"] = Int(at.timeIntervalSince1970 * 1000) }
            result(reply)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Updates the running activity, or starts one. A different mantra means
    /// a new activity, because a mantra is an attribute and cannot change.
    @available(iOS 17.0, *)
    private static func show(mantra: String, state: CounterActivityAttributes.ContentState) async {
        let content = ActivityContent(state: state, staleDate: nil)
        let running = Activity<CounterActivityAttributes>.activities

        if let current = running.first(where: { $0.attributes.mantra == mantra }) {
            await current.update(content)
            for other in running where other.id != current.id {
                await other.end(nil, dismissalPolicy: .immediate)
            }
            return
        }
        for activity in running {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        do {
            _ = try Activity.request(
                attributes: CounterActivityAttributes(mantra: mantra),
                content: content,
                pushType: nil)
        } catch {
            NSLog("japmala: could not start the lock screen counter: \(error)")
        }
    }
}
