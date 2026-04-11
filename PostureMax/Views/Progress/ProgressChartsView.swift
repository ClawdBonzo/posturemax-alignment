import SwiftUI
import SwiftData
import Charts

struct ProgressChartsView: View {
    @Query(sort: \DailyLog.date) private var logs: [DailyLog]
    @State private var selectedRange: TimeRange = .week
    @State private var selectedTrait: PostureTrait = .overall
    @State private var showUpgradeSheet = false

    private var isPro: Bool { PurchaseManager.shared.isPro }

    enum TimeRange: String, CaseIterable {
        case week    = "7D"
        case month   = "30D"
        case quarter = "90D"
        case all     = "All"

        var days: Int? {
            switch self {
            case .week:    return 7
            case .month:   return 30
            case .quarter: return 90
            case .all:     return nil
            }
        }
    }

    enum PostureTrait: String, CaseIterable {
        case overall   = "Overall"
        case pain      = "Pain"
        case neck      = "Neck"
        case shoulders = "Shoulders"
        case spine     = "Spine"
        case hips      = "Hips"
        case mobility  = "Mobility"
    }

    private var filteredLogs: [DailyLog] {
        guard let days = selectedRange.days else { return logs }
        let cutoff = Date().daysAgo(days)
        return logs.filter { $0.date >= cutoff }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pmGroupedBackground.ignoresSafeArea()
                AmbientParticleBackground(particleCount: 10)

                ScrollView {
                    VStack(spacing: 20) {
                        // Time range picker
                        Picker("Time range", selection: $selectedRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .accessibilityLabel("Chart time range")
                        .onChange(of: selectedRange) { _, newRange in
                            if !isPro && newRange != .week {
                                selectedRange = .week
                                showUpgradeSheet = true
                            }
                        }

                        mainChart
                        traitSelector
                        statsSummary
                        traitBreakdown
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Progress")
            .sheet(isPresented: $showUpgradeSheet) {
                ContextualPaywallSheet(
                    feature: "Full Progress History",
                    icon: "chart.line.uptrend.xyaxis",
                    description: "See your 30-day, 90-day, and all-time posture trends to track your real transformation."
                )
            }
        }
    }

    // MARK: - Chart

    private var mainChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedTrait.rawValue)
                .font(.headline)
                .padding(.horizontal)

            if filteredLogs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundStyle(Color.pmPrimary)
                        .neonGlow(radius: 8)
                        .accessibilityHidden(true)
                    Text("No data yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("No chart data available yet")
            } else {
                Chart(filteredLogs) { log in
                    LineMark(
                        x: .value("Date",  log.date),
                        y: .value("Score", traitValue(for: log))
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .leading, endPoint: .trailing)
                    )
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date",  log.date),
                        y: .value("Score", traitValue(for: log))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.pmPrimary.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date",  log.date),
                        y: .value("Score", traitValue(for: log))
                    )
                    .foregroundStyle(Color.pmGold)
                    .symbolSize(24)
                }
                .chartYScale(domain: 0...10)
                .chartYAxis { AxisMarks(values: [0, 2, 4, 6, 8, 10]) }
                .frame(height: 220)
                .padding(.horizontal)
                .accessibilityLabel("\(selectedTrait.rawValue) score chart over \(selectedRange.rawValue)")
            }
        }
        .padding(.vertical, 16)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    // MARK: - Trait selector

    private var traitSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PostureTrait.allCases, id: \.self) { trait in
                    Button {
                        selectedTrait = trait
                    } label: {
                        Text(trait.rawValue)
                            .font(.subheadline.weight(selectedTrait == trait ? .semibold : .regular))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedTrait == trait
                                    ? AnyShapeStyle(LinearGradient(colors: [.pmPrimary, .pmGold.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color.pmCardBackground)
                            )
                            .foregroundStyle(selectedTrait == trait ? Color.black : Color.primary)
                            .clipShape(Capsule())
                            .shadow(color: selectedTrait == trait ? Color.pmPrimary.opacity(0.35) : .clear, radius: 6)
                    }
                    .accessibilityLabel("\(trait.rawValue) trait")
                    .accessibilityAddTraits(selectedTrait == trait ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Stats summary

    private var statsSummary: some View {
        let avg    = filteredLogs.isEmpty ? 0.0 : Double(filteredLogs.map { traitValue(for: $0) }.reduce(0, +)) / Double(filteredLogs.count)
        let best   = filteredLogs.map { traitValue(for: $0) }.max() ?? 0
        let latest = filteredLogs.last.map { traitValue(for: $0) } ?? 0

        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            StatCard(title: "Average", value: String(format: "%.1f", avg), icon: "divide",   color: .pmSecondary)
            StatCard(title: "Best",    value: "\(best)",                   icon: "arrow.up",  color: .pmSuccess)
            StatCard(title: "Latest",  value: "\(latest)",                 icon: "clock",     color: .pmPrimary)
        }
        .padding(.horizontal)
    }

    // MARK: - Trait breakdown

    private var traitBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trait Breakdown")
                .font(.headline)
                .padding(.horizontal)

            if let latest = filteredLogs.last {
                VStack(spacing: 10) {
                    TraitRow(name: "Overall Posture",   score: latest.postureRating)
                    TraitRow(name: "Pain Level",        score: 10 - latest.painLevel, inverted: true)
                    TraitRow(name: "Neck Alignment",    score: latest.neckAlignment)
                    TraitRow(name: "Shoulder Balance",  score: latest.shoulderBalance)
                    TraitRow(name: "Spine Alignment",   score: latest.spineAlignment)
                    TraitRow(name: "Hip Alignment",     score: latest.hipAlignment)
                    TraitRow(name: "Mobility",          score: latest.overallMobility)
                }
                .padding(.horizontal)
            } else {
                Text("Log your first day to see breakdown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private func traitValue(for log: DailyLog) -> Int {
        switch selectedTrait {
        case .overall:   return log.postureRating
        case .pain:      return 10 - log.painLevel
        case .neck:      return log.neckAlignment
        case .shoulders: return log.shoulderBalance
        case .spine:     return log.spineAlignment
        case .hips:      return log.hipAlignment
        case .mobility:  return log.overallMobility
        }
    }
}

// MARK: - Trait Row (neon progress bar)

struct TraitRow: View {
    let name:     String
    let score:    Int
    var inverted: Bool = false

    private var barColor: Color {
        switch score {
        case 0...3:  return .pmDanger
        case 4...5:  return .pmWarning
        case 6...7:  return .pmAccent
        default:     return .pmSuccess
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("\(score)/10")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(barColor.opacity(0.12))
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(score) / 10.0)
                        .shadow(color: barColor.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name): \(score) out of 10")
    }
}
