import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

// The lock-screen counter: a Live Activity with a +1 button that works
// without unlocking or opening the app.
//
// Taps go to AddBeadIntent (CounterActivityShared.swift), which only counts
// them as pending; the app writes them to the ledger when it next comes
// forward. The activity wears the app's theme, read from the same app group
// the home screen widget uses.

struct CounterLockScreenView: View {
    let attributes: CounterActivityAttributes
    let state: CounterActivityAttributes.ContentState

    private var theme: WidgetTheme {
        WidgetTheme.read(UserDefaults(suiteName: counterAppGroupId))
    }

    private var fraction: Double {
        guard state.malaSize > 0 else { return 0 }
        return min(max(Double(state.beads) / Double(state.malaSize), 0), 1)
    }

    var body: some View {
        let theme = theme
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(attributes.mantra)
                    .font(.headline)
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(state.beads) / \(state.malaSize)")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(theme.accent)
                    .contentTransition(.numericText())
                ProgressView(value: fraction)
                    .tint(theme.accent)
                Text("\(state.todayTotal)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(theme.secondaryText)
            }
            Button(intent: AddBeadIntent()) {
                Text("+1")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .frame(width: 76, height: 76)
                    .background(theme.accent, in: Circle())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Count a bead")
        }
        .padding(16)
        .activityBackgroundTint(theme.background)
    }
}

struct JapMalaLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CounterActivityAttributes.self) { context in
            CounterLockScreenView(attributes: context.attributes, state: context.state)
        } dynamicIsland: { context in
            let accent = WidgetTheme.read(UserDefaults(suiteName: counterAppGroupId)).accent
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(context.state.beads) / \(context.state.malaSize)")
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: AddBeadIntent()) {
                        Text("+1").font(.title3.weight(.bold))
                    }
                    .tint(accent)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.mantra)
                        .font(.subheadline)
                        .lineLimit(1)
                }
            } compactLeading: {
                Text("\(context.state.beads)")
                    .monospacedDigit()
                    .foregroundStyle(accent)
            } compactTrailing: {
                Text("/\(context.state.malaSize)")
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Text("\(context.state.beads)")
                    .monospacedDigit()
                    .foregroundStyle(accent)
            }
        }
    }
}
