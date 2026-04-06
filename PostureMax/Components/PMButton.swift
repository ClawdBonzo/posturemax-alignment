import SwiftUI

struct PMButton: View {
    let title: String
    var icon: String? = nil
    var style: PMButtonStyle = .primary
    let action: () -> Void

    enum PMButtonStyle {
        case primary, secondary, outline, destructive
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(background)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.pmPrimary, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var background: some ShapeStyle {
        switch style {
        case .primary: return AnyShapeStyle(Color.pmGradient)
        case .secondary: return AnyShapeStyle(Color.pmCardBackground)
        case .outline: return AnyShapeStyle(Color.clear)
        case .destructive: return AnyShapeStyle(Color.pmDanger)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .primary
        case .outline: return .pmPrimary
        case .destructive: return .white
        }
    }
}

struct PMSmallButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.pmPrimary.opacity(0.15))
            .foregroundStyle(Color.pmPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
