import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        if coordinator.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingContainerView()
        }
    }
}

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            Tab("Dashboard", image: "Tab-Dashboard", value: .dashboard) {
                DashboardView()
            }

            Tab("Log", image: "Tab-DailyLogger", value: .logger) {
                DailyLoggerStandaloneView()
            }

            Tab("Photos", image: "Tab-StreakCalendar", value: .photos) {
                PhotoJournalView()
            }

            Tab("Progress", image: "Tab-ProgressCharts", value: .progress) {
                ProgressChartsView()
            }

            Tab("Settings", image: "Tab-Settings", value: .routines) {
                RoutineLibraryView()
            }
        }
        .tint(Color.pmPrimary)
    }
}

// Standalone version that wraps the logger in its own nav
struct DailyLoggerStandaloneView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var showLogger = false

    private var todayLog: DailyLog? {
        logs.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            if let log = todayLog {
                // Show today's log summary
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.pmSuccess)
                            Text("Today's Log Complete")
                                .font(.title3.weight(.semibold))
                            Text(Date().mediumFormatted)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 30)

                        ScoreRing(score: log.postureRating, maxScore: 10, size: 120, label: "Posture Score")

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Pain Level", value: "\(log.painLevel)/10", icon: "bolt.fill", color: .pmDanger)
                            StatCard(title: "Neck", value: "\(log.neckAlignment)/10", icon: "figure.wave", color: .pmSecondary)
                            StatCard(title: "Spine", value: "\(log.spineAlignment)/10", icon: "figure.stand", color: .pmPrimary)
                            StatCard(title: "Mobility", value: "\(log.overallMobility)/10", icon: "figure.flexibility", color: .pmAccent)
                        }
                        .padding(.horizontal)

                        if !log.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes")
                                    .font(.headline)
                                Text(log.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.pmCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                        }

                        PMButton(title: "Edit Today's Log", icon: "pencil", style: .secondary) {
                            showLogger = true
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.pmGroupedBackground)
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.pmPrimary.opacity(0.5))
                    Text("No log today yet")
                        .font(.title3.weight(.semibold))
                    Text("Track your posture and pain levels")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    PMButton(title: "Start Today's Log", icon: "plus.circle.fill") {
                        showLogger = true
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                }
                .background(Color.pmGroupedBackground)
            }
        }
        .navigationTitle("Daily Log")
        .sheet(isPresented: $showLogger) {
            DailyLoggerView()
        }
    }
}
