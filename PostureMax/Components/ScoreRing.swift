import SwiftUI

struct ScoreRing: View {
    let score: Int
    let maxScore: Int
    var size: CGFloat = 100
    var lineWidth: CGFloat = 10
    var label: String? = nil

    private var progress: Double {
        Double(score) / Double(maxScore)
    }

    private var ringColor: Color {
        switch progress {
        case 0..<0.3: return .pmDanger
        case 0.3..<0.6: return .pmWarning
        case 0.6..<0.8: return .pmAccent
        default: return .pmSuccess
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.2), lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)

                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                    Text("/\(maxScore)")
                        .font(.system(size: size * 0.12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: size, height: size)

            if let label {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
