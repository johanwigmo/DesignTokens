import SwiftUI

// MARK: - Themed View Modifiers

public extension View {
    /// Apply themed padding using spacing tokens.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .padding(.themed(\.inset))
    /// ```
    func themedPadding(_ edges: Edge.Set = .all, _ keyPath: KeyPath<ThemeSpacing, CGFloat>) -> some View {
        modifier(ThemedPaddingModifier(edges: edges, keyPath: keyPath))
    }
}

private struct ThemedPaddingModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let edges: Edge.Set
    let keyPath: KeyPath<ThemeSpacing, CGFloat>

    func body(content: Content) -> some View {
        content.padding(edges, theme.spacing[keyPath: keyPath])
    }
}

// MARK: - Semantic Text Views

/// Convenience initializers that pair text styles with semantic colors.
public extension Text {
    /// Title text with primary label color.
    func titleStyle(_ theme: any Theme) -> Text {
        self
            .font(theme.typography.title)
            .foregroundColor(theme.label)
    }

    /// Body text with primary label color.
    func bodyStyle(_ theme: any Theme) -> Text {
        self
            .font(theme.typography.body)
            .foregroundColor(theme.label)
    }

    /// Caption text with secondary label color.
    func captionStyle(_ theme: any Theme) -> Text {
        self
            .font(theme.typography.caption)
            .foregroundColor(theme.labelSecondary)
    }
}
