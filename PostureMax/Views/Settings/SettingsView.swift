import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppCoordinator.self) private var coordinator
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var photos: [PosturePhoto]
    @Query private var streaks: [StreakRecord]

    @State private var showExportSheet = false
    @State private var showResetAlert = false
    @State private var exportedPDFData: Data?

    private var profile: UserProfile? { profiles.first }
    private var streak: StreakRecord { streaks.first ?? StreakRecord() }

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section("Profile") {
                    if let profile {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.pmPrimary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.displayName)
                                    .font(.headline)
                                Text("Member since \(profile.createdAt.mediumFormatted)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        HStack {
                            Text("Subscription")
                            Spacer()
                            Text(profile.isPremium ? "Premium" : "Free")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Stats Section
                Section("Statistics") {
                    StatRow(label: "Total Logs", value: "\(logs.count)")
                    StatRow(label: "Current Streak", value: "\(streak.currentStreak) days")
                    StatRow(label: "Longest Streak", value: "\(streak.longestStreak) days")
                    StatRow(label: "Total Photos", value: "\(photos.count)")
                }

                // Export
                Section("Reports") {
                    Button {
                        generatePDF()
                    } label: {
                        Label("Export PDF Report", systemImage: "doc.richtext")
                    }
                }

                // Data
                Section("Data & Privacy") {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(Color.pmSuccess)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("100% Private")
                                .font(.subheadline.weight(.medium))
                            Text("All data stored locally on your device")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://posturemax.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://posturemax.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your logs, photos, and progress. This cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                if let data = exportedPDFData {
                    ShareSheet(items: [data])
                }
            }
        }
    }

    private func generatePDF() {
        guard let profile else { return }
        let data = PDFExportService.generateReport(
            profile: profile,
            logs: logs,
            photos: photos,
            streak: streak
        )
        exportedPDFData = data
        showExportSheet = true
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: DailyLog.self)
            try modelContext.delete(model: PosturePhoto.self)
            try modelContext.delete(model: RoutineItem.self)
            try modelContext.delete(model: StreakRecord.self)
            try modelContext.delete(model: UserProfile.self)
            try modelContext.save()
            coordinator.resetOnboarding()
        } catch {
            print("Reset failed: \(error)")
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
