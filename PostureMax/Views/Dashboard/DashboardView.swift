import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var profiles: [UserProfile]
    @Query private var streaks: [StreakRecord]

    @State private var showLogger = false

    private var profile: UserProfile? { profiles.first }
    private var streak: StreakRecord { streaks.first ?? StreakRecord() }
    private var todayLog: DailyLog? {
        logs.first { Calendar.current.isDateInToday($0.date) }
    }

    private var weekLogs: [DailyLog] {
        let weekAgo = Date().daysAgo(7)
        return logs.filter { $0.date >= weekAgo }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    greetingSection

                    // Today's Score
                    todayScoreSection

                    // Quick Log Button
                    if todayLog == nil {
                        PMButton(title: "Log Today's Posture", icon: "plus.circle.fill") {
                            showLogger = true
                        }
                        .padding(.horizontal)
                    }

                    // Stats Grid
                    statsGrid

                    // Week at a Glance
                    weekGlanceSection

                    // Tips
                    dailyTipSection
                }
                .padding(.vertical)
            }
            .background(Color.pmGroupedBackground)
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showLogger) {
                DailyLoggerView()
            }
        }
    }

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(profile?.displayName ?? "there")
                    .font(.title.weight(.bold))
            }
            Spacer()
            StreakBadge(count: streak.currentStreak)
        }
        .padding(.horizontal)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning,"
        case 12..<17: return "Good afternoon,"
        default: return "Good evening,"
        }
    }

    private var todayScoreSection: some View {
        VStack(spacing: 12) {
            if let log = todayLog {
                ScoreRing(score: log.postureRating, maxScore: 10, size: 130, label: "Today's Posture")

                HStack(spacing: 20) {
                    MiniStat(title: "Pain", value: "\(log.painLevel)/10", icon: "bolt.fill", color: log.painLevel > 5 ? .pmDanger : .pmSuccess)
                    MiniStat(title: "Neck", value: "\(log.neckAlignment)/10", icon: "figure.wave", color: .pmSecondary)
                    MiniStat(title: "Spine", value: "\(log.spineAlignment)/10", icon: "figure.stand", color: .pmPrimary)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.pmPrimary.opacity(0.5))
                    Text("No log yet today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Tap below to track your posture")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Current Streak",
                value: "\(streak.currentStreak) days",
                icon: "flame.fill",
                color: .orange
            )
            StatCard(
                title: "Best Streak",
                value: "\(streak.longestStreak) days",
                icon: "trophy.fill",
                color: .pmAccent
            )
            StatCard(
                title: "Total Logs",
                value: "\(streak.totalDaysLogged)",
                icon: "calendar.badge.checkmark",
                color: .pmSecondary
            )
            StatCard(
                title: "Avg Posture",
                value: averagePosture,
                icon: "chart.line.uptrend.xyaxis",
                color: .pmPrimary
            )
        }
        .padding(.horizontal)
    }

    private var averagePosture: String {
        guard !weekLogs.isEmpty else { return "--" }
        let avg = weekLogs.map(\.postureRating).reduce(0, +) / weekLogs.count
        return "\(avg)/10"
    }

    private var weekGlanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Date().daysAgo(6 - dayOffset)
                    let log = logs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }

                    VStack(spacing: 6) {
                        Text(date.dayOfWeek)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)

                        ZStack {
                            Circle()
                                .fill(log != nil ? Color.pmPrimary : Color.pmPrimary.opacity(0.1))
                                .frame(width: 36, height: 36)

                            if let log {
                                Text("\(log.postureRating)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private var dailyTipSection: some View {
        let tips = [
            ("Stand Tall", "Imagine a string pulling the top of your head toward the ceiling", "figure.stand"),
            ("Screen Height", "Your eyes should be level with the top third of your monitor", "desktopcomputer"),
            ("Move Often", "Set a timer to stand and stretch every 30 minutes", "timer"),
            ("Breathe Deep", "Deep diaphragmatic breathing helps relax tight posture muscles", "wind"),
            ("Shoulder Check", "Roll your shoulders back and down — that's your neutral position", "figure.arms.open")
        ]

        let tip = tips[Calendar.current.component(.day, from: Date()) % tips.count]

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Daily Tip")
                    .font(.headline)
            }
            HStack(spacing: 12) {
                Image(systemName: tip.2)
                    .font(.title2)
                    .foregroundStyle(Color.pmPrimary)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tip.0)
                        .font(.subheadline.weight(.semibold))
                    Text(tip.1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
}

struct MiniStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline.weight(.bold).monospacedDigit())
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}
