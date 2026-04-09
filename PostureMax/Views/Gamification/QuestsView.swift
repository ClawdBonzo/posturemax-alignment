import SwiftUI
import SwiftData

struct QuestsView: View {
    @Query var allQuests: [Quest]
    @State private var selectedTab: QuestTab = .daily

    enum QuestTab {
        case daily
        case weekly
    }

    var dailyQuests: [Quest] {
        allQuests.filter { !$0.isWeekly }.sorted { !$0.isCompleted && $1.isCompleted }
    }

    var weeklyQuests: [Quest] {
        allQuests.filter { $0.isWeekly }.sorted { !$0.isCompleted && $1.isCompleted }
    }

    var activeQuests: [Quest] {
        selectedTab == .daily ? dailyQuests : weeklyQuests
    }

    var completedCount: Int {
        activeQuests.filter { $0.isCompleted }.count
    }

    var body: some View {
        ZStack {
            Color.pmBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                // Tab Selection
                Picker("Quest Type", selection: $selectedTab) {
                    Text("Daily").tag(QuestTab.daily)
                    Text("Weekly").tag(QuestTab.weekly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Progress Summary
                VStack(spacing: 8) {
                    HStack {
                        Text(selectedTab == .daily ? "Today's Progress" : "This Week's Progress")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.pmText)
                        Spacer()
                        Text("\(completedCount)/\(activeQuests.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.pmAccent)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.pmPrimary.opacity(0.1))

                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.pmSuccess)
                                .frame(width: geometry.size.width * (activeQuests.isEmpty ? 0 : Double(completedCount) / Double(activeQuests.count)))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal)

                // Quests List
                if activeQuests.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.pmSuccess)
                        Text("No Quests Available")
                            .font(.headline)
                            .foregroundColor(.pmSecondaryText)
                        Text("Check back soon for new \(selectedTab == .daily ? "daily" : "weekly") quests!")
                            .font(.caption)
                            .foregroundColor(.pmSecondaryText)
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
}

#Preview {
    NavigationStack {
        QuestsView()
            .modelContainer(for: [Quest.self], inMemory: true)
    }
}
