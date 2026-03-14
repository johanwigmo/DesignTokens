# DesignTokens

A Swift package providing a themeable design token system for iOS apps. Defines a `Theme` protocol with semantic colors, typography, and spacing tokens that integrate with SwiftUI via `@Environment`. Ships with sensible defaults mapped to iOS system colors, and includes WCAG contrast checking utilities.

Requires iOS 26+ and Swift 6.2.

## Setup

```swift
// 1. Add the package dependency
// 2. Import in your files
import DesignTokens

// 3. Inject at app root
ContentView()
    .theme(DefaultTheme())

// 4. Read in any view
@Environment(\.theme) private var theme
```

## Colors

| Token               | Purpose                        | Maps to                          |
|---------------------|--------------------------------|----------------------------------|
| `theme.primary`     | Brand / tint color             | `.accentColor`                   |
| `theme.secondary`   | Supporting brand color         | `.secondaryLabel`                |
| `theme.accent`      | Interactive elements           | `.accentColor`                   |
| `theme.background`  | Main screen background         | `.systemBackground`              |
| `theme.backgroundSecondary` | Grouped/inset background | `.secondarySystemBackground`    |
| `theme.backgroundTertiary`  | Nested grouped background | `.tertiarySystemBackground`    |
| `theme.surface`     | Card / grouped container       | `.systemGroupedBackground`       |
| `theme.surfaceSecondary` | Nested card              | `.secondarySystemGroupedBackground` |
| `theme.label`       | Primary text                   | `.label`                         |
| `theme.labelSecondary` | Supporting text             | `.secondaryLabel`                |
| `theme.labelTertiary`  | Placeholder / disabled      | `.tertiaryLabel`                 |
| `theme.labelQuaternary` | Faintest text             | `.quaternaryLabel`               |
| `theme.separator`   | Dividers                       | `.separator`                     |
| `theme.destructive` | Delete / error                 | `.red`                           |
| `theme.success`     | Confirmation / done            | `.green`                         |
| `theme.warning`     | Caution states                 | `.orange`                        |
| `theme.info`        | Informational highlights       | `.blue`                          |

## Typography

All tokens map to `Font.TextStyle` so Dynamic Type works automatically.

| Token                       | Text Style    | Typical Use           |
|-----------------------------|---------------|-----------------------|
| `theme.typography.largeTitle` | `.largeTitle` | Nav bar large title   |
| `theme.typography.title`      | `.title`      | Section header        |
| `theme.typography.title2`     | `.title2`     | Subsection header     |
| `theme.typography.title3`     | `.title3`     | Card header           |
| `theme.typography.headline`   | `.headline`   | Emphasized label      |
| `theme.typography.body`       | `.body`       | Default reading text  |
| `theme.typography.callout`    | `.callout`    | Secondary content     |
| `theme.typography.subheadline` | `.subheadline` | Metadata, bylines  |
| `theme.typography.footnote`   | `.footnote`   | Annotations           |
| `theme.typography.caption`    | `.caption`    | Timestamps, labels    |
| `theme.typography.caption2`   | `.caption2`   | Legal, fine print     |

## Spacing (4pt grid)

| Token       | Value  | Semantic Alias     |
|-------------|--------|--------------------|
| `.xxs`      | 2pt    |                    |
| `.xs`       | 4pt    |                    |
| `.sm`       | 8pt    | `.compact`         |
| `.md`       | 12pt   | `.gap`             |
| `.lg`       | 16pt   | `.inset`           |
| `.xl`       | 24pt   | `.section`         |
| `.xxl`      | 32pt   |                    |
| `.xxxl`     | 48pt   |                    |
| `.minTapTarget` | 44pt | HIG minimum    |

## WCAG Compliance

The default theme uses Apple's semantic `UIColor` values which automatically meet
WCAG AA (4.5:1 for text, 3:1 for large text) in both light and dark mode.

For custom themes, use the included contrast checker:

```swift
// Runtime check
let ratio = ContrastCheck.ratio(
    between: UIColor.label,
    and: UIColor.systemBackground
)
// → ~17:1 in light mode

let passes = ContrastCheck.passes(
    foreground: UIColor(myCustomColor),
    background: UIColor.systemBackground,
    level: .normalAA
)

// Debug overlay
Text("Hello")
    .contrastDebug(
        foreground: .label,
        background: .systemBackground
    )
```

## Creating a Theme

Only `name`, `primary`, `secondary`, and `accent` are required.
Everything else has sensible defaults from the protocol extension.

### Color-only theme (minimal)

```swift
struct ForestTheme: Theme {
    let name = "Forest"
    let primary: Color = .green
    let secondary: Color = Color(red: 0.4, green: 0.5, blue: 0.3)
    let accent: Color = Color(red: 0.2, green: 0.7, blue: 0.4)
}
```

### With a different font design

```swift
struct RoundedTheme: Theme {
    let name = "Rounded"
    let primary: Color = .purple
    let secondary: Color = .pink
    let accent: Color = .indigo

    var typography: ThemeTypography { .system(.rounded) }
}
```

### With a custom font family

```swift
struct EditorialTheme: Theme {
    let name = "Editorial"
    let primary: Color = .brown
    let secondary: Color = Color(red: 0.6, green: 0.5, blue: 0.4)
    let accent: Color = .orange

    // Uses "Georgia" at Apple's standard point sizes,
    // with relativeTo: for Dynamic Type scaling.
    var typography: ThemeTypography { .custom("Georgia") }
}
```

### With selective overrides

```swift
struct OceanTheme: Theme {
    let name = "Ocean"
    let primary: Color = Color(red: 0.0, green: 0.48, blue: 0.80)
    let secondary: Color = Color(red: 0.40, green: 0.60, blue: 0.70)
    let accent: Color = Color(red: 0.0, green: 0.78, blue: 0.75)

    // Override just the status colors that differ.
    let success: Color = Color(red: 0.0, green: 0.70, blue: 0.50)
    let info: Color = Color(red: 0.0, green: 0.48, blue: 0.80)
}
```

## File Structure

```
DesignTokens/
├── Package.swift
├── LICENSE
├── Sources/DesignTokens/
│   ├── Theme.swift              ← Protocol + DefaultTheme
│   ├── Typography.swift         ← Font tokens
│   ├── Spacing.swift            ← Spacing tokens
│   ├── ThemeEnvironment.swift   ← @Environment integration
│   ├── Modifiers.swift          ← View modifiers
│   └── ContrastCheck.swift      ← WCAG utilities
├── Tests/DesignTokensTests/     ← Unit tests
└── Examples/
    ├── OceanTheme.swift         ← Example custom theme
    └── ExampleUsage.swift       ← Usage patterns
```
