import SwiftUI

// MARK: - Environment Integration

/// Environment key that carries the active theme down the view tree.
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any Theme = DefaultTheme()
}

public extension EnvironmentValues {
    /// The current design theme.
    ///
    /// Read in any view:
    /// ```swift
    /// @Environment(\.theme) private var theme
    /// ```
    var theme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public extension View {
    /// Inject a theme for this view subtree.
    ///
    /// ```swift
    /// ContentView()
    ///     .theme(OceanTheme())
    /// ```
    func theme(_ theme: any Theme) -> some View {
        environment(\.theme, theme)
    }
}
