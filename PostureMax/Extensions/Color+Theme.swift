import SwiftUI

extension Color {
    // Primary brand colors
    static let pmPrimary = Color(red: 0.0, green: 0.75, blue: 0.72)        // Teal
    static let pmSecondary = Color(red: 0.18, green: 0.55, blue: 0.98)     // Blue
    static let pmAccent = Color(red: 0.98, green: 0.56, blue: 0.15)        // Orange
    static let pmSuccess = Color(red: 0.20, green: 0.78, blue: 0.35)       // Green
    static let pmWarning = Color(red: 0.98, green: 0.82, blue: 0.0)        // Yellow
    static let pmDanger = Color(red: 0.93, green: 0.26, blue: 0.26)        // Red

    // Background colors
    static let pmBackground = Color(.systemBackground)
    static let pmCardBackground = Color(.secondarySystemBackground)
    static let pmGroupedBackground = Color(.systemGroupedBackground)

    // Gradient
    static let pmGradientStart = Color(red: 0.0, green: 0.75, blue: 0.72)
    static let pmGradientEnd = Color(red: 0.18, green: 0.55, blue: 0.98)

    static var pmGradient: LinearGradient {
        LinearGradient(
            colors: [.pmGradientStart, .pmGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension ShapeStyle where Self == LinearGradient {
    static var pmBrandGradient: LinearGradient {
        LinearGradient(
            colors: [.pmGradientStart, .pmGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
