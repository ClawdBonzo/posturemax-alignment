import SwiftUI

extension Color {
    // Primary brand colors — vibrant neon palette
    static let pmPrimary  = Color(red: 0.0,  green: 0.941, blue: 1.0)   // Electric Teal #00F0FF
    static let pmGold     = Color(red: 1.0,  green: 0.843, blue: 0.0)   // Glowing Gold #FFD700
    static let pmCyan     = Color(red: 0.0,  green: 0.831, blue: 1.0)   // Electric Cyan #00D4FF
    static let pmSecondary = Color(red: 0.18, green: 0.55, blue: 0.98)  // Bright Blue
    static let pmAccent   = Color(red: 1.0,  green: 0.843, blue: 0.0)   // Gold (same as pmGold)
    static let pmSuccess  = Color(red: 0.20, green: 0.78,  blue: 0.35)  // Neon Green
    static let pmWarning  = Color(red: 0.98, green: 0.82,  blue: 0.0)   // Amber
    static let pmDanger   = Color(red: 0.93, green: 0.26,  blue: 0.26)  // Red

    // Text colors (system-adaptive)
    static let pmText          = Color(uiColor: .label)
    static let pmSecondaryText = Color(uiColor: .secondaryLabel)

    // Background colors (system-adaptive)
    static let pmBackground        = Color(uiColor: .systemBackground)
    static let pmCardBackground    = Color(uiColor: .secondarySystemBackground)
    static let pmGroupedBackground = Color(uiColor: .systemGroupedBackground)

    // Gradient stops
    static let pmGradientStart = Color(red: 0.0,  green: 0.941, blue: 1.0)   // Electric Teal
    static let pmGradientMid   = Color(red: 1.0,  green: 0.843, blue: 0.0)   // Glowing Gold
    static let pmGradientEnd   = Color(red: 0.0,  green: 0.831, blue: 1.0)   // Electric Cyan

    // Brand gradient (3-stop teal → gold → cyan)
    static var pmGradient: LinearGradient {
        LinearGradient(
            colors: [.pmGradientStart, .pmGradientMid, .pmGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Neon glow gradient (for text, rings, highlights)
    static var pmNeonGradient: LinearGradient {
        LinearGradient(
            colors: [.pmPrimary, .pmGold],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension ShapeStyle where Self == LinearGradient {
    static var pmBrandGradient: LinearGradient {
        LinearGradient(
            colors: [.pmGradientStart, .pmGradientMid, .pmGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var pmNeonGradient: LinearGradient {
        LinearGradient(
            colors: [Color.pmPrimary, Color.pmGold],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - View Modifiers for Neon Glow

extension View {
    /// Adds a neon teal glow shadow
    func neonGlow(color: Color = .pmPrimary, radius: CGFloat = 12) -> some View {
        self
            .shadow(color: color.opacity(0.8), radius: radius * 0.5)
            .shadow(color: color.opacity(0.4), radius: radius)
    }

    /// Adds a gold glow shadow
    func goldGlow(radius: CGFloat = 12) -> some View {
        self
            .shadow(color: Color.pmGold.opacity(0.8), radius: radius * 0.5)
            .shadow(color: Color.pmGold.opacity(0.3), radius: radius)
    }
}
