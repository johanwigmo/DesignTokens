import SwiftUI

// MARK: - Example: Custom Theme

/// A minimal color-only theme. Only brand colors and tweaked
/// status colors are declared — everything else inherits from
/// the protocol defaults.
///
/// ```swift
/// ContentView()
///     .theme(OceanTheme())
/// ```
public struct OceanTheme: Theme {
    public let name = "Ocean"

    public let primary: Color = Color(red: 0.0, green: 0.48, blue: 0.80)
    public let secondary: Color = Color(red: 0.40, green: 0.60, blue: 0.70)
    public let accent: Color = Color(red: 0.0, green: 0.78, blue: 0.75)

    // Optional overrides — only declare what differs.
    public let success: Color = Color(red: 0.0, green: 0.70, blue: 0.50)
    public let info: Color = Color(red: 0.0, green: 0.48, blue: 0.80)

    public init() {}
}
