import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var icon: String = "chart.bar.fill"
    var color: Color = .pmPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StreakBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color.pmGold)
                .goldGlow(radius: 4)
            Text("\(count)")
                .font(.headline.weight(.bold).monospacedDigit())
                .foregroundStyle(Color.pmGold)
            Text("day streak")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.pmGold.opacity(0.10))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.pmGold.opacity(0.25), lineWidth: 1))
    }
}
