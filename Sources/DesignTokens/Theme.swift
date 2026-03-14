import SwiftUI

// MARK: - Theme Protocol

/// The contract every theme must fulfill.
/// Covers semantic colors, typography, and spacing.
public protocol Theme: Sendable {
    var name: String { get }

    // MARK: Brand Colors (required)
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }

    // MARK: Semantic Colors (defaulted)
    var background: Color { get }
    var backgroundSecondary: Color { get }
    var backgroundTertiary: Color { get }
    var surface: Color { get }
    var surfaceSecondary: Color { get }
    var label: Color { get }
    var labelSecondary: Color { get }
    var labelTertiary: Color { get }
    var labelQuaternary: Color { get }
    var separator: Color { get }
    var destructive: Color { get }
    var success: Color { get }
    var warning: Color { get }
    var info: Color { get }

    // MARK: Typography & Spacing (defaulted)
    var typography: ThemeTypography { get }
    var spacing: ThemeSpacing { get }
}

// MARK: - Default Implementations

/// System-standard defaults for every property except brand colors.
/// A minimal theme only needs `name`, `primary`, `secondary`, and `accent`.
public extension Theme {
    var background: Color { Color(.systemBackground) }
    var backgroundSecondary: Color { Color(.secondarySystemBackground) }
    var backgroundTertiary: Color { Color(.tertiarySystemBackground) }
    var surface: Color { Color(.systemGroupedBackground) }
    var surfaceSecondary: Color { Color(.secondarySystemGroupedBackground) }
    var label: Color { Color(.label) }
    var labelSecondary: Color { Color(.secondaryLabel) }
    var labelTertiary: Color { Color(.tertiaryLabel) }
    var labelQuaternary: Color { Color(.quaternaryLabel) }
    var separator: Color { Color(.separator) }
    var destructive: Color { .red }
    var success: Color { .green }
    var warning: Color { .orange }
    var info: Color { .blue }

    var typography: ThemeTypography { .default }
    var spacing: ThemeSpacing { .default }
}

// MARK: - Default Theme

/// Maps directly to iOS system colors and standard metrics.
/// Looks and feels like a stock iOS app out of the box.
public struct DefaultTheme: Theme {
    public let name = "Default"
    public let primary: Color = .accentColor
    public let secondary: Color = Color(.secondaryLabel)
    public let accent: Color = .accentColor

    public init() {}
}
