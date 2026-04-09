import SwiftUI
import SwiftData

struct QuestsView: View {
    @Query var allQuests: [Quest]
    @State private var selectedTab: QuestTab = .daily

    enum QuestTab { case daily, weekly }

    var dailyQuests:  [Quest] { allQuests.filter { !$0.isWeekly }.sorted { !$0.isCompleted && $1.isCompleted } }
    var weeklyQuests: [Quest] { allQuests.filter {  $0.isWeekly }.sorted { !$0.isCompleted && $1.isCompleted } }
    var activeQuests: [Quest] { selectedTab == .daily ? dailyQuests : weeklyQuests }
    var completedCount: Int   { activeQuests.filter { $0.isCompleted }.count }

    var body: some View {
        ZStack {
            Color.pmBackground.ignoresSafeArea()

            // Ambient particles — decorative, hidden from accessibility
            AmbientParticleBackground(particleCount: 10)

            VStack(spacing: 20) {
                // Tab picker
                Picker("Quest Type", selection: $selectedTab) {
                    Text("Daily").tag(QuestTab.daily)
                    Text("Weekly").tag(QuestTab.weekly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .accessibilityLabel("Quest category")

                // Progress summary
                VStack(spacing: 8) {
                    HStack {
                        Text(selectedTab == .daily ? "Today's Progress" : "This Week's Progress")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.pmText)
                        Spacer()
                        Text("\(completedCount)/\(activeQuests.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.pmGold)
                            .goldGlow(radius: 3)
                            .accessibilityLabel("\(completedCount) of \(activeQuests.count) quests completed")
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.pmPrimary.opacity(0.1))

                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.pmPrimary, .pmGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progressRatio)
                                .neonGlow(radius: 4)
                        }
                    }
                    .frame(height: 12)
                    .accessibilityLabel("Quest progress")
                    .accessibilityValue("\(completedCount) of \(activeQuests.count) completed")
                }
                .padding(.horizontal)

                // Quest list
                if activeQuests.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.pmSuccess)
                            .neonGlow(color: .pmSuccess, radius: 8)
                            .accessibilityHidden(true)
                        Text("No Quests Available")
                            .font(.headline)
                            .foregroundStyle(Color.pmSecondaryText)
                        Text("Check back soon for new \(selectedTab == .daily ? "daily" : "weekly") quests!")
                            .font(.caption)
                            .foregroundStyle(Color.pmSecondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(activeQuests, id: \.id) { quest in
                                QuestCard(quest: quest, isCompleted: quest.isCompleted)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Quests")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressRatio: CGFloat {
        guard !activeQuests.isEmpty else { return 0 }
        return CGFloat(completedCount) / CGFloat(activeQuests.count)
    }
}

#Preview {
    NavigationStack {
        QuestsView()
            .modelContainer(for: [Quest.self], inMemory: true)
    }
}
