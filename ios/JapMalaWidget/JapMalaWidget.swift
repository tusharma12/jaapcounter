import SwiftUI
import WidgetKit

// The JapMala home screen widget.
//
// Values are written by the app into the shared app group (see
// WidgetService in lib/core/services/widget_service.dart), so the widget
// renders current numbers without launching the app.
//
// This file is not part of the Runner target. Add it to a Widget Extension
// target in Xcode — docs/PLATFORM_SETUP.md has the steps.

private let appGroupId = "group.com.japmala.japmala"

private enum Palette {
    static let saffron = Color(red: 0.961, green: 0.651, blue: 0.137)
    static let track = Color(red: 0.929, green: 0.922, blue: 0.902)
}

struct JapMalaEntry: TimelineEntry {
    let date: Date
    let mantra: String
    let beads: Int
    let malaSize: Int
    let todayTotal: Int
    let todayMalas: Int
    let streak: Int

    var fraction: Double {
        guard malaSize > 0 else { return 0 }
        return min(max(Double(beads) / Double(malaSize), 0), 1)
    }

    static let placeholder = JapMalaEntry(
        date: Date(),
        mantra: "ॐ नमः शिवाय",
        beads: 42,
        malaSize: 108,
        todayTotal: 324,
        todayMalas: 3,
        streak: 12
    )
}

struct JapMalaProvider: TimelineProvider {
    func placeholder(in context: Context) -> JapMalaEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (JapMalaEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JapMalaEntry>) -> Void) {
        // The app refreshes the widget whenever beads are counted; this
        // schedule is only a fallback so a stale widget still catches up.
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [read()], policy: .after(next)))
    }

    private func read() -> JapMalaEntry {
        let store = UserDefaults(suiteName: appGroupId)
        return JapMalaEntry(
            date: Date(),
            mantra: store?.string(forKey: "mantra") ?? "JapMala",
            beads: store?.integer(forKey: "beads") ?? 0,
            malaSize: max(store?.integer(forKey: "malaSize") ?? 108, 1),
            todayTotal: store?.integer(forKey: "todayTotal") ?? 0,
            todayMalas: store?.integer(forKey: "todayMalas") ?? 0,
            streak: store?.integer(forKey: "streak") ?? 0
        )
    }
}

struct JapMalaWidgetView: View {
    let entry: JapMalaEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.mantra)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(entry.beads)")
                    .font(.system(size: 30, weight: .semibold))
                Text("/ \(entry.malaSize)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Palette.track)
                    Capsule()
                        .fill(Palette.saffron)
                        .frame(width: geometry.size.width * entry.fraction)
                }
            }
            .frame(height: 7)

            HStack(spacing: 6) {
                Text("Today \(entry.todayTotal)")
                if entry.todayMalas > 0 {
                    Text("· \(entry.todayMalas)×")
                }
                if entry.streak > 0 {
                    Text("· 🔥 \(entry.streak)")
                }
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct JapMalaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "JapMalaWidget", provider: JapMalaProvider()) { entry in
            JapMalaWidgetView(entry: entry)
        }
        .configurationDisplayName("JapMala")
        .description("Today's Jaap and the mala in progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct JapMalaWidgetBundle: WidgetBundle {
    var body: some Widget { JapMalaWidget() }
}
