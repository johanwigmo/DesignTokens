import SwiftUI
import DesignTokens

// MARK: - App Entry Point

/// Inject a theme at the root of your app.
/// Every child view reads tokens via @Environment(\.theme).
@main
struct ExampleApp: App {
    @State private var currentTheme: any Theme = DefaultTheme()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .theme(currentTheme)
        }
    }
}

// MARK: - Using Tokens in Views

struct ContentView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.gap) {

                    // Typography tokens
                    Text("Welcome back")
                        .font(theme.typography.largeTitle)
                        .foregroundStyle(theme.label)

                    Text("Here's what's new today.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.labelSecondary)

                    // Color tokens
                    HStack(spacing: theme.spacing.sm) {
                        StatusBadge(text: "Active", color: theme.success)
                        StatusBadge(text: "Warning", color: theme.warning)
                        StatusBadge(text: "Error", color: theme.destructive)
                    }

                    // Spacing tokens — no magic numbers
                    VStack(spacing: theme.spacing.xs) {
                        ForEach(0..<3) { i in
                            TaskRow()
                        }
                    }
                    .padding(theme.spacing.inset)
                    .background(theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(theme.spacing.inset)
            }
            .background(theme.background)
            .navigationTitle("Home")
        }
    }
}

// MARK: - Component Examples

struct StatusBadge: View {
    @Environment(\.theme) private var theme
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(theme.typography.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(color)
            .clipShape(Capsule())
    }
}

struct TaskRow: View {
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "circle")
                .foregroundStyle(theme.primary)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Task title")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.label)

                Text("Due tomorrow")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.labelTertiary)
            }

            Spacer()
        }
        .frame(minHeight: theme.spacing.minTapTarget)
    }
}

// MARK: - Switching Themes

/// Example of a theme picker — users select a theme and the
/// entire app updates instantly via the environment.
struct ThemePickerView: View {
    @Binding var currentTheme: any Theme

    private let themes: [(String, any Theme)] = [
        ("Default", DefaultTheme()),
        ("Ocean", OceanTheme())
    ]

    var body: some View {
        List {
            ForEach(themes, id: \.0) { name, theme in
                Button {
                    currentTheme = theme
                } label: {
                    HStack {
                        Circle()
                            .fill(theme.primary)
                            .frame(width: 24, height: 24)
                        Text(name)
                        Spacer()
                        if currentTheme.name == theme.name {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle("Theme")
    }
}

// MARK: - Themed Padding Modifier Usage

struct ModifierExample: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Text("Padded content")
            .themedPadding(.all, \.inset)
            .background(theme.surface)
    }
}
