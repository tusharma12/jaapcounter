import SwiftUI
import WidgetKit

// The Smaran home screen widget.
//
// Values are written by the app into the shared app group (see
// WidgetService in lib/core/services/widget_service.dart), so the widget
// renders current numbers without launching the app.
//
// It wears the theme chosen in the app: the app writes that theme's colours
// alongside the counts. With the Auto theme none are written, and the widget
// follows the system's light and dark instead, as the app does.

private let appGroupId = "group.com.naamjapcounter.smaran"

/// Colours from the app's theme, or the system's when it is on Auto.
struct WidgetTheme {
    var background: Color = Color(.systemBackground)
    var text: Color = .primary
    var secondaryText: Color = .secondary
    var accent: Color = Color(red: 0.961, green: 0.651, blue: 0.137)
    var track: Color = Color(.systemGray5)
    var streak: Color = .secondary

    static func read(_ store: UserDefaults?) -> WidgetTheme {
        var theme = WidgetTheme()
        func color(_ key: String) -> Color? {
            guard let store, store.object(forKey: key) != nil else { return nil }
            let argb = UInt32(truncatingIfNeeded: store.integer(forKey: key))
            return Color(
                .sRGB,
                red: Double((argb >> 16) & 0xFF) / 255,
                green: Double((argb >> 8) & 0xFF) / 255,
                blue: Double(argb & 0xFF) / 255,
                opacity: Double((argb >> 24) & 0xFF) / 255
            )
        }
        if let c = color("colorBackground") { theme.background = c }
        if let c = color("colorText") { theme.text = c }
        if let c = color("colorSecondaryText") { theme.secondaryText = c }
        if let c = color("colorAccent") { theme.accent = c }
        if let c = color("colorTrack") { theme.track = c }
        if let c = color("colorStreak") { theme.streak = c }
        return theme
    }
}

struct JapMalaEntry: TimelineEntry {
    let date: Date
    let mantra: String
    let beads: Int
    let malaSize: Int
    let todayTotal: Int
    let todayMalas: Int
    let streak: Int
    var theme = WidgetTheme()

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
            mantra: store?.string(forKey: "mantra") ?? "Smaran",
            beads: store?.integer(forKey: "beads") ?? 0,
            malaSize: max(store?.integer(forKey: "malaSize") ?? 108, 1),
            todayTotal: store?.integer(forKey: "todayTotal") ?? 0,
            todayMalas: store?.integer(forKey: "todayMalas") ?? 0,
            streak: store?.integer(forKey: "streak") ?? 0,
            theme: WidgetTheme.read(store)
        )
    }
}

struct JapMalaWidgetView: View {
    let entry: JapMalaEntry

    var body: some View {
        let theme = entry.theme
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image("AppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(entry.mantra.replacingOccurrences(of: "\n", with: " "))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
            }

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(entry.beads)")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(theme.text)
                    .monospacedDigit()
                Text("/ \(entry.malaSize)")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.secondaryText)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.track)
                    Capsule()
                        .fill(theme.accent)
                        .frame(width: geometry.size.width * entry.fraction)
                }
            }
            .frame(height: 7)

            HStack(spacing: 6) {
                Text("Today \(entry.todayTotal)")
                    .foregroundStyle(theme.secondaryText)
                if entry.todayMalas > 0 {
                    Text("· \(entry.todayMalas)×")
                        .foregroundStyle(theme.secondaryText)
                }
                if entry.streak > 0 {
                    Label("\(entry.streak)", systemImage: "flame.fill")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(theme.streak)
                }
            }
            .font(.system(size: 12, weight: .medium))
            .lineLimit(1)
        }
        .containerBackground(for: .widget) { theme.background }
    }
}

struct JapMalaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "JapMalaWidget", provider: JapMalaProvider()) { entry in
            JapMalaWidgetView(entry: entry)
        }
        .configurationDisplayName("NaamJapCounter")
        .description("Today's Jaap and the mala in progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct JapMalaWidgetBundle: WidgetBundle {
    var body: some Widget { JapMalaWidget() }
}
