import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Timeline Entry
struct PostureEntry: TimelineEntry {
    let date: Date
    let postureScore: Int
    let painLevel: Int
    let streak: Int
    let hasLoggedToday: Bool
}

// MARK: - Timeline Provider
struct PostureTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PostureEntry {
        PostureEntry(date: .now, postureScore: 7, painLevel: 3, streak: 5, hasLoggedToday: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (PostureEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PostureEntry>) -> Void) {
        // In production, read from shared SwiftData container or App Group
        let entry = PostureEntry(
            date: .now,
            postureScore: 7,
            painLevel: 3,
            streak: 5,
            hasLoggedToday: false
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views
struct PostureWidgetSmallView: View {
    let entry: PostureEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "figure.stand")
                    .foregroundStyle(.teal)
                Text("PostureMax")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if entry.hasLoggedToday {
                VStack(spacing: 4) {
                    Text("\(entry.postureScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.teal)
                    Text("Today's Score")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 28))
                        .foregroundStyle(.teal.opacity(0.6))
                    Text("Log Today")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Text("\(entry.streak) day streak")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PostureWidgetMediumView: View {
    let entry: PostureEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left: Score
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(.teal.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: Double(entry.postureScore) / 10.0)
                        .stroke(.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(entry.postureScore)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("/10")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)

                Text("Posture Score")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            // Right: Stats
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.stand")
                        .foregroundStyle(.teal)
                    Text("PostureMax")
                        .font(.subheadline.weight(.semibold))
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pain")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text("\(entry.painLevel)/10")
                            .font(.subheadline.weight(.bold).monospacedDigit())
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Streak")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.orange)
                            Text("\(entry.streak)")
                                .font(.subheadline.weight(.bold).monospacedDigit())
                        }
                    }
                }

                if !entry.hasLoggedToday {
                    Text("Tap to log today")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.teal.opacity(0.15))
                        .foregroundStyle(.teal)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration
struct PostureMaxWidget: Widget {
    let kind: String = "PostureMaxWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PostureTimelineProvider()) { entry in
            if #available(iOS 18, *) {
                PostureWidgetSmallView(entry: entry)
            }
        }
        .configurationDisplayName("Posture Glance")
        .description("Quick view of today's posture score and streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle
@main
struct PostureMaxWidgetBundle: WidgetBundle {
    var body: some Widget {
        PostureMaxWidget()
    }
}
